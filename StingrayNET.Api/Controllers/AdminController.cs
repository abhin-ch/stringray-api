using Microsoft.AspNetCore.Mvc;
using StingrayNET.ApplicationCore.Models.Admin;
using StingrayNET.ApplicationCore.Interfaces;
using Microsoft.AspNetCore.Authorization;
using StingrayNET.ApplicationCore.Abstractions;
using StingrayNET.ApplicationCore.HelperFunctions;
using System.Diagnostics;

namespace StingrayNET.Api.Controllers;

[Route("api/[controller]")]
[Authorize]
public class AdminController : ControllerBase
{
    private readonly IRepositoryXL<AdminProcedure, AdminResult> _repository;
    private readonly IIdentityService _identityService;
    private readonly IEmailService _emailService;
    private readonly IAdminHelperFunctions _helperFunctions;
    private readonly ICacheProvider _cache;
    private readonly IHttpContextAccessor _httpContextAccessor;
    public AdminController(IRepositoryXL<AdminProcedure, AdminResult> repository, IAdminHelperFunctions helperFunctions,
    IIdentityService identityService, IEmailService emailService, ICacheProvider cache, IHttpContextAccessor httpContextAccessor)
    {
        _repository = repository;
        _identityService = identityService;
        _emailService = emailService;
        _helperFunctions = helperFunctions;
        _cache = cache;
        _httpContextAccessor = httpContextAccessor;
    }

    #region Attributes

    //PUT api/admin/attribute
    //Adds Attribute
    //Attribute and AttributeType/AttributeTypeID are required
    [HttpPut]
    [Route("attribute")]
    public async Task<JsonResult> AddAttribute([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_01(model));
    }

    //DELETE api/admin/attribute
    //Deletes Attribute
    //AttributeID or Attribute and AttributeType/AttributeTypeID are required
    [HttpDelete]
    [Route("attribute")]
    public async Task<JsonResult> DeleteAttribute([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_02(model));
    }

    //PATCH api/admin/attribute
    //Edits Attribute Name
    //AttributeID and Attribute are required
    [HttpPatch]
    [Route("attribute")]
    public async Task<JsonResult> EditAttribute([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_03(model));
    }

    //POST api/admin/attribute
    //Get Attributes
    //Attribute and AttributeType/AttributeTypeID or AttributeID (All optional)
    [HttpPost]
    [Route("attribute")]
    public async Task<JsonResult> GetAttributes([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_04(model));
    }

    #region  Attribute Types

    //PUT api/admin/attribute/type
    //Adds Attribute Type
    //AttributeType and Supersedence are required
    [HttpPut]
    [Route("attribute/type")]
    public async Task<JsonResult> AddAttributeType([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_35(model));
    }

    //DELETE api/admin/attribute/type
    //Deletes Attribute Type
    //AttributeType or AttributeTypeID are required
    [HttpDelete]
    [Route("attribute/type")]
    public async Task<JsonResult> DeleteAttributeType([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_36(model));
    }

    //POST api/admin/attribute/type
    //Get Attribute Types
    //AttributeType or AttributeTypeID (Both are optional)
    [HttpPost]
    [Route("attribute/type")]
    public async Task<JsonResult> GetAttributeTypes([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_37(model));
    }

    //PATCH api/admin/attribute/type
    //Edit Attribute Type
    //AttributeType, AttributeTypeID, and Supersedence are required
    [HttpPatch]
    [Route("attribute/type")]
    public async Task<JsonResult> EditAttributeType([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_52(model));
    }


    #endregion

    #endregion

    #region Access Request Overhaul

    //PUT api/admin/request
    //Add new access request(s) 
    //Module or ModuleID required
    //IsMimicRequest, (ModuleID or Module), EmployeeIDInsert required
    //If IsMimicRequest false, Description is required
    //If IsMimicRequest true, MimicOfEmployeeID is required, Description is optional
    [HttpPut]
    [Route("request")]
    public async Task<JsonResult> AddAccessRequest([FromBody] AdminProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        BaseResult result = BaseResult.JsonResult(await _repository.Op_53(model));

        await _helperFunctions.AccessRequestEmail(model);

        return result;
    }

