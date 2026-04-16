/****** Object:  View [stng].[VV_GovernTree_ProcessOwner]    Script Date: 11/19/2025 9:22:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE view [stng].[VV_GovernTree_ProcessOwner] as
select 
a.UniqueID
, a.GTID
,  concat(FirstName, ' ', LastName) as ProcessOwner
,a.ProcessOwner as ProcessOwnerID
from stng.GovernTree_ProcessOwner as a 
left join  [stng].[Admin_User] b on a.ProcessOwner=b.EmployeeID
GO


