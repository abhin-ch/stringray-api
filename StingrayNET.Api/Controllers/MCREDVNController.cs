using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Interfaces;
using System.Net;
using StingrayNET.ApplicationCore.Models.MCREDVN;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.Api.Controllers;

[Authorize]
[Route("api/[controller]")]
[ApiController]
public class MCREDVNController : ControllerBase
{
    private readonly IRepositoryL<MCREDVNProcedure, MCREDVNResult> _repository;
    private readonly IIdentityService _identityService;

    public MCREDVNController(IRepositoryL<MCREDVNProcedure, MCREDVNResult> repository, IIdentityService identityService)
    {
        _repository = repository;
        _identityService = identityService;
    }

    [HttpPost]
    [Route("dvnAll")]
    public async Task<JsonResult> Op_2([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_02(body);
        return BaseResult.JsonResult(result);
    }

    [HttpPost]
    [Route("dvnDetail")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_3([FromBody] MCREDVNProcedure body)//int? DVNID)
    {
        // MCREDVNProcedure body = new MCREDVNProcedure();
        // body.DVNID = DVNID;
        var result = await _repository.Op_03(body);
        return BaseResult.JsonResult(result);
    }

    [HttpGet]
    [Route("mcrP6Projects")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_4()
    {
        var result = await _repository.Op_04();
        return BaseResult.JsonResult(result);
    }

    [HttpPut]
    [Route("newDVN")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_5([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_05(body);
        return BaseResult.JsonResult(result);
    }

    [HttpPost]
    [Route("mcrActs")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_6([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_06(body);
        return BaseResult.JsonResult(result);
    }

    [HttpPost]
    [Route("dvnMRoCWeight")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_7([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_07(body);
        return BaseResult.JsonResult(result);
    }

    [HttpPost]
    [Route("dvnAllMRoC")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_8([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_08(body);
        return BaseResult.JsonResult(result);
    }

    [HttpGet]
    [Route("mcrUsers")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_9()
    {
        var result = await _repository.Op_09();
        return BaseResult.JsonResult(result);
    }

    [HttpPut]
    [Route("addActivity")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_10([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_10(body);
        return BaseResult.JsonResult(result);
    }

    [HttpPut]
    [Route("submitDVN")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_11([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_11(body);
        return BaseResult.JsonResult(result);
    }

    [HttpPut]
    [Route("addActivityMROC")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_12([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_12(body);
        return BaseResult.JsonResult(result);
    }

    [HttpPut]
    [Route("mcrReasons")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_13([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_13(body);
        return BaseResult.JsonResult(result);
    }

    [HttpPut]
    [Route("dvnremove")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_14([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_14(body);
        return BaseResult.JsonResult(result);
    }
    [HttpPost]
    [Route("dvnPDFDetailsLog")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_15([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_15(body);
        return BaseResult.JsonResult(result);
    }
    [HttpPost]
    [Route("dvnarchive")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_16([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_16(body);
        return BaseResult.JsonResult(result);
    }
    [HttpPut]
    [Route("dvn-header-change")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_17([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_17(body);
        return BaseResult.JsonResult(result);
    }
    [HttpPut]
    [Route("dvnRevisedMROCWeight")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_18([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_18(body);
        return BaseResult.JsonResult(result);
    }
    [HttpPut]
    [Route("dvnCause")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_19([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_19(body);
        return BaseResult.JsonResult(result);
    }
    [HttpPut]
    [Route("rejectDVN")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_20([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_20(body);
        return BaseResult.JsonResult(result);
    }
    [HttpPut]
    [Route("approveDVN")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_21([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_21(body);
        return BaseResult.JsonResult(result);
    }
    [HttpPut]
    [Route("deleteActivity")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_22([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_22(body);
        return BaseResult.JsonResult(result);
    }
    [HttpPut]
    [Route("deleteActivityMROC")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_23([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_23(body);
        return BaseResult.JsonResult(result);
    }
    [HttpPost]
    [Route("dvnStatusLog")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_24([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_24(body);
        return BaseResult.JsonResult(result);
    }

    [HttpPost]
    [Route("dvnPDFDetails")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_25([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_25(body);
        return BaseResult.JsonResult(result);
    }

    [HttpPut]
    [Route("mcrSubProjects")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_26([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_26(body);
        return BaseResult.JsonResult(result);
    }

    [HttpPut]
    [Route("dvnUpdateActivityRow")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_27([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_27(body);
        return BaseResult.JsonResult(result);
    }
    [HttpPut]
    [Route("dvnUpdateMROCRow")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_28([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_28(body);
        return BaseResult.JsonResult(result);
    }

    [HttpPost]
    [Route("mcrActsMROC")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_29([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_29(body);
        return BaseResult.JsonResult(result);
    }

    [HttpPost]
    [Route("dvnHeader")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_30([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_30(body);
        return BaseResult.JsonResult(result);
    }

    [HttpGet]
    [Route("reminder-emails")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_31()
    {
        var result = await _repository.Op_31();
        return BaseResult.JsonResult(result);
    }

    //Put api/mcredvn/dvncancel
    [HttpPut]
    [Route("dvncancel")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_33([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_33(body);
        return BaseResult.JsonResult(result);
    }

    //Put api/mcredvn/withdrawDVN
    [HttpPut]
    [Route("withdrawDVN")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_34([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_34(body);
        return BaseResult.JsonResult(result);
    }

    [HttpPut]
    [Route("addActivityFull")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_35([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_35(body);
        return BaseResult.JsonResult(result);
    }

    [HttpPut]
    [Route("clearActivity")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_36([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_36(body);
        return BaseResult.JsonResult(result);
    }

    [HttpPut]
    [Route("addActivityMRoCFull")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_37([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_37(body);
        return BaseResult.JsonResult(result);
    }

    [HttpPut]
    [Route("clearActivityMRoC")]
    [ProducesResponseType(typeof(Return<MCREDVNResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Op_38([FromBody] MCREDVNProcedure body)
    {
        var result = await _repository.Op_38(body);
        return BaseResult.JsonResult(result);
    }
}