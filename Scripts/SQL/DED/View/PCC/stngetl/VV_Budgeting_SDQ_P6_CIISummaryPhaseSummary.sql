CREATE OR ALTER view [stngetl].[VV_Budgeting_SDQ_P6_CIISummaryPhaseSummary] as
with newinfo as
(
	select SDQUID, PhaseCode, PhaseC,
	sum(Budget) as Budget, sum(LabourRemainingCost) as LabourRemainingCost,
	sum(NonLabourRemainingCost) as NonLabourRemainingCost, 
	min(CurrentStart) as CurrentStart,
	cast(max(cast(StartActualized as tinyint)) as bit) as StartActualized,
	max(CurrentEnd) as CurrentEnd,
	cast(min(cast(EndActualized as tinyint)) as bit) as EndActualized
	from stngetl.VV_Budgeting_SDQ_P6_CIISDS
	where Legacy = 0
	group by SDQUID, PhaseCode, PhaseC
),
legacy as
(
	select SDID as SDQUID, Phase as PhaseCode, PhaseC,
	x.BudgetSum as Budget, x.LabourSum as LabourRemainingCost, x.NonlabourSum as NonLabourRemainingCost,
	case when try_convert(datetime2, x.MinStart) is not null then x.MinStart
	when x.MinStart like '%A' then left(x.MinStart,len(x.MinStart) - 2) 	
	else replace(x.MinStart,'*','') end as CurrentStart, 
	case when x.MinStart like '%A' then 1 else 0 end as StartActualized,
	case when try_convert(datetime2, x.MaxFinish) is not null then x.MaxFinish
	when x.MaxFinish like '%A' then left(x.MaxFinish,len(x.MaxFinish) - 2) 	
	else replace(x.MaxFinish,'*','') end as CurrentEnd, 
	case when x.MaxFinish like '%A' then 1 else 0 end as EndActualized
	from stng.Budgeting_SDQ_P6_Legacy_ClassIISummary_Summary as x
),
unioned as 
(
	select SDQUID, PhaseCode, PhaseC, Budget, LabourRemainingCost, NonLabourRemainingCost, CurrentStart, StartActualized, CurrentEnd, EndActualized
	from newinfo
	union
	select SDQUID, PhaseCode, PhaseC, Budget, LabourRemainingCost, NonLabourRemainingCost, CurrentStart, StartActualized, CurrentEnd, EndActualized
	from legacy
)

select *
from unioned