using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Models.CSA;
using StingrayNET.ApplicationCore.Specifications;
using System.Net;

namespace StingrayNET.Api.Controllers;

[Authorize]
[ModuleRoute("api/[controller]", ModuleEnum.CSA)]
[ApiController]
public class CSAController : ControllerBase
{
    private readonly IRepositoryM<CSAProcedure, CSAResult> _repository;
    private readonly IIdentityService _identityService;

    public CSAController(IRepositoryM<CSAProcedure, CSAResult> repository, IIdentityService identityService)
    {
        _repository = repository;
        _identityService = identityService;
    }

    //POST api/csa/add-csa
    [HttpPost]
    [Route("add-csa")]
    public async Task<JsonResult> AddCSA([FromBody] CSAProcedure model)
    {
        var employeeID = HttpContext.Items[@"EmployeeID"].ToString();
        model.CurrentUser = employeeID;
        model.INID = employeeID;
        var result = await _repository.Op_01(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/csa/save-bom
    [HttpPost]
    [Route("save-bom")]
    [ProducesResponseType(typeof(Return<CSAResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> SaveBOM([FromBody] CSAProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_02(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/csa/my-csa
    [HttpGet]
    [Route("my-csa")]
    public async Task<JsonResult> MyCSA()
    {
        var employeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var procedure = new CSAProcedure { CurrentUser = employeeID };
        var result = await _repository.Op_03(procedure);
        return BaseResult.JsonResult(result);
    }

    //GET api/csa/all-csa
    [HttpGet]
    [Route("all-csa")]
    public async Task<JsonResult> AllCSA()
    {
        var employeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var procedure = new CSAProcedure { CurrentUser = employeeID };
        var result = await _repository.Op_04(procedure);
        return BaseResult.JsonResult(result);
    }

    //POST api/csa/personnel-date
    [HttpPost]
    [Route("personnel-date")]
    [ProducesResponseType(typeof(Return<CSAResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> PersonnelDate([FromBody] CSAProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_05(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/csa/mel
    [HttpPost]
    [Route("mel")]
    public async Task<JsonResult> MEL([FromBody] CSAProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_06(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/csa/bom
    [HttpPost]
    [Route("bom")]
    public async Task<JsonResult> BOM([FromBody] CSAProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_07(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/csa/status-log
    [HttpPost]
    [Route("status-log")]
    public async Task<JsonResult> StatusLog([FromBody] CSAProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_08(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/csa/search-csa
    [HttpPost]
    [Route("search-csa")]
    public async Task<JsonResult> SearchCSA([FromBody] CSAProcedure model)
    {
        var employeeID = HttpContext.Items[@"EmployeeID"].ToString();
        model.CurrentUser = employeeID;
        var result = await _repository.Op_09(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/csa/check-csa
    [HttpPost]
    [Route("check-csa")]
    public async Task<JsonResult> CheckCSA([FromBody] CSAProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/csa/save-csa
    [HttpPost]
    [Route("save-csa")]
    public async Task<JsonResult> SaveCSA([FromBody] CSAProcedure model)
    {
        var employeeID = HttpContext.Items[@"EmployeeID"].ToString();
        model.CurrentUser = employeeID;
        var result = await _repository.Op_11(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/csa/status
    [HttpPatch]
    [Route("status")]
    public async Task<JsonResult> ChangeCSAStatus([FromBody] CSAProcedure model)
    {
        var employeeID = HttpContext.Items[@"EmployeeID"].ToString();
        model.CurrentUser = employeeID;
        var result = await _repository.Op_12(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/csa/add-sa
    [HttpPost]
    [Route("add-sa")]
    [ProducesResponseType(typeof(Return<CSAResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> AddSA([FromBody] CSAProcedure model)
    {
        var employeeID = HttpContext.Items[@"EmployeeID"].ToString();
        model.CurrentUser = employeeID;
        var result = await _repository.Op_13(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/csa/add-sa-item
    [HttpPost]
    [Route("add-sa-item")]
    [ProducesResponseType(typeof(Return<CSAResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> AddSAItem([FromBody] CSAProcedure model)
    {
        var employeeID = HttpContext.Items[@"EmployeeID"].ToString();
        model.CurrentUser = employeeID;
        var result = await _repository.Op_14(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/csa/my-sa
    [HttpGet]
    [Route("my-sa")]
    [ProducesResponseType(typeof(Return<CSAResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> MySA()
    {
        var employeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var procedure = new CSAProcedure { CurrentUser = employeeID };
        var result = await _repository.Op_15(procedure);
        return BaseResult.JsonResult(result);
    }

    //GET api/csa/all-csa
    [HttpGet]
    [Route("all-sa")]
    [ProducesResponseType(typeof(Return<CSAResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> AllSA()
    {
        var employeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var procedure = new CSAProcedure { CurrentUser = employeeID };
        var result = await _repository.Op_16(procedure);
        return BaseResult.JsonResult(result);
    }

    //POST api/csa/sa-item
    [HttpPost]
    [Route("sa-item")]
    [ProducesResponseType(typeof(Return<CSAResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> SAItem([FromBody] CSAProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_17(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/csa/save-sa
    [HttpPost]
    [Route("save-sa")]
    [ProducesResponseType(typeof(Return<CSAResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> SaveSA([FromBody] CSAProcedure model)
    {
        var employeeID = HttpContext.Items[@"EmployeeID"].ToString();
        model.CurrentUser = employeeID;
        var result = await _repository.Op_18(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/csa/search-item
    [HttpPost]
    [Route("search-item")]
    [ProducesResponseType(typeof(Return<CSAResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> SearchItem([FromBody] CSAProcedure model)
    {
        var employeeID = HttpContext.Items[@"EmployeeID"].ToString();
        model.CurrentUser = employeeID;
        var result = await _repository.Op_19(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/csa/search-item
    [HttpDelete]
    [Route("remove-item")]
    [ProducesResponseType(typeof(Return<CSAResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> RemoveItem([FromBody] CSAProcedure model)
    {
        var employeeID = HttpContext.Items[@"EmployeeID"].ToString();
        model.CurrentUser = employeeID;
        var result = await _repository.Op_20(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/csa/item-management
    [HttpGet]
    [Route("item-management")]
    [ProducesResponseType(typeof(Return<CSAResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> ItemMangement()
    {
        var employeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var procedure = new CSAProcedure { CurrentUser = employeeID };
        var result = await _repository.Op_21(procedure);
        return BaseResult.JsonResult(result);
    }

    //POST api/csa/save-item-management
    [HttpPost]
    [Route("save-item-management")]
    [ProducesResponseType(typeof(Return<CSAResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> SaveItemManagment([FromBody] CSAProcedure model)
    {
        var employeeID = HttpContext.Items[@"EmployeeID"].ToString();
        model.CurrentUser = employeeID;
        var result = await _repository.Op_22(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/csa/item-mgmt-check
    [HttpPost]
    [Route("item-mgmt-check")]
    [ProducesResponseType(typeof(Return<CSAResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> ItemMgmtCheck([FromBody] CSAProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_23(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/csa/add-mgmt-item
    [HttpPost]
    [Route("add-mgmt-item")]
    [ProducesResponseType(typeof(Return<CSAResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> AddMgmtItem([FromBody] CSAProcedure model)
    {
        var employeeID = HttpContext.Items[@"EmployeeID"].ToString();
        model.CurrentUser = employeeID;
        var result = await _repository.Op_24(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/csa/search-ec
    [HttpPost]
    [Route("search-ec")]
    [ProducesResponseType(typeof(Return<CSAResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> SearchEC([FromBody] CSAProcedure model)
    {
        var employeeID = HttpContext.Items[@"EmployeeID"].ToString();
        model.CurrentUser = employeeID;
        var result = await _repository.Op_25(model);
        return BaseResult.JsonResult(result);
    }


    //POST api/csa/export
    [HttpPost]
    [Route("export")]
    [ProducesResponseType(typeof(Return<CSAResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Export([FromBody] CSAProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_26(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/csa/workflow
    [HttpPatch]
    [Route("workflow")]
    [ProducesResponseType(typeof(Return<CSAResult>), (int)HttpStatusCode.OK)]
    public async Task<JsonResult> Workflow([FromBody] CSAProcedure model)
    {
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_27(model);
        return BaseResult.JsonResult(result);

    }

    //GET api/csa/reason
    [HttpGet]
    [Route("reason")]
    public async Task<JsonResult> GetReason()
    {
        var model = new CSAProcedure { };
        model.CurrentUser = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_28(model);
        return BaseResult.JsonResult(result);
    }

}
