/****** Object:  View [stng].[VV_GovernTree_IndustryStandardFull]    Script Date: 4/17/2024 8:30:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




/****** Script for SelectTopNRows command from SSMS  ******/

CREATE view [stng].[VV_GovernTree_IndustryStandardFull] as 

with  a as(
Select  [IndustryStandardSectionID],TC,[TSC] from
(
SELECT 
      [PersonnelType]
      ,[IndustryStandardSectionID]
 ,STRING_AGG(PersonnelC, ', ') as PersonnelC
  
  FROM [stng].[VV_GovernTree_IndustryStandardSectionPersonnel] group by PersonnelType, IndustryStandardSectionID
  ) AS SourceTable 
pivot
(     MAX([PersonnelC]) FOR [PersonnelType] in([TC],[TSC])) AS PivotTable)
select b.[IndustryStandardID]
   
      ,b.[Org]
      ,b.[OrgShort]
      ,b.[IndustryStandard]
      ,b.[IndustryStandardTitle]
      ,b.[IndustryStandardSection]
      ,b.[IndustryStandardSectionTitle]
      ,b.[IndustryStandardSectionID]
    

, Cast(a.TC as varchar(50)) as TC ,Cast(a.TSC as varchar(50)) as TSC 
from
			stng.VV_GovernTree_IndustryStandardSection b left join 
			a on a.[IndustryStandardSectionID]=b.[IndustryStandardSectionID]


GO


