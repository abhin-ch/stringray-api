/****** Object:  View [stng].[VV_Admin_Role_Manage]    Script Date: 10/21/2024 12:49:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE view [stng].[VV_Admin_Role_Manage] as
with rolefullcount as
(
	select RoleID, count(PermissionID) as countPermission
	from stng.VV_Admin_AllRolePermissionDirect
	group by RoleID
),
roleactualcount as
(
	select a.RoleID, b.EmployeeID, count(a.PermissionID) as countPermission
	from stng.VV_Admin_AllRolePermissionDirect as a
	inner join stng.VV_Admin_ActualUserPermission_Manage as b on a.PermissionID = b.PermissionID
	group by a.RoleID, b.EmployeeID
)


select b.EmployeeID, a.RoleID, c.Role
from rolefullcount as a
inner join roleactualcount as b on a.RoleID = b.RoleID
inner join stng.VV_Admin_AllRole as c on a.RoleID = c.UniqueID
where a.countPermission = b.countPermission
GO


