/****** Object:  View [stng].[VV_Admin_EndpointPermission]    Script Date: 10/21/2024 12:27:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE view [stng].[VV_Admin_EndpointPermission] as
select a.EndpointID, a.Endpoint, a.HTTPVerb, b.PermissionID, c.Permission, CONCAT(a.Endpoint, '||', a.HTTPVerb, '||', c.Permission) as UniqueID
from stng.VV_Admin_AllEndpoint as a
inner join stng.Admin_EndpointPermission as b on a.EndpointID = b.EndpointID and b.Deleted = 0
inner join stng.Admin_Permission as c on b.PermissionID = c.UniqueID and c.Deleted = 0
GO


