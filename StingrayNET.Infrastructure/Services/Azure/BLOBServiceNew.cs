using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Specialized;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.File;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.AspNetCore.Http;
using StingrayNET.ApplicationCore.Models.WSService;
using Azure;
using Azure.Storage.Blobs.Models;
using StingrayNET.ApplicationCore.Specifications;
using Microsoft.Data.SqlClient;
using System.Data;
using System.Text.RegularExpressions;
using s = Serilog;

namespace StingrayNET.Infrastructure.Services.Azure;
public class BLOBServiceNew : IBLOBServiceNew
{
    // private readonly BlobServiceClient _blobServiceClient;
    private readonly IConfiguration _config;
    private readonly IWSService _wsService;
    private readonly IKVService _kvService;
    private readonly IDatabase<SC> _dbSC;
    private readonly IDatabase<DED> _dbDED;
    private readonly IHttpContextAccessor _httpContextAccessor;
    private readonly s.ILogger _logger;

    public BLOBServiceNew(IConfiguration config, IWSService wsService, IKVService kvService,
    IDatabase<SC> dbSC, IDatabase<DED> dbDED, IHttpContextAccessor httpContextAccessor, s.ILogger logger)
    {
        // _blobServiceClient = blobServiceClient;
        _config = config;
        _wsService = wsService;
        _kvService = kvService;
        _dbSC = dbSC;
        _dbDED = dbDED;
        _httpContextAccessor = httpContextAccessor;
        _logger = logger;
    }

    private BlobServiceClient GetClient(bool alwaysUseProduction = false)
    {
        if (alwaysUseProduction)
        {
            return new BlobServiceClient(new Uri(_config[@"BLOBOverride:ServiceUri"]), _kvService.GetCredential());
        }

        else
        {
            _logger.Information("Service URI:" + _config[@"Storage:ServiceUri"]);
            return new BlobServiceClient(new Uri(_config[@"Storage:ServiceUri"]), _kvService.GetCredential());
        }

    }

