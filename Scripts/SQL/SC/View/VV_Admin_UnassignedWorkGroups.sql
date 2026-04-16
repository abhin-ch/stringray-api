CREATE view [stng].[VV_Admin_UnassignedWorkGroups] as
SELECT a.UniqueID, a.WorkGroup
FROM [stng].[Admin_WorkGroup] as a
left join [stng].[Admin_WorkGroup_Map] as b on a.UniqueID = b.WorkGroupID and a.Deleted = 0
where b.UniqueID is null