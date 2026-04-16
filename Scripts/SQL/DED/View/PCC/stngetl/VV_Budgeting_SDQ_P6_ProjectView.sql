CREATE OR ALTER view [stngetl].[VV_Budgeting_SDQ_P6_ProjectView] as
with legacyinfo as
(
	select a.SDQUID, b.RunID, a.WBSName as wbs_name, a.activityid, a.activityname, a.BPDQCommitment, a.G4008BPDeliverableType, a.G4009BPResponsibleDiscipline, a.InterProjectIntegrations as InterProjectIntegration,
	case when a.[Start] like '%A' then left(a.[Start],len(a.[Start]) - 2) 	
	else replace(a.[Start],'*','') end as CurrentStart, 
	case when a.[Finish] like '%A' then left(a.[Finish],len(a.[Finish]) - 2) 	
	else replace(a.[Finish],'*','') end as CurrentEnd, 
	case when a.[Start] like '%A'  then 1 else 0 end as StartActualized,
	case when a.[Finish] like '%A'  then 1 else 0 end as EndActualized,
	null as baselinestart, null as baselineend
	from stng.VV_Budgeting_SDQ_P6_Legacy_Projects as a
	inner join stng.Budgeting_SDQP6Link as b on a.SDQUID = b.SDQUID and b.Active = 1
	inner join stngetl.Budgeting_SDQ_Run as c on b.RunID = c.RunID and c.Legacy = 1
),
newinfo as
(
	select b.SDQUID, a.RunID, a.wbs_name, a.activityid, a.activityname, a.BPDQCommitment, a.G4008BPDeliverableType, a.G4009BPResponsibleDiscipline, a.InterProjectIntegration,
	a.CurrentStart, a.CurrentEnd, a.StartActualized, a.EndActualized, a.baselinestart, a.baselineend
	from stngetl.Budgeting_SDQ_P6 as a
	inner join stng.Budgeting_SDQP6Link as b on a.RunID = b.RunID and b.Active = 1
	inner join stngetl.Budgeting_SDQ_Run as c on b.RunID = c.RunID and c.Legacy = 0
	where a.milestonewbs = 1 and a.activityid is not null
),
unioned as 
(
	select SDQUID, RunID, wbs_name, activityid, activityname, BPDQCommitment, G4008BPDeliverableType, G4009BPResponsibleDiscipline, InterProjectIntegration,
	CurrentStart, CurrentEnd, StartActualized, EndActualized, BaselineStart, BaselineEnd
	from newinfo
	union
	select SDQUID, RunID, wbs_name, activityid, activityname, BPDQCommitment, G4008BPDeliverableType, G4009BPResponsibleDiscipline, InterProjectIntegration,
	CurrentStart, CurrentEnd, StartActualized, EndActualized, BaselineStart, BaselineEnd
	from legacyinfo
)

select *
from unioned