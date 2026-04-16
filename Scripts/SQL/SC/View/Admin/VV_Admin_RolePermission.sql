/****** Object:  View [stng].[VV_Admin_RolePermission]    Script Date: 10/21/2024 12:52:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create view [stng].[VV_Admin_RolePermission] as
select a.RoleID, a.PermissionID, c.Permission, b.Role 
from stng.Admin_RolePermission as a
inner join stng.Admin_Role as b on a.RoleID = b.UniqueID and b.Deleted = 0
inner join stng.VV_Admin_AllPermission as c on a.PermissionID = c.PermissionID
where a.Deleted = 0
GO


