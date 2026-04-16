CREATE VIEW [stng].[VV_Admin_VendorWorkGroups] as
SELECT a.UniqueID, a.VendorID, a.WorkGroupID, b.WorkGroup
FROM [stng].[Admin_WorkGroup_Map] as a
inner join [stng].[Admin_WorkGroup] as b on a.WorkGroupID = b.UniqueID and b.Deleted = 0 
