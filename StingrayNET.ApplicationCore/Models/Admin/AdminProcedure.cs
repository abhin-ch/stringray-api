using System.Collections.Generic;
using StingrayNET.ApplicationCore.Specifications;
using StingrayNET.ApplicationCore.Abstractions;

namespace StingrayNET.ApplicationCore.Models.Admin;
public class AdminProcedure : BaseProcedure, System.ICloneable
{
    public string? Attribute { get; set; }
    public string? UniqueID { get; set; }
    public string? AttributeID { get; set; }
    public string? AttributeTypeID { get; set; }
    public string? AttributeType { get; set; }
    public bool? Supersedence { get; set; }
    public string? Endpoint { get; set; }
    public string? EndpointID { get; set; }
    public string? HTTPVerb { get; set; }
    public string? Permission { get; set; }
    public string? PermissionID { get; set; }
    public string? ParentPermission { get; set; }
    public string? ParentPermissionID { get; set; }
    public long? UniqueIDNum { get; set; }
    public string? Role { get; set; }
    public string? RoleID { get; set; }
    public string? Description { get; set; }
    public string? UserName { get; set; }
    public string? FirstName { get; set; }
    public string? LastName { get; set; }
    public string? Email { get; set; }
    public string? Title { get; set; }
    public string? LANID { get; set; }
    public string? EmployeeIDInsert { get; set; }
    public bool? Active { get; set; }
    public string? Module { get; set; }
    public string? Department { get; set; }
    public bool? IsMimicRequest { get; set; }
    public string? MimicOfEmployeeID { get; set; }
    public string? RequestID { get; set; }
    public string? SubRequestID { get; set; }
    public bool? IsApproved { get; set; }
    public string? ModuleID { get; set; }
    public string? LinkID { get; set; }

    [StoredProcIgnore]
    public List<AttributeArg>? AttributeArgs { get; set; }

    [StoredProcIgnore]
    public List<PermissionArg>? PermissionArgs { get; set; }

    [StoredProcIgnore]
    public List<RoleArg>? RoleArgs { get; set; }

    public string? Origin { get; set; }

    public object Clone()
    {
        return new AdminProcedure
        {
            Attribute = this.Attribute,
            UniqueID = this.UniqueID,
            AttributeID = this.AttributeID,
            AttributeTypeID = this.AttributeTypeID,
            AttributeType = this.AttributeType,
            Supersedence = this.Supersedence,
            Endpoint = this.Endpoint,
            EndpointID = this.EndpointID,
            HTTPVerb = this.HTTPVerb,
            Permission = this.Permission,
            PermissionID = this.PermissionID,
            ParentPermission = this.ParentPermission,
            ParentPermissionID = this.ParentPermissionID,
            UniqueIDNum = this.UniqueIDNum,
            Role = this.Role,
            RoleID = this.RoleID,
            Description = this.Description,
            UserName = this.UserName,
            FirstName = this.FirstName,
            LastName = this.LastName,
            Email = this.Email,
            Title = this.Title,
            LANID = this.LANID,
            EmployeeIDInsert = this.EmployeeIDInsert,
            Active = this.Active,
            Module = this.Module,
            Department = this.Department,
            IsMimicRequest = this.IsMimicRequest,
            MimicOfEmployeeID = this.MimicOfEmployeeID,
            RequestID = this.RequestID,
            SubRequestID = this.SubRequestID,
            IsApproved = this.IsApproved,
            ModuleID = this.ModuleID,
            LinkID = this.LinkID,
            AttributeArgs = this.AttributeArgs,
            PermissionArgs = this.PermissionArgs,
            RoleArgs = this.RoleArgs,
            Origin = this.Attribute,
        };
    }

}