    //GET api/admin/request
    //Get all 'Unreviewed' access requests that can be edited by user
    [HttpGet]
    [Route("request")]
    public async Task<JsonResult> CurrentAccessRequests()
    {
        //model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _repository.Op_54();
        return BaseResult.JsonResult(result);
    }

    //GET api/admin/request-status
    //Get all statuses associated with access requests current user has
    [HttpGet]
    [Route("request-status")]
    public async Task<JsonResult> CurrentAccessRequestStatuses()
    {
        var result = await _repository.Op_66();
        return BaseResult.JsonResult(result);
    }

    //POST api/admin/request-comments
    //Get comments associated with request
    //RequestID required
    [HttpPost]
    [Route("request-comments")]
    public async Task<JsonResult> GetRequestComments([FromBody] AdminProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        return BaseResult.JsonResult(await _repository.Op_67(model));
    }

    //PATCH api/admin/request
    //Edit status of request to approved or rejected
    //IsApproved, SubRequestID required
    [HttpPatch]
    [Route("request")]
    public async Task<JsonResult> EditAccessRequest([FromBody] AdminProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        return BaseResult.JsonResult(await _repository.Op_55(model));
    }


    //PUT api/admin/request/approve-role
    //Checks if role can be approved then grants to user
    //Requires SubRequestID and RoleArgs
    [HttpPut]
    [Route("request/approve-role")]
    public async Task<JsonResult> ApproveRole([FromBody] AdminProcedure model)
    {
        var result = await _repository.Op_71(model);
        _cache.Remove($"endpoint_perms:{model.EmployeeIDInsert}");
        return BaseResult.JsonResult(result);
    }

    //POST api/admin/grantable-moduleroles
    //Get module based roles with check that employee can grant them
    //Department is needed, Module, Role, and RoleID optional
    [HttpPost]
    [Route("grantable-moduleroles")]
    public async Task<JsonResult> GetGrantableModuleRoles([FromBody] AdminProcedure model)
    {
        model.EmployeeID = HttpContext.Items[@"EmployeeID"].ToString();
        return BaseResult.JsonResult(await _repository.Op_72(model));
    }

    #endregion

    #region Users
    //POST api/admin/user/attribute
    //Get User Attribute 
    //no required parameters
    [HttpPost]
    [Route("user/attribute")]
    public async Task<JsonResult> GetUserAttributes([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_28(model));
    }

    //PUT api/admin/user/attribute
    //Link user to Attribute
    //(EmployeeID) and (AttributeID or AttributeTypeID or (Attribute,AttributeType)) or AttributeArgs
    [HttpPut]
    [Route("user/attribute")]
    public async Task<JsonResult> LinkUserAttribute([FromBody] AdminProcedure model)
    {
        var result = await _repository.Op_26(model);
        _cache.Remove($"endpoint_perms:{model.EmployeeIDInsert}");
        return BaseResult.JsonResult(result);
    }

    //POST api/admin/user/unlinked-attributes
    //Gets unlinked-attributes for a user
    //EmployeeID is required
    [HttpPost]
    [Route("user/unlinked-attributes")]
    public async Task<JsonResult> GetUnlinkedUserAttributes([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_70(model));
    }

    //POST api/admin/user/unassigned-roles
    //Get User unassigned roles
    //EmployeeID and EmployeeIDInsert needed
    [HttpPost]
    [Route("user/unassigned-roles")]
    public async Task<JsonResult> GetUserUnassignedRoles([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_59(model));
    }

    //POST api/admin/user/unassigned-permissions
    //Get User unassigned permissions
    //EmployeeID and EmployeeIDInsert needed
    [HttpPost]
    [Route("user/unassigned-permissions")]
    public async Task<JsonResult> GetUserUnassignedPermissions([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_60(model));
    }

    #region Current User

    //GET api/admin/user/me 
    //Get current user info; creates user if not in the Admin_User table     
    [HttpGet]
    [Route("user/me")]
    public async Task<JsonResult> CurrentUserInfo()
    {

        string? employeeID = HttpContext.Items[@"EmployeeID"].ToString();
        var result = await _helperFunctions.GetUserDetails(employeeID);

        return BaseResult.JsonResult(result);
    }

