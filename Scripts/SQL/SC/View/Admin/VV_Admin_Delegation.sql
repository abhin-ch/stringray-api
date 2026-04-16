/****** Object:  View [stng].[VV_Admin_Delegation]    Script Date: 10/21/2024 12:23:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE view [stng].[VV_Admin_Delegation] as
SELECT [UniqueID]
			  ,[Delegator]
			  ,[Delegatee]
			  , (b.FirstName + ' ' + b.LastName) as [DelegateeName]
			  --,[Description]
			  ,a.[Active]
			  ,a.Indefinite
			  ,[ExpireDate]
			  ,[CreatedBy]
			  ,a.[CreatedDate]
			  ,CASE
			
				WHEN Indefinite = 1 and a.Active = 1 THEN 'Active'
				WHEN Indefinite = 1 and a.Active = 0 THEN 'Disabled'
				WHEN a.[Active] = 1 and ExpireDate >= stng.GetDate() THEN 'Active' 
				WHEN a.[Active] = 1 and ExpireDate <= stng.GetDate() THEN 'Expired' 
				WHEN a.[Active] = 0 and ExpireDate >= stng.GetDate() THEN 'Disabled'
				WHEN a.[Active] = 0 and ExpireDate <= stng.GetDate() THEN 'Expired'
			
			  END  AS [Status]

			  FROM (SELECT * FROM [stng].[Admin_Delegation] WHERE  Deleted=0) as a
			  LEFT JOIN stng.Admin_User as b on b.EmployeeID = a.Delegatee
GO


