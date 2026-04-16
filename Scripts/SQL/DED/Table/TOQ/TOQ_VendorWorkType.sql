CREATE TABLE stng.TOQ_VendorWorkType (
	UniqueID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
	VendorID UNIQUEIDENTIFIER REFERENCES stng.Common_ValueLabel(UniqueID),
	WorkTypeID UNIQUEIDENTIFIER REFERENCES stng.Common_ValueLabel(UniqueID),
	Tier VARCHAR(2),
	CreatedDate DATETIME DEFAULT stng.GetDate(),
	CreatedBy VARCHAR(20) REFERENCES stng.Admin_User(EmployeeID)
)
