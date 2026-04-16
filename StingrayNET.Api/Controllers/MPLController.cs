using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.MPL;
using System.Net;


namespace StingrayNET.Api.Controllers;

[Authorize]
[Route("api/[controller]")]
[EnableCors("stingrayCORS")]
[ApiController]
public class MPLController : ControllerBase
{
    private readonly IRepositoryL<MPLProcedure, MPLResult> _repository;
    private readonly IIdentityService _identityService;

    public MPLController(IRepositoryL<MPLProcedure, MPLResult> repository, IIdentityService identityService)
    {
        _repository = repository;
        _identityService = identityService;
    }
    //POST api/[controller]
    [HttpPost]
    public async Task<JsonResult> GetMPLData()
    {
        var result = await _repository.Op_01();
        return BaseResult.JsonResult(result);
    }

    //POST api/[controller]/pmc
    [HttpPost]
    [Route("pmc")]
    public async Task<JsonResult> GetPMCData()
    {
        var result = await _repository.Op_02();
        return BaseResult.JsonResult(result);
    }

    [HttpPost]
    //POST api/[controller]/sc
    [Route("sc")]
    public async Task<JsonResult> GetSCData()
    {
        var result = await _repository.Op_03();
        return BaseResult.JsonResult(result);
    }

    //POST api/[controller]/ded
    [HttpPost]
    [Route("ded")]
    public async Task<JsonResult> GetDEDDate()
    {
        var result = await _repository.Op_04();
        return BaseResult.JsonResult(result);
    }

    //POST api/[controller]/user-department
    [HttpPost]
    [Route("user-department")]
    public async Task<JsonResult> GetUserDepartment()
    {
        MPLProcedure model = new MPLProcedure();
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_05(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/[controller]/status
    [HttpPost]
    [Route("status")]
    public async Task<JsonResult> GetStatus()
    {
        var result = await _repository.Op_06();
        return BaseResult.JsonResult(result);
    }

    //POST api/[controller]/phase
    [HttpPost]
    [Route("phase")]
    public async Task<JsonResult> GetPhases()
    {
        var result = await _repository.Op_07();
        return BaseResult.JsonResult(result);
    }

    //POST api/changeRequest
    [HttpPost]
    [Route("changeRequest")]
    public async Task<JsonResult> ChangeRequest([FromBody] MPLProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_08(model);
        return BaseResult.JsonResult(result);
    }

    //Post api/[controller]/masterList
    [HttpPost]
    [Route("masterList")]
    public async Task<JsonResult> GetMasterList()
    {
        var result = await _repository.Op_09();
        return BaseResult.JsonResult(result);
    }


    //Post api/[controller]/changeRequestTab
    [HttpPost]
    [Route("changeRequestTab")]
    public async Task<JsonResult> GetChangeRequestTab([FromBody] MPLProcedure model)
    {

        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/[controller]/approvalResp
    [HttpPost]
    [Route("approvalResp")]
    public async Task<JsonResult> ApprovalResponse([FromBody] MPLProcedure model)
    {
        model.CurrentUser = await _identityService.GetEmployeeID(HttpContext);
        var result = await _repository.Op_12(model);
        return BaseResult.JsonResult(result);
    }

    //Post api/[controller]/statusLog
    [HttpPost]
    [Route("statusLog")]
    public async Task<JsonResult> GetStatusLog([FromBody] MPLProcedure model)
    {

        var result = await _repository.Op_13(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/[controller]/duplicateCount
    [HttpPost]
    [Route("duplicateCount")]
    public async Task<JsonResult> GetDuplicateCount([FromBody] MPLProcedure model)
    {
        var result = await _repository.Op_14(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/[controller]/overruledValue
    [HttpPatch]
    [Route("overruledValue")]
    public async Task<JsonResult> UpdateOverruledValue([FromBody] MPLProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_15(model);
        return BaseResult.JsonResult(result);

    }


    [HttpPatch]
    [Route("sceditfields")]
    public async Task<JsonResult> EditSCFields([FromBody] MPLProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_11(model);
        return BaseResult.JsonResult(result);
    }

    //Post api/[controller]/changeRequestRole
    [HttpPost]
    [Route("changeRequestRole")]
    public async Task<JsonResult> GetChangeRequestRole()
    {
        MPLProcedure model = new MPLProcedure();
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_16(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/[controller]/CR-approvalPrivileges
    [HttpPost]
    [Route("CR-approvalPrivileges")]
    public async Task<JsonResult> GetCRApprovalPrivileges()
    {
        MPLProcedure model = new MPLProcedure();
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_17(model);
        return BaseResult.JsonResult(result);
    }

    [HttpPost]
    [Route("emailUpdate")]
    public async Task<JsonResult> SendEmailUpdate([FromBody] MPLProcedure model)
    {

        var result = await _repository.Op_18(model);
        return BaseResult.JsonResult(result);
    }

    [HttpPost]
    [Route("replaceUser")]
    public async Task<JsonResult> ReplaceUser([FromBody] MPLProcedure model)
    {

        var result = await _repository.Op_19(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/changeRequest
    [HttpGet]
    [Route("changeRequest")]
    public async Task<JsonResult> GetChangeRequestID()
    {
        var result = await _repository.Op_20();
        return BaseResult.JsonResult(result);
    }

    //POST api/[controller]/invoice
    [HttpPost]
    [Route("invoice")]
    public async Task<JsonResult> GetEngInvoice()
    {
        var result = await _repository.Op_21();
        return BaseResult.JsonResult(result);
    }

    //POST API/[controller]/changerequestemail
    [HttpPost]
    [Route("changerequestemail")]
    public async Task<JsonResult> changerequestemail([FromBody] MPLProcedure model)
    {

        var result = await _repository.Op_22(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/[controller]/user-department
    [HttpPatch]
    [Route("user-department")]
    public async Task<JsonResult> SetUserDepartment([FromBody] MPLProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_23(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/mpl/comment
    [Route("comment")]
    [HttpPatch]
    public async Task<JsonResult> Op_24([FromBody] MPLProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_24(model);
        return BaseResult.JsonResult(result);
    }
}