    public async Task<List<string>> Upload(HttpContext context, string module, Department department, bool alwaysUseProduction = false)
    {
        _logger.Information("Upload");

        using (StingrayWS ws = await _wsService.GetWebSocket(context))
        {
            _logger.Information("WebSocket connection established for module:" + module);

            List<string> returnList = new List<string>();

            //Get BLOB temp container
            BlobServiceClient client = GetClient(alwaysUseProduction);
            var tempContainer = client.GetBlobContainerClient("temp");
            var prodContainer = client.GetBlobContainerClient("prod");

            //Await the start request
            FileRequest startRequest = await _wsService.ReceiveJson<FileRequest>(ws);

            if (startRequest == null)
            {
                _logger.Information("StartRequest NULL");

            }
            else
            {
                _logger.Information("StartRequest Filename:" + startRequest.FileName);
            }

            while (startRequest != null)
            {
                var result = await UploadTasks(ws, module, department, startRequest, client, tempContainer, prodContainer);
                returnList.Add(result);

                _logger.Information("UploadTasks result:" + result);

                try
                {
                    startRequest = await _wsService.ReceiveJson<FileRequest>(ws);
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);
                    _logger.Error(ex.Message);
                }
            }

            await _wsService.CloseWebSocket(ws);

            return returnList;
        }
    }

    private async Task<string> UploadTasks(StingrayWS ws, string module, Department department, FileRequest startRequest, BlobServiceClient client, BlobContainerClient tempContainer, BlobContainerClient prodContainer)
    {
        //Process start message
        if (startRequest.FileRequestType != FileRequestType.Start)
        {
            throw new Exception(@"First message in upload session must be of type Start");
        }

        //Send back UUID
        Guid uuid = await StartUpload(module, tempContainer);
        await _wsService.SendJson(ws, new { UUID = uuid });

        //Receive chunked messages
        int incrementalID = 1;

        while (incrementalID <= startRequest.ChunkCount)
        {
            //Get binary as stream
            MemoryStream stream = new MemoryStream(await _wsService.ReceiveBytes(ws));

            //Send to BLOB
            await UploadChunk(stream, uuid, incrementalID, module, tempContainer);

            //Write back to sender
            await _wsService.SendJson(ws, new { Message = $"File {uuid}, Chunk {incrementalID} of {startRequest.ChunkCount} uploaded" });

            //Increment incrementalID
            incrementalID++;
        }

        //Receive end message
        FileRequest endRequest = await _wsService.ReceiveJson<FileRequest>(ws);

        if (endRequest.FileRequestType != FileRequestType.End)
        {
            throw new Exception(@"Last message in upload session must be of type End");
        }

        //Process end message
        await EndUpload(module, endRequest.FileName, (int)startRequest.ChunkCount, uuid, department, tempContainer, prodContainer, endRequest.ParentID, endRequest.GroupBy);
        await _wsService.SendJson(ws, new { Message = $"Upload complete for {endRequest.FileName}", UUID = uuid });

        //Return
        return uuid.ToString();

    }

    private async Task<Guid> StartUpload(string module, BlobContainerClient tempContainer)
    {
        //Create GUID
        Guid uuid = Guid.NewGuid();

        //If uuid blob exists, remove
        foreach (var blob in tempContainer.GetBlobs(prefix: String.Format(@"{0}/{1}", module, uuid)))
        {
            await tempContainer.GetBlobClient(blob.Name).DeleteAsync();
        }

        return uuid;
    }

    private async Task UploadChunk(Stream blobStream, Guid uuid, int incrementalID, string module, BlobContainerClient tempContainer)
    {
        //Instantiate incremental ID BLOB object in temporary UUID container
        BlobClient blobClient = tempContainer.GetBlobClient(string.Format(@"{0}/{1}/{2}", module, uuid, incrementalID));

        //Stream from BLOB body in request and upload to BLOB client
        blobStream.Seek(0, SeekOrigin.Begin);
        using (blobStream)
        {
            await blobClient.UploadAsync(blobStream);
        }
    }

    private async Task EndUpload(string module, string fileName, int chunkCount, Guid uuid, Department department, BlobContainerClient tempContainer, BlobContainerClient prodContainer, string? parentID = null, string? groupBy = null)
    {
        string fullName = string.Format(@"{0}/{1}", module, uuid);

        //Instantiate blockblob object
        BlockBlobClient blockClient = prodContainer.GetBlockBlobClient(fullName);

        //Loop through all incremental IDs, get BLOB stream from temp UUID container, and stage it
        List<string> workingIDs = new List<string>();
        int incrementalID = 1;
        while (incrementalID <= chunkCount)
        {
            BlobClient workingBlob = tempContainer.GetBlobClient(string.Format(@"{0}/{1}", fullName, incrementalID));

            MemoryStream stream = new MemoryStream();

            await workingBlob.DownloadToAsync(stream);
            stream.Seek(0, SeekOrigin.Begin);

            string base64IncrementalID = Convert.ToBase64String(BitConverter.GetBytes(incrementalID));
            using (stream)
            {
                await blockClient.StageBlockAsync(base64IncrementalID, stream);
            }

            workingIDs.Add(base64IncrementalID);
            incrementalID++;
        }

        //Commit block
        await blockClient.CommitBlockListAsync(workingIDs);

        //Add filename as metadata
        Dictionary<string, string> tags = new Dictionary<string, string>()
            {
                {"Filename", Uri.EscapeDataString(fileName) }
            };

        await blockClient.SetMetadataAsync(tags);

        if (!string.IsNullOrEmpty(parentID))
        {
            List<SqlParameter> parameters = new List<SqlParameter>()
                {
                    new SqlParameter()
                    {
                        ParameterName = @"@Operation",
                        SqlDbType = SqlDbType.Int,
                        Value = 4
                    },
                    new SqlParameter()
                    {
                        ParameterName = @"@Num1",
                        SqlDbType = SqlDbType.Int,
                        Value = (int)department
                    },
                    new SqlParameter()
                    {
                        ParameterName = @"@Value1",
                        SqlDbType = SqlDbType.NVarChar,
                        Value = fileName
                    },
                    new SqlParameter()
                    {
                        ParameterName = @"@Value2",
                        SqlDbType = SqlDbType.NVarChar,
                        Value = uuid.ToString()
                    },
                    new SqlParameter()
                    {
                        ParameterName = @"@Value3",
                        SqlDbType = SqlDbType.NVarChar,
                        Value = module
                    },
                    new SqlParameter()
                    {
                        ParameterName = @"@Value4",
                        SqlDbType = SqlDbType.NVarChar,
                        Value = parentID
                    },
                    new SqlParameter()
                    {
                        ParameterName = @"@Value5",
                        SqlDbType = SqlDbType.NVarChar,
                        Value = groupBy
                    },
                    new SqlParameter()
                    {
                        ParameterName = @"@EmployeeID",
                        SqlDbType = SqlDbType.NVarChar,
                        Value = _httpContextAccessor.HttpContext.Items[@"EmployeeID"].ToString()
                    }
                };

            if (department == Department.SC)
            {
                await _dbSC.ExecuteReaderAsync(@"stng.SP_Common_CRUD", parameters);
            }

            else if (department == Department.DED)
            {
                await _dbDED.ExecuteReaderAsync(@"stng.SP_Common_CRUD", parameters);
            }

            else
            {
                throw new Exception(@"Unhandled Department");
            }
        }


    }

    public async Task<FileStreamResult> Download(FileDownloadRequest fileDownloadRequest)
    {
        //Get BLOB container
        var prodContainer = GetClient().GetBlobContainerClient("prod");
        BlobClient blobClient = prodContainer.GetBlobClient(fileDownloadRequest.UUID);
        if (!await blobClient.ExistsAsync())
        {
            throw new Exception(String.Format(@"BLOB {0} does not exist in {1} production container", fileDownloadRequest.UUID.Split('/')[1], fileDownloadRequest.UUID.Split('/')[0]));
        }
        string fileName = await GetFileName(blobClient);

        return new FileStreamResult(await blobClient.OpenReadAsync(), @"application/octet-stream")
        {
            FileDownloadName = fileName
        };
    }

    public async Task<FileStreamResult> DownloadDirect(string containerName, string path)
    {
        if (string.IsNullOrEmpty(path))
        {
            throw new ArgumentNullException(nameof(path));
        }

        else if (string.IsNullOrEmpty(containerName))
        {
            throw new ArgumentNullException(nameof(containerName));
        }

        //Get BLOB container
        BlobContainerClient container = GetClient().GetBlobContainerClient(containerName);
        BlobClient blobClient = container.GetBlobClient(path);
        if (!await blobClient.ExistsAsync())
        {
            throw new Exception(String.Format(@"BLOB {0} does not exist in container {1}", path, containerName));
        }

        string fileName = await GetFileName(blobClient);

        return new FileStreamResult(await blobClient.OpenReadAsync(), @"application/octet-stream")
        {
            FileDownloadName = fileName
        };
    }

    public async Task<FileStreamResult> DownloadLatest(string containerName, string? path = null)
    {
        try
        {
            _logger.Information($"DownloadLatest Info; Path: {path};");

            if (string.IsNullOrEmpty(containerName))
            {
                throw new ArgumentNullException(nameof(containerName));
            }

            //Get BLOB container
            BlobContainerClient container = GetClient().GetBlobContainerClient(containerName);

            //Get all blobs
            AsyncPageable<BlobItem> blobs = container.GetBlobsAsync();

            //Return latest blob
            BlobItem workingBlob = null;
            await foreach (BlobItem item in blobs)
            {
                if (!string.IsNullOrEmpty(path))
                {
                    string itemPath = Regex.Replace(Regex.Replace(item.Name, @"(?<=\/)[^\/]+$", string.Empty), @"\/$", string.Empty);

                    if (itemPath.ToLower() == path.ToLower())
                    {
                        if (workingBlob == null)
                        {
                            workingBlob = item;
                        }

                        else if (item.Properties.CreatedOn > workingBlob.Properties.CreatedOn)
                        {
                            workingBlob = item;
                        }
                    }
                }

                else
                {
                    if (workingBlob == null)
                    {
                        workingBlob = item;
                    }

                    else if (item.Properties.CreatedOn > workingBlob.Properties.CreatedOn)
                    {
                        workingBlob = item;
                    }
                }

            }

            if (workingBlob == null)
            {
                throw new Exception($"Unable to find any blobs in specified container/path");
            }

            BlobClient blobClient = container.GetBlobClient(workingBlob.Name);

            string fileName = await GetFileName(blobClient);

            return new FileStreamResult(await blobClient.OpenReadAsync(), @"application/octet-stream")
            {
                FileDownloadName = fileName
            };
        }
        catch (Exception e)
        {
            _logger.Error($"DownloadLatest Error: {e.Message}; Path: {path};");
            throw e;
        }

    }

    public async Task<bool> Delete(FileDeleteRequest fileDeleteRequest)
    {
        //Get BLOB container
        var prodContainer = GetClient().GetBlobContainerClient("prod");
        BlobClient blobClient = prodContainer.GetBlobClient(fileDeleteRequest.UUID);
        if (!await blobClient.ExistsAsync())
        {
            throw new Exception(String.Format(@"BLOB {0} does not exist in {1} production container", fileDeleteRequest.UUID.Split('/')[1], fileDeleteRequest.UUID.Split('/')[0]));
        }
        string fileName = await GetFileName(blobClient);

        return await blobClient.DeleteIfExistsAsync();
    }

    private async Task<string> GetFileName(BlobClient blobClient)
    {
        var metaResponse = await blobClient.GetPropertiesAsync();
        foreach (var meta in metaResponse.Value.Metadata)
        {
            if (meta.Key.ToLower() == @"Filename".ToLower())
            {
                return meta.Value;
            }
        }
        throw new Exception(String.Format(@"Unable to locate Filename metadata on BLOB {0}", blobClient.Uri));
    }

}
