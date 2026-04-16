create view [stng].[VV_ER_Prerequisite] as
select a.UniqueID, a.ERID, a.Prerequisite, b.PrerequisiteType,
a.RAD as AddedOn, case when a.RAB = 'SYSTEM' then a.RAB else CONCAT(c.firstname, ' ', c.LastName) end as AddedBy,
a.Completed, a.CompletedOn, null as CompletionCondition
from stng.ER_Prerequisite as a
inner join stng.ER_Prerequisite_Type as b on a.PrerequisiteType = b.UniqueID
inner join stng.Admin_User as c on a.RAB = c.EmployeeID