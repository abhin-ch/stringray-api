using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.ETDB;

namespace StingrayNET.Api.Controllers;

[Route("api/[controller]")]
public class ETDBController : BaseApiController
{
    private readonly IRepositoryM<ETDBProcedure, ETDBResult> _repository;

    public ETDBController(IRepositoryM<ETDBProcedure, ETDBResult> repository, IIdentityService identityService) : base(identityService)
    {
        _repository = repository;
    }

    [HttpGet]

    public async Task<JsonResult> GetTDSMain(bool archive)
    {
        var model = new ETDBProcedure
        {
            IsTrue1 = archive
        };
        var result = await _repository.Op_02(model);
        return BaseResult.JsonResult(result);
    }

    [Route("tds")]
    [HttpPost]

    public async Task<JsonResult> CreateTDS([FromBody] ETDBProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_01(model);
        return BaseResult.JsonResult(result);
    }

    [Route("tds")]
    [HttpGet]

    public async Task<JsonResult> SingleTDSInfo(string sheetId)
    {
        var model = new ETDBProcedure
        {
            Value1 = sheetId,
        };
        var result = await _repository.Op_09(model);
        return BaseResult.JsonResult(result);
    }

    [Route("tds")]
    [HttpPatch]
    public async Task<JsonResult> UpdateTDS([FromBody] ETDBProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_03(model);
        return BaseResult.JsonResult(result);
    }

    [Route("detail")]
    [HttpDelete]

    public async Task<JsonResult> DeleteTDS([FromBody] ETDBProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_04(model);
        return BaseResult.JsonResult(result);
    }

    [Route("detail")]
    [HttpPost]
    public async Task<JsonResult> AddScopeDetail([FromBody] ETDBProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_05(model);
        return BaseResult.JsonResult(result);
    }

    [Route("details")]
    [HttpGet]

    public async Task<JsonResult> GetTDSDetails(bool archive)
    {
        var result = await _repository.Op_07(new ETDBProcedure { IsTrue1 = archive });
        return BaseResult.JsonResult(result);
    }

    [Route("tds")]
    [HttpPut]
    public async Task<JsonResult> EditTDS([FromBody] ETDBProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_15(model);
        return BaseResult.JsonResult(result);
    }

    [Route("statuslog")]
    [HttpGet]

    public async Task<JsonResult> GetStatusLog(string sheetID)
    {
        var model = new ETDBProcedure
        {
            Value1 = sheetID,
        };
        var result = await _repository.Op_06(model);
        return BaseResult.JsonResult(result);
    }

    [Route("tds-details")]
    [HttpGet]

    public async Task<JsonResult> GetTDSDetails(string sheetId)
    {
        var model = new ETDBProcedure
        {
            Value1 = sheetId
        };
        var result = await _repository.Op_08(model);
        return BaseResult.JsonResult(result);
    }

    [Route("item-issues")]
    [HttpPatch]
    public async Task<JsonResult> UpdateItemIssues([FromBody] ETDBProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    [Route("email")]
    [HttpPost]
    public async Task<JsonResult> GetTemplateEmail([FromBody] ETDBProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_11(model);
        return BaseResult.JsonResult(result);
    }

    [Route("email-cancelled")]
    [HttpGet]

    public async Task<JsonResult> GetStatusCancelledEmailTemplate(string sheetID)
    {
        var model = new ETDBProcedure
        {
            Value1 = sheetID,
            EmployeeID = HttpContext.Items[@"EmployeeID"].ToString(),
            IsTrue1 = false
        };
        var result = await _repository.Op_11(model);
        return BaseResult.JsonResult(result);
    }

    [Route("email-tempus-pick")]
    [HttpGet]
    public async Task<JsonResult> GetEmailInfo(string projectId)
    {
        var model = new ETDBProcedure
        {
            Value1 = projectId
        };
        var result = await _repository.Op_12(model);
        return BaseResult.JsonResult(result);
    }

    [Route("issues")]
    [HttpPatch]
    public async Task<JsonResult> UpdateIssues([FromBody] ETDBProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_13(model);
        return BaseResult.JsonResult(result);
    }

    [Route("assignment")]
    [HttpPatch]
    public async Task<JsonResult> UpdateAssignment([FromBody] ETDBProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_14(model);
        return BaseResult.JsonResult(result);
    }

    [Route("related-commitments")]
    [HttpGet]

    public async Task<JsonResult> GetRelatedCommitments(string projectId)
    {
        var model = new ETDBProcedure
        {
            Value1 = projectId,
        };
        var result = await _repository.Op_16(model); // not correct op
        return BaseResult.JsonResult(result);
    }

    [Route("mpl")]
    [HttpGet]
    public async Task<JsonResult> mplsc(string sheetID)
    {
        var model = new ETDBProcedure
        {
            Value1 = sheetID,
        };
        var result = await _repository.Op_17(model); // not correct op
        return BaseResult.JsonResult(result);
    }

}
