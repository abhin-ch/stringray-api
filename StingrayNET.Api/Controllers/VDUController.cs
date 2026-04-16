using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Specialized;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Cors;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.VDU;
using StingrayNET.ApplicationCore.Models.File;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Specifications;
using StingrayNET.ApplicationCore.HelperFunctions;
//To Be Refactored
using OfficeOpenXml;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace StingrayNET.Api.Controllers;

[Authorize]
[Route("api/[controller]")]
[EnableCors("stingrayCORS")]
[ApiController]
public class VDUController : ControllerBase
{
    private readonly IBLOBService _blobService;
    private readonly IRepositoryM<VDUProcedure, VDUResult> _repository;
    private readonly BlobServiceClient _blobServiceClient;
    private readonly IConfiguration _config;

    public VDUController(IRepositoryM<VDUProcedure, VDUResult> repository,IBLOBService blobService, BlobServiceClient blobServiceClient,IConfiguration config)
    {

        _repository = repository;
        _blobService = blobService;
        _blobServiceClient = blobServiceClient;
        _config = config;
    }

    //Get api/vdu/vendor
    //No params
    [HttpGet]
    [Route("vendor")]
    public async Task<JsonResult> GetVendors()
    {
        VDUProcedure model = new VDUProcedure();
        model.CurrentUser = HttpContext!.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_01(model);
        return BaseResult.JsonResult(result);
    }

    //Post api/vdu/suborg
    //Pass in VENID
    [HttpPost]
    [Route("suborg")]
    public async Task<JsonResult> GetSuborg([FromBody] VDUProcedure model)
    {
        var result = await _repository.Op_02(model);
        return BaseResult.JsonResult(result);
    }

    //Post api/vdu/report
    //Pass in SOID
    [HttpPost]
    [Route("report")]
    public async Task<JsonResult> GetReport([FromBody] VDUProcedure model)
    {
        var result = await _repository.Op_04(model);
        return BaseResult.JsonResult(result);
    }

    //Post api/vdu/tabmap
    //Pass in ReportId
    [HttpPost]
    [Route("tabmap")]
    public async Task<JsonResult> GetTabMap([FromBody] VDUProcedure model)
    {
        var result = await _repository.Op_05(model);
        return BaseResult.JsonResult(result);
    }

    //Post api/vdu/reportdata
    //Pass in TabMapId and UploadId
    [HttpPost]
    [Route("reportdata")]
    public async Task<JsonResult> GetReportData([FromBody] VDUProcedure model)
    {
        var result = await _repository.Op_06(model);
        return BaseResult.JsonResult(result);
    }

    //Post api/vdu/splitrules
    //Pass in tblRules
    [HttpPost]
    [Route("splitrules")]
    public async Task<JsonResult> SplitRules([FromBody] VDUProcedure model)
    {
        var result = await _repository.Op_07(model);
        return BaseResult.JsonResult(result);
    }

    //Get api/vdu/customvalues
    //No params
    [HttpGet]
    [Route("customvalues")]
    public async Task<JsonResult> GetCustomValues()
    {
        var result = await _repository.Op_08();
        return BaseResult.JsonResult(result);
    }

    //Get api/vdu/customvendor
    //No params
    [HttpGet]
    [Route("customvendor")]
    public async Task<JsonResult> GetCustomVendors()
    {
        var result = await _repository.Op_09();
        return BaseResult.JsonResult(result);
    }

    //Get api/vdu/customsuborg
    //No params
    [HttpGet]
    [Route("customsuborg")]
    public async Task<JsonResult> GetCustomSuborg()
    {
        var result = await _repository.Op_10();
        return BaseResult.JsonResult(result);
    }

    //Post api/vdu/reporttypes
    //Pass in ReportId
    [HttpPost]
    [Route("reporttypes")]
    public async Task<JsonResult> GetReportTypes([FromBody] VDUProcedure model)
    {
        var result = await _repository.Op_11(model);
        return BaseResult.JsonResult(result);
    }

    //Post api/vdu/sheetschema
    //Pass in ReportId
    [HttpPost]
    [Route("sheetschema")]
    public async Task<JsonResult> GetSheetsSchema([FromBody] VDUProcedure model)
    {
        var result = await _repository.Op_12(model);
        return BaseResult.JsonResult(result);
    }

