using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Models.StandardComp;
using StingrayNET.ApplicationCore.Specifications;
using System.Net;

namespace StingrayNET.Api.Controllers;

[Authorize]
[Route("api/[controller]")]
[EnableCors("stingrayCORS")]
[ApiController]
public class StandardCompController : ControllerBase
{
    private readonly IRepositoryS<StandardCompProcedure, StandardCompResult> _repository;

    public StandardCompController(IRepositoryS<StandardCompProcedure, StandardCompResult> repository)
    {
        _repository = repository;
    }

    //POST api/standardcomp/main-data
    [HttpPost]
    [Route("main-data")]
    public async Task<JsonResult> MainData([FromBody] StandardCompProcedure model)
    {
        var result = await _repository.Op_01(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/standardcomp/main-data
    [HttpPost]
    [Route("save-form")]
    public async Task<JsonResult> SaveForm([FromBody] StandardCompProcedure model)
    {
        var result = await _repository.Op_02(model);
        return BaseResult.JsonResult(result);
    }

}