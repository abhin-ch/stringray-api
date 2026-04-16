/****** Object:  View [stng].[VV_Admin_AllUserPermission]    Script Date: 10/21/2024 12:24:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO









CREATE view [stng].[VV_Admin_AllUserPermission] as
with directpermissions as 
(
	select EmployeeID, null as RoleID, null as [Role], PermissionID, b.Permission, 'Direct Permission' as Origin, b.PermissionDescription
	from stng.Admin_UserPermission as a
	inner join stng.Admin_Permission as b on a.PermissionID = b.UniqueID and b.Deleted = 0
	where a.Deleted = 0 
),
inheritedpermissions as 
(
	select distinct a.EmployeeID, null as RoleID, null as [Role], b.PermissionID, b.Permission, 'Inherited Permission' as Origin, b.PermissionDescription
	from directpermissions as a
	inner join stng.VV_Admin_AllPermission as b on a.PermissionID = b.[ParentPermissionID] and b.ParentPermissionID <> b.PermissionID
),
directroles as
(
	select a.EmployeeID, a.RoleID, b.[Role]
	from stng.Admin_UserRole as a
	inner join stng.Admin_Role as b on a.RoleID = b.UniqueID and b.Deleted = 0
	where a.Deleted = 0
),
rolepermissionsdirect as
(
	select a.EmployeeID, a.RoleID, a.[Role], b.PermissionID, c.Permission, 'Role, Direct Permission' as Origin, c.PermissionDescription
	from directroles as a 
	inner join stng.Admin_RolePermission as b on a.RoleID = b.RoleID and b.Deleted = 0
	inner join stng.Admin_Permission as c on b.PermissionID = c.UniqueID and c.Deleted = 0
),
rolepermissionsinherited as
(
	select distinct a.EmployeeID, a.RoleID, a.[Role], b.PermissionID, b.Permission, 'Role, Inherited Permission' as Origin, b.PermissionDescription
	from rolepermissionsdirect as a
	inner join stng.VV_Admin_AllPermission as b on a.PermissionID = b.ParentPermissionID
),
unioned as
(
	select EmployeeID, RoleID, [Role], PermissionID, Permission, Origin, PermissionDescription
	from directpermissions
	union
	select EmployeeID, RoleID, [Role], PermissionID, Permission, Origin, PermissionDescription
	from inheritedpermissions
	union
	select EmployeeID, RoleID, [Role], PermissionID, Permission, Origin, PermissionDescription
	from rolepermissionsdirect
	union
	select EmployeeID, RoleID, [Role], PermissionID, Permission, Origin, PermissionDescription
	from rolepermissionsinherited
)

select EmployeeID, RoleID, [Role], PermissionID, Permission, Origin, PermissionDescription
from unioned
GO


