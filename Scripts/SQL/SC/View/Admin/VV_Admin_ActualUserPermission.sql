/****** Object:  View [stng].[VV_Admin_ActualUserPermission]    Script Date: 10/21/2024 12:36:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE view [stng].[VV_Admin_ActualUserPermission] as
with usersuper as
(
	select a.EmployeeID, a.Attribute, a.AttributeType, a.Supersedence
	from stng.VV_Admin_UserAttribute as a
	where a.Supersedence = 1
),
initialquery as 
(
	select a.*, b.Attribute, b.AttributeType, 
	case when b.Supersedence is null then 0 else b.Supersedence end as Supersedence,
	c.Attribute as UserAttribute, c.AttributeType as UserAttributeType, c.Supersedence as UserAttributeSupersedence
	from stng.VV_Admin_AllUserPermission as a
	left join stng.VV_Admin_PermissionAttribute as b on a.PermissionID = b.PermissionID 
	left join usersuper as c on a.EmployeeID = c.EmployeeID
),
userhassuper as
(
	select x.EmployeeID
	from
	(
		select a.EmployeeID, max(cast(a.UserAttributeSupersedence as tinyint)) as HasSuper
		from initialquery as a
		group by a.EmployeeID
	) as x
	where x.HasSuper = 1
)

select EmployeeID, RoleID, [Role], PermissionID, Permission, Origin, PermissionDescription
from initialquery
where Supersedence = 1
union
select a.EmployeeID, a.RoleID, a.[Role], a.PermissionID, a.Permission, a.Origin, a.PermissionDescription
from initialquery as a
left join userhassuper as b on a.EmployeeID = b.EmployeeID
where b.EmployeeID is null and a.Supersedence = 0
GO


