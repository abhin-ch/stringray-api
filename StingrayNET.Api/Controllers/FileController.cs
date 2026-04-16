using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Models.File;
using StingrayNET.ApplicationCore.Specifications;
using StingrayNET.ApplicationCore.CustomExceptions;
using StingrayNET.ApplicationCore.HelperFunctions;

namespace StingrayNET.Api.Controllers;

[Authorize]
[Route("api/[controller]")]
[EnableCors("stingrayCORS")]
[ApiController]
public class FileController : ControllerBase
{
    const int MAX_CHUNK_SIZE = 3000000; // Bytes = 30MB  
    private readonly IBLOBService _blobService;
    private readonly IIdentityService _identityService;
    private readonly IRepositoryM<Procedure, CommonResult> _repository;

    public FileController(IBLOBService blobService, IRepositoryM<Procedure, CommonResult> repository, IIdentityService identityService)
    {
        _blobService = blobService;
        _repository = repository;
        _identityService = identityService;
    }

    // [HttpGet]
    // public async Task<JsonResult> GetFile([FromBody] FileStartRequest model)
    // {
    //     try
    //     {
    //         //Call injected service method
    //         var uuid = await _blobService.StartUpload(model);
    //         return BaseResult.JsonResult<HttpSuccess>(uuid);
    //     }
    //     catch (Exception e)
    //     {
    //         return BaseResult.JsonResult<HttpError>(string.Format(@"Error occurred during temporary container creation - {0}", e.Message));
    //     }
    // }

    [HttpGet]
    [Route("list")]
    public async Task<JsonResult> ListFiles([FromQuery] Procedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_05(model);
        return BaseResult.JsonResult(result);
    }

    [HttpPost]
    [Route("start")]
    public async Task<JsonResult> StartUpload([FromBody] FileStartRequest model)
    {
        try
        {
            //Call injected service method
            var uuid = await _blobService.StartUpload(model);
            return BaseResult.JsonResult<HttpSuccess>(uuid);
        }
        catch (Exception e)
        {
            return BaseResult.JsonResult<HttpError>(string.Format(@"Error occurred during temporary container creation - {0}", e.Message));
        }
    }

    [HttpPost]
    [Route("upload")]
    [RequestFormLimits(ValueCountLimit = MAX_CHUNK_SIZE)]
    public async Task<JsonResult> UploadChunk(IFormFile file, string module, string uuid, int id)
    {
        try
        {
            //Call injected service method
            await _blobService.UploadChunk(new FileChunkRequest
            {
                Module = module,
                UUID = uuid,
                IncrementalID = id
            }, file.OpenReadStream());
            return BaseResult.JsonResult<HttpSuccess>("Upload Complete");
        }
        catch (Exception e)
        {
            return BaseResult.JsonResult<HttpError>(string.Format(@"Error occurred during temporary container creation - {0}", e.Message));
        }
    }

    [HttpPost]
    [Route("end")]
    public async Task<JsonResult> EndUpload([FromBody] FileEndRequest fileEndRequest)
    {
        try
        {
            //Call injected service method
            await _blobService.EndUpload(fileEndRequest);

            var result = await _repository.Op_04(new Procedure
            {
                Num1 = (int)fileEndRequest.Department,
                Value1 = fileEndRequest.FileName,
                Value2 = fileEndRequest.UUID,
                Value3 = fileEndRequest.Module,
                Value4 = fileEndRequest.ParentID,
                Value5 = fileEndRequest.GroupBy,
                EmployeeID = HttpContext.Items[@"EmployeeID"].ToString()
            });

            return BaseResult.JsonResult<HttpSuccess>("Upload complete");
        }
        catch (Exception e)
        {
            throw new ValidationException(@"Error occurred during upload completion", new List<string> { e.Message });
        }
    }

    [HttpPost]
    [Route("download")]
    public async Task<ActionResult> Download([FromBody] FileDownloadRequest fileDownloadRequest)
    {
        try
        {
            //Call injected service method
            return await _blobService.Download(fileDownloadRequest);
        }
        catch (Exception e)
        {
            return StatusCode(500, string.Format(@"Error occurred during download - {0}", e.Message));
        }

    }

    [HttpDelete]
    public async Task<JsonResult> Delete([FromBody] FileDeleteRequest fileDeleteRequest)
    {
        try
        {
            var EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();

            //first, backend check to see if blobservice needs to delete
            if (DataParser.GetValueFromData<bool>((await _repository.Op_18(new Procedure
            {
                Num1 = (int)fileDeleteRequest.Department,
                Value1 = EmployeeID.ToString(),
                Value2 = fileDeleteRequest.UUID.Split('/')[1],
                Value3 = fileDeleteRequest.ParentID
            })).Data1, "deleteFromBlob"))//then attempt to delete in blob
            {
                var deleted = await _blobService.Delete(fileDeleteRequest);
                if (!deleted)
                //if blobservice fails, return
                {
                    return BaseResult.JsonResult<HttpError>($"Could not delete file or file not found");
                }
            }
            //delete meta record
            var result = await _repository.Op_08(new Procedure
            {
                Num1 = (int)fileDeleteRequest.Department,
                Value1 = EmployeeID.ToString(),
                Value2 = fileDeleteRequest.UUID.Split('/')[1],
                Value3 = fileDeleteRequest.ParentID
            });
            //Call injected service method
            return BaseResult.JsonResult(result);
        }
        catch (Exception e)
        {
            return BaseResult.JsonResult<HttpError>(string.Format(@"Error occurred during file deletion - {0}", e.Message));
        }

    }

    [HttpPost]
    [Route("copy")]
    public async Task<JsonResult> Copy([FromBody] FileCopyRequest fileCopyRequest)
    {
        try
        {
            var EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();

            var result = await _repository.Op_17(new Procedure
            {
                Num1 = (int)fileCopyRequest.Department,
                Value1 = EmployeeID.ToString(),
                Value7 = fileCopyRequest.DelimitedFileMetaIDs,
                Value6 = fileCopyRequest.DelimitedParentIDs
            });
            //Call injected service method
            return BaseResult.JsonResult(result);
        }
        catch (Exception e)
        {
            return BaseResult.JsonResult<HttpError>(string.Format(@"Error occurred during file deletion - {0}", e.Message));
        }

    }
}
