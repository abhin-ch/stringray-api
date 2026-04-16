CREATE TABLE stng.Budgeting_SDQApprovalStatusLog
(
	UniqueID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
	SDQUID BIGINT REFERENCES stng.Budgeting_SDQMain(SDQUID),
	CustomerID VARCHAR(20) REFERENCES stng.Admin_User(EmployeeID),
	SectionID BIGINT REFERENCES stng.General_MPLOrganizationMap(UniqueID),
	SectionManagerID VARCHAR(20) REFERENCES stng.Admin_User(EmployeeID),
	[Status] NVARCHAR(255),
	Comment NVARCHAR(1000),
	CreatedDate DATETIME DEFAULT stng.GetDate(),
	CreatedBy VARCHAR(20) 
)