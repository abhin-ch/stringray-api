CREATE TABLE stng.Budgeting_SDQSMApproval
(
	UniqueID UNIQUEIDENTIFIER DEFAULT NEWID(),
	SDQUID BIGINT REFERENCES stng.Budgeting_SDQMain(SDQUID),
	SectionID BIGINT REFERENCES stng.General_MPLOrganizationMap(UniqueID), 
	SectionManagerID VARCHAR(20) REFERENCES stng.Admin_User(EmployeeID),
	RemainingHours INT,
	Approved BIT,
	[Status] AS CASE WHEN Approved IS NULL THEN 'Awaiting Approval' WHEN Approved = 0 THEN 'Correction Required' WHEN Approved = 1 THEN 'Approved' END,
	LAMP4 BIT,
	CreatedDate DATETIME DEFAULT stng.GetDate(),
	CreatedBy VARCHAR(20) REFERENCES stng.Admin_User(EmployeeID),
	DeletedDate DATETIME,
	DeletedBy varchar(20) NULL,
	Deleted AS (CASE WHEN DeletedDate IS NOT NULL THEN 1 ELSE 0 END),
)