/****** Object:  View [stng].[VV_Admin_PermissionAttribute]    Script Date: 10/21/2024 12:35:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE view [stng].[VV_Admin_PermissionAttribute] as
with attributes as
(
	select a.UniqueID as AttributeID, a.Attribute, b.AttributeType, b.UniqueID as AttributeTypeID, b.Supersedence
	from stng.Admin_Attribute as a
	inner join stng.Admin_AttributeType as b on a.AttributeType = b.UniqueID and b.Deleted = 0
	where a.Deleted = 0
)

select a.UniqueID, b.UniqueID as PermissionID, b.[Permission], c.Attribute, c.AttributeID,
case when a.AttributeTypeID is null then c.AttributeTypeID else a.AttributeTypeID end as AttributeTypeID,
case when a.AttributeTypeID is null then c.AttributeType else d.AttributeType end as AttributeType,
case when a.AttributeTypeID is null then c.Supersedence else d.Supersedence end as Supersedence
from stng.Admin_PermissionAttribute as a
inner join stng.Admin_Permission as b on a.PermissionID = b.UniqueID
left join attributes as c on a.AttributeID = c.AttributeID
left join stng.Admin_AttributeType as d on a.AttributeTypeID = d.UniqueID and d.Deleted = 0
where a.Deleted = 0
GO


