CREATE OR ALTER view [stngetl].[VV_Budgeting_SDQ_P6_CVWBS] as
with legacyinfo as
(
	select a.SDID as SDQUID, b.RunID, a.WBSName as wbs_name, a.WBSCode as wbs_code, a.DeliverableType, d.DeliverableName, a.UNITUDF as unit, a.PhaseCode, a.DisciplineCode,
	case when a.[Start] like '%A' then left(a.[Start],len(a.[Start]) - 2) 	
	else replace(a.[Start],'*','') end as CurrentStart, 
	case when a.[Finish] like '%A' then left(a.[Finish],len(a.[Finish]) - 2) 	
	else replace(a.[Finish],'*','') end as CurrentEnd, 
	case when a.[Start] like '%A'  then 1 else 0 end as StartActualized,
	case when a.[Finish] like '%A'  then 1 else 0 end as EndActualized,
	a.ActualLaborUnits as LabourActualUnits, a.ActualLaborCost as LabourActualCost, a.ActualNonlaborUnits as NonLabourActualUnits, a.ActualNonlaborCost as NonLabourActualCost, 
	a.ActualLaborCost + a.ActualNonlaborCost as SunkCost, a.RemainingLaborUnits as LabourRemainingUnits, a.RemainingNonlaborUnits as NonLabourRemainingUnits,
	a.RemainingLaborCost as LabourRemainingCost, 
	a.RemainingNonlaborCost as NonLabourRemainingCost,
	a.RemainingLaborCost + a.RemainingNonlaborCost as RemainingCost, null as BLBudgetedCost
	from stng.Budgeting_SDQ_P6_Legacy_0323_ClassVWBS as a
	inner join stng.Budgeting_SDQP6Link as b on a.SDID = b.SDQUID and b.Active = 1
	inner join stngetl.Budgeting_SDQ_Run as c on b.RunID = c.RunID and c.Legacy = 1
	CROSS APPLY (SELECT * FROM stng.FN_Budgeting_SDQ_StandardDeliverable(b.SDQUID) f WHERE a.DeliverableType = f.DeliverableID) as d
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
	coalesce(d.LabourActualUnits ,0) as LabourActualUnits ,
	coalesce(d.LabourActualCost,0) as LabourActualCost,
	coalesce(d.NonLabourActualUnits,0) as NonLabourActualUnits,
	coalesce(d.NonLabourActualCost,0) as NonLabourActualCost,
	coalesce(d.SunkCost,0) as SunkCost,
	coalesce(d.LabourRemainingUnits,0) as LabourRemainingUnits,
	coalesce(d.NonLabourRemainingUnits,0) as NonLabourRemainingUnits,
	coalesce(d.LabourRemainingCost,0) as LabourRemainingCost,
	coalesce(d.NonLabourRemainingCost,0) as NonLabourRemainingCost,
	coalesce(d.RemainingCost,0) as RemainingCost
	--,
	--coalesce(d.BLBudgetedCost,0) as BLBudgetedCost
	from stngetl.Budgeting_SDQ_P6 as a
	inner join stng.Budgeting_SDQP6Link as b on a.RunID = b.RunID and b.Active = 1
	left join stngetl.VV_Budgeting_P6_ActivityResource as d on a.task_id= d.task_id and a.RunID = d.runid and d.Baseline = 0
	--left join stngetl.VV_Budgeting_P6_ActivityResource as e on a.BaselineTaskID = e.TASK_ID and a.RunID = e.RunID and e.Baseline = 1
	inner join stngetl.Budgeting_SDQ_Run as f on b.RunID = f.RunID and f.Legacy = 0
	CROSS APPLY (SELECT * FROM stng.FN_Budgeting_SDQ_StandardDeliverable(b.SDQUID) f WHERE a.DeliverableType = f.DeliverableID) as c
	where a.CV = 1 and a.wbs_lvl = 6
),
lvl6wbssum as
(
	select SDQUID, RunID, wbs_name, wbs_code, 
	DeliverableType, Unit,
	DeliverableName, Direct, PhaseCode, 
	DisciplineCode,
	min(CurrentStart) as CurrentStart, cast(max(cast(StartActualized as tinyint)) as bit) as StartActualized, 
	max(CurrentEnd) as CurrentEnd, cast(min(cast(EndActualized as tinyint)) as bit) as EndActualized,
	sum(LabourActualUnits) as LabourActualUnits,
	sum(LabourActualCost) as LabourActualCost,
	sum(NonLabourActualUnits) as NonLabourActualUnits,
	sum(NonLabourActualCost) as NonLabourActualCost,
	sum(SunkCost) as SunkCost,
	sum(LabourRemainingUnits) as LabourRemainingUnits,
	sum(NonLabourRemainingUnits) as NonLabourRemainingUnits,
	sum(LabourRemainingCost) as LabourRemainingCost,
	sum(NonLabourRemainingCost) as NonLabourRemainingCost,
	sum(RemainingCost) as RemainingCost
	--,
	--sum(BLBudgetedCost) as BLBudgetedCost
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
	coalesce(e.BLBudgetedCost,0) as BLBudgetedCost
	from stngetl.Budgeting_SDQ_P6 as a
	inner join stng.Budgeting_SDQP6Link as b on a.RunID = b.RunID and b.Active = 1
	inner join stngetl.Budgeting_SDQ_Run as c on b.RunID = c.RunID and c.Legacy = 0
	left join stngetl.VV_Budgeting_P6_ActivityResource as d on a.task_id= d.task_id and a.RunID = d.runid and d.Baseline = 0
	left join stngetl.VV_Budgeting_P6_ActivityResource as e on a.BaselineTaskID = e.TASK_ID and a.RunID = e.RunID and e.Baseline = 1
	where a.CV = 0 and a.wbs_lvl > 6
),
childwbssum as
(
	select  SDQUID, RunID, wbslvl6,
	sum(LabourActualUnits) as LabourActualUnits,
	sum(LabourActualCost) as LabourActualCost,
	sum(NonLabourActualUnits) as NonLabourActualUnits,
	sum(NonLabourActualCost) as NonLabourActualCost,
	sum(SunkCost) as SunkCost,
	sum(LabourRemainingUnits) as LabourRemainingUnits,
	sum(NonLabourRemainingUnits) as NonLabourRemainingUnits,
	sum(LabourRemainingCost) as LabourRemainingCost,
	sum(NonLabourRemainingCost) as NonLabourRemainingCost,
	sum(RemainingCost) as RemainingCost
	--,
	--sum(BLBudgetedCost) as BLBudgetedCost
	from childwbs
	group by SDQUID, RunID, wbslvl6
),
initialquery as
(
	select a.SDQUID, a.RunID, a.wbs_name, a.wbs_code, a.DeliverableType, a.DeliverableName, a.unit, a.direct, a.phasecode, a.disciplinecode, 
	a.CurrentStart, a.StartActualized, a.CurrentEnd, a.EndActualized,
	Round(sum(a.LabourActualUnits + coalesce(b.LabourActualUnits,0)),2) as LabourActualUnits, 
	Round(sum(a.LabourActualCost+ coalesce(b.LabourActualCost,0)),2) as LabourActualCost, 
	Round(sum(a.NonLabourActualUnits + coalesce(b.NonLabourActualUnits,0)),2) as NonLabourActualUnits, 
	Round(sum(a.NonLabourActualCost + coalesce(b.NonLabourActualCost,0)),2) as NonLabourActualCost,
	Round(sum(a.SunkCost + coalesce(b.SunkCost,0)),2) as SunkCost, 
	Round(sum(a.LabourRemainingUnits + coalesce(b.LabourRemainingUnits,0)),2) as LabourRemainingUnits, 
	Round(sum(a.NonLabourRemainingUnits + coalesce(b.NonLabourRemainingUnits,0)),2) as NonLabourRemainingUnits, 
	Round(sum(a.LabourRemainingCost + coalesce(b.LabourRemainingCost,0)),2) as LabourRemainingCost,
	Round(sum(a.NonLabourRemainingCost + coalesce(b.NonLabourRemainingCost,0)),2) as NonLabourRemainingCost, 
	Round(sum(a.RemainingCost + coalesce(b.RemainingCost,0)),2) as RemainingCost
	--,
	--Round(sum(a.BLBudgetedCost + coalesce(b.BLBudgetedCost,0)),2) as BLBudgetedCost
	from lvl6wbssum as a
	left join childwbssum as b on a.RunID = b.RunID and a.wbs_code = b.wbslvl6
	group by a.SDQUID, a.RunID, a.wbs_name, a.wbs_code, a.deliverabletype, a.DeliverableName, a.unit, a.direct, a.phasecode, a.DisciplineCode,a.CurrentStart, a.StartActualized, a.CurrentEnd, a.EndActualized
),
unioned as 
(
	select SDQUID, RunID, wbs_name, wbs_code, deliverabletype, DeliverableName, unit, Direct, PhaseCode, DisciplineCode,
	CurrentStart, StartActualized, CurrentEnd, EndActualized,
	LabourActualUnits, LabourActualCost, NonLabourActualUnits, NonLabourActualCost, 
	SunkCost, LabourRemainingUnits, NonLabourRemainingUnits, LabourRemainingCost, NonLabourRemainingCost,
	RemainingCost, 
	--BLBudgetedCost
	0 as Legacy
	from initialquery
	union
	select SDQUID, RunID, wbs_name, wbs_code, deliverabletype, DeliverableName, unit, 0 as Direct, PhaseCode, DisciplineCode,
	CurrentStart, StartActualized, CurrentEnd, EndActualized,
	LabourActualUnits, LabourActualCost, NonLabourActualUnits, NonLabourActualCost, 
	SunkCost, LabourRemainingUnits, NonLabourRemainingUnits, LabourRemainingCost, NonLabourRemainingCost,
	RemainingCost, 
	--BLBudgetedCost,
	1 as Legacy
	from legacyinfo
)

select *
from unioned
GO


