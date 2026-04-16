create view stng.VV_Plugin_Session_Task as
with latestinstancetaskstatuses as 
(
	select x.InstanceID, z.SessionStatus as TaskStatus, x.TaskStatusDate
	from
	(
		select a.InstanceID, max(b.RAD) as TaskStatusDate
		from stng.Plugin_Session_Task_Instance as a
		inner join stng.Plugin_Session_Task_Instance_StatusLog as b on a.InstanceID = b.InstanceID
		group by a.InstanceID
	) x
	inner join stng.Plugin_Session_Task_Instance_StatusLog as y on x.InstanceID = y.InstanceID and x.TaskStatusDate = y.RAD
	inner join stng.Plugin_Session_Status as z on y.SessionStatusID = z.SessionStatusID
),
initialquery as 
(
	select a.SessionID, a.RAB as SessionOwner, b.InstanceID, b.SessionTaskID, c.SessionTask, c.SessionTaskPath, d.TaskStatus, d.TaskStatusDate
	from stng.Plugin_Session as a
	inner join stng.Plugin_Session_Task_Instance as b on a.SessionID = b.SessionID
	inner join stng.Plugin_Session_Task as c on b.SessionTaskID = c.SessionTaskID
	inner join latestinstancetaskstatuses as d on b.InstanceID = d.InstanceID
),
params as
(
	select a.InstanceID, string_agg(concat(c.ParameterName,'=',b.ParameterValue),'&') as QueryParams
	from initialquery as a
	inner join stng.Plugin_Session_Task_Parameter_Instance as b on a.InstanceID = b.InstanceID
	inner join stng.Plugin_Session_Task_Parameter as c on b.SessionTaskPID = c.SessionTaskPID
	group by a.InstanceID
),
paths as
(
	select a.SessionID, a.SessionOwner, a.InstanceID, a.SessionTaskID, a.SessionTask, a.TaskStatus, a.TaskStatusDate, b.QueryParams,
	case when b.QueryParams is not null then CONCAT('stng:',a.SessionTaskPath,'?',b.QueryParams) else concat('stng:',a.SessionTaskPath) end as FullPath
	from initialquery as a
	left join params as b on a.InstanceID = b.InstanceID
)

select *
from paths