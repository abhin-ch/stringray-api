/****** Object:  View [stng].[VV_Admin_ModuleRoles]    Script Date: 10/21/2024 12:47:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE view [stng].[VV_Admin_ModuleRoles] as
select a.RoleID, b.Role, b.RoleDescription, c.AttributeID as ModuleAttributeID, c.Attribute as Module, e.AttributeID as DeptAttributeID, e.Attribute as Department,
concat(b.Role,'||',c.Attribute,'||',e.Attribute) as UniqueID
from stng.Admin_RoleAttribute as a 
inner join stng.Admin_Role as b on a.roleID = b.UniqueID and b.Deleted = 0
inner join stng.VV_Admin_Attribute as c on a.AttributeID = C.AttributeID and C.AttributeType = 'Module'
left join stng.Admin_DepartmentModule as d on C.AttributeID = d.AttributeModID
left join stng.VV_Admin_Attribute as e on d.AttributeDeptID = e.AttributeID and e.AttributeType = 'Department'
where a.Deleted = 0
GO


