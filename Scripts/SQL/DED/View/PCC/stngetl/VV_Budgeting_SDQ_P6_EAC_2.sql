CREATE OR ALTER view [stngetl].[VV_Budgeting_SDQ_P6_EAC_2] as 
with ciisums as 
(
	select SDQUID, sum(SunkCost) as SunkCost, sum(RemainingCost) as RemainingCII, sum(SunkCost) + sum(RemainingCost) as RequestedCost
	from stngetl.VV_Budgeting_SDQ_P6_CIIDeliverable_MatView
	group by SDQUID
),
cvsums as
(
	select SDQUID, sum(SunkCost) + sum(RemainingCost) as FutureCost
	from stngetl.Budgeting_SDQ_P6_CVWBS_Materialized
	group by SDQUID
),
joinedcosts as
(
	select a.SDQUID, a.SunkCost, a.RemainingCII, a.RequestedCost, 
	isnull(b.FutureCost,0) as FutureCost
	from ciisums as a
	left join cvsums as b on a.SDQUID = b.SDQUID
)

select a.SDQUID, isnull(c.LAMP3,0) as LAMP3, a.SunkCost, a.RemainingCII, a.RequestedCost, a.FutureCost, a.RequestedCost + a.FutureCost as EAC, 
b.EcoSysEAC as EcoSysEAC, b.IsLive as EcoSysEACIsLive
from joinedcosts as a
left join stng.VV_Budgeting_SDQ_EcoSysEAC as b on a.SDQUID = b.SDQUID
left join stng.Budgeting_SDQMain as c on a.SDQUID = c.SDQUID
GO