/****** Object:  View [stng].[VV_Admin_Endpoint_Expression]    Script Date: 10/21/2024 12:45:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create view [stng].[VV_Admin_Endpoint_Expression] as
select a.EndpointID, a.Endpoint, a.HTTPVerb, c.ExpressionName, c.Expression
from stng.VV_Admin_AllEndpoint as a
inner join stng.Admin_Endpoint_RSS as b on a.EndpointID = b.EndpointID
inner join stng.Expression_Main as c on b.ExpressionID = c.ExpressionID and c.Deleted = 0
GO


