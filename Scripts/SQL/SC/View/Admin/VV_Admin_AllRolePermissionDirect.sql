/****** Object:  View [stng].[VV_Admin_AllRolePermissionDirect]    Script Date: 10/21/2024 12:37:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE view [stng].[VV_Admin_AllRolePermissionDirect] as
with directroles as
(
	select UniqueID as RoleID, [Role]
	from stng.Admin_Role
	where Deleted = 0
),
rolepermissionsdirect as
(
	select a.RoleID, a.[Role], b.PermissionID,c.PermissionDescription, c.Permission
	from directroles as a 
	inner join stng.Admin_RolePermission as b on a.RoleID = b.RoleID
	inner join stng.Admin_Permission as c on b.PermissionID = c.UniqueID and c.Deleted = 0
	where b.Deleted = 0
)

select RoleID, [Role], PermissionID, PermissionDescription, Permission, concat(Role,'||',Permission) as UniqueID
from rolepermissionsdirect
GO


