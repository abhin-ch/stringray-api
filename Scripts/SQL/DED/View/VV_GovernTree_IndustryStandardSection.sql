/****** Object:  View [stng].[VV_GovernTree_IndustryStandardSection]    Script Date: 5/27/2024 10:54:08 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE view [stng].[VV_GovernTree_IndustryStandardSection] as
select a.*,
b.IndustryStandardSection, b.IndustryStandardSectionTitle, b.UniqueID as IndustryStandardSectionID
from stng.VV_GovernTree_IndustryStandard as a
inner join stng.GovernTree_IndustryStandardSection as b on a.IndustryStandardID = b.IndustryStandardID
where b.Active = 1 and Deleted = 0
GO


