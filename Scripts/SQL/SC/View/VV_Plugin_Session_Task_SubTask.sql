create or alter view stng.VV_Plugin_Session_Task_SubTask as
with initialquery as
(
                select distinct a.SessionID, a.SessionOwner, a.SessionTaskID, a.SessionTask, a.FullPath,
                b.SessionSubTask, b.SessionSubTaskWeight, b.SessionSubTaskID, b.SessionSubTaskOrder
                from stng.VV_Plugin_Session_Task as a
                inner join stng.Plugin_Session_Task_SubTask as b on a.SessionTaskID = b.SessionTaskID
),
taskcount as
(
                select SessionID, count(SessionTask) as taskCount
                from stng.VV_Plugin_Session_Task
                group by SessionID
)

select a.SessionID, a.SessionOwner, a.SessionTaskID, a.SessionTask, a.FullPath, a.SessionSubTask, cast(a.SessionSubTaskWeight as float) / cast(b.taskCount as float) as SessionSubTaskWeight,
a.SessionSubTaskID, a.SessionSubTaskOrder
from initialquery as a
inner join taskcount as b on a.SessionID = b.SessionID
