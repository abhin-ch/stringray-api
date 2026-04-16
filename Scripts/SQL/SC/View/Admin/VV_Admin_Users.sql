/****** Object:  View [stng].[VV_Admin_Users]    Script Date: 10/21/2024 12:32:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE view [stng].[VV_Admin_Users]
with SCHEMABINDING
as
select 
a.UserID,
a.Username,
a.FirstName,
a.LastName,
a.FullName,
a.Email,
a.Active,
a.LastLogin,
a.CreatedDate,
a.EmployeeID,
a.Title,
a.LANID,
a.Tag,
a.WorkGroup,
concat(a.FirstName,' ', a.LastName) as EmpName
from stng.Admin_User as a
GO


