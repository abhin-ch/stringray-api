using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Models.ALR;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Specifications;
using System.Net;

namespace StingrayNET.Api.Controllers;

[ModuleRoute("api/[controller]", ModuleEnum.ALR)]
[EnableCors("stingrayCORS")]
[ApiController]
[Authorize]
[AppSecurity("ALRMain", AppSecurityTypeEnum.General, "Basic access to controls and various views such as ALR")]
public class ALRController : ControllerBase
{
    private readonly IRepositoryS<Procedure, ALRResult> _repository;

    public ALRController(IRepositoryS<Procedure, ALRResult> repository)
    {
        _repository = repository;
    }

    //GET /api/MainTableData/
    [Route("MainTableData")]
    [HttpGet]
    public async Task<JsonResult> Op_1()
    {
        var ALRMain = await _repository.Op_01();
        return BaseResult.JsonResult(ALRMain);
    }

    //GET /api/UserAssignment/
    [Route("UserAssignment")]
    [HttpGet]
    public async Task<JsonResult> Op_2(int parentID, string sourceName)
    {
        var ALRObject = new Procedure();
        ALRObject.Num1 = parentID;
        ALRObject.Value1 = sourceName;
        var result = await _repository.Op_02(ALRObject);
        return BaseResult.JsonResult(result);
    }

    //GET /api/Comments/
    [Route("Comments")]
    [HttpGet]
    public async Task<JsonResult> Op_3(int parentID)
    {
        var ALRObject = new Procedure();
        ALRObject.Num1 = parentID;
        var result = await _repository.Op_03(ALRObject);
        return BaseResult.JsonResult(result);
    }

    //GET /api/WorkOrders/
    [Route("WorkOrders")]
    [HttpGet]
    public async Task<JsonResult> Op_4(int parentID, string sourceName)
    {
        var ALRObject = new Procedure();
        ALRObject.Num1 = parentID;
        ALRObject.Value1 = sourceName;
        var result = await _repository.Op_04(ALRObject);
        return BaseResult.JsonResult(result);
    }

    //GET /api/RelatedItems/
    [Route("RelatedItems")]
    [HttpGet]
    public async Task<JsonResult> Op_5(int parentID, string sourceName)
    {
        var ALRObject = new Procedure();
        ALRObject.Num1 = parentID;
        ALRObject.Value1 = sourceName;
        var result = await _repository.Op_05(ALRObject);
        return BaseResult.JsonResult(result);
    }

    //GET /api/Activities/
    [Route("Activities")]
    [HttpGet]
    public async Task<JsonResult> Op_6(int parentID)
    {
        var ALRObject = new Procedure();
        ALRObject.Num1 = parentID;
        var result = await _repository.Op_06(ALRObject);
        return BaseResult.JsonResult(result);
    }

    //GET /api/TabRowCounts/
    [Route("TabRowCounts")]
    [HttpGet]
    public async Task<JsonResult> Op_7(int parentID, string sourceName)
    {
        var ALRObject = new Procedure();
        ALRObject.Num1 = parentID;
        ALRObject.Value1 = sourceName;
        var result = await _repository.Op_07(ALRObject);
        return BaseResult.JsonResult(result);
    }

    //POST api/ALR/UserAssignment
    [Route("UserAssignment")]
    [HttpPost]
    public async Task<JsonResult> Op_8(int parentID, string sourceName, string deliverable, string aStatus, int hour, int userIDAssigned)
    {
        var ALRObject = new Procedure();
        ALRObject.Num1 = parentID;
        ALRObject.Value1 = sourceName;
        ALRObject.Value2 = deliverable;
        ALRObject.Value3 = aStatus;
        ALRObject.Num2 = hour;
        ALRObject.Num3 = userIDAssigned;
        var result = await _repository.Op_08(ALRObject);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/ALR/UserAssignment
    [Route("UserAssignment")]
    [HttpPatch]
    public async Task<JsonResult> Op_9(int ADID, string deliverable, string aStatus, int hour, int userIDAssigned)
    {
        var ALRObject = new Procedure();
        ALRObject.Num1 = ADID;
        ALRObject.Value1 = deliverable;
        ALRObject.Value2 = aStatus;
        ALRObject.Num2 = hour;
        ALRObject.Num3 = userIDAssigned;
        var result = await _repository.Op_09(ALRObject);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/ALR/UserAssignment
    [Route("UserAssignment")]
    [HttpDelete]
    public async Task<JsonResult> Op_10(int ADID)
    {
        var ALRObject = new Procedure();
        ALRObject.Num1 = ADID;
        var result = await _repository.Op_10(ALRObject);
        return BaseResult.JsonResult(result);
    }

    //GET /api/ALR/PossibleAssignments/
    [Route("PossibleAssignments")]
    [HttpGet]
    public async Task<JsonResult> Op_12()
    {
        var ALRObject = await _repository.Op_12();
        return BaseResult.JsonResult(ALRObject);
    }
}
