CREATE OR ALTER view [stngetl].[VV_Budgeting_SDQ_P6_CIIOrg] as
with legacy as
(
	select concat(ResponsibleOrganization,'||',MultiVendor) as UniqueID,
	a.SDQUID,
	b.RunID,
	ResponsibleOrganization as RespOrg,
	MultiVendor as MultipleVendor,
	G4017ActivityType,
	LaborUnits as LabourRemainingUnits,
	LaborCost as LabourRemainingCost,
	NonlaborCost as NonLabourRemainingCost,
	TotalCost as RemainingCost,
	ActualTotalCost as SunkCost,
	BLProjectTotalCost,
	TotalRequest as RequestCost,
	TotalRequest - BLProjectTotalCost as CurrentRequest
	from stng.VV_Budgeting_SDQ_P6_Legacy_ClassIIByOrg as a
	inner join stng.Budgeting_SDQP6Link as b on a.SDQUID = b.SDQUID and b.Active = 1
	inner join stngetl.Budgeting_SDQ_Run as c on b.RunID = c.RunID and c.Legacy = 1
),
initialquery as
(
	select concat(a.RespOrg,'||',a.MultipleVendor) as UniqueID, b.SDQUID, a.RunID, a.RespOrg, a.MultipleVendor,
	coalesce(sum(c.LabourRemainingUnits),0) as LabourRemainingUnits, 
	coalesce(sum(c.LabourRemainingCost),0) as LabourRemainingCost, 
	coalesce(sum(c.NonLabourRemainingCost),0) as NonLabourRemainingCost, 
	coalesce(sum(c.RemainingCost),0) as RemainingCost, 
	coalesce(sum(c.SunkCost),0) as SunkCost,
	coalesce(sum(c.RequestCost),0) as RequestCost,
	coalesce(sum(c.DQWithoutContingency),0) as DQWithoutContingency	
	from stngetl.Budgeting_SDQ_P6 as a
	inner join stng.Budgeting_SDQP6Link as b on a.RunID = b.RunID and b.Active = 1
	left join stngetl.VV_Budgeting_P6_ActivityResource as c on a.task_id = c.task_id and a.RunID = c.runid and c.Baseline = 0
	inner join stngetl.Budgeting_SDQ_Run as d on b.RunID = d.RunID and d.Legacy = 0
	where a.CV = 0 and (a.RespOrg is not null or a.MultipleVendor is not null)
	group by concat(a.RespOrg,'||',a.MultipleVendor), b.SDQUID, a.RunID, a.RespOrg, a.MultipleVendor
),
bl as 
(
	select concat(a.RespOrg,'||',a.MultipleVendor) as UniqueID, b.SDQUID, a.RunID, a.RespOrg, a.MultipleVendor,
	coalesce(sum(c.BLBudgetedCost),0) as BLProjectTotalCost
	from stngetl.Budgeting_SDQ_P6 as a
	inner join stng.Budgeting_SDQP6Link as b on a.RunID = b.RunID and b.Active = 1
	left join stngetl.VV_Budgeting_P6_ActivityResource as c on a.BaselineTaskID = c.task_id and a.RunID = c.runid and c.Baseline = 1
	inner join stngetl.Budgeting_SDQ_Run as d on b.RunID = d.RunID and d.Legacy = 0
	where a.CV = 0 and (a.RespOrg is not null or a.MultipleVendor is not null)
	group by concat(a.RespOrg,'||',a.MultipleVendor), b.SDQUID, a.RunID, a.RespOrg, a.MultipleVendor
),
secondquery as
(
	select distinct a.UniqueID, a.SDQUID, a.RunID, a.RespOrg, a.MultipleVendor,
	a.LabourRemainingUnits, a.LabourRemainingCost, a.NonLabourRemainingCost,
	a.RemainingCost, a.SunkCost, a.RequestCost,
	coalesce(b.BLProjectTotalCost,0) as BLProjectTotalCost,
	a.RequestCost - coalesce(b.BLProjectTotalCost,0) as CurrentRequest,
	a.DQWithoutContingency
	from initialquery as a
	left join bl as b on a.SDQUID = b.SDQUID and a.RunID = b.RunID and a.UniqueID = b.UniqueID
),
unioned as
(
	select UniqueID, SDQUID, RunID, RespOrg, MultipleVendor, G4017ActivityType,
	LabourRemainingUnits, LabourRemainingCost, NonLabourRemainingCost,
	RemainingCost, SunkCost, RequestCost, BLProjectTotalCost,CurrentRequest, 1 as Legacy, 0 DQWithoutContingency
	from legacy
	union 
	select UniqueID, SDQUID, RunID, RespOrg, MultipleVendor, null,
	LabourRemainingUnits, LabourRemainingCost, NonLabourRemainingCost,
	RemainingCost, SunkCost, RequestCost, BLProjectTotalCost,CurrentRequest, 0 as Legacy, DQWithoutContingency
	from secondquery
)

select *
from unioned
GO