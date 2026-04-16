/****** Object:  View [stng].[VV_GovernTree_ProcessHealth]    Script Date: 9/27/2024 2:35:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO









ALTER view [stng].[VV_GovernTree_ProcessHealth] as
select a.UniqueID, 
	a.GTID, 
	a.Governance,
	d.StatusColour as GovernanceColour, 
	a.Compliance, 
	e.StatusColour as ComplianceColour,
	a.Excellence, 
	f.StatusColour as ExcellenceColour,
	a.Comment, a.RAD, 
	a.Deleted, 
	a.DeletedBy, 
	a.DeletedOn, 
	concat(FirstName, ' ', LastName) as RAB,
	a.Quarter,
	c.[DocumentNo] as DocumentNoC



from stng.GovernTree_ProcessHealth as a left join  [stng].[Admin_User] b on a.RAB=b.EmployeeID
left join [stng].[VV_GovernTree_Main] as c on a.GTID = c.UniqueID
left join [stng].[GovernTree_ProcessHealth_Matrix] as d on a.Governance = d.Description
left join [stng].[GovernTree_ProcessHealth_Matrix] as e on a.Compliance = e.Description
left join [stng].[GovernTree_ProcessHealth_Matrix] as f on a.Excellence = f.Description
GO


