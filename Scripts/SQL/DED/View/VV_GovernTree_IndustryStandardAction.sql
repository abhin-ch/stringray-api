/****** Object:  View [stng].[VV_GovernTree_IndustryStandardAction]    Script Date: 5/27/2024 10:54:47 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







/****** Script for SelectTopNRows command from SSMS  ******/
 CREATE view  [stng].[VV_GovernTree_IndustryStandardAction] as
 
 SELECT  a.[UniqueID]
      ,[ActionTitle]
      ,[IndustryStandardSectionID]
      ,[ActionOwner]
      ,[TCD]
   

      ,[ActionStatus]
	  ,b.IndustryStatus as ActionStatusC
	  ,a.[IntID]
	  ,a.[LUB]
	  ,a.[LUD]
  
  FROM [stng].[GovernTree_IndustryStandardAction] as a
  LEFT JOIN  [stng].[GovernTree_IndustryStatus] as b
  ON a.[ActionStatus] = b.[UniqueID]


  where Active=1

GO


