CREATE OR ALTER view [stngetl].[VV_Budgeting_SDQ_P6_PMPC] as
with newinfonum as 
(
	select SDQUID, sum(RemainingCost) as PMPCCost
	from stngetl.Budgeting_SDQ_P6_CIIOrg_Materialized
	where Legacy = 0 and RespOrg like '%PMPC%'
	group by SDQUID
),
newinfodenom as 
(
	select SDQUID, sum(RemainingCost) as NonPMPCCost
	from stngetl.Budgeting_SDQ_P6_CIIOrg_Materialized
	where Legacy = 0 and RespOrg not like '%PMPC%'
	group by SDQUID
),
newinfo as
(
	select distinct a.SDQUID, 
	coalesce(b.PMPCCost,0) as PMPCCost, 
	coalesce(c.NonPMPCCost,0) as NonPMPCCost,
	case when coalesce(c.NonPMPCCost,0) > 0 then  coalesce(b.PMPCCost,0) / coalesce(c.NonPMPCCost,0) end as PMPCPct
	from stngetl.Budgeting_SDQ_P6_CIIOrg_Materialized as a
	left join newinfonum as b on a.SDQUID = b.SDQUID
	left join newinfodenom as c on a.SDQUID = c.SDQUID
	where a.Legacy = 0 
),
legacy as
(
	select SDID as SDQUID, try_convert(float,replace(PMPCPCT,'%','')) / 100 as PMPCPct
	from stng.Budgeting_SDQ_P6_Legacy_PMPCPercent
),
unioned as
(
	select SDQUID, PMPCCost, NonPMPCCost, PMPCPct
	from newinfo
	union
	select SDQUID, null as PMPCCost, null as NonPMPCCost, PMPCPct
	from legacy
)

select *
from unioned
GO


