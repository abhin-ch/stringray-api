/****** Object:  View [stng].[VV_GovernTree_JobAidLink]    Script Date: 4/17/2024 8:32:53 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE view [stng].[VV_GovernTree_JobAidLink] as
select a.UniqueID, a.GTID, a.JobAidURL, a.JobAidID--, b.DocumentNo, b.Revision, b.DocumentTitle
from stng.GovernTree_JobAidLink as a 
--left join stng.VV_GovernTree_JobAid as b on a.JobAidID =cast( b.JobAidID as varchar)
GO


