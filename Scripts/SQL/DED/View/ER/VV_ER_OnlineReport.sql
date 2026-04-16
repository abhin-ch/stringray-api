ALTER view [stng].[VV_ER_OnlineReport] as

with validpermits as
(
	select *
	from stng.VV_ER_Main
	where CurrentStatusShort not in ('COM','CAN') and ERType in ('ENCD','ENGD','MJT','EVD','ENGC','ENGP','EQ','ENGS')
)

select distinct
 a.ER
, a.ERStatus as MaximoERStatus
, n.TICKETUID
, a.ERType
, a.Facility as SiteID
, o.EarliestTweek
, o.EarliestExecDate
, o.HighestWOPriority
, o.HighPriorityBacklog
, o.PHCFlag
, a.ERAge as ERAge
, c.ERTCD as DMSTCD
, c.CurrentStatus as WorkflowStatus
, DATEDIFF(d,cast(g.RAD as date), cast(getdate() as date)) as DaysAtCurrentWorkflowStatus
, f.Section as AssignedSection
, f.SM as PrimarySM
, f.Department
, b.WONUM as LinkedWO
, case when l.WORKORDERID is null then k.WORKORDERID else l.WORKORDERID end as LinkedWOID
, b.woheader as LinkedWOHeader
, j.workorderid as LinkedWOHeaderID
, b.ScheduleBacklog
, b.ScheduleGrade
, b.WOType
, b.PHCFlag as PHCWO
, b.PCTR
, b.Tweek as WOTweek
, b.ExecDate as WOExecDate
, b.WOPRIORITY
, case 
	when b.Tweek >= 36 then dateadd(day,(b.Tweek - 36)*7,DATEADD(wk,datediff(wk,0,GETDATE()),4))
	when b.Tweek < 36 and b.Tweek >= 14 then dateadd(day,(b.Tweek - 14)*7,DATEADD(wk,datediff(wk,0,GETDATE()),4))
end as Tweek14Date
, a.PMER as PMFlag
, a.CritCat
,i.PMNUM, i.PMType,  i.description as PMDesc, i.AllCat, j.FinishNoLaterThan as PMLateDate,
case when i.AllCat like '%L%' or i.AllCat like '%M%' then 1 else 0 end as CriticalPMCat
from stngetl.ER_SupportInfo as a
inner join stngetl.ER_SupportingWOInfo as b on a.UniqueID = b.ERID and b.ScheduleBacklog in ('EX','PP','CY','ME')
inner join
(
	select ERID, min(ExecDate) as EarliestExecDate, min(Tweek) as EarliestTweek, min(wopriority) as HighestWOPriority,
	max(case when EmergentBacklog = 'H' then 1 else 0 end) as HighPriorityBacklog, max(PHCFlag) as PHCFlag
	from stngetl.ER_SupportingWOInfo
	where ScheduleBacklog in ('EX','PP','CY','ME') and WOStatus not in ('COMP','CAN','CLOSE')
	group by ERID
) as o on a.UniqueID = o.ERID
inner join validpermits as c on a.UniqueID = c.ERID
left join stng.VV_ER_Section as f on c.Section = f.SECID and [Primary] = 1
left join 
(
	select ERID, [StatusID], max(StatusDate) as RAD
	from stng.VV_ER_StatusLog
	group by ERID, [StatusID]
) as g on c.ERID = g.ERID and c.CurrentStatusID = g.[StatusID]
left join [stngetl].[VV_General_PMRSupportingInfo] as i on b.WOHeader = i.CurrentWO
left join stngetl.General_AllWO as j on b.WOHeader = j.WONUM
left join stngetl.General_AllWO as k on b.wonum = k.WONUM
left join stngetl.General_AllWOTask as l on b.WONUM = l.TASK
left join stngetl.General_AllCR as n on c.ER = n.CR
GO


