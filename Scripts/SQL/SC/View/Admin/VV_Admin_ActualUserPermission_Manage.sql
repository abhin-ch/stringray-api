/****** Object:  View [stng].[VV_Admin_ActualUserPermission_Manage]    Script Date: 10/22/2024 10:55:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE view [stng].[VV_Admin_ActualUserPermission_Manage] as
with actualuserpermission_manage as 
(
	select distinct EmployeeID, PermissionID, Permission, PermissionDescription
	from stng.VV_Admin_ActualUserPermission
	where (Origin = 'Inherited Permission' or Origin = 'Role, Inherited Permission') or Permission = 'SysAdmin'
)

select EmployeeID, PermissionID, Permission, PermissionDescription, concat(EmployeeID,'||',Permission) as UniqueID from actualuserpermission_manage
GO


