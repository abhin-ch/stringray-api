/****** Object:  View [stng].[VV_Admin_UserPermissionDirect]    Script Date: 10/21/2024 12:34:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE view [stng].[VV_Admin_UserPermissionDirect] as
select a.EmployeeID, b.PermissionID, c.Permission
from stng.Admin_User as a
inner join stng.Admin_UserPermission as b on a.EmployeeID = b.EmployeeID
inner join stng.Admin_Permission as c on b.PermissionID = c.UniqueID and c.Deleted = 0
where b.Deleted = 0
GO


