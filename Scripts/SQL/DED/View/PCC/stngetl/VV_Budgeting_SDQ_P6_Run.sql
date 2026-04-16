CREATE OR ALTER view [stngetl].[VV_Budgeting_SDQ_P6_Run] as 
select a.SDQUID, a.RunID, a.RunSubID, 
concat(b.FirstName, ' ', b.LastName) as RABC,
a.PipelineStartTime, a.PipelineCompleteTime
from stngetl.Budgeting_SDQ_Run as a
inner join stng.Admin_User as b on a.RAB = b.EmployeeID
where PipelineCompleteTime is not null
GO