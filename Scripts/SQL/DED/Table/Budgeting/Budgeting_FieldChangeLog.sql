CREATE TABLE stng.Budgeting_FieldChangeLog
(
	UniqueID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	RecordType VARCHAR(4) CHECK (RecordType IN ('SDQ','DVN','PBRF')),
	RecordTypeUniqueID BIGINT,
	[TypeID] UNIQUEIDENTIFIER REFERENCES stng.Common_ValueLabel(UniqueID),
	[Group] NVARCHAR(255),
	FieldName NVARCHAR(255),
	FromValue NVARCHAR(4000),
	ToValue NVARCHAR(4000),
	CreatedBy VARCHAR(20) REFERENCES stng.Admin_User(EmployeeID),
	CreatedDate DATETIME DEFAULT GETDATE()
)