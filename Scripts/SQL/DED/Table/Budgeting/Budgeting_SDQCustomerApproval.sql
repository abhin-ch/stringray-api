CREATE TABLE [stng].[Budgeting_SDQCustomerApproval](
	UniqueID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
	SDQUID BIGINT REFERENCES stng.Budgeting_SDQMain(SDQUID),
	CustomerEmployeeID VARCHAR(20) REFERENCES stng.Admin_User(EmployeeID),
	Approved BIT,
	[Status] AS CASE WHEN Approved IS NULL THEN 'Awaiting Approval' WHEN Approved = 0 THEN 'Correction Required' WHEN Approved = 1 THEN 'Approved' END,
	CreatedDate DATETIME DEFAULT stng.GetDate(),
	CreatedBy VARCHAR(20) REFERENCES stng.Admin_User(EmployeeID)
)