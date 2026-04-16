/****** Object:  View [stng].[VV_Admin_ActualUserEndpoint]    Script Date: 10/21/2024 12:36:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE view [stng].[VV_Admin_ActualUserEndpoint] as
with authenticationep as
(
	select b.EmployeeID, a.EndpointID, a.Endpoint, a.HTTPVerb
	from stng.VV_Admin_EndpointAttribute as a, stng.Admin_User as b
	where a.Attribute = 'AuthenticationOnly'
)

select distinct a.EmployeeID, a.PermissionID, a.Permission, b.EndpointID, b.Endpoint, b.HTTPVerb, 0 as AuthOnly
from stng.VV_Admin_ActualUserPermission as a
inner join stng.VV_Admin_EndpointPermission as b on a.PermissionID = b.PermissionID 
union
select EmployeeID, null as PermissionID, null as Permission, EndpointID, Endpoint, HTTPVerb, 1 as AuthOnly
from authenticationep 
GO


