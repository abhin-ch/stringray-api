using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models.Escalations;

using System.Net;

namespace StingrayNET.Api.Controllers;

[Authorize]
[Route("api/[controller]")]
[EnableCors("stingrayCORS")]
[ApiController]

public class EscalationsController : ControllerBase
{
    private readonly IRepositoryS<EscalationProcedure, EscalationResult> _repository;
    private readonly IIdentityService _identityService;

    public EscalationsController(IRepositoryS<EscalationProcedure, EscalationResult> repository, IIdentityService identityService)
    {
        _repository = repository;
        _identityService = identityService;
    }

    //POST api/[controller]/create
    [HttpPost]
    public async Task<JsonResult> Op_1([FromBody] EscalationProcedure body)
    {
        body.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_01(body);
        return BaseResult.JsonResult(result);
    }

    [Route("escalationmain")]
    [HttpPost]
    public async Task<JsonResult> Op_2([FromBody] EscalationProcedure body)
    {

        var result = await _repository.Op_02(body);
        return BaseResult.JsonResult(result);
    }

    //GET api/[controller]/update

    [HttpPatch]
    [ProducesResponseType(typeof(Return<EscalationResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_3([FromBody] EscalationProcedure body)
    {
        body.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_03(body);
        return BaseResult.JsonResult(result);
    }

    [Route("changelog")]
    [HttpGet]
    [ProducesResponseType(typeof(Return<EscalationResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_4(string PK_ID)
    {

        var result = await _repository.Op_04(new EscalationProcedure { PK_ID = PK_ID });
        return BaseResult.JsonResult(result);
    }
    [Route("carla")]
    [HttpGet]
    public async Task<JsonResult> Op_5()
    {
        var result = await _repository.Op_05();
        return BaseResult.JsonResult(result);
    }
}