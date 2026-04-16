CREATE OR ALTER view [stngetl].[VV_Budgeting_SDQ_P6_Discipline] as
with legacyinfo as
(
	select a.SDQUID, b.RunID, e.PersonGroup, e.Description as PersonGroupDescription, a.RemainingMeasuringUnit as LabourRemainingUnits
	from stng.VV_Budgeting_SDQ_P6_Legacy_HourByDisciplines as a
	inner join stng.Budgeting_SDQP6Link as b on a.SDQUID = b.SDQUID and b.Active = 1
	inner join stngetl.Budgeting_SDQ_Run as c on b.RunID = c.RunID and c.Legacy = 1
	inner join temp.TT_0154_Section as d on a.SECID = d.SECID
	inner join stng.General_Organization as e on d.PersonGroup = e.PersonGroup
),
newinfo as
(
	select b.SDQUID, a.RunID, e.PersonGroup, e.Description as PersonGroupDescription,
	sum(case when c.LabourRemainingUnits  is null then 0 else c.LabourRemainingUnits end) as LabourRemainingUnits
	from stngetl.Budgeting_SDQ_P6 as a 
	inner join stng.Budgeting_SDQP6Link as b on a.RunID = b.RunID and b.Active = 1
	inner join stngetl.VV_Budgeting_P6_ActivityResource as c on a.task_id= c.task_id and a.RunID = c.runid
	inner join stng.General_Organization_P6RoleMapping as d on c.RoleName = d.P6RoleName
	inner join stng.General_Organization as e on d.PersonGroup = e.PersonGroup
	group by b.SDQUID, a.RunID, e.PersonGroup, e.Description
),
unioned as 
(
	select SDQUID, RunID,PersonGroup, PersonGroupDescription, LabourRemainingUnits
	from newinfo
	union
	select SDQUID, RunID,PersonGroup, PersonGroupDescription, LabourRemainingUnits
	from legacyinfo
)

select *
from unioned
