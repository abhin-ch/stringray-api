CREATE TABLE stng.Admin_Impersonate
(
	UniqueID INT IDENTITY(1,1),
	EmployeeID VARCHAR(20),
	ImpersonateUserEmployeeID VARCHAR(20),
	Active BIT DEFAULT 0,
	CreatedDate DATETIME DEFAULT stng.GetDate(),
	CreatedBy VARCHAR(20),
	LastImpersonateDate DATETIME,
	CONSTRAINT CNST_Admin_Impersonate_Unique UNIQUE(EmployeeID, ImpersonateUserEmployeeID)
)