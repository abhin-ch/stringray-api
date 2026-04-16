create or alter view [stngetl].[VV_Budgeting_SDQ_P6_CIIPhase] as
select b.SDQUID, b.RunID, b.RunSubID, a.WBS as Phase, 
sum(a.BUDGETEDLABOURCOST + a.BUDGETEDNONLABOURCOST) as BudgetedCost,
sum(a.ACTUALLABOURCOST) as LabourCost,
sum(a.ACTUALNONLABOURCOST) as NonLabourCost, 
min(case when a.act_start_date is null then a.target_start_date else a.act_start_date end) as StartDate,
max(case when a.act_end_date is null then a.target_end_date else a.act_end_date end) as EndDate
from stngetl.Budgeting_SDQ_P6 as a
inner join stngetl.Budgeting_SDQ_Run as b on a.RunID = b.RunID and b.PipelineCompleteTime is not null
where a.WBSPATH like '%ENGINEERING\%' and a.CV = 0
group by b.SDQUID, b.RunID, b.RunSubID, a.WBS
GO


