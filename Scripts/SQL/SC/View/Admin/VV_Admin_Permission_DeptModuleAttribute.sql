/****** Object:  View [stng].[VV_Admin_Permission_DeptModuleAttribute]    Script Date: 10/21/2024 12:48:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE view [stng].[VV_Admin_Permission_DeptModuleAttribute] as
with depts as
(
	select PermissionID, STRING_AGG(Attribute, '; ') as depts
	from stng.VV_Admin_PermissionAttribute
	where AttributeType = 'Department'
	group by PermissionID
),
modules as
(
	select PermissionID, STRING_AGG(Attribute, '; ') as modules
	from stng.VV_Admin_PermissionAttribute
	where AttributeType = 'Module'
	group by PermissionID
)


select distinct a.EmployeeID, a.Permission, a.PermissionID, a.UniqueID, b.depts, c.modules, d.PermissionDescription
from stng.VV_Admin_ActualUserPermission_Manage as a
inner join stng.Admin_Permission as d on a.PermissionID = d.UniqueID
left join depts as b on a.PermissionID = b.PermissionID
left join modules as c on a.[PermissionID] = c.PermissionID;
GO