    //Post api/vdu/reportcolumns
    //Pass in ReportId
    [HttpPost]
    [Route("reportcolumns")]
    public async Task<JsonResult> GetReportColumns([FromBody] VDUProcedure model)
    {
        var result = await _repository.Op_13(model);
        return BaseResult.JsonResult(result);
    }

    //Post api/vdu/reportrules
    //Pass in ReportId
    [HttpPost]
    [Route("reportrules")]
    public async Task<JsonResult> GetReportRules([FromBody] VDUProcedure model)
    {
        var result = await _repository.Op_14(model);
        return BaseResult.JsonResult(result);
    }

    //Get api/vdu/reporttypes
    //No params
    [HttpGet]
    [Route("reporttypes")]
    public async Task<JsonResult> GetReportTypes()
    {
        var result = await _repository.Op_15();
        return BaseResult.JsonResult(result);
    }

    //Get api/vdu/ruletypes
    //No params
    [HttpGet]
    [Route("ruletypes")]
    public async Task<JsonResult> GetRuleTypes()
    {
        var result = await _repository.Op_16();
        return BaseResult.JsonResult(result);
    }

    //Get api/vdu/uploadlog
    //No params
    [HttpGet]
    [Route("uploadlog")]
    public async Task<JsonResult> GetUploadLog()
    {
        var result = await _repository.Op_17();
        return BaseResult.JsonResult(result);
    }

    //Get api/vdu/ebsuploadlog
    //No params
    [HttpGet]
    [Route("ebsuploadlog")]
    public async Task<JsonResult> GetEBSUploadLog()
    {
        var result = await _repository.Op_18();
        return BaseResult.JsonResult(result);
    }

    //Get api/vdu/projectexemption
    //No params
    [HttpGet]
    [Route("projectexemption")]
    public async Task<JsonResult> GetProjectExemption()
    {
        var result = await _repository.Op_19();
        return BaseResult.JsonResult(result);
    }

    //Get api/vdu/dedprojectmap
    //No params
    [HttpGet]
    [Route("dedprojectmap")]
    public async Task<JsonResult> GetDEDProjectMap()
    {
        var result = await _repository.Op_20();
        return BaseResult.JsonResult(result);
    }

    //Get api/vdu/projectexemptionlist
    //No params
    [HttpGet]
    [Route("projectexemptionlist")]
    public async Task<JsonResult> GetProjectExemptionList()
    {
        var result = await _repository.Op_21();
        return BaseResult.JsonResult(result);
    }

     //Post api/vdu/uploadstart
    [HttpPost]
    [Route("uploadstart")]
    public async Task<JsonResult> UploadStart([FromBody] VDUProcedure model )
    {
       
        try
        {
            //Call injected service method
            var uuid = await _blobService.StartUpload(new FileStartRequest {Module = "VDU"});
            return BaseResult.JsonResult<HttpSuccess>(uuid);
        }
        catch (Exception e)
        {
            return BaseResult.JsonResult<HttpError>(string.Format(@"Error occurred during temporary container creation - {0}", e.Message));
        }
    }

