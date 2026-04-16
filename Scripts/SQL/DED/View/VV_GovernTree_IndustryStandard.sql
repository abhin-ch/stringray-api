/****** Object:  View [stng].[VV_GovernTree_IndustryStandard]    Script Date: 4/17/2024 8:29:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE view [stng].[VV_GovernTree_IndustryStandard] as
select a.UniqueID as IndustryStandardID, a.OrgID, b.Org, b.OrgShort,
a.IndustryStandard, a.IndustryStandardTitle
from stng.GovernTree_IndustryStandard as a
inner join stng.General_IndustryStandardOrg as b on a.OrgID = b.UniqueID and b.Active = 1
where a.Active = 1
GO


