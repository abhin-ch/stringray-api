using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;
using Serilog;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Models.CMDS;
using StingrayNET.ApplicationCore.Specifications;

namespace StingrayNET.Api.Controllers;

[Authorize]
[ModuleRoute("api/[controller]", ModuleEnum.CMDS)]
[EnableCors("stingrayCORS")]
[ApiController]
public class CMDSController : ControllerBase
{
    private readonly IRepositoryL<CMDSProcedure, CMDSResult> _repository;
    private readonly IIdentityService _identityService;

    public CMDSController(IRepositoryL<CMDSProcedure, CMDSResult> repository, IIdentityService identityService)
    {
        _repository = repository;
        _identityService = identityService;
    }

    //GET api/cmds/goal
    [HttpGet]
    [Route("goal")]
    public async Task<JsonResult> GetGoal()
    {
        var result = await _repository.Op_01();
        return BaseResult.JsonResult(result);
    }

    //POST api/cmds/goal
    [HttpPost]
    [Route("goal")]
    public async Task<JsonResult> AddGoal([FromBody] CMDSProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_02(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/cmds/goal
    [HttpPatch]
    [Route("goal")]
    public async Task<JsonResult> EditGoal([FromBody] CMDSProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_03(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/cmds/comment
    [HttpPost]
    [Route("comment")]
    public async Task<JsonResult> GetComment([FromBody] CMDSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_04(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/cmds/comment
    [HttpPut]
    [Route("comment")]
    public async Task<JsonResult> AddComment([FromBody] CMDSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_05(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/cmds/comment
    [HttpDelete]
    [Route("comment")]
    public async Task<JsonResult> DeleteComment([FromBody] CMDSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_06(model);
        return BaseResult.JsonResult(result);
    }

    //PATCHs api/cmds/comment
    [HttpPatch]
    [Route("comment")]
    public async Task<JsonResult> EditComment([FromBody] CMDSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_07(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/cmds/status
    [HttpGet]
    [Route("status")]
    public async Task<JsonResult> GetStatus()
    {
        var result = await _repository.Op_08();
        return BaseResult.JsonResult(result);
    }

    //PUT api/cmds/status
    [HttpPut]
    [Route("status")]
    public async Task<JsonResult> AddStatus([FromBody] CMDSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_09(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/cmds/status
    [HttpDelete]
    [Route("status")]
    public async Task<JsonResult> DeleteStatus([FromBody] CMDSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/cmds/goal-level
    [HttpGet]
    [Route("goal-level")]
    public async Task<JsonResult> GetGoalLevel()
    {
        var result = await _repository.Op_11();
        return BaseResult.JsonResult(result);
    }

    //PUT api/cmds/goal-level
    [HttpPut]
    [Route("goal-level")]
    public async Task<JsonResult> AddGoalLevel([FromBody] CMDSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_12(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/cmds/goal-level
    [HttpDelete]
    [Route("goal-level")]
    public async Task<JsonResult> DeleteGoalLevel([FromBody] CMDSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_13(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/cmds/work-program
    [HttpGet]
    [Route("work-program")]
    public async Task<JsonResult> GetWorkProgram()
    {
        var result = await _repository.Op_14();
        return BaseResult.JsonResult(result);
    }

    //PUT api/cmds/work-program
    [HttpPut]
    [Route("work-program")]
    public async Task<JsonResult> AddWorkProgram([FromBody] CMDSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_15(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/cmds/work-program
    [HttpDelete]
    [Route("work-program")]
    public async Task<JsonResult> DeleteWorkProgram([FromBody] CMDSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_16(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/cmds/section
    [HttpGet]
    [Route("section")]
    public async Task<JsonResult> GetSection()
    {
        var result = await _repository.Op_17();
        return BaseResult.JsonResult(result);
    }

    //PUT api/cmds/section
    [HttpPut]
    [Route("section")]
    public async Task<JsonResult> AddSection([FromBody] CMDSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_18(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/cmds/section
    [HttpDelete]
    [Route("section")]
    public async Task<JsonResult> DeleteSection([FromBody] CMDSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_19(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/cmds/action
    [HttpPost]
    [Route("action")]
    public async Task<JsonResult> GetAction([FromBody] CMDSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_20(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/cmds/action
    [HttpPut]
    [Route("action")]
    public async Task<JsonResult> AddAction([FromBody] CMDSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_21(model);
        return BaseResult.JsonResult(result);
    }

    //PATCHs api/cmds/action
    [HttpPatch]
    [Route("action")]
    public async Task<JsonResult> EditAction([FromBody] CMDSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_22(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/cmds/action
    [HttpDelete]
    [Route("action")]
    public async Task<JsonResult> DeleteAction([FromBody] CMDSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_23(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/cmds/date
    [HttpPost]
    [Route("date")]
    public async Task<JsonResult> GetDate([FromBody] CMDSProcedure model)
    {
        var result = await _repository.Op_24(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/cmds/date
    [HttpPut]
    [Route("date")]
    public async Task<JsonResult> AddDate([FromBody] CMDSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_25(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/cmds/date
    [HttpDelete]
    [Route("date")]
    public async Task<JsonResult> DeleteDate([FromBody] CMDSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_26(model);
        return BaseResult.JsonResult(result);
    }


    //GET api/cmds/category
    [HttpGet]
    [Route("category")]
    public async Task<JsonResult> GetCategory()
    {
        var result = await _repository.Op_27();
        return BaseResult.JsonResult(result);
    }

    //PUT api/cmds/category
    [HttpPut]
    [Route("category")]
    public async Task<JsonResult> AddCategory([FromBody] CMDSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_28(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/cmds/category
    [HttpDelete]
    [Route("category")]
    public async Task<JsonResult> DeleteCategory([FromBody] CMDSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_29(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/cmds/category
    [HttpPost]
    [Route("category")]
    public async Task<JsonResult> Strategy([FromBody] CMDSProcedure model)
    {
        var result = await _repository.Op_30(model);
        return BaseResult.JsonResult(result);
    }
    //PATCH api/cmds/category
    [HttpPatch]
    [Route("category")]
    public async Task<JsonResult> UpdateCategory([FromBody] CMDSProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_31(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/cmds/status-log
    [HttpPost]
    [Route("status-log")]
    public async Task<JsonResult> StatusLog([FromBody] CMDSProcedure model)
    {
        var result = await _repository.Op_32(model);
        return BaseResult.JsonResult(result);
    }


    //GET api/cmds/action-status
    [HttpGet]
    [Route("action-status")]
    public async Task<JsonResult> GetActionStatus()
    {
        var result = await _repository.Op_33();
        return BaseResult.JsonResult(result);
    }

    //PUT api/cmds/action-status
    [HttpPut]
    [Route("action-status")]
    public async Task<JsonResult> AddActionStatus([FromBody] CMDSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_34(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/cmds/action-status
    [HttpDelete]
    [Route("action-status")]
    public async Task<JsonResult> DeleteActionStatus([FromBody] CMDSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_35(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/cmds/goal
    [HttpDelete]
    [Route("goal")]
    public async Task<JsonResult> DeleteGoal([FromBody] CMDSProcedure model)
    {

        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_36(model);
        return BaseResult.JsonResult(result);
    }
}