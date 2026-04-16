/****** Object:  View [stng].[VV_ER_SectionManger]    Script Date: 4/8/2026 11:21:12 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO














ALTER view [stng].[VV_ER_SectionManger] as

with primarySM as (
	SELECT a.Section, b.EmpName as SMName, SM as SMID
	FROM stng.ER_SectionManager as a
	left join stng.VV_Admin_UserView as b on a.SM = b.EmployeeID
	where a.Deleted = 0 and [Primary] = 1
	
),
 listedSM as (
	SELECT a.Section, STRING_AGG(b.EmpName, '; ') within group (order by a.[Primary] desc) as AllSMs
	FROM stng.ER_SectionManager as a
	left join stng.VV_Admin_UserView as b on a.SM = b.EmployeeID
	where a.Deleted = 0
	GROUP BY a.Section
)

Select 
a.[UniqueID]
,a.[Section]
,b.SMName
,b.SMID
,a.DED
,a.ProjectRequired
,c.AllSMs
,e.Department
,f.SupervisorName
,f.PersonGroup
FROM [stng].[ER_Section] as a
left join primarySM as b on a.UniqueID = b.Section
left join listedSM as c on a.UniqueID = c.Section
left join stng.ER_SectionToDepartment as d on a.UniqueID = d.SECID
left join stng.ER_Department as e on d.DPID = e.UniqueID
left join stng.[VV_General_OrganizationView] as f on e.Department = f.[Description]
where a.Deleted = 0
or a.UniqueID in (
 SELECT distinct Section
 from stng.ER_Main
)
GO