    //GET api/admin/user/me/role
    //Get current user role info
    [HttpGet]
    [Route("user/me/role")]
    public async Task<JsonResult> CurrentUserRoles()
    {
        var result = await _repository.Op_34();
        return BaseResult.JsonResult(result);
    }

    //POST api/admin/user/me/role
    //Get current user role info
    [HttpPost]
    [Route("user/me/role")]
    public async Task<JsonResult> CurrentUserRolesSpecify([FromBody] AdminProcedure model)
    {
        var result = await _repository.Op_34(model);
        return BaseResult.JsonResult(result);
    }

    //GET api/admin/user/me/permission
    //Get current user permissions
    [HttpGet]
    [Route("user/me/permission")]
    public async Task<JsonResult> CurrentUserPermissions()
    {
        return BaseResult.JsonResult(await _repository.Op_56());
    }

    //POST api/admin/user/me/permission
    //Get current user permissions
    //Permission optional
    [HttpPost]
    [Route("user/me/permission")]
    public async Task<JsonResult> CurrentUserPermissionsSpecify([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_56(model));
    }

    //GET api/admin/user/me/module
    //Get current user modules 
    [HttpGet]
    [Route("user/me/module")]
    public async Task<JsonResult> CurrentUserModules()
    {
        var result = await _repository.Op_57();


        return BaseResult.JsonResult(result);
    }

    //POST api/admin/user/me/module
    //Get current user modules 
    [HttpPost]
    [Route("user/me/module")]
    public async Task<JsonResult> CurrentUserModulesSpecify([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_57(model));
    }

    //GET api/admin/user/me/attribute
    //Get current user attributes 
    [HttpGet]
    [Route("user/me/attribute")]
    public async Task<JsonResult> CurrentUserAttributes()
    {
        return BaseResult.JsonResult(await _repository.Op_75());
    }

    //POST api/admin/user/me/attribute
    //Get current user attributes 
    [HttpPost]
    [Route("user/me/attribute")]
    public async Task<JsonResult> CurrentUserAttributesSpecify([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_75(model));
    }

    //DELETE api/admin/user/attribute
    //Delete user attribute
    //Required: EmployeeIDInsert, LinkID
    [HttpDelete]
    [Route("user/attribute")]
    public async Task<JsonResult> DeleteUserAttribute([FromBody] AdminProcedure model)
    {
        var result = await _repository.Op_27(model);
        _cache.Remove($"endpoint_perms:{model.EmployeeIDInsert}");
        return BaseResult.JsonResult(result);
    }

    //GET api/admin/user/me/endpoint
    //Get current user endpoints
    [HttpGet]
    [Route("user/me/endpoint")]
    public async Task<JsonResult> CurrentUserEndpoints()
    {
        return BaseResult.JsonResult(await _repository.Op_76());
    }

    #endregion

    #region User Roles

