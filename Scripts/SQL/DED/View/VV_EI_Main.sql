/****** Object:  View [stng].[VV_EI_Main]    Script Date: 1/6/2026 7:57:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







ALTER VIEW [stng].[VV_EI_Main]
AS

with category as (
SELECT [EIID]
      ,string_agg(b.Category, '; ') as Categories
	  FROM [stng].[EI_Category_Map] as a
 inner join stng.EI_Category as b on a.Category = b.UniqueID and b.Deleted = 0
 group by EIID
 ),

 condition as (
SELECT [EIID]
      ,string_agg(b.Condition, '; ') as Conditions
	  FROM [stng].[EI_Condition_Map] as a
 inner join stng.EI_Condition as b on a.Condition = b.UniqueID and b.Deleted = 0
 group by EIID
 ),

 deliverable as (
SELECT [EIID]
      ,string_agg(b.Deliverable, '; ') as Deliverables
	  FROM [stng].[EI_Deliverable_Map] as a
 inner join stng.EI_Deliverable as b on a.Deliverable = b.UniqueID and b.Deleted = 0
 group by EIID
 ),

 organization as (
SELECT [EIID]
      ,string_agg(b.Organization, '; ') as Organizations
	  FROM [stng].[EI_Organization_Map] as a
 inner join stng.EI_Organization as b on a.Organization = b.UniqueID and b.Deleted = 0
 group by EIID
 ),

 review as (
SELECT [EIID]
      ,string_agg(b.Review, '; ') as Reviews
	  FROM [stng].[EI_Review_Map] as a
 inner join stng.EI_Review as b on a.Review = b.UniqueID and b.Deleted = 0
 group by EIID
 )

SELECT DISTINCT  
	  a.[UniqueID]
      ,a.[ID]
      ,a.[InsightTitle]
      ,a.[InsightDetails]
      ,a.[Section]
      ,a.[QualityRating]
      ,a.[Status]
      ,a.[RAD]
      ,a.[RAB]
      ,a.[LUD]
      ,a.[LUB]
	  ,b.[Status] as StatusC
	  ,c.EmpName as [Initiator]
	  ,d.QualityRating as QualityRatingC
	  ,e.[Description] as SectionC
	  ,f.[Description] as DepartmentC
	  ,g.Categories as QualityCategory
	  ,h.Conditions as QualityCondition
	  ,i.Deliverables as SubjectDeliverable
	  ,j.Organizations as SubjectOrganization
	  ,k.Reviews as Review
	  ,a.Outcome
	  ,l.Outcome as OutcomeC
	  ,a.FocusArea
	  ,m.FocusArea as FocusAreaC
	  ,a.CR
	  ,a.QualityScore
	  ,a.ObservedGroup
	  ,a.ErrorDetected
	  ,n.[Description] as ObservedGroupC
	  ,case 
		 when a.SubmissionDate is null then cast(a.RAD as date)
		 else a.SubmissionDate
	   end as SubmissionDate
FROM stng.EI_Main AS a 
left join stng.EI_Status as b on a.[Status] = b.UniqueID
left join stng.VV_Admin_UserView as c on a.RAB = c.EmployeeID
left join stng.EI_QualityRating as d on a.QualityRating = d.UniqueID
left join stng.General_Organization as e on a.Section = e.PersonGroup
left join stng.General_Organization as f on e.ParentPersonGroup = f.PersonGroup and e.[Type] = 'Section'
left join category as g on a.UniqueID = g.EIID
left join condition as h on a.UniqueID = h.EIID
left join deliverable as i on a.UniqueID = i.EIID
left join organization as j on a.UniqueID = j.EIID
left join review as k on a.UniqueID = k.EIID
left join stng.EI_Outcome as l on a.Outcome = l.UniqueID
left join stng.EI_FocusArea as m on a.FocusArea = m.UniqueID
left join stng.General_Organization as n on a.ObservedGroup = n.PersonGroup
where a.Deleted = 0

GO


