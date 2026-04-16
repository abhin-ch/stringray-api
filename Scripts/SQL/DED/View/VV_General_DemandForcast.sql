CREATE VIEW [stng].[VV_General_WODemandForecast] as
with totaldemand as
(
	select itemnum, sum(itemqty) as totaldemand
  FROM [stng].[VV_General_WODemand]
	group by itemnum
),
twoyrdemand as
(
	select itemnum, sum(itemqty) as twoyrdemand
	from stng.VV_General_WODemand
	where cast(WOSTARTDATE as date) <= cast(DATEadd(YEAR,2,getdate()) as date)
	group by itemnum
),
fiveyrdemand as
(
	select itemnum, sum(itemqty) as fiveyrdemand
	from stng.VV_General_WODemand
	where cast(WOSTARTDATE as date) <= cast(DATEadd(YEAR,5,getdate()) as date)
	group by itemnum
)

select distinct a.itemnum, a.totaldemand, 
case when b.twoyrdemand is null then 0 else b.twoyrdemand end as twoyrdemand, 
case when c.fiveyrdemand is null then 0 else c.fiveyrdemand end as fiveyrdemand
from totaldemand as a
left join twoyrdemand as b on a.itemnum = b.itemnum
left join fiveyrdemand as c on a.itemnum = c.itemnum



