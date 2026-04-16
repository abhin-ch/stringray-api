CREATE OR ALTER  view [stngetl].[VV_Budgeting_SDQ_P6_CIIDeliverable] as
with legacyinfo as
(
	select a.SDQUID, b.RunID, a.WBSName as wbs_name, a.WBSCode as wbs_code, a.DeliverableType, d.DeliverableName, a.UNITUDF as unit, a.PhaseCode, a.DisciplineCode,
	case when a.[Start] like '%A' then left(a.[Start],len(a.[Start]) - 2) 	
	else replace(a.[Start],'*','') end as CurrentStart, 
	case when a.[Finish] like '%A' then left(a.[Finish],len(a.[Finish]) - 2) 	
	else replace(a.[Finish],'*','') end as CurrentEnd, 
	case when a.[Start] like '%A'  then 1 else 0 end as StartActualized,
	case when a.[Finish] like '%A'  then 1 else 0 end as EndActualized,
	a.ActualLaborUnits as LabourActualUnits, a.ActualLaborCost as LabourActualCost, a.ActualNonlaborUnits as NonLabourActualUnits, a.ActualNonlaborCost as NonLabourActualCost, 
	a.SunkCost, a.RemainingLaborUnits as LabourRemainingUnits, a.RemainingNonlaborUnits as NonLabourRemainingUnits,
	a.RemainingLaborCost as LabourRemainingCost, 
	a.RemainingNonlaborCost as NonLabourRemainingCost,
	a.RemainingCost,
	a.BIMSEstimate,
	a.BIMSCommit,
	a.FinalBIMSCommit
	from stng.VV_Budgeting_SDQ_P6_Legacy_ClassIIDeliverable as a
	inner join stng.Budgeting_SDQP6Link as b on a.SDQUID = b.SDQUID and b.Active = 1
	inner join stngetl.Budgeting_SDQ_Run as c on b.RunID = c.RunID and c.Legacy = 1
	left join stng.Budgeting_SDQ_StandardDeliverable as d on a.DeliverableType = d.DeliverableID
),
lvl6wbs as 
(
	select distinct b.SDQUID, a.RunID, a.wbs_name, a.wbs_code, a.activityid, 
	a.DeliverableType, a.Unit,
	c.DeliverableName, c.Direct, a.PhaseCode, 
	case when c.Direct = 0 then '0'
	when a.PhaseCode in (0,1) then '0'
	else a.DisciplineCode end as DisciplineCode,
	a.CurrentStart, a.StartActualized, a.CurrentEnd, a.EndActualized,
	coalesce(d.LabourActualUnits,0) as LabourActualUnits,
	coalesce(d.LabourActualCost,0) as LabourActualCost,
	coalesce(d.NonLabourActualUnits,0) as NonLabourActualUnits,
	coalesce(d.NonLabourActualCost,0) as NonLabourActualCost,
	coalesce(d.SunkCost,0) as SunkCost,
	coalesce(d.LabourRemainingUnits,0) as LabourRemainingUnits,
	coalesce(d.NonLabourRemainingUnits,0) as NonLabourRemainingUnits,
	coalesce(d.LabourRemainingCost,0) as LabourRemainingCost,
	coalesce(d.NonLabourRemainingCost,0) as NonLabourRemainingCost,
	coalesce(d.RemainingCost,0) as RemainingCost,
	c.SavingPCT,
    c.CommittedSaving
	from stng.Budgeting_SDQP6Link as b
	
	inner join stngetl.Budgeting_SDQ_Run as f on b.RunID = f.RunID and f.Legacy = 0
	inner join stngetl.Budgeting_SDQ_P6 as a on a.RunID = b.RunID and a.CV = 0 and a.wbs_lvl = 6
	inner join stng.Budgeting_SDQ_StandardDeliverable as c on a.DeliverableType = c.DeliverableID and c.Deleted = 0
	left join stngetl.VV_Budgeting_P6_ActivityResource as d on a.task_id = d.task_id and a.RunID = d.runid and d.Baseline = 0
	where b.Active = 1
),
lvl6wbssum as
(
	select SDQUID, RunID, wbs_name, wbs_code, 
	DeliverableType, Unit,
	DeliverableName, Direct, PhaseCode, 
	DisciplineCode,
	min(CurrentStart) as CurrentStart, max(cast(StartActualized as tinyint)) as StartActualized, 
	max(CurrentEnd) as CurrentEnd, min(cast(EndActualized as tinyint)) as EndActualized,
	sum(LabourActualUnits) as LabourActualUnits,
	sum(LabourActualCost) as LabourActualCost,
	sum(NonLabourActualUnits) as NonLabourActualUnits,
	sum(NonLabourActualCost) as NonLabourActualCost,
	sum(SunkCost) as SunkCost,
	sum(LabourRemainingUnits) as LabourRemainingUnits,
	sum(NonLabourRemainingUnits) as NonLabourRemainingUnits,
	sum(LabourRemainingCost) as LabourRemainingCost,
	sum(NonLabourRemainingCost) as NonLabourRemainingCost,
    sum(RemainingCost) as RemainingCost,
    max(SavingPCT) as SavingPCT,
    max(CommittedSaving) as CommittedSaving
	from lvl6wbs
	group by SDQUID, RunID, wbs_name, wbs_code, 
	DeliverableType, Unit,
	DeliverableName, Direct, PhaseCode, DisciplineCode
),
childwbs as
(
	select distinct b.SDQUID, a.RunID, a.wbslvl6, a.activityid,
	coalesce(d.LabourActualUnits,0) as LabourActualUnits,
	coalesce(d.LabourActualCost,0) as LabourActualCost,
	coalesce(d.NonLabourActualUnits,0) as NonLabourActualUnits,
	coalesce(d.NonLabourActualCost,0) as NonLabourActualCost,
	coalesce(d.SunkCost,0) as SunkCost,
	coalesce(d.LabourRemainingUnits,0) as LabourRemainingUnits,
	coalesce(d.NonLabourRemainingUnits,0) as NonLabourRemainingUnits,
	coalesce(d.LabourRemainingCost,0) as LabourRemainingCost,
	coalesce(d.NonLabourRemainingCost,0) as NonLabourRemainingCost,
	coalesce(d.RemainingCost,0) as RemainingCost,
	CurrentStart, CurrentEnd, StartActualized, EndActualized
	from stngetl.Budgeting_SDQ_P6 as a
	inner join stng.Budgeting_SDQP6Link as b on a.RunID = b.RunID and b.Active = 1
	inner join stngetl.Budgeting_SDQ_Run as c on b.RunID = c.RunID and c.Legacy = 0
	left join stngetl.VV_Budgeting_P6_ActivityResource as d on a.task_id= d.task_id and a.RunID = d.runid and d.Baseline = 0
	where a.CV = 0 and a.wbs_lvl > 6
),
childwbssum as
(
	select SDQUID, RunID, wbslvl6,
	sum(LabourActualUnits) as LabourActualUnits,
	sum(LabourActualCost) as LabourActualCost,
	sum(NonLabourActualUnits) as NonLabourActualUnits,
	sum(NonLabourActualCost) as NonLabourActualCost,
	sum(SunkCost) as SunkCost,
	sum(LabourRemainingUnits) as LabourRemainingUnits,
	sum(NonLabourRemainingUnits) as NonLabourRemainingUnits,
	sum(LabourRemainingCost) as LabourRemainingCost,
	sum(NonLabourRemainingCost) as NonLabourRemainingCost,
	sum(RemainingCost) as RemainingCost,
	min(CurrentStart) as CurrentStart, max(cast(StartActualized as tinyint)) as StartActualized, 
	max(CurrentEnd) as CurrentEnd, min(cast(EndActualized as tinyint)) as EndActualized
	from childwbs
	group by SDQUID, RunID, wbslvl6
),
initialquery as
(
	select a.SDQUID, a.RunID, a.wbs_name, a.wbs_code, a.DeliverableType, a.DeliverableName, a.unit, a.direct, a.phasecode, a.disciplinecode, 
	--,a.CurrentStart, a.StartActualized, a.CurrentEnd, a.EndActualized
	min(case when a.CurrentStart < b.CurrentStart or b.CurrentStart is null then a.CurrentStart else b.CurrentStart end) as CurrentStart,
	cast(max(case when a.StartActualized > b.StartActualized or b.StartActualized is null then a.StartActualized else b.StartActualized end) as bit) as StartActualized, 
	max(case when a.CurrentEnd > b.CurrentEnd or b.CurrentEnd is null then a.CurrentEnd else b.CurrentEnd end) as CurrentEnd,
	cast(min(case when a.EndActualized < b.EndActualized or b.EndActualized is null then a.EndActualized else b.EndActualized end) as bit) as EndActualized, 
	Round(sum(a.LabourActualUnits + coalesce(b.LabourActualUnits,0)),2) as LabourActualUnits, 
	Round(sum(a.LabourActualCost+ coalesce(b.LabourActualCost,0)),2) as LabourActualCost, 
	Round(sum(a.NonLabourActualUnits + coalesce(b.NonLabourActualUnits,0)),2) as NonLabourActualUnits, 
	Round(sum(a.NonLabourActualCost + coalesce(b.NonLabourActualCost,0)),2) as NonLabourActualCost,
	Round(sum(a.SunkCost + coalesce(b.SunkCost,0)),2) as SunkCost, 
	Round(sum(a.LabourRemainingUnits + coalesce(b.LabourRemainingUnits,0)),2) as LabourRemainingUnits, 
	Round(sum(a.NonLabourRemainingUnits + coalesce(b.NonLabourRemainingUnits,0)),2) as NonLabourRemainingUnits, 
	Round(sum(a.LabourRemainingCost + coalesce(b.LabourRemainingCost,0)),2) as LabourRemainingCost,
	Round(sum(a.NonLabourRemainingCost + coalesce(b.NonLabourRemainingCost,0)),2) as NonLabourRemainingCost, 
	Round(sum(a.RemainingCost + coalesce(b.RemainingCost,0)),2) as RemainingCost,
	max(a.SavingPCT) as SavingPCT,
    max(a.CommittedSaving) as CommittedSaving
	from lvl6wbssum as a
	left join childwbssum as b on a.RunID = b.RunID and a.wbs_code = b.wbslvl6
	group by a.SDQUID, a.RunID, a.wbs_name, a.wbs_code, a.deliverabletype, a.DeliverableName, a.unit, a.direct, a.phasecode, a.DisciplineCode
	--,a.CurrentStart, a.StartActualized, a.CurrentEnd, a.EndActualized
)
,
unioned as 
(
	select a.SDQUID, a.RunID, a.wbs_name, a.wbs_code, a.DeliverableType, a.DeliverableName, a.unit, a.Direct, a.PhaseCode, a.DisciplineCode,
    a.CurrentStart, a.StartActualized, a.CurrentEnd, a.EndActualized,
    a.LabourActualUnits, a.LabourActualCost, a.NonLabourActualUnits, a.NonLabourActualCost, 
    a.SunkCost, a.LabourRemainingUnits, a.NonLabourRemainingUnits, a.LabourRemainingCost, a.NonLabourRemainingCost,
    a.RemainingCost,
    a.RemainingCost - (a.RemainingCost * a.SavingPCT/100.0) as BIMSEstimate,
    a.RemainingCost - (a.RemainingCost * a.CommittedSaving/100.0) as BIMSCommit,
    coalesce(m.FinalBIMSCommit, a.RemainingCost - (a.RemainingCost * a.CommittedSaving/100.0)) as FinalBIMSCommit,
	0 as Legacy
    from initialquery a
    left join stng.Budgeting_SDQ_FinalBIMSCommitMap m on a.RunID = m.RunID and a.DeliverableType = m.DeliverableType and a.wbs_code = m.WBSCode
	union all
	select SDQUID, RunID, wbs_name, wbs_code, DeliverableType, DeliverableName, unit, 0 as Direct, PhaseCode, DisciplineCode,
	CurrentStart, StartActualized, CurrentEnd, EndActualized,
	LabourActualUnits, LabourActualCost, NonLabourActualUnits, NonLabourActualCost, 
	SunkCost, LabourRemainingUnits, NonLabourRemainingUnits, LabourRemainingCost, NonLabourRemainingCost,
	RemainingCost, BIMSEstimate, BIMSCommit, FinalBIMSCommit,
	1 as Legacy
	from legacyinfo
)

select *
from unioned
GO