    //POST api/admin/user/role
    //Get specific user role info
    //Requires EmployeeID
    [HttpPost]
    [Route("user/role")]
    public async Task<JsonResult> GetUserRoles([FromBody] AdminProcedure model)
    {
        var result = await _repository.Op_34(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/admin/user/role
    //Adds specific role to specific user
    //Requires EmployeeIDInsert and Role/RoleID
    [HttpPut]
    [Route("user/role")]
    public async Task<JsonResult> AddUserRole([FromBody] AdminProcedure model)
    {
        var result = await _repository.Op_32(model);
        _cache.Remove($"endpoint_perms:{model.EmployeeIDInsert}");
        return BaseResult.JsonResult(result);
    }

    //DELETE api/admin/user/role
    //Deletes specific role from specific user
    //Requires EmployeeIDInsert and Role/RoleID
    [HttpDelete]
    [Route("user/role")]
    public async Task<JsonResult> DeleteUserRole([FromBody] AdminProcedure model)
    {
        var result = await _repository.Op_33(model);
        _cache.Remove($"endpoint_perms:{model.EmployeeIDInsert}");
        return BaseResult.JsonResult(result);
    }


    #endregion

    #region User Permissions

    //PUT api/admin/user/permission
    //Adds Direct Permission to User
    //EmployeeIDInsert and Permission/PermissionID are required
    [HttpPut]
    [Route("user/permission")]
    public async Task<JsonResult> AddUserPermission([FromBody] AdminProcedure model)
    {
        var result = await _repository.Op_29(model);
        _cache.Remove($"endpoint_perms:{model.EmployeeIDInsert}");
        return BaseResult.JsonResult(result);
    }

    //DELETE api/admin/user/permission
    //Deletes Direct Permission from User
    //EmployeeIDInsert and Permission/PermissionID are required
    [HttpDelete]
    [Route("user/permission")]
    public async Task<JsonResult> DeleteUserPermission([FromBody] AdminProcedure model)
    {
        var result = await _repository.Op_30(model);
        _cache.Remove($"endpoint_perms:{model.EmployeeIDInsert}");
        return BaseResult.JsonResult(result);
    }

    //POST api/admin/user/permission
    //Get Permissions of User
    //EmployeeIDInsert and Permission/PermissionID are required; Origin is optional
    [HttpPost]
    [Route("user/permission")]
    public async Task<JsonResult> GetUserPermissions([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_31(model));
    }

    //POST api/admin/user/inherited-permission
    //Get Inherited Permissions of User
    //EmployeeIDInsert and Permission/PermissionID are required; Origin is optional
    [HttpPost]
    [Route("user/inherited-permission")]
    public async Task<JsonResult> GetUserInheritedPermissions([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_73(model));
    }

    #endregion

    //GET api/admin/user/impersonate
    //Returns boolean result.canImpersonate
    //No Requirements
    [HttpGet]
    [Route("user/impersonate")]
    public async Task<JsonResult> CanImpersonate()
    {
        bool canImpersonate = await _identityService.ImpersonateCheck(_httpContextAccessor.HttpContext, _repository);

        AdminResult result = new AdminResult();
        result.canImpersonate = canImpersonate;

        return BaseResult.JsonResult(result);
    }

    //GET api/admin/user/impersonate-end
    //Ends impersonation
    //No Requirements
    [HttpGet]
    [Route("user/impersonate-end")]
    public async Task<JsonResult> EndImpersonation()
    {
        await _identityService.EndImpersonation(_httpContextAccessor.HttpContext);
        return BaseResult.JsonResult(new AdminResult());
    }

    //GET api/admin/user/clear-cache
    //Clears cache from ICacheProvider
    //No Requirements
    [HttpGet]
    [Route("clear-cache")]
    public JsonResult ClearCache()
    {
        _cache.Clear();
        return BaseResult.JsonResult(new AdminResult());
    }

    //PATCH api/admin/user
    //Edits User (Active flag for now)
    //EmployeeIDInsert and Active are required
    [HttpPatch]
    [Route("user")]
    public async Task<JsonResult> UpdateUser([FromBody] AdminProcedure model)
    {
        var result = await _repository.Op_50(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/admin/user
    //Gets Users
    //EmployeeID and Active (Default true) are all optional
    [HttpPost]
    [Route("user")]
    public async Task<JsonResult> GetUsers([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_25(model));
    }

    #endregion

    #region Roles

    //PUT api/admin/role
    //Adds new Role
    //Requires Role and Description
    [HttpPut]
    [Route("role")]
    public async Task<JsonResult> CreateRole([FromBody] AdminProcedure model)
    {
        var result = await _repository.Op_15(model);
        return BaseResult.JsonResult(result);
    }

    //PATCH api/admin/role
    //Edits role
    //Role, RoleID, and Description are required
    [HttpPatch]
    [Route("role")]
    public async Task<JsonResult> EditRole([FromBody] AdminProcedure model)
    {
        var result = await _repository.Op_17(model);
        return BaseResult.JsonResult(result);
    }

    //DELETE api/admin/role
    //Deletes role
    //Role or RoleID is required
    [HttpDelete]
    [Route("role")]
    public async Task<JsonResult> DeleteRole([FromBody] AdminProcedure model)
    {
        var result = await _repository.Op_16(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/admin/role
    //Get roles
    //Role/RoleID is optional
    [HttpPost]
    [Route("role")]
    public async Task<JsonResult> GetRoles([FromBody] AdminProcedure model)
    {
        var result = await _repository.Op_18(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/admin/moduleroles
    //Get module based roles
    //Module and Department is needed
    [HttpPost]
    [Route("moduleroles")]
    public async Task<JsonResult> GetModuleRoles([FromBody] AdminProcedure model)
    {
        var result = await _repository.Op_58(model);
        return BaseResult.JsonResult(result);
    }

    //POST api/admin/role/unlinked-attributes
    //Gets unlined-attributes for a role
    //RoleID is required
    [HttpPost]
    [Route("role/unlinked-attributes")]
    public async Task<JsonResult> GetUnlinkedRoleAttributes([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_69(model));
    }

    //PUT api/admin/role/attribute
    //Link role to Attribute
    //(RoleID or Role) and (AttributeID or AttributeTypeID or (Attribute,AttributeType)) or AttributeArgs
    [HttpPut]
    [Route("role/attribute")]
    public async Task<JsonResult> LinkRoleAttribute([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_19(model));
    }

    //POST api/admin/role/attribute
    //Get role Attribute 
    //EmployeeID, AttributeID, Attribute, AttributeTypeID, Attribute, AttributeType (All optional)
    [HttpPost]
    [Route("role/attribute")]
    public async Task<JsonResult> GetRoleAttributes([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_21(model));
    }

    #region Role Permissions

    //PUT api/admin/role/permission
    //Adds Permission to Role
    //Requires RoleID/Role and PermissionID/Permission 
    [HttpPut]
    [Route("role/permission")]
    public async Task<JsonResult> AddRolePermission([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_22(model));
    }

    //DELETE api/admin/role/permission
    //Deletes Permission from Role
    //Requires RoleID/Role and PermissionID/Permission 
    [HttpDelete]
    [Route("role/permission")]
    public async Task<JsonResult> DeleteRolePermission([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_23(model));
    }

    //POST api/admin/role/permission
    //Gets Permissions in Role
    //RoleID, Role, PermissionID, Permission are all optional
    [HttpPost]
    [Route("role/permission")]
    public async Task<JsonResult> GetRolePermissions([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_24(model));
    }

    //POST api/admin/role/unlinked-permission
    //Gets unlinked-permission for a Role
    //EmployeeID and RoleID are needed
    [HttpPost]
    [Route("role/unlinked-permission")]
    public async Task<JsonResult> GetRoleUnlinkedPermissions([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_61(model));
    }

    #endregion

    #endregion

    #region Endpoints

    //PUT api/admin/endpoint
    //Adds Endpoint
    //Endpoint and HTTPVerb are required
    [HttpPut]
    [Route("endpoint")]
    public async Task<JsonResult> AddEndpoint([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_38(model));
    }

    //DELETE api/admin/endpoint
    //Deletes Endpoint
    //Endpoint and HTTPVerb or EndpointID are required
    [HttpDelete]
    [Route("endpoint")]
    public async Task<JsonResult> DeleteEndpoint([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_39(model));
    }

    //POST api/admin/endpoint
    //Gets Endpoint
    //Endpoint and HTTPVerb or EndpointID (All optional)
    [HttpPost]
    [Route("endpoint")]
    public async Task<JsonResult> GetEndpoints([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_40(model));
    }

    //PATCH api/admin/endpoint
    //Edit Endpoint
    //Endpoint, HTTPVerb, and EndpointID are required
    [HttpPatch]
    [Route("endpoint")]
    public async Task<JsonResult> EditEndpoint([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_41(model));
    }

    #region Endpoint Attributes

    //PUT api/admin/endpoint/attribute
    //Adds Endpoint Attribute
    //(Endpoint and HTTPVerb or EndpointID) and (Attribute and AttributeType or AttributeID and AttributeTypeID) are required
    [HttpPut]
    [Route("endpoint/attribute")]
    public async Task<JsonResult> AddEndpointAttribute([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_42(model));
    }

    //POST api/admin/endpoint/attribute
    //Adds Endpoint Attribute
    //(Endpoint, HTTPVerb, EndpointID, Attribute, AttributeID, AttributeType, AttributeTypeID (All Optional)
    [HttpPost]
    [Route("endpoint/attribute")]
    public async Task<JsonResult> GetEndpointAttribute([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_44(model));
    }

    //DELETE api/admin/endpoint/attribute
    //Deletes attribute from Endpoint
    //AttributeID, AttributeTypeID and Endpoint and HTTPVerb or EndpointID are required
    [HttpDelete]
    [Route("endpoint/attribute")]
    public async Task<JsonResult> DeleteEndpointAttribute([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_43(model));
    }

    //POST api/admin/endpoint/unlinked-attributes
    //Gets unlined-attributes for aan Endpoint
    //EndpointID is required
    [HttpPost]
    [Route("endpoint/unlinked-attributes")]
    public async Task<JsonResult> GetEPUnlinkedAttributes([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_65(model));
    }

    #endregion

    #region  Endpoint Permissions

    //PUT api/admin/endpoint/permission
    //Adds Permission to Endpoint
    //Permission/PermissionID and Endpoint and HTTPVerb or EndpointID are required
    [HttpPut]
    [Route("endpoint/permission")]
    public async Task<JsonResult> AddEndpointPermission([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_45(model));
    }

    //DELETE api/admin/endpoint/permission
    //Deletes Permission from Endpoint
    //Permission/PermissionID and Endpoint and HTTPVerb or EndpointID are required
    [HttpDelete]
    [Route("endpoint/permission")]
    public async Task<JsonResult> DeleteEndpointPermission([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_46(model));
    }

    //POST api/admin/endpoint/permission
    //Gets Permissions from Endpoints
    //Permission, PermissionID, Endpoint, HTTPVerb, EndpointID are all optional
    [HttpPost]
    [Route("endpoint/permission")]
    public async Task<JsonResult> GetEndpointPermissions([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_47(model));
    }

    //POST api/admin/endpoint/unlinked-permissions
    //Gets unlinked-permissions for aan Endpoint
    //EndpointID is required
    [HttpPost]
    [Route("endpoint/unlinked-permissions")]
    public async Task<JsonResult> GetEPUnlinkedPermissions([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_64(model));
    }

    #endregion

    #endregion

    #region Permissions

    //PUT api/admin/permission
    //Adds Permission
    //Permission and Description are required
    //ParentPermission/ParentPermissionID are optional
    [HttpPut]
    [Route("permission")]
    public async Task<JsonResult> AddPermission([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_05(model));
    }

    //DELETE api/admin/permission
    //Deletes Permission
    //Permission/PermissionID are required
    [HttpDelete]
    [Route("permission")]
    public async Task<JsonResult> DeletePermission([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_06(model));
    }

    //PATCH api/admin/permission
    //Edits Permission Name
    //Permission, PermissionID, and Description are required
    [HttpPatch]
    [Route("permission")]
    public async Task<JsonResult> EditPermission([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_07(model));
    }

    //POST api/admin/permission
    //Gets all (or specified) active permissions that the user can manage
    //EmployeeID is required and Permission or PermissionID (Both optional)
    [HttpPost]
    [Route("permission")]
    public async Task<JsonResult> GetPermission([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_08(model));
    }

    //POST api/admin/modulepermissions
    //Get module based permissions
    //Department is needed. Module is optional
    [HttpPost]
    [Route("modulepermissions")]
    public async Task<JsonResult> GetModulePermissions([FromBody] AdminProcedure model)
    {
        var result = await _repository.Op_63(model);
        return BaseResult.JsonResult(result);
    }

    //PUT api/admin/permission/attribute
    //Link Permission to Attribute
    //(PermissionID or Permission) and (AttributeID or AttributeTypeID or (Attribute,AttributeType))
    [HttpPut]
    [Route("permission/attribute")]
    public async Task<JsonResult> LinkPermissionAttribute([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_09(model));
    }

    //POST api/admin/permission/attribute
    //Get permission Attribute 
    //EmployeeID, AttributeID, Attribute, AttributeTypeID, Attribute, AttributeType (All optional)
    [HttpPost]
    [Route("permission/attribute")]
    public async Task<JsonResult> GetPermissionAttributes([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_11(model));
    }

    //DELETE api/admin/permission/attribute
    //Deletes attribute from permission
    //AttributeID, AttributeTypeID and permission  or permissionID are required
    [HttpDelete]
    [Route("permission/attribute")]
    public async Task<JsonResult> DeletePermissionAttribute([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_10(model));
    }

    //POST api/admin/permission/unlinked-attributes
    //Gets unlined-attributes for a Permission
    //PermissionID is required
    [HttpPost]
    [Route("permission/unlinked-attributes")]
    public async Task<JsonResult> GetUnlinkedPermissionAttributes([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_68(model));
    }

    #region Permission Children

    //PUT api/admin/permission/child
    //Adds Permission Child
    //Permission/PermissionID and ParentPermission/ParentPermissionID  are required
    [HttpPut]
    [Route("permission/child")]
    public async Task<JsonResult> AddPermissionChild([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_12(model));
    }

    //DELETE api/admin/permission/child
    //Deletes Permission Child; promotes any children of child to child's parent(s)
    //Permission/PermissionID and ParentPermission/ParentPermissionID are required
    [HttpDelete]
    [Route("permission/child")]
    public async Task<JsonResult> DeletePermissionChild([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_13(model));
    }

    //POST api/admin/permission/child
    //Gets all child permissions of parent permission (Or specific child permission)
    //Permission/PermissionID, ParentPermission/ParentPermissionID (All optional)
    [HttpPost]
    [Route("permission/child")]
    public async Task<JsonResult> GetPermissionChild([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_14(model));
    }

    //POST api/admin/permission/unassigned-child
    //Gets all unassigned child permissions of parent permission
    //ParentPermission and EmployeeID required
    [HttpPost]
    [Route("permission/unassigned-child")]
    public async Task<JsonResult> GetUnassignedPermissionChild([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_74(model));
    }

    //GET api/admin/vendor/unassigned-workgroup
    //Get all 'Unassigned' work groups that arent linked to a vendor
    [HttpGet]
    [Route("vendor/unassigned-workgroup")]
    public async Task<JsonResult> GetUnassignedWorkGroup()
    {
        var result = await _repository.Op_77();
        return BaseResult.JsonResult(result);
    }

    //POST api/admin/vendor/workgroup
    //Get all work groups associated with the vendor
    //AttributeID required
    [HttpPost]
    [Route("vendor/workgroup")]
    public async Task<JsonResult> GetVendorWorkGroup([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_78(model));
    }

    //DELETE api/admin/vendor/workgroup
    //Deletes Work Group from Vendor
    //UniqueIDNum required
    [HttpDelete]
    [Route("vendor/workgroup")]
    public async Task<JsonResult> DeleteWorkGroup([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_79(model));
    }

    //PUT api/admin/vendor/workgroup
    //Add work groups to the linked vendor
    //RoleID and PermissionArgs required
    [HttpPut]
    [Route("vendor/workgroup")]
    public async Task<JsonResult> AddWorkGroup([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_80(model));
    }

    //GET api/admin/ring-fence
    //Get all Ring Fence Users
    [HttpGet]
    [Route("ring-fence")]
    public async Task<JsonResult> GetRingFenceUsers()
    {
        var result = await _repository.Op_81();
        return BaseResult.JsonResult(result);
    }

    //PUT api/admin/ring-fence
    //Adds Ring Fence User
    //EmployeeIDInsert required
    [HttpPut]
    [Route("ring-fence")]
    public async Task<JsonResult> AddRingFenceUser([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_82(model));
    }

    //DELETE api/admin/ring-fence
    //Deletes Ring Fence User
    //UniqueID required
    [HttpDelete]
    [Route("ring-fence")]
    public async Task<JsonResult> DeleteRingFenceUser([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await _repository.Op_83(model));
    }

    //PUT api/admin/alternate-email
    //Adds Alternate Email for user, updates if already exists
    //EmployeeIDInsert, Email required
    [HttpPut]
    [Route("alternate-email")]
    public async Task<JsonResult> AddAlternateEmail([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await this._repository.Op_84(model));
    }

    //POST api/admin/alternate-email
    //Fetches alternate emails, specified by optional EmployeeIDInsert
    //EmployeeIDInsert optional
    [HttpPost]
    [Route("alternate-email")]
    public async Task<JsonResult> GetAlternateEmails([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await this._repository.Op_85(model));
    }

    //DELETE api/admin/alternate-email
    //Deletes Alternate Email record
    //EmployeeIDInsert required
    [HttpDelete]
    [Route("alternate-email")]
    public async Task<JsonResult> DeleteAlternateEmail([FromBody] AdminProcedure model)
    {
        return BaseResult.JsonResult(await this._repository.Op_86(model));
    }


    #endregion


    #endregion

}