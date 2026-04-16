CREATE view [stng].[VV_ER_Resource] as
select a.UniqueID, a.ERID, a.[Resource], b.EmpName as ResourceC, a.ResourceType, c.ResourceType as ResourceTypeC, a.RAB, a.RAD
from [stng].[ER_Resource] as a
inner join [stng].[VV_Admin_UserView] as b on a.Resource = b.EmployeeID
inner join [stng].[ER_Resource_Type] as c on a.ResourceType = c.UniqueID and c.Deleted = 0
where a.Deleted = 0