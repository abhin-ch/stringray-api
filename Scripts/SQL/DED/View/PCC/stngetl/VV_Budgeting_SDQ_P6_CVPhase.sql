CREATE OR ALTER view [stngetl].[VV_Budgeting_SDQ_P6_CVPhase] as
with initialquery as
(
	select a.SDQUID, a.RunID, a.PhaseCode,
	case when a.PhaseCode = 0 then 'Initiation'
	when a.PhaseCode = 1 then 'Conceptual Design (Development)'
	when a.PhaseCode = 2 then 'Preliminary Engineering (Definition)'
	when a.PhaseCode = 3 then 'Detailed Engineering (Preparation)'
	when a.PhaseCode = 4 then 'Engineering Execution Support (Execution/Turnover'
	when a.PhaseCode = 5 then 'Design Closeout (Closeout)' end as PhaseC,
	a.LabourRemainingCost, a.LabourRemainingUnits, a.NonLabourRemainingCost, a.RemainingCost
	from stngetl.Budgeting_SDQ_P6_CVWBS_Materialized as a
	where a.Legacy = 0
),
newinfo as 
(
	select SDQUID, RunID, PhaseCode, PhaseC,
	sum(LabourRemainingCost) as LabourRemainingCost,
	sum(LabourRemainingUnits) as LabourRemainingUnits,
	sum(NonLabourRemainingCost) as NonLabourRemainingCost,
	sum(RemainingCost) as RemainingCost
	from initialquery
	group by SDQUID, RunID, PhaseCode, PhaseC
),
legacy as 
(
	select a.SDID as SDQUID, b.RunID, a.Rev as PhaseCode, a.RevC as PhaseC,
	a.LaborCost as LabourRemainingCost, a.LaborUnits as LabourRemainingUnits, a.NonlaborCost as NonLabourRemainingCost,
	a.LaborCost + a.NonlaborCost as RemainingCost
	from stng.Budgeting_SDQ_P6_Legacy_0324_ClassVByPhase as a
	inner join stng.Budgeting_SDQP6Link as b on a.SDID = b.SDQUID and b.Active = 1
	inner join stngetl.Budgeting_SDQ_Run as c on b.RunID = c.RunID and c.Legacy = 1
),
unioned as
(	
	select SDQUID, RunID, PhaseCode, PhaseC, LabourRemainingCost, LabourRemainingUnits, NonLabourRemainingCost, RemainingCost
	from newinfo
	union
	select SDQUID, RunID, PhaseCode, PhaseC, LabourRemainingCost, LabourRemainingUnits, NonLabourRemainingCost, RemainingCost
	from legacy
)

select *
from unioned
GO


