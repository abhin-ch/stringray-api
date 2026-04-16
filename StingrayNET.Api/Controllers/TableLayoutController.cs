using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Models.TableLayout;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Specifications;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Api.Controllers;

[Route("api/[controller]")]
[EnableCors("stingrayCORS")]
[ApiController]
[Authorize]
public class TableLayoutController : ControllerBase
{
    private readonly IRepositoryS<Procedure, TableLayoutResult> _repository;
    private readonly IIdentityService _identityService;

    public TableLayoutController(IRepositoryS<Procedure, TableLayoutResult> repository, IIdentityService identityService)
    {
        _repository = repository;
        _identityService = identityService;
    }

    //GET /api/TableLayout/LayoutList
    [Route("LayoutList")]
    [HttpGet]
    public async Task<JsonResult> Op_1(string ModuleName, int UserID)
    {
        var model = new Procedure();
        model.Value1 = ModuleName;
        model.Num1 = UserID;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_01(model);
        return BaseResult.JsonResult(result);
    }

    //GET /api/TableLayout/Layout
    [Route("Layout")]
    [HttpGet]
    public async Task<JsonResult> Op_2(int TableLayoutID)
    {
        var TableLayoutObject = new Procedure();
        TableLayoutObject.Num1 = TableLayoutID;

        var result = await _repository.Op_02(TableLayoutObject);
        return BaseResult.JsonResult(result);
    }

    //POST /api/TableLayout/Layout
    [Route("Layout")]
    [HttpPost]
    public async Task<JsonResult> Op_3([FromBody] Procedure TableLayoutObject)
    {
        TableLayoutObject.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_03(TableLayoutObject);
        return BaseResult.JsonResult(result);
    }

    //PATCH /api/TableLayout/Layout
    [Route("Layout")]
    [HttpPatch]
    public async Task<JsonResult> Op_4([FromBody] Procedure TableLayoutObject)
    {
        var result = await _repository.Op_04(TableLayoutObject);
        return BaseResult.JsonResult(result);
    }

    //DELETE /api/TableLayout/Layout
    [Route("Layout")]
    [HttpDelete]
    public async Task<JsonResult> Op_5([FromBody] Procedure TableLayoutObject)
    {

        var result = await _repository.Op_05(TableLayoutObject);
        return BaseResult.JsonResult(result);
    }

    //POST /api/TableLayout/Layout
    [Route("LayoutShare")]
    [HttpPost]
    public async Task<JsonResult> Op_6([FromBody] Procedure TableLayoutObject)
    {
        TableLayoutObject.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_06(TableLayoutObject);
        return BaseResult.JsonResult(result);
    }

    //GET /api/TableLayout/LayoutList
    [Route("ShareList")]
    [HttpGet]
    public async Task<JsonResult> Op_7(string ModuleName, int UserID)
    {
        var model = new Procedure();
        model.Value1 = ModuleName;
        model.Num1 = UserID;
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_07(model);
        return BaseResult.JsonResult(result);
    }
}