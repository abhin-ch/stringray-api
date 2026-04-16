ALTER view [stng].[VV_GovernTree_ProcessHealthExport] as

	with governance as (
		select
		a.[DocumentNo] as DocumentNumber,
		c.UniqueID, 
		c.GTID,
		a.ProcessOwnerC as ProcessOwner,
		a.Title,
		a.[Status],
		c.Governance,
		d.StatusColour as GovernanceColour, 
		c.Compliance, 
		e.StatusColour as ComplianceColour,
		c.Excellence, 
		f.StatusColour as ExcellenceColour,
		c.Comment, 
		c.RAD as AddDate, 
		c.Deleted, 
		c.DeletedBy, 
		c.DeletedOn, 
		concat(FirstName, ' ', LastName) as AddedBy,
		c.Quarter
		from stng.[VV_GovernTree_Main] as a
		left join [stng].GovernTree_ProcessHealth as c on c.GTID = a.UniqueID
		left join  [stng].[Admin_User] b on c.RAB=b.EmployeeID
		left join [stng].[GovernTree_ProcessHealth_Matrix] as d on c.Governance = d.Description
		left join [stng].[GovernTree_ProcessHealth_Matrix] as e on c.Compliance = e.Description
		left join [stng].[GovernTree_ProcessHealth_Matrix] as f on c.Excellence = f.Description
	),
	processhealth as (
		SELECT DISTINCT
		c.DocumentNumber,
		c.Title,
		c.[Status],
		c.ProcessOwner,
		c.GovernanceColour,
		c.ComplianceColour,
		c.ExcellenceColour,
		c.Comment,
		c.[Quarter],
		c.AddDate,
		c.AddedBy
		FROM governance AS c
		WHERE c.AddDate = (
			SELECT MAX(d.AddDate) 
			FROM governance AS d 
			WHERE d.DocumentNumber = c.DocumentNumber
		)
		AND c.Deleted = 0
	)

	select 
	DocumentNumber
	, Title
	, [Status]
	, ProcessOwner
	, GovernanceColour
	, ComplianceColour
	, ExcellenceColour
	, Comment
	, [Quarter]
	, AddDate
	, AddedBy
	from processhealth
	union
	select 	
	a.[DocumentNo] as DocumentNumber,
	a.Title,
	a.[Status],
	a.ProcessOwnerC as ProcessOwner,
	null,
	null,
	null,
	null,
	null,
	null,
	null
	from stng.VV_GovernTree_Main as a
	left join processhealth as b on a.DocumentNo = b.DocumentNumber
	where b.DocumentNumber is null and a.SubType in ('STND - ADMINISTRATIVE STANDARDS', 'PROC - PROCEDURES')
	
GO


