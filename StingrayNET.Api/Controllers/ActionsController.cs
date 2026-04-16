using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Models.Actions;
using StingrayNET.ApplicationCore.Specifications;

namespace StingrayNET.Api.Controllers;

[Authorize]
[ModuleRoute("api/[controller]", ModuleEnum.Actions)]
[ApiController]
public class ActionsController : ControllerBase
{
    private readonly IRepositoryS<ActionsProcedure, ActionsResult> _repository;
    private readonly IIdentityService _identityService;

    public ActionsController(IRepositoryS<ActionsProcedure, ActionsResult> repository, IIdentityService identityService)
    {
        _repository = repository;
        _identityService = identityService;
    }

    [HttpGet]
    [Route("all")]
    public async Task<JsonResult> Op_2()
    {
        var result = await _repository.Op_02();
        return BaseResult.JsonResult(result);
    }

    [HttpGet]
    [Route("mcrProjects")]
    public async Task<JsonResult> Op_3()
    {
        var procedure = new ActionsProcedure { };
        var result = await _repository.Op_03(procedure);
        return BaseResult.JsonResult(result);
    }

    [HttpGet]
    [Route("mcrResources")]
    public async Task<JsonResult> Op_4()
    {
        var result = await _repository.Op_04();
        return BaseResult.JsonResult(result);
    }

    [HttpPut]
    [Route("New")]
    public async Task<JsonResult> Op_5([FromBody] ActionsProcedure body)
    {
        var result = await _repository.Op_05(body);
        return BaseResult.JsonResult(result);
    }

    [HttpPut]
    [Route("actionStatus")]
    public async Task<JsonResult> Op_6([FromBody] ActionsProcedure body)
    {
        var result = await _repository.Op_06(body);
        return BaseResult.JsonResult(result);
    }

    [HttpPut]
    [Route("actionTCD")]
    public async Task<JsonResult> Op_7([FromBody] ActionsProcedure body)
    {
        var result = await _repository.Op_07(body);
        return BaseResult.JsonResult(result);
    }

    [HttpGet]
    [Route("actionDetail")]
    public async Task<JsonResult> Op_8(int? ActID)
    {
        ActionsProcedure body = new ActionsProcedure();
        body.ActID = ActID;
        var result = await _repository.Op_08(body);
        return BaseResult.JsonResult(result);
    }

    [HttpPost]
    [Route("actionDetails")]
    public async Task<JsonResult> Op_8([FromBody] ActionsProcedure body)
    {
        //ActionsProcedure body = new ActionsProcedure();
        //body.ActID = ActID;
        var result = await _repository.Op_08(body);
        return BaseResult.JsonResult(result);
    }

    [HttpPut]
    [Route("actionUpdate")]
    public async Task<JsonResult> Op_9([FromBody] ActionsProcedure body)
    {
        var result = await _repository.Op_09(body);
        return BaseResult.JsonResult(result);
    }

    [HttpGet]
    [Route("actionLog")]
    public async Task<JsonResult> Op_10(int? ActID)
    {
        ActionsProcedure body = new ActionsProcedure();
        body.ActID = ActID;
        var result = await _repository.Op_10(body);
        return BaseResult.JsonResult(result);
    }

    [HttpGet]
    [Route("mcrDescriptions")]
    public async Task<JsonResult> Op_11()
    {
        var result = await _repository.Op_11();
        return BaseResult.JsonResult(result);
    }
}