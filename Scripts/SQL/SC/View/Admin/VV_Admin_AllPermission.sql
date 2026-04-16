/****** Object:  View [stng].[VV_Admin_AllPermission]    Script Date: 10/21/2024 12:22:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

















CREATE view [stng].[VV_Admin_AllPermission] as
with recurse(ParentPermissionID, PermissionID, PermissionPath, [Level]) as
(
	select ParentPermissionID, PermissionID, cast(PermissionID as varchar(max)), 1
	from stng.Admin_PermissionHierarchy
	where ParentPermissionID is null and Deleted = 0
	union all
	select a.ParentPermissionID, a.PermissionID, cast(concat(b.PermissionPath, '|',a.PermissionID) as varchar(max)), b.[Level] + 1
	from stng.Admin_PermissionHierarchy as a
	inner join recurse as b on a.ParentPermissionID = b.PermissionID
	where a.Deleted = 0
)
,
recurseflatten as
(
	select x.ParentPermissionID, x.PermissionID, y.Permission, z.Permission as ParentPermission, y.PermissionDescription
	from
	(
		select value as ParentPermissionID, PermissionID
		from recurse
		cross apply string_split(PermissionPath, '|') 
	) x
	inner join stng.Admin_Permission as y on x.PermissionID = y.UniqueID and y.Deleted = 0
	left join stng.Admin_Permission as z on x.ParentPermissionID = z.UniqueID and z.Deleted = 0
	where x.PermissionID <> x.ParentPermissionID or y.UniqueID = '5E7FB06C-EDF5-499C-8F6A-F5DBD2640BCE' --SysAdmin
)

select ParentPermissionID, PermissionID, Permission, ParentPermission, PermissionDescription
from recurseflatten
--where Permission = 'VDUAdmin'

--select a.PermissionID, a.ParentPermissionID, a.PermissionPath, y.Permission, z.Permission as ParentPermission
--from recurse as a
--inner join stng.Admin_Permission as y on a.PermissionID = y.UniqueID and y.Deleted = 0
--left join stng.Admin_Permission as z on a.ParentPermissionID = z.UniqueID and z.Deleted = 0
--where y.Permission = 'VDUAdmin'
--GO


GO