    //Post api/vdu/upload
    [HttpPost]
    [Route("upload")]
    public async Task<JsonResult> UploadFile(IFormFile file, string module, string uuid, int id)
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
            return BaseResult.JsonResult<HttpSuccess>("Upload Chunk Success");
        }
        catch (Exception e)
        {
            return BaseResult.JsonResult<HttpError>(string.Format(@"Error occurred during temporary container creation - {0}", e.Message));
        }
    }

    [HttpPost]
    [Route("uploadend")]
    public async Task<JsonResult> UploadEnd([FromBody] FileEndRequest fileEndRequest )
    {
       try
        {
            //Call injected service method
            await _blobService.EndUpload(fileEndRequest);
            return BaseResult.JsonResult<HttpSuccess>("Blob Upload Complete");
        }
        catch (Exception e)
        {
            return BaseResult.JsonResult<HttpError>(string.Format(@"Error occurred during upload completion - {0}", e.Message));
        }
    }

    [HttpPost]
    [Route("importblob")]
    public async Task<JsonResult> ImportBlob(string uuid,int UploadId ,int VENID, int SOID, int ReportId, int ReportPeriod, DateTime ReportBucket, DateTime ReportDate, string FileName )
    {
        var prodContainer = _blobServiceClient.GetBlobContainerClient("prod");
        BlobClient blobClient = prodContainer.GetBlobClient(uuid);
        if (!await blobClient.ExistsAsync())
            {
                //Try in lcase
                string lCaseBlob = $"{uuid.Split('/')[0]}/{uuid.Split('/')[1].ToLower()}";
                blobClient = prodContainer.GetBlobClient(lCaseBlob);

                if (!await blobClient.ExistsAsync())
                {
                    throw new Exception(String.Format(@"BLOB {0} does not exist in {1} production container", uuid.Split('/')[1], uuid.Split('/')[0]));
                }
            }
        var blobfile = await blobClient.DownloadContentAsync();
        await using var stream = blobfile.Value.Content.ToStream();

        using var excelFile = new ExcelPackage(stream);

        VDUProcedure model = new VDUProcedure();
        List<VDSReportError> ReportErrors = new List<VDSReportError>();

         int? reuploadPreviousId = VDUVerification.IsMyValueEmpty(UploadId) ? (int?)null : (int)UploadId;

        VDSReport report = new VDSReport(reportId: (int)ReportId,
                                         vendorId: (int)VENID,
                                         suborgId: (int)SOID,
                                         reportPeriod: (int)ReportPeriod,
                                         reportBucket: (DateTime)ReportBucket,
                                         vendorDate: (DateTime)ReportDate,
                                         reuploadPreviousId: reuploadPreviousId);

        model.ReportId = ReportId;
        var result = await _repository.Op_25(model);

        report.GenerateSchema("report",result.reportInfo,result.sheetSchema, result.columnSchema, result.ruleSchema);

        var connectionString = _config.GetConnectionString("DED_CONNECTION");

        DataTable tableStructure = new DataTable();
    
        string mySql;

        mySql = string.Format("EXEC [stng].[SP_VDU_CRUD] @Operation = 6, @TabMapId = {0}", report.ReportSheets[0].TabMapId);

        tableStructure = VDSHelper.GetDataInTable(mySql,connectionString);

        ReportErrors.AddRange(VDSHelper.TryImportExcel(report, excelFile, connectionString));
        var result3 = new VDUResult();
        
        VDSVerification.ErrorsFound errorsFound = VDSVerification.ErrorTypesFound(ReportErrors);
        if (errorsFound == VDSVerification.ErrorsFound.Errors || errorsFound == VDSVerification.ErrorsFound.ErrorsAndWarnings)
        {
            result3.ReportErrors = ReportErrors;
            return BaseResult.JsonResult(result3);
        }

        string dbError = VDSHelper.PostExcelDataToServer(report,
                                                          FileName,
                                                          connectionString,
                                                          HttpContext!.Items[@"EmployeeID"].ToString(), uuid.Split('/')[1]);
        if (dbError != null)
        {
            ReportErrors = new List<VDSReportError>();
            ReportErrors.Add(new VDSReportError(VDSVerification.RuleType.Error, dbError));
        }
                
        result3.ReportErrors = ReportErrors;
        return BaseResult.JsonResult(result3);
    }

    [HttpPost]
    [Route("importdirect")]
    public async Task<JsonResult> ImportDirect(IFormFile file,int UploadId ,int VENID, int SOID, int ReportId, int ReportPeriod, DateTime ReportBucket, DateTime ReportDate, string FileName )
    {
        VDUProcedure model = new VDUProcedure();
        var stream = file.OpenReadStream();
        using var excelFile = new ExcelPackage(stream);
        List<VDSReportError> ReportErrors = new List<VDSReportError>();

        int? reuploadPreviousId = VDUVerification.IsMyValueEmpty(UploadId) ? (int?)null : (int)UploadId;

        VDSReport report = new VDSReport(reportId: (int)ReportId,
                                         vendorId: (int)VENID,
                                         suborgId: (int)SOID,
                                         reportPeriod: (int)ReportPeriod,
                                         reportBucket: (DateTime)ReportBucket,
                                         vendorDate: (DateTime)ReportDate,
                                         reuploadPreviousId: reuploadPreviousId);

        model.ReportId = ReportId;
        var result = await _repository.Op_25(model);

        report.GenerateSchema("report",result.reportInfo,result.sheetSchema, result.columnSchema, result.ruleSchema);

        var connectionString = _config.GetConnectionString("DED_CONNECTION");

        DataTable tableStructure = new DataTable();
    
        string mySql;

        mySql = string.Format("EXEC [stng].[SP_VDU_CRUD] @Operation = 6, @TabMapId = {0}", report.ReportSheets[0].TabMapId);

        tableStructure = VDSHelper.GetDataInTable(mySql,connectionString);

        ReportErrors.AddRange(VDSHelper.TryImportExcel(report, excelFile, connectionString));
        var result3 = new VDUResult();
        
        VDSVerification.ErrorsFound errorsFound = VDSVerification.ErrorTypesFound(ReportErrors);
        if (errorsFound == VDSVerification.ErrorsFound.Errors || errorsFound == VDSVerification.ErrorsFound.ErrorsAndWarnings)
        {
            result3.ReportErrors = ReportErrors;
            return BaseResult.JsonResult(result3);
        }
        
        string dbError = VDSHelper.PostExcelDataToServer(report,
                                                          FileName,
                                                          connectionString,
                                                          HttpContext!.Items[@"EmployeeID"].ToString());
        if (dbError != null)
        {
            ReportErrors = new List<VDSReportError>();
            ReportErrors.Add(new VDSReportError(VDSVerification.RuleType.Error, dbError));
        }
                
        result3.ReportErrors = ReportErrors;
        return BaseResult.JsonResult(result3);

    }

    [HttpPost]
    [Route("testschema")]
    public async Task<JsonResult> TestSchema([FromBody] VDUProcedure model )
    {


        int? reuploadPreviousId = VDUVerification.IsMyValueEmpty(model.UploadId) ? (int?)null : (int)model.UploadId;

        VDSReport report = new VDSReport(reportId: (int)model.ReportId,
                                         vendorId: (int)model.VENID,
                                         suborgId: (int)model.SOID,
                                         reportPeriod: (int)model.ReportPeriod,
                                         reportBucket: (DateTime)model.ReportBucket,
                                         vendorDate: (DateTime)model.ReportDate,
                                         reuploadPreviousId: reuploadPreviousId);


        var result = await _repository.Op_25(model);

        report.GenerateSchema("test",result.reportInfo,result.sheetSchema, result.columnSchema, result.ruleSchema);

        DataTable tableStructure = new DataTable();
       
        var connectionString = _config.GetConnectionString("DED_CONNECTION");
        string mySql;

        
        mySql = string.Format("EXEC [stng].[SP_VDU_CRUD] @Operation = 6, @TabMapId = {0}", report.ReportSheets[0].TabMapId);
        tableStructure = VDSHelper.GetDataInTable(mySql,connectionString);

        return BaseResult.JsonResult<HttpSuccess>( tableStructure.Columns[8].ColumnName);
       
    }

    //Post api/vdu/uploadrevert
    [HttpPost]
    [Route("uploadcomplete")]
    public async Task<JsonResult> UploadComplete([FromBody] VDUProcedure model )
    {
        var result = await _repository.Op_23(model);
        return BaseResult.JsonResult(result);
    }

     //Post api/vdu/rollback
    [HttpPost]
    [Route("rollback")]
    public async Task<JsonResult> Rollback([FromBody] VDUProcedure model )
    {
        var result = await _repository.Op_24(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/vdu/email
    [HttpPost]
    [Route("email")]
    public async Task<JsonResult> SendAutoEmail([FromBody] VDUProcedure model)
    {
        var result = await _repository.Op_26(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/vdu/togglereupload
    [HttpPost]
    [Route("togglereupload")]
    public async Task<JsonResult> ToggleReupload([FromBody] VDUProcedure model)
    {
        var result = await _repository.Op_28(model);
        return BaseResult.JsonResult(result);
    }

    //Post api/vdu/reportrollup
    //Pass in TabMapId and UploadId
    [HttpPost]
    [Route("reportrollup")]
    public async Task<JsonResult> GetReportRollUp([FromBody] VDUProcedure model)
    {
        var result = await _repository.Op_29(model);
        return BaseResult.JsonResult(result);
    }

}