create view stng.VV_Plugin_Session_Status as
with totaltasks as
(
	select SessionID, count(InstanceID) as taskCount 
	from stng.VV_Plugin_Session_Task
	group by SessionID
),
failedtasks as
(
	select SessionID, count(InstanceID) as taskCount 
	from stng.VV_Plugin_Session_Task
	where TaskStatus = 'Failed'
	group by SessionID
),
completedtasks as
(
	select SessionID, count(InstanceID) as taskCount 
	from stng.VV_Plugin_Session_Task
	where TaskStatus = 'Completed'
	group by SessionID
),
inprogresstasks as
(
	select SessionID, count(InstanceID) as taskCount 
	from stng.VV_Plugin_Session_Task
	where TaskStatus = 'In Progress'
	group by SessionID
),
taskcounts as 
(
	select distinct a.SessionID, 
	e.taskCount as TotalCount,
	coalesce(b.taskCount, 0) as FailedCount,
	coalesce(c.taskCount, 0) as CompletedCount,
	coalesce(d.taskCount, 0) as InProgressCount
	from stng.VV_Plugin_Session_Task as a
	inner join totaltasks as e on a.SessionID = e.SessionID
	left join failedtasks as b on a.SessionID = b.SessionID
	left join completedtasks as c on a.SessionID = c.SessionID
	left join inprogresstasks as d on a.SessionID = d.SessionID
)

select distinct a.SessionID, a.SessionOwner, 
case when b.FailedCount > 0 then 'Failed'
when b.TotalCount = b.CompletedCount then 'Completed'
when b.InProgressCount > 0 then 'In Progress'
end as SessionStatus
from stng.VV_Plugin_Session_Task as a
inner join taskcounts as b on a.SessionID = b.SessionID