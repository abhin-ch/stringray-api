CREATE OR ALTER view [stngetl].[VV_Budgeting_SDQ_P6_TotalForecast_CV] as
with newinfo as
(
	select d.SDQUID, a.RunID, a.FirstOfMonth, sum(a.Forecast) as Forecast
	from stngetl.Budgeting_SDQ_P6_Forecast as a
	inner join stngetl.Budgeting_SDQ_P6 as b on a.RunID = b.RunID and a.ActivityID = b.activityid
	inner join stngetl.Budgeting_SDQ_Run as e on a.RunID = e.RunID and e.Legacy = 0
	inner join stng.Budgeting_SDQP6Link as d on a.RunID = d.RunID and d.Active = 1
	where a.Forecast is not null and b.CV = 1
	group by d.SDQUID, a.RunID, a.FirstofMonth
)

select *
from newinfo