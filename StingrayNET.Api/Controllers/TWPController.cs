using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Specifications;
using StingrayNET.ApplicationCore.Models.TWP;
using StingrayNET.ApplicationCore.Models.ExcelService;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Api.Controllers;

[Authorize]
[Route("api/[controller]")]
[ApiController]
public class TWPController : ControllerBase
{
    private readonly IRepositoryL<TWPProcedure, TWPResult> _repository;

    private readonly IIdentityService _identityService;

    private readonly IExcelService _excelService;

    public TWPController(IRepositoryL<TWPProcedure, TWPResult> repository, IIdentityService identityService, IExcelService excelService)
    {

        _repository = repository;
        _identityService = identityService;
        _excelService = excelService;
    }

    //Get api/twp
    //No params
    [HttpGet]

    public async Task<JsonResult> MainTable()
    {
        var result = await _repository.Op_01();
        return BaseResult.JsonResult(result);
    }

    //POST api/twp/childactivity
    //Requires Parent Acitivity ID
    [HttpPost]
    [Route("childactivity")]

    public async Task<JsonResult> GetChildrenActivities([FromBody] TWPProcedure model)
    {
        var result = await _repository.Op_02(model);
        return BaseResult.JsonResult(result);
    }

    [HttpPost]
    [Route("projects")]
    public async Task<JsonResult> GetProjects([FromBody] TWPProcedure model)
    {
        var result = await _repository.Op_03(model);
        return BaseResult.JsonResult(result);
    }

    [HttpPost]
    [Route("tasks")]
    public async Task<JsonResult> GetTasks([FromBody] TWPProcedure model)
    {
        var result = await _repository.Op_04(model);
        return BaseResult.JsonResult(result);
    }

    [HttpPost]
    [Route("flagged")]
    public async Task<JsonResult> FlagActivity([FromBody] TWPProcedure model)
    {
        var result = await _repository.Op_05(model);
        return BaseResult.JsonResult(result);
    }

    [HttpPatch]
    [Route("udfedits")]
    public async Task<JsonResult> UpdateChildTasks([FromBody] TWPProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_06(model);
        return BaseResult.JsonResult(result);
    }

    [HttpGet]
    [Route("status")]
    public async Task<JsonResult> GetStatus()
    {
        var result = await _repository.Op_07();
        return BaseResult.JsonResult(result);
    }

    [HttpPost]
    [Route("gcactivity")]
    public async Task<JsonResult> GetGCActivity([FromBody] TWPProcedure model)
    {
        var result = await _repository.Op_08(model);
        return BaseResult.JsonResult(result);
    }

    [HttpPut]
    [Route("gcactivityadd")]
    public async Task<JsonResult> AddGCActivity([FromBody] TWPProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_09(model);
        return BaseResult.JsonResult(result);
    }

    [HttpPatch]
    [Route("gcactivitydelete")]

    public async Task<JsonResult> DeleteGCActivity([FromBody] TWPProcedure model)
    {
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    [HttpGet]
    [Route("gctaskoptions")]
    public async Task<JsonResult> GetGCTaskOptions()
    {
        var result = await _repository.Op_11();
        return BaseResult.JsonResult(result);
    }

    [HttpPatch]
    [Route("udfeditsgc")]
    public async Task<JsonResult> UpdateGCTasks([FromBody] TWPProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_12(model);
        return BaseResult.JsonResult(result);
    }

    [HttpPost]
    [Route("searchallecs")]
    public async Task<JsonResult> SearchALLEC([FromBody] TWPProcedure model)
    {
        var result = await _repository.Op_13(model);
        return BaseResult.JsonResult(result);
    }


    [HttpPost]
    [Route("exportTWP")]
    public async Task<IActionResult> ExporttoExcelTWP(ExcelConvertRequest request)
    {
        var data = (await _repository.Op_15()).Data1;

        Dictionary<string, List<object>> dataset = new Dictionary<string, List<object>>()
            {
                {request.Worksheets[0].SheetName, data}
            };

        return await _excelService.Convert(request, dataset);
    }

}