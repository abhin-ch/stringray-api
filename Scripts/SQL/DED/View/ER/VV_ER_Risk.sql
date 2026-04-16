CREATE view [stng].[VV_ER_Risk] as
select a.UniqueID, a.ERID, a.Risk,
case when a.RAB <> 'SYSTEM' then concat(b.FirstName, ' ',b.LastName) else a.RAB end as Originator,
a.RAD as RiskDate
from stng.ER_Risk as a
inner join stng.Admin_User as b on a.RAB = b.EmployeeID
where a.Deleted = 0;