using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Specialized;
using Microsoft.AspNetCore.Mvc;
using Serilog;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.File;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace StingrayNET.Infrastructure.Services.Azure
{
    public class BLOBService : IBLOBService
    {
        private readonly BlobServiceClient _blobServiceClient;

        public BLOBService(BlobServiceClient blobServiceClient)
        {
            _blobServiceClient = blobServiceClient;
        }

        public async Task<string> StartUpload(FileStartRequest fileStartRequest)
        {
            var uuid = Guid.NewGuid().ToString().ToUpper();

            //Get BLOB temp container
            var tempContainer = _blobServiceClient.GetBlobContainerClient("temp");

            //If uuid blob exists, remove
            foreach (var blob in tempContainer.GetBlobs(prefix: String.Format(@"{0}/{1}", fileStartRequest.Module, uuid)))
            {
                await tempContainer.GetBlobClient(blob.Name).DeleteAsync();
            }
            return uuid;
        }

        public async Task UploadChunk(FileChunkRequest fileChunkRequest, Stream body)
        {

            //Get BLOB temp container
            var tempContainer = _blobServiceClient.GetBlobContainerClient("temp");

            //Instantiate incremental ID BLOB object in temporary UUID container
            BlobClient blobClient = tempContainer.GetBlobClient(string.Format(@"{0}/{1}/{2}", fileChunkRequest.Module, fileChunkRequest.UUID, fileChunkRequest.IncrementalID));

            //Stream from BLOB body in request and upload to BLOB client
            body.Seek(0, SeekOrigin.Begin);
            using (body)
            {
                await blobClient.UploadAsync(body);
            }

        }

        public async Task EndUpload(FileEndRequest fileEndRequest)
        {
            string fullName = string.Format(@"{0}/{1}", fileEndRequest.Module, fileEndRequest.UUID.ToUpper());
            //Get BLOB containers
            var prodContainer = _blobServiceClient.GetBlobContainerClient("prod");
            var tempContainer = _blobServiceClient.GetBlobContainerClient("temp");

            //Sort IncrementalIDs in ascending order
            fileEndRequest.IncrementalIDs = fileEndRequest.IncrementalIDs.OrderBy(i => i).ToList();

            //Instantiate blockblob object
            BlockBlobClient blockClient = prodContainer.GetBlockBlobClient(fullName);

            //Loop through all incremental IDs, get BLOB stream from temp UUID container, and stage it
            List<string> workingIDs = new List<string>();
            foreach (int incrementalID in fileEndRequest.IncrementalIDs)
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
            }

            //Commit block
            await blockClient.CommitBlockListAsync(workingIDs);

            //Add filename as metadata
            Dictionary<string, string> tags = new Dictionary<string, string>()
            {
                {"Filename", fileEndRequest.FileName }
            };

            await blockClient.SetMetadataAsync(tags);
        }

        public async Task<FileStreamResult> Download(FileDownloadRequest fileDownloadRequest)
        {
            //Get BLOB container
            var prodContainer = _blobServiceClient.GetBlobContainerClient("prod");
            BlobClient blobClient = prodContainer.GetBlobClient(fileDownloadRequest.UUID);
            if (!await blobClient.ExistsAsync())
            {
                //Try in lcase
                string lCaseBlob = $"{fileDownloadRequest.UUID.Split('/')[0]}/{fileDownloadRequest.UUID.Split('/')[1].ToLower()}";
                blobClient = prodContainer.GetBlobClient(lCaseBlob);

                if (!await blobClient.ExistsAsync())
                {
                    throw new Exception(String.Format(@"BLOB {0} does not exist in {1} production container", fileDownloadRequest.UUID.Split('/')[1], fileDownloadRequest.UUID.Split('/')[0]));
                }
            }
            string fileName = await GetFileName(blobClient);

            return new FileStreamResult(await blobClient.OpenReadAsync(), @"application/octet-stream")
            {
                FileDownloadName = fileName
            };
        }

        public async Task<bool> Delete(FileDeleteRequest fileDeleteRequest)
        {
            //Get BLOB container
            var prodContainer = _blobServiceClient.GetBlobContainerClient("prod");
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
}
