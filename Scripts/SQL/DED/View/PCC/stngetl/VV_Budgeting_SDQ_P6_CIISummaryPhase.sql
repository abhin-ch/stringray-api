CREATE OR ALTER VIEW [stngetl].[VV_Budgeting_SDQ_P6_CIISummaryPhase]
AS
with newinfo as
(
	select SDQUID, concat(SDQUID,PhaseCode,SDSUnit) as UniqueID, PhaseCode, PhaseC, SDSUnit, 
	sum(Budget) as Budget, sum(LabourRemainingCost) as LabourRemainingCost,
	sum(NonLabourRemainingCost) as NonLabourRemainingCost, 
	min(CurrentStart) as CurrentStart,
	cast(max(cast(StartActualized as tinyint)) as bit) as StartActualized,
	max(CurrentEnd) as CurrentEnd,
	cast(min(cast(EndActualized as tinyint)) as bit) as EndActualized
	from stngetl.VV_Budgeting_SDQ_P6_CIISDS
	where Legacy = 0
	group by SDQUID, concat(SDQUID,PhaseCode,SDSUnit), PhaseCode, PhaseC, SDSUnit
),
legacy as
(
	select SDID as SDQUID, concat(SDID,Phase,SDSUnits) as UniqueID, Phase as PhaseCode, PhaseC, SDSUnits as SDSUnit, 
	x.BudgetSum as Budget, x.LabourSum as LabourRemainingCost, x.NonlabourSum as NonLabourRemainingCost,
	case when try_convert(datetime2, x.MinStart) is not null then x.MinStart
	when x.MinStart like '%A' then left(x.MinStart,len(x.MinStart) - 2)              
	else replace(x.MinStart,'*','') end as CurrentStart, 
	case when x.MinStart like '%A' then 1 else 0 end as StartActualized,
	case when try_convert(datetime2, x.MaxFinish) is not null then x.MaxFinish
	when x.MaxFinish like '%A' then left(x.MaxFinish,len(x.MaxFinish) - 2)      
	else replace(x.MaxFinish,'*','') end as CurrentEnd, 
	case when x.MaxFinish like '%A' then 1 else 0 end as EndActualized
	from stng.Budgeting_SDQ_P6_Legacy_ClassIISummary_byPhase as x
),
unioned as 
(
	select SDQUID, UniqueID, PhaseCode, PhaseC, SDSUnit, Budget, LabourRemainingCost, NonLabourRemainingCost, CurrentStart, StartActualized, CurrentEnd, EndActualized
	from newinfo
	union
	 (  select L.SDQUID, L.UniqueID, L.PhaseCode, L.PhaseC, L.SDSUnit, L.Budget, L.LabourRemainingCost, L.NonLabourRemainingCost, L.CurrentStart, L.StartActualized, L.CurrentEnd, L.EndActualized
	from legacy L
	where not exists (select 1 from newinfo n where n.SDQUID=l.sdquid ))
)
select *
from unioned
