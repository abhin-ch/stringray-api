/****** Object:  View [stng].[VV_Admin_UserView]    Script Date: 11/26/2024 3:29:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER view [stng].[VV_Admin_UserView] as
select  a.[UserID]
      ,a.[Username]
      ,a.[FirstName]
      ,a.[LastName]
      ,a.[FullName]
      ,a.[Email]
      ,a.[Active]
      ,a.[LastLogin]
      ,a.[CreatedDate]
      ,a.[EmployeeID]
      ,a.[Title]
      ,a.[LANID]
      ,a.[WorkGroup]
	  ,case when a.Title = 'External Non-Time Reporter' then 1 else 0 end as Contractor
,concat(a.FirstName,' ', a.LastName) as EmpName
from stng.Admin_User as a
GO


