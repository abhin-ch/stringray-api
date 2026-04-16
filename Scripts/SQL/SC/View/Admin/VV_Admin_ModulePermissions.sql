/****** Object:  View [stng].[VV_Admin_ModulePermissions]    Script Date: 10/21/2024 12:45:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE view [stng].[VV_Admin_ModulePermissions] as
select a.PermissionID, b.Permission, b.PermissionDescription, c.AttributeID as ModuleAttributeID, c.Attribute as Module, e.AttributeID as DeptAttributeID, e.Attribute as Department,
concat(b.Permission,'||',c.Attribute,'||',e.Attribute) as UniqueID
from stng.Admin_PermissionAttribute as a 
inner join stng.Admin_Permission as b on a.PermissionID = b.UniqueID and b.Deleted = 0
inner join stng.VV_Admin_Attribute as c on a.AttributeID = C.AttributeID and C.AttributeType = 'Module'
left join stng.Admin_DepartmentModule as d on C.AttributeID = d.AttributeModID
left join stng.VV_Admin_Attribute as e on d.AttributeDeptID = e.AttributeID and e.AttributeType = 'Department'
where a.Deleted = 0

union 

select a.PermissionID, b.Permission, b.PermissionDescription, null as ModuleAttributeID, null as Module, c.AttributeID as DeptAttributeID, c.Attribute as Department,
concat(b.Permission,'||',c.Attribute) as UniqueID
from stng.Admin_PermissionAttribute as a 
inner join stng.Admin_Permission as b on a.PermissionID = b.UniqueID and b.Deleted = 0
inner join stng.VV_Admin_Attribute as c on a.AttributeID = C.AttributeID and C.AttributeType = 'Department'
where a.Deleted = 0

GO


