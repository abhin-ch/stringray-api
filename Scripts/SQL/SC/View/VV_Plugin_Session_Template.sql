create or alter view stng.VV_Plugin_Session_Template as
select a.SessionTemplateID, a.SessionTemplate, 
c.SessionTaskID, c.SessionTask, c.SessionTaskPath, 
d.SessionTaskPID, d.ParameterName, d.Mandatory
from stng.Plugin_Session_Template as a
inner join stng.Plugin_Session_Template_Task as b on a.SessionTemplateID = b.SessionTemplateID
inner join stng.Plugin_Session_Task as c on b.SessionTaskID = c.SessionTaskID
left join stng.Plugin_Session_Task_Parameter as d on c.SessionTaskID = d.SessionTaskID