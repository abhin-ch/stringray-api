/****** Object:  View [stng].[VV_Admin_Attribute]    Script Date: 10/21/2024 12:23:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE view [stng].[VV_Admin_Attribute] as
select a.UniqueID as AttributeID, a.Attribute, b.UniqueID as AttributeTypeID, b.AttributeType
from stng.Admin_Attribute as a
inner join stng.Admin_AttributeType as b on a.AttributeType = b.UniqueID and b.Deleted = 0
where a.Deleted = 0
GO


