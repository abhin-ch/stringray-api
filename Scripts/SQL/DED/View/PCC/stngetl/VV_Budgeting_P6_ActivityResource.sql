ALTER view [stngetl].[VV_Budgeting_P6_ActivityResource] as
with fulllist as
(
	select distinct runid,task_id, RoleName, Baseline
	from stngetl.Budgeting_SDQ_P6_ActivityResource	
),
labour as
(
	select RunID, TASK_ID, RoleName, Baseline, sum(RemainingUnits) as RemainingUnits, sum(RemainingCost) as RemainingCost, sum(ActualUnits) as ActualUnits, sum(ActualCost) as ActualCost,
	sum(BudgetedCost) as BudgetedCost
	from stngetl.Budgeting_SDQ_P6_ActivityResource
	where [Type] = 'Labour'
	group by RunID, TASK_ID, RoleName, Baseline
),
nonlabour as
(
	select RunID, TASK_ID, RoleName, Baseline, sum(RemainingUnits) as RemainingUnits, sum(RemainingCost) as RemainingCost, sum(ActualUnits) as ActualUnits, sum(ActualCost) as ActualCost,
	sum(BudgetedCost) as BudgetedCost
	from stngetl.Budgeting_SDQ_P6_ActivityResource
	where [Type] = 'Non-Labour'
	group by RunID, TASK_ID, RoleName, Baseline
),
initialquery as
(
	select a.runid, a.task_id, a.RoleName, a.Baseline,
	case when b.RemainingCost is null then 0 else Round(b.RemainingCost,2) end as LabourRemainingCost,
	case when b.RemainingUnits is null then 0 else Round(b.RemainingUnits,2) end as LabourRemainingUnits,
	case when b.ActualCost is null then 0 else Round(b.ActualCost,2) end as LabourActualCost,
	case when b.ActualUnits is null then 0 else Round(b.ActualUnits,2) end as LabourActualUnits,
	case when c.RemainingCost is null then 0 else Round(c.RemainingCost,2) end as NonLabourRemainingCost,
	case when c.RemainingUnits is null then 0 else Round(c.RemainingUnits,2) end as NonLabourRemainingUnits,
	case when c.ActualCost is null then 0 else Round(c.ActualCost,2) end as NonLabourActualCost,
	case when c.ActualUnits is null then 0 else Round(c.ActualUnits,2) end as NonLabourActualUnits
	from fulllist as a
	left join labour as b on a.RunID = b.RunID and a.TASK_ID = b.TASK_ID and (a.RoleName = b.RoleName or b.RoleName is null) and b.Baseline = 0
	left join nonlabour as c on a.RunID = c.RunID and a.TASK_ID = c.TASK_ID and (a.RoleName = c.RoleName or c.RoleName is null) and c.Baseline = 0
	where a.Baseline = 0
),
baselinecost as
(
	select a.runid, a.task_id, a.RoleName, a.Baseline, round(coalesce(b.BudgetedCost,0) + coalesce(c.BudgetedCost,0),2) as BLBudgetedCost
	from fulllist as a
	left join labour as b on a.RunID = b.RunID and a.TASK_ID = b.TASK_ID and (a.RoleName = b.RoleName or b.RoleName is null) and b.Baseline = 1
	left join nonlabour as c on a.RunID = c.RunID and a.TASK_ID = c.TASK_ID and (a.RoleName = c.RoleName or c.RoleName is null) and c.Baseline = 1
	where a.Baseline = 1
),
secondquery as
(
	select a.RunID, a.TASK_ID, a.RoleName, a.Baseline, a.LabourRemainingCost, a.LabourRemainingUnits, a.LabourActualCost, a.LabourActualUnits,
	a.NonLabourRemainingCost, a.NonLabourRemainingUnits, a.NonLabourActualCost, a.NonLabourActualUnits,
	a.LabourActualCost + a.NonLabourActualCost as SunkCost,
	a.LabourRemainingCost + a.NonLabourRemainingCost as RemainingCost
	from initialquery as a
),
thirdquery as 
(
	select RunID, TASK_ID, RoleName, Baseline, LabourRemainingCost, LabourRemainingUnits, LabourActualCost, LabourActualUnits, NonLabourRemainingCost,
	NonLabourRemainingUnits, NonLabourActualCost, NonLabourActualUnits, SunkCost, RemainingCost, SunkCost + RemainingCost as RequestCost, 0 as BLBudgetedCost
	from secondquery 
	union all
	select RunID, TASK_ID, RoleName, Baseline, 0 as LabourRemainingCost, 0 as LabourRemainingUnits, 0 as LabourActualCost, 0 as LabourActualUnits, 0 as NonLabourRemainingCost,
	0 as NonLabourRemainingUnits, 0 as NonLabourActualCost, 0 as NonLabourActualUnits, 0 as SunkCost, 0 as RemainingCost, 0 as RequestCost, BLBudgetedCost
	from baselinecost
)

select  *
from thirdquery
GO