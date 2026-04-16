CREATE TABLE [stng].Common_ValueLabel(
	UniqueID uniqueidentifier PRIMARY KEY DEFAULT NEWID(),
	[ModuleID] uniqueidentifier REFERENCES stng.Admin_Module(UniqueID),
	[Group] NVARCHAR(255) NOT NULL,
	[Field] NVARCHAR(255) NOT NULL,
	[Label] NVARCHAR(255),
	[Value] NVARCHAR(1000),
	[Value1] NVARCHAR(255),
	[Value2] NVARCHAR(255),
	[Active] BIT DEFAULT 1,
	[Sort] SMALLINT,
	CreatedBy VARCHAR(20) REFERENCES stng.Admin_User(EmployeeID),
	CreatedDate DATETIME DEFAULT stng.GetDate()
)

ALTER TABLE stng.Common_ValueLabel ALTER COLUMN Value1 NVARCHAR(1000)
ALTER TABLE stng.Common_ValueLabel ALTER COLUMN Value2 NVARCHAR(1000)
ALTER TABLE stng.Common_ValueLabel ADD Value3 NVARCHAR(1000)