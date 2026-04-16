CREATE view [stng].[VV_TOQLite_VendorDeliverable_Activity] as
select a.UniqueID as VendorDeliverableID, a.TOQLiteID, 
b.Activity, b.ActivityType, b.ActivityHours, b.ActivityStart, b.ActivityFinish, b.UniqueID as ActivityUniqueID, b.SortOrder
from stng.TOQLite_VendorDeliverable as a
inner join stng.TOQLite_VendorDeliverable_Activity as b on a.UniqueID = b.VendorDeliverableID
inner join stng.ER_StandardDeliverable as c on a.DeliverableID = c.UniqueID
where a.Deleted = 0 and b.Deleted = 0 and c.Active = 1
GO