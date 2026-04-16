/****** Object:  View [stng].[VV_GovernTree_IndustryStandardSectionPersonnelPivot]    Script Date: 4/17/2024 8:32:15 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/

CREATE view [stng].[VV_GovernTree_IndustryStandardSectionPersonnelPivot] as 


Select  UniqueId,[IndustryStandardSectionID],TC,[TSC] from
(
SELECT 
      [PersonnelType],UniqueID
      ,[IndustryStandardSectionID]
 , PersonnelC
  
  FROM [stng].[VV_GovernTree_IndustryStandardSectionPersonnel]
  ) AS SourceTable 
pivot
(     MAX([PersonnelC]) FOR [PersonnelType] in([TC],[TSC])) AS PivotTable
GO


