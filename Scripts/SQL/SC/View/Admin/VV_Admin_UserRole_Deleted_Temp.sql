/****** Object:  View [stng].[VV_Admin_UserRole_Deleted]    Script Date: 10/21/2024 12:33:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





create view [stng].[VV_Admin_UserRole_Deleted] as
select a.EmployeeID, b.RoleID, c.[Role]
from stng.Admin_User as a
inner join stng.Admin_UserRole as b on a.EmployeeID = b.EmployeeID
inner join stng.Admin_Role as c on b.RoleID = c.UniqueID and c.Deleted = 0
where b.Deleted = 1
GO


