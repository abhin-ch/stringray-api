using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.Interfaces;
using StingrayNET.ApplicationCore.Models;
using StingrayNET.ApplicationCore.Models.Admin;
using StingrayNET.ApplicationCore.Models.Common;
using StingrayNET.ApplicationCore.Specifications;

namespace StingrayNET.Api.Controllers;
[Authorize]
[ModuleRoute("api/[controller]", ModuleEnum.Admin)]
[EnableCors("stingrayCORS")]
[ApiController]
public class DelegateController : ControllerBase
{
    private readonly IRepositoryM<Procedure, DelegateResult> _repository;
    private readonly IIdentityService _identityService;

    public DelegateController(IRepositoryM<Procedure, DelegateResult> repository, IIdentityService identityService)
    {
        _repository = repository;
        _identityService = identityService;
    }

    //POST api/delegate/delegations
    [HttpPost]
    [Route("delegations")]
    public async Task<JsonResult> GetDelegations()
    {
        var model = new Procedure
        {
            EmployeeID = HttpContext.Items[@"EmployeeID"].ToString()
        };
        var result = await _repository.Op_01(model);
        return BaseResult.JsonResult(result);
    }


    //POST api/delegate/assign
    [HttpPost]
    [Route("assign")]
    public async Task<JsonResult> CreateDelegate([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_02(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/delegate/users
    [Route("users")]
    [HttpGet]
    public async Task<JsonResult> GetDelegateSecurity()
    {
        var model = new Procedure
        {
            EmployeeID = HttpContext.Items[@"EmployeeID"].ToString()
        };
        var result = await _repository.Op_03(model);
        return BaseResult.JsonResult(result);
    }



    //POST api/delegate/user-role
    [Route("user-role")]
    [HttpPost]
    public async Task<JsonResult> GetUserroles()
    {
        var model = new Procedure
        {
            EmployeeID = HttpContext.Items[@"EmployeeID"].ToString()
        };
        var result = await _repository.Op_04(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/delegate/delegation-role
    [Route("delegation-role")]
    [HttpPost]
    public async Task<JsonResult> GetDelegationRoles([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_05(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/delegate/assign-role
    [Route("assign-role")]
    [HttpPost]
    public async Task<JsonResult> CreateDelegateRole([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_06(model);
        return BaseResult.JsonResult(result);
    }



    //POST api/delegate/permission
    [Route("permission")]
    [HttpPost]
    public async Task<JsonResult> GetUserPermission([FromBody] Procedure model)
    {

        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_07(model);
        return BaseResult.JsonResult(result);
    }


    //POST api/delegate/add-permission
    [Route("assign-permission")]
    [HttpPost]
    public async Task<JsonResult> AddUserPermission([FromBody] Procedure model)
    {

        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_08(model);
        return BaseResult.JsonResult(result);
    }


    //POST api/delegate/delegation-permissions
    [Route("delegation-permissions")]
    [HttpPost]
    public async Task<JsonResult> GetDelegationPermissions([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_09(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/delegate/delegation-role-permissions
    [Route("delegation-role-permissions")]
    [HttpPost]
    public async Task<JsonResult> GetDelegationRolePermissions([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_10(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/delegate/delegation-checklist
    [Route("delegation-checklist")]
    [HttpPost]
    public async Task<JsonResult> GetDelegationChecklist([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_11(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/delegate/change-delegation-permission
    [Route("change-delegation-permission")]
    [HttpPost]
    public async Task<JsonResult> UpdateDelegationPermission([FromBody] Procedure model)
    {
        var result = await _repository.Op_12(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/delegate/change-delegation-role
    [Route("change-delegation-role")]
    [HttpPost]
    public async Task<JsonResult> UpdateDelegationRole([FromBody] Procedure model)
    {
        var result = await _repository.Op_13(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/delegate/clone-delegation
    [Route("clone-delegation")]
    [HttpPost]
    public async Task<JsonResult> CloneDelegation([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_14(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/delegate/change-indefinite
    [Route("change-indefinite")]
    [HttpPost]
    public async Task<JsonResult> UpdateIndefinite([FromBody] Procedure model)
    {
        var result = await _repository.Op_15(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/delegate/change-expire-date
    [Route("change-expire-date")]
    [HttpPost]
    public async Task<JsonResult> UpdateExpire([FromBody] Procedure model)
    {
        var result = await _repository.Op_16(model);
        return BaseResult.JsonResult(result);
    }


    //POST api/delegate/change-active
    [Route("change-active")]
    [HttpPost]
    public async Task<JsonResult> UpdateDelegateActive([FromBody] Procedure model)
    {
        var result = await _repository.Op_17(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/delegate/remove-delegation
    [Route("remove-delegation")]
    [HttpPost]
    public async Task<JsonResult> DeleteDelegate([FromBody] Procedure model)
    {
        var result = await _repository.Op_18(model);
        return BaseResult.JsonResult(result);
    }


    //POST api/delegate/delegators
    [HttpPost]
    [Route("delegators")]
    public async Task<JsonResult> GetDelegators()
    {
        var model = new Procedure
        {
            EmployeeID = HttpContext.Items[@"EmployeeID"].ToString()
        };
        var result = await _repository.Op_19(model);
        return BaseResult.JsonResult(result);
    }


    //POST api/delegate/delegatee-role
    [Route("delegatee-role")]
    [HttpPost]
    public async Task<JsonResult> GetDelegateeRoles([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_20(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/delegate/delegatee-role-permissions
    [Route("delegatee-role-permissions")]
    [HttpPost]
    public async Task<JsonResult> GetDelegateeRolePermissions([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_21(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/delegate/delegatee-checklist
    [Route("delegatee-checklist")]
    [HttpPost]
    public async Task<JsonResult> GetDelegateeChecklist([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_22(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/delegate/delegatee-permissions
    [Route("delegatee-permissions")]
    [HttpPost]
    public async Task<JsonResult> GetDelegateePermissions([FromBody] Procedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_23(model);
        return BaseResult.JsonResult(result);
    }


    //-----------------------------------LEGACY-------------------------------------------

    // //PATCH api/delegate
    // [HttpPatch]
    // public async Task<JsonResult> UpdateDelegate([FromBody] Procedure model)
    // {
    //     var result = await _repository.Op_02(model);
    //     return BaseResult.JsonResult(result);
    // }

    // //DELETE api/delegate
    // [HttpDelete]
    // public async Task<JsonResult> DeleteUserDelegate([FromBody] Procedure model)
    // {
    //     var result = await _repository.Op_03(model);
    //     return BaseResult.JsonResult(result);
    // }

    // //POST
    // [Route("access")]
    // [HttpPost]
    // public async Task<JsonResult> CreateDelegateAccess([FromBody] Procedure model)
    // {
    //     model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
    //     var result = await _repository.Op_06(model);
    //     return BaseResult.JsonResult(result);
    // }

    // //DELETE
    // [Route("access")]
    // [HttpDelete]
    // public async Task<JsonResult> DeleteDelegateAccess([FromBody] Procedure model)
    // {
    //     var result = await _repository.Op_07(model);
    //     return BaseResult.JsonResult(result);
    // }

    // //GET
    // [Route("access")]
    // [HttpGet]
    // public async Task<JsonResult> GetDelegateAccess(int delegateID)
    // {
    //     var result = await _repository.Op_08(new Procedure { Num1 = delegateID });
    //     return BaseResult.JsonResult(result);
    // }

    // // //PATCH
    // // [Route("access")]
    // // [HttpPatch]
    // // public async Task<JsonResult> UpdateDelegateAccess([FromBody] Procedure model)
    // // {
    // //     var result = await _repository.Op_09(model);
    // //     return BaseResult.JsonResult(result);
    // // }

    // //Delete
    // [Route("access/all")]
    // [HttpDelete]
    // public async Task<JsonResult> DeleteDelegateAccessAll([FromBody] Procedure model)
    // {
    //     var result = await _repository.Op_13(model);
    //     return BaseResult.JsonResult(result);
    // }

    // //GET
    // [Route("login")]
    // [HttpGet]
    // public async Task<JsonResult> LoginDelegate()
    // {
    //     var model = new Procedure
    //     {
    //         EmployeeID = HttpContext.Items[@"EmployeeID"].ToString()
    //     };
    //     var result = await _repository.Op_14(model);
    //     return BaseResult.JsonResult(result);
    // }

    // //PATCH
    // [Route("expire-date")]
    // [HttpPatch]
    // public async Task<JsonResult> UpdateExpireDate([FromBody] Procedure model)
    // {
    //     var result = await _repository.Op_15(model);
    //     return BaseResult.JsonResult(result);
    // }

}
