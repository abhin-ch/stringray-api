/****** Object:  View [stng].[VV_ER_Main]    Script Date: 2/3/2026 3:08:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO









CREATE view [stng].[VV_ER_Main] as

WITH smduedates AS (
  SELECT ERID, MIN(SMDueDate) AS SMDueDate
  FROM (
    SELECT ERID, RAD, SMDueDate,
           ROW_NUMBER() OVER (PARTITION BY ERID ORDER BY RAD DESC) AS rn
    FROM stng.ER_SMDueDate
  ) AS ranked
  WHERE rn = 1
  GROUP BY ERID
),
--latestduedateoverrides as
--(
--	select x.ERID, min(DueDateOverride) as DueDateOverride
--	from stng.ER_DueDateOverride as x
--	inner join
--	(
--		select ERID, max(RAD) as RAD
--		from stng.ER_DueDateOverride
--		group by ERID
--	) as y on x.ERID = y.ERID and x.RAD = y.RAD
--	group by x.ERID
--),
hasInHouseDeliverable as (
	Select ERID, case when max(cast(InHouse as int)) = 1 then 'Yes' when max(cast(InHouse as int)) = 0 then 'No' else null end as InHouse
	From [stng].[VV_ER_Deliverable]
	group by ERID
),
linkedDeliverables as (
	SELECT ERID, STRING_AGG(DelName, '; ') AS Deliverables
	FROM (
		SELECT DISTINCT ERID, DelName
		FROM [stng].[VV_ER_Deliverable]
	) AS DistinctDeliverables
	GROUP BY ERID
)
,linkedVendors as (
	SELECT ERID, STRING_AGG(VendorName, '; ') AS Vendors
	FROM (
		SELECT DISTINCT ERID, VendorName
		FROM [stng].[VV_ER_Deliverable]
	) AS DistinctVendors
	GROUP BY ERID
)

SELECT
a.UniqueID as ERID,
a.ER, 
case when l.TICKETUID is not null then concat('https://prod-maximo.corp.brucepower.com/maximo/ui/?event=loadapp&value=plusca&uniqueid=',cast(l.TICKETUID as varchar(20))) end as MaximoLink,
c.ERTitle
,c.ERStatus as MaximoStatus
,c.ERType
,a.CurrentStatus as CurrentStatusID
,b.StatusShort as CurrentStatusShort
,b.[Status] as CurrentStatus
,assignedIndiv.ResourceC as AssignedIndividual
,verifier.ResourceC as Verifier
,alternateAssessor.ResourceC as AlternateAssessor
,a.ERTCD
,a.ScheduleBuilt
,a.AtRisk
,n.InHouse
,a.CompDate
--, a.CompFlag, 
,c.WOPriority, cast(c.PMER as bit) as PMER, c.MinExecDate, trim(c.[Facility]) AS SiteID, c.Outage, c.OrigDate
,a.ProjectID
,case when a.OverrideERDueDateCheck = 1 then a.ERDueDateOverride else c.ERDueDate end as ERDueDateActual
,a.OverrideERDueDateCheck
,a.ERDueDateOverride
,c.ERDueDate
,c.DueDateType, 
c.MaximoTCD,c.CritCat, cast(c.PHCFlag as bit) as PHCFlag, c.EarliestWOAge,
a.RAD,
c.ERAge, c.ERComments as MaximoComments, c.Tweek, c.TweekRender, c.TweekCalc,
cast(case when c.InventoryWO is null then 0 else c.InventoryWO end as bit) as InventoryWO,
case 
when c.InventoryWO = 1 then
	case 
		when c.itemnum is not null then 
			case 
				when e.STOCK > 0 then 'A'
				else 'B'
			end
		else 'C'
	end
end as InventoryCategory
,c.EmergentBacklog
, c.EmergentBacklogRender
,a.Section
,m.Section as SectionName
,m.SMName
,m.SMID
,m.AllSMs
,m.Department as DepartmentName
,m.PersonGroup as DeptPersonGroup
--cast(case when 
--(cast(n.DueDateOverride as date) < cast(getdate() as date))
--or
--(TT_0152.CPDDID IS NOT NULL AND VV_0176.DueDate = B.PermitDueDate)
--then 1  
--ELSE 0 END AS bit) AS MissedDueDate, TT_0152.CPDDID, VV_0176.MissedRationaleC, 
--VV_0176.DueDate AS OldMissedDueDate, TT_0152.Z299, TT_0152.NCA, CAST(CASE WHEN B.PermitComments IS NULL OR
--trim(B.PermitComments) = '' THEN 0 ELSE 1 END AS bit) AS HasPermitComments, 
,c.AssignedTo as AssignedToID
, c.AssignedGroup
, k.EmpName as AssignedTo,
c.[Initiator] as InitiatorID
, c.InitiatedWorkGroup
, concat(g.FirstName, ' ', g.LastName) as [Initiator],
h.EstimatedHours, 
c.RelatedWOs, c.AllScheduleBacklog, c.AllScheduleGrade
,c.AllCanceledWO,
c.EPT, c.RSE, c.RCE, c.RDE, c.[Location], 
c.EQUIPMENTTYPE as LocationType, c.USI, c.SYSTEMDESC as USIDesc
--,a.OverallCost,
,c.FinishDate, 
c.AllActiveOutages, c.AllActiveWOTypes, c.OnlineReporting, c.AllWOGroups, c.AllWOProj, c.AllWOPCTR, c.AllWOHeader, 
j.SMDueDate
,case when cast(j.SMDueDate as date) < cast(getdate() as date) then 1 else 0 end as PastSMDueDate
,a.Reason
,p.Reason as ReasonC
,q.Deliverables
,s.Vendors
--,r.Comments
,datediff(day, CAST(a.ERTCD AS date), CAST(case when a.OverrideERDueDateCheck = 1 then a.ERDueDateOverride else c.ERDueDate end AS date)) AS DateVariance
,case when 
	(a.Section is null	and c.ERType in ('ENCD','ENGD','MJT','EQ','ENGS'))
	or
	m.DED = 1 then
		'Y'
	else
		'N'
	end 
as [Design ER]
, case when c.allactiveoutages like '%A233[0-9]%' then 1 else 0 end as MCR3
, case when c.allactiveoutages like '%B206[0-9]%' then 1 else 0 end as MCR6
, case when c.allactiveoutages like '%A254[0-9]%' or allactiveoutages like '%A264[0-9]%' then 1 else 0 end as MCR4  
FROM stng.ER_Main AS a
inner join stng.ER_Status as b on a.CurrentStatus = b.UniqueID
left join stngetl.ER_SupportInfo as c on a.ER = c.ER
--left join latestduedateoverrides as d on a.UniqueID = d.ERID
left join stngetl.General_CatalogMain as e on c.itemnum = e.ITEM
left join stng.Admin_User as g on c.[Initiator] = g.EmployeeID
left join 
(
	select ERID, sum(EstimatedHours) as EstimatedHours
	from [stng].[VV_ER_Deliverable]
	group by ERID
) as h on a.UniqueID = h.ERID
left join smduedates as j on a.UniqueID = j.ERID
left join stng.VV_Admin_UserView as k on c.[AssignedTo] = k.EmployeeID
left join stngetl.General_CRMapping as l on a.ER = l.TICKETID
left join stng.[VV_ER_SectionManger] as m on a.Section = m.UniqueID
left join stng.VV_ER_Resource as assignedIndiv on a.UniqueID = assignedIndiv.ERID and assignedIndiv.ResourceTypeC = 'Assigned Individual'
left join stng.VV_ER_Resource as verifier on a.UniqueID = verifier.ERID and verifier.ResourceTypeC = 'Verifier'
left join stng.VV_ER_Resource as alternateAssessor on a.UniqueID = alternateAssessor.ERID and alternateAssessor.ResourceTypeC = 'Alternate Assessor'
left join hasInHouseDeliverable as n on a.UniqueID = n.ERID
left join stng.ER_Reason as p on a.Reason = p.UniqueID
left join linkedDeliverables as q on a.UniqueID = q.ERID
--left join 
--(
--	select x.ERID, string_agg(concat(concat('(',FORMAT(x.CommentDate,'MMM dd yyyy'),') (',x.Commenter,')'),char(13),char(10),x.Comment), concat(char(13),char(10),'---------',char(13),char(10))) within group (order by x.CommentDate desc) as Comments
--	from stng.VV_ER_Comment as x
--	group by x.ERID 					
--) as r on a.UniqueID = r.ERID
left join linkedVendors as s on a.UniqueID = s.ERID
where c.ERStatus is not null --Removes any CRs that has their Maximo types/classes changed after initial creation
GO


