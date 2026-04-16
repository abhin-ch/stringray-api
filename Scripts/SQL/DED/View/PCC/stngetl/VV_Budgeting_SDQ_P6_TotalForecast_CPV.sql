CREATE OR ALTER view [stngetl].[VV_Budgeting_SDQ_P6_TotalForecast_CPV] as
with wbslvl6 as 
(
	select distinct a.RunID, a.wbs_code, a.DeliverableType
	from stngetl.Budgeting_SDQ_P6 as a
	where a.wbs_lvl = 6
),
newinfo as
(
	select d.SDQUID, a.RunID, a.FirstOfMonth, sum(a.Forecast) as Forecast
	from stngetl.Budgeting_SDQ_P6_Forecast as a
	inner join stngetl.Budgeting_SDQ_P6 as b on a.RunID = b.RunID and a.ActivityID = b.activityid
	inner join stngetl.Budgeting_SDQ_Run as e on a.RunID = e.RunID and e.Legacy = 0
	inner join stng.Budgeting_SDQP6Link as d on a.RunID = d.RunID and d.Active = 1
	inner join wbslvl6 as g on b.wbslvl6 = g.wbs_code and b.RunID = g.RunID
	CROSS APPLY  (SELECT * FROM stng.FN_Budgeting_SDQ_StandardDeliverable(d.SDQUID) f WHERE g.DeliverableType = f.DeliverableID) as f 
	where a.Forecast is not null and b.CV = 0 and f.Direct = 1
	group by d.SDQUID, a.RunID, a.FirstofMonth
),
legacy as
(
	select a.SDQUID, e.RunID, a.CPVDate as FirstofMonth, a.SumCPVCost as Forecast
	from stng.VV_Budgeting_SDQ_P6_Legacy_Forecast_PlannedValue as a
	inner join stngetl.Budgeting_SDQ_Run as e on a.SDQUID = e.SDQUID and e.Legacy = 1
	inner join stng.Budgeting_SDQP6Link as d on e.RunID = d.RunID and d.Active = 1
),
unioned as
(
	select SDQUID, RunID,FirstofMonth, Forecast
	from newinfo
	union
	select SDQUID, RunID,FirstofMonth, Forecast
	from legacy
)


select *
from unioned