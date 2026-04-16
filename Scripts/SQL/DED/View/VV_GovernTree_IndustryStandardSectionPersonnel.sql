/****** Object:  View [stng].[VV_GovernTree_IndustryStandardSectionPersonnel]    Script Date: 5/27/2024 10:55:50 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE view [stng].[VV_GovernTree_IndustryStandardSectionPersonnel] as
select a.UniqueID, d.PersonnelType, c.IndustryStandardSectionID, c.IndustryStandardSection, a.Personnel, a.IntID,
concat(b.FirstName, ' ', b.LastName) as PersonnelC
from stng.GovernTree_IndustryStandardSectionPersonnel as a
inner join stng.Admin_User as b on a.Personnel = b.EmployeeID and b.Active = 1
inner join stng.VV_GovernTree_IndustryStandardSection as c on a.IndustryStandardSection = c.IndustryStandardSectionID
inner join stng.GovernTree_IndustryStandardPersonnel_Type as d on a.PersonnelType = d.UniqueID and d.Deleted = 0
where a.Deleted = 0
GO


