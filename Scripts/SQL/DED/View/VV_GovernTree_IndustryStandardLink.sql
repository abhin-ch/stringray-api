/****** Object:  View [stng].[VV_GovernTree_IndustryStandardLink]    Script Date: 4/17/2024 8:31:03 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create view [stng].[VV_GovernTree_IndustryStandardLink] as
select a.UniqueID, a.GTID, b.IndustryStandard, b.IndustryStandardTitle, c.Org, c.OrgShort
from stng.GovernTree_IndustryStandardLink as a
inner join stng.GovernTree_IndustryStandard as b on a.IndustryStandard = b.UniqueID and b.Active = 1
inner join stng.General_IndustryStandardOrg as c on b.OrgID = c.UniqueID and c.Active = 1
GO


