CREATE view [stng].[VV_GovernTree_Actions] as
select a.UniqueID as ActionsID
, a.PHID
, a.Action
, a.Responsibility
, c.EmpName as ResponsibilityC
, a.DueDate
, a.[StatusID]
, a.RAD
, a.RAB
, b.ActionStatus as ActionStatusC
, a.[ProcessHealthSection]
from stng.GovernTree_Actions as a
left join stng.GovernTree_ActionStatus as b on a.StatusID = b.UniqueID 
left join stng.VV_Admin_UserView as c on a.Responsibility = c.EmployeeID
where a.Deleted = 0
GO


