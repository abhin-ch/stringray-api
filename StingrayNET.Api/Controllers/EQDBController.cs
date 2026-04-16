using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Models.EQDB;
using StingrayNET.ApplicationCore.Models.ExcelService;
using StingrayNET.ApplicationCore.Specifications;

namespace StingrayNET.Api.Controllers;

[Authorize]
[ModuleRoute("api/[controller]", ModuleEnum.EQDB)]
[ApiController]
public class EQDBController : ControllerBase
{
    private readonly IRepositoryM<EQDBProcedure, EQDBResult> _repository;
    private readonly IIdentityService _identityService;
    private readonly IExcelService _excelService;

    public EQDBController(IRepositoryM<EQDBProcedure, EQDBResult> repository, IIdentityService identityService, IExcelService excelService)
    {
        _repository = repository;
        _identityService = identityService;
        _excelService = excelService;
    }

    //GET api/eqdb
    [HttpGet]
    public async Task<JsonResult> GetMainData()
    {
        var result = await _repository.Op_01();
        return BaseResult.JsonResult(result);
    }

    //POST api/eqdb/installation
    [HttpPost]
    [Route("installation")]
    public async Task<JsonResult> GetInstallation([FromBody] EQDBProcedure model)
    {
        var result = await _repository.Op_02(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/eqdb/predefined
    [HttpPost]
    [Route("predefined")]
    public async Task<JsonResult> GetPredefined([FromBody] EQDBProcedure model)
    {
        var result = await _repository.Op_03(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/eqdb/documents
    [HttpPost]
    [Route("documents")]
    public async Task<JsonResult> GetDocuments([FromBody] EQDBProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_04(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/eqdb/ec
    [HttpPost]
    [Route("ec")]
    public async Task<JsonResult> GetEC([FromBody] EQDBProcedure model)
    {
        var result = await _repository.Op_05(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/eqdb/dcr
    [HttpPost]
    [Route("dcr")]
    public async Task<JsonResult> GetDCR([FromBody] EQDBProcedure model)
    {
        var result = await _repository.Op_06(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/eqdb/pm-info
    [HttpPost]
    [Route("pm-info")]
    public async Task<JsonResult> GetPMInfo([FromBody] EQDBProcedure model)
    {
        var result = await _repository.Op_07(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/eqdb/assembly
    [HttpPost]
    [Route("assembly")]
    public async Task<JsonResult> GetAssembly([FromBody] EQDBProcedure model)
    {
        var result = await _repository.Op_08(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/eqdb/location-report
    [HttpGet]
    [Route("location-report")]
    public async Task<JsonResult> GetLocationReport()
    {
        var result = await _repository.Op_09();
        return BaseResult.JsonResult(result);
    }

    //GET api/eqdb/doc-report
    [HttpGet]
    [Route("doc-report")]
    public async Task<JsonResult> GetDocumentReport()
    {
        var result = await _repository.Op_10();
        return BaseResult.JsonResult(result);
    }

    //GET api/eqdb/eql-verification
    [HttpGet]
    [Route("eql-verification")]
    public async Task<JsonResult> GetEQLVerification()
    {
        var result = await _repository.Op_11();
        return BaseResult.JsonResult(result);
    }
    //PATCH api/eqdb/override
    [HttpPatch]
    [Route("override")]
    public async Task<JsonResult> EQOverride([FromBody] EQDBProcedure model)
    {
        var result = await _repository.Op_12(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/eqdb/override
    [HttpPost]
    [Route("override")]
    public async Task<JsonResult> GetOverride([FromBody] EQDBProcedure model)
    {
        var result = await _repository.Op_13(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/eqdb/outstanding-changes
    [HttpPatch]
    [Route("outstanding-changes")]
    public async Task<JsonResult> UpdateOutstandingChanges([FromBody] EQDBProcedure model)
    {
        var result = await _repository.Op_14(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/eqdb/failure-message
    [HttpGet]
    [Route("failure-message")]
    public async Task<JsonResult> GetFailureMessage()
    {
        var result = await _repository.Op_15();
        return BaseResult.JsonResult(result);
    }

    //POST api/eqdb/failure
    [HttpPost]
    [Route("eqebom-failure")]
    public async Task<JsonResult> GetEQEBOMFailures([FromBody] EQDBProcedure model)
    {
        var result = await _repository.Op_16(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/eqdb/eqdoc-failure
    [HttpPost]
    [Route("eqdoc-failure")]
    public async Task<JsonResult> GetEQDOCFailures([FromBody] EQDBProcedure model)
    {
        var result = await _repository.Op_17(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/eqdb/completion-failure
    [HttpPost]
    [Route("completion-failure")]
    public async Task<JsonResult> GetPredefinedCompletion([FromBody] EQDBProcedure model)
    {
        var result = await _repository.Op_18(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/eqdb/failure-report
    [HttpPost]
    [Route("failure-report")]
    public async Task<IActionResult> ExporttoExcelProcessHealth(ExcelConvertRequest request)
    {
        var data = (await _repository.Op_19()).Data1;

        Dictionary<string, List<object>> dataset = new Dictionary<string, List<object>>()
            {
                {request.Worksheets[0].SheetName, data}
            };

        return await _excelService.Convert(request, dataset);
    }

}