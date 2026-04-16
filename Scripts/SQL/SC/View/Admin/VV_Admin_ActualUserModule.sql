/****** Object:  View [stng].[VV_Admin_ActualUserModule]    Script Date: 10/21/2024 12:37:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE view [stng].[VV_Admin_ActualUserModule] as
with moduleattributes as
(
	select Attribute, AttributeID
	from stng.VV_Admin_Attribute
	where AttributeType = 'Module'
),
moduleendpoints as
(
	select a.UniqueID as EndpointID, a.HTTPVerb, a.[Endpoint], c.Attribute as Module
	from stng.Admin_Endpoint as a
	inner join stng.Admin_EndpointAttribute as b on a.UniqueID = b.EndpointID
	inner join moduleattributes as c on b.AttributeID = c.AttributeID
	where a.Deleted = 0 and b.Deleted = 0
)

select distinct b.EmployeeID, c.Color, c.NameShort as Name, c.Icon, c.Path, c.Department, c.Description
from moduleendpoints as a
inner join stng.VV_Admin_ActualUserEndpoint as b on a.EndpointID = b.EndpointID
inner join stng.Admin_Module as c on a.Module = c.NameShort and c.Active = 1
GO


