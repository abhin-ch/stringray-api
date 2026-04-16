/****** Object:  View [stng].[VV_Admin_AllEndpoint]    Script Date: 10/21/2024 12:22:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create view [stng].[VV_Admin_AllEndpoint] as
select a.UniqueID as EndpointID, a.[Endpoint], a.HTTPVerb
from stng.Admin_Endpoint as a
where a.Deleted = 0
GO


