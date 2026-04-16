/****** Object:  View [stng].[VV_Admin_UserRole]    Script Date: 10/21/2024 12:32:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE view [stng].[VV_Admin_UserRole] as
select a.EmployeeID, b.RoleID, c.[Role]
from stng.Admin_User as a
inner join stng.Admin_UserRole as b on a.EmployeeID = b.EmployeeID and b.Deleted = 0
inner join stng.Admin_Role as c on b.RoleID = c.UniqueID and c.Deleted = 0
where a.Active = 1
GO


