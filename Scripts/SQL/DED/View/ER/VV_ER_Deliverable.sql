CREATE VIEW [stng].[VV_ER_Deliverable]
AS
SELECT a.UniqueID, a.ERID, a.DeliverableID, 
a.RAB, a.RAD, a.EstimatedHours, b.Deliverable AS DelName, a.InHouse, a.Vendor, e.VendorName,
concat(d.FirstName, ' ', d.LastName) as RABC
FROM stng.ER_Deliverable_Temp as a
inner join stng.VV_ER_StandardDeliverable as b on a.DeliverableID = b.UniqueID 
and b.ActivityType = case when a.InHouse = 1 then 'Internal' else 'External' end
inner join stng.Admin_User as d on a.RAB = d.EmployeeID
left join stng.General_Vendor as e on a.vendor = e.UniqueID
where a.Deleted = 0