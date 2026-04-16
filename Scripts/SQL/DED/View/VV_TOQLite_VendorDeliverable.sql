/****** Object:  View [stng].[VV_TOQLite_VendorDeliverable]    Script Date: 11/19/2025 9:21:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE view [stng].[VV_TOQLite_VendorDeliverable] as
select a.UniqueID, d.ERID, a.TOQLiteID, a.DeliverableID, b.Deliverable, a.DeliverableCost,
sum(c.ActivityHours) as DeliverableHours, min(c.ActivityStart) as StartDate, max(c.ActivityFinish) as EndDate,
d.VendorID
from stng.TOQLite_VendorDeliverable as a
inner join stng.ER_StandardDeliverable as b on a.DeliverableID = b.UniqueID
left join stng.TOQLite_VendorDeliverable_Activity as c on a.UniqueID = c.VendorDeliverableID and c.Deleted = 0
left join stng.TOQLite_Main as d on a.TOQLiteID = d.UniqueID
where a.Deleted = 0
group by a.UniqueID, a.TOQLiteID, a.DeliverableID, b.Deliverable, a.DeliverableCost, VendorID, ERID
GO


