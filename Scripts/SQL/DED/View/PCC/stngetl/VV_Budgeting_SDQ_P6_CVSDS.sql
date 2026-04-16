CREATE OR ALTER view [stngetl].[VV_Budgeting_SDQ_P6_CVSDS] as
with legacy as
(
	select 
	a.SDID as SDQUID,
	b.RunID,
	cast(a.CWID as varchar) as  wbs_code,
	a.WBSName as wbs_name,
	a.DeliverableName as Deliverable,
	a.DeliverableType,a.Budget,
	a.RemainingLaborCost as LabourRemainingCost,
	a.RemainingNonlaborCost as NonLabourRemainingCost,
	a.Direct,
	a.Indirect,
	case when a.Direct = 'Y' then a.Budget else 0 end as DirectBudget,
	case when a.Indirect = 'Y' then a.Budget else 0 end as IndirectBudget,
	case when ROCbySDSCode <> 'N/A' then cast(ROCbySDSCode as float)*100 end as RoC,
	case when a.[Start] like '%A' then left(a.[Start],len(a.[Start]) - 2) 	
	else replace(a.[Start],'*','') end as CurrentStart, 
	case when a.[Start] like '%A' then 1 else 0 end as StartActualized,
	case when try_convert(datetime2, a.[Finish]) is not null then a.[Finish]
	when a.[Finish] like '%A' then left(a.[Finish],len(a.[Finish]) - 2) 	
	else replace(a.[Finish],'*','') end as CurrentEnd, 
	case when a.[Finish] like '%A' then 1 else 0 end as EndActualized,
	a.SDSWP,
	a.SDSCode 
	from stng.Budgeting_SDQ_P6_Legacy_ClassVSDS as a
	inner join stng.Budgeting_SDQP6Link as b on a.SDID = b.SDQUID and b.Active = 1
	inner join stngetl.Budgeting_SDQ_Run as c on b.RunID = c.RunID and c.Legacy = 1
),
initialquery as 
(
	select distinct a.SDQUID, a.RunID, a.wbs_name, a.wbs_code, a.DeliverableName as Deliverable, a.DeliverableType, a.RemainingCost as Budget,
	a.LabourRemainingCost, a.NonLabourRemainingCost, a.LabourRemainingUnits,
	a.Direct as DirectBool,
	case when a.Direct = 1 then 'Y' end as Direct,
	case when a.Direct = 0 then 'Y' end as Indirect,
	case when a.Direct = 1 then a.RemainingCost else 0 end as DirectBudget,
	case when a.Direct = 0 then a.RemainingCost else 0 end as IndirectBudget,
	a.CurrentStart, a.StartActualized,
	a.CurrentEnd, a.EndActualized,
	case when b.OverrideValue is not null then b.OverrideValue
	when (a.Direct = 1 and a.PhaseCode >= 0 and a.PhaseCode <= 3) or (a.Direct= 0 and a.PhaseCode in (1,0)) then 1 else a.PhaseCode end as SDSWP,
	case when a.Direct = 0 then '4'
	when a.PhaseCode in (0,1) then '1'
	when a.PhaseCode = 2 then '2'
	when a.PhaseCode = 3 then '3'
	else '4' end as SubPhaseCode,
	a.DisciplineCode, a.PhaseCode,
	a.Unit
	from stngetl.Budgeting_SDQ_P6_CVWBS_Materialized as a
	left join stng.VV_Budgeting_SDSWP_Override as b on a.RunID = b.RunID and a.wbs_code = b.wbs_code
	where a.EndActualized = 0 and a.RemainingCost > 0 and a.Legacy = 0
),
secondquery as
(
	select *,
	case when SubPhaseCode = 1 or (SubPhaseCode = 4 and (SDSWP = 1 or (SDSWP >= 10 and SDSWP <= 19))) then 'Conceptual Engineering (Development)'
	when SubPhaseCode = 2 or (SubPhaseCode = 4 and (SDSWP = 2 or (SDSWP >= 20 and SDSWP <= 29))) then 'Preliminary Engineering (Definition)'
	when SubPhaseCode = 3 or (SubPhaseCode = 4 and (SDSWP = 3 or (SDSWP >= 30 and SDSWP <= 39))) then 'Detailed Engineering (Preparation)'
	when SubPhaseCode = 4 and (SDSWP = 4 or (SDSWP >= 40 and SDSWP <= 69)) then 'Engineering Execution Support (Execution/Turnover)'
	when SubPhaseCode = 4 and (SDSWP = 5 or (SDSWP >= 70 and SDSWP <= 99)) then 'Design Closeout (Closeout)'
	end as PhaseC,
	case when DirectBool = 0 then '0'
	when SubPhaseCode in (1,4) then '0'
	when DisciplineCode in (10,13,14) then '0'
	when DisciplineCode in (1,15) then '1'
	when DisciplineCode in (12) then '8'
	when DisciplineCode in (11) then '9'
	when DisciplineCode >= 2 and DisciplineCode <=7 then DisciplineCode end as SDSDisciplineCode,
	case when PhaseCode in (0,1,2) or (PhaseCode = 4 and SDSWP in (1,2)) then '9'
	when Unit in ('0','1','2','3','4','5','6','7','8','01','02','03','04','05','06','07','08') then Unit
	when Unit in ('09','9') and PhaseCode not in (3,4) then '9'
	else 0
	end as SDSUnit
	from initialquery
),
thirdquery as
(
	select *,
	concat(SubPhaseCode,SDSDisciplineCode,cast(FORMAT(SDSWP,'00') as varchar(2)),SDSUnit) as SDSCode
	from secondquery
),
sdsbudget as
(
	select RunID, SDSCode, sum(Budget) as Budget
	from thirdquery
	where DirectBool = 1
	group by RunID, SDSCode
),
fourthquery as
(
	select x.*,
	case when x.DirectBool = 1 and  x.SubPhaseCode not in ('4','5') then (coalesce(x.Budget,0)/coalesce(y.Budget,0))*100 end as RoC
	from thirdquery as x
	left join sdsbudget as y on x.SDSCode = y.SDSCode and x.RunID = y.RunID
),
unioned as
(
	select x.SDQUID, x.RunID, x.wbs_name, x.wbs_code, x.unit, x.SubPhaseCode, x.SDSWP, x.SDSUnit, x.SDSDisciplineCode, x.SDSCode, x.PhaseCode, x.PhaseC, x.LabourRemainingCost, x.NonLabourRemainingCost, x.Deliverable, x.DeliverableType,
	x.LabourRemainingUnits,
	x.DisciplineCode, x.RoC, x.Budget, x.DirectBudget, x.IndirectBudget, x.CurrentStart, x.StartActualized,  x.CurrentEnd, x.EndActualized, x.DirectBool, x.Direct, x.Indirect, 0 as Legacy
	from fourthquery as x
	union
	select x.SDQUID, x.RunID, x.wbs_name, x.wbs_code, null as unit, null as SubPhaseCode, x.SDSWP, null as SDSUnit, null as SDSDisciplineCode, x.SDSCode, null as PhaseCode, null as PhaseC, x.LabourRemainingCost, x.NonLabourRemainingCost, x.Deliverable, x.DeliverableType,
	null as LabourRemainingUnits,
	null as DisciplineCode, x.RoC, x.Budget, x.DirectBudget, x.IndirectBudget, x.CurrentStart, x.StartActualized,  x.CurrentEnd, x.EndActualized, 0 as DirectBool, x.Direct, x.Indirect, 1 as Legacy
	from legacy as x
)


select *
from unioned
GO


