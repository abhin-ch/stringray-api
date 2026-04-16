CREATE TABLE [stng].Common_FileMeta(
	[FileMetaID] [int] IDENTITY(1,1) PRIMARY KEY,
	[UUID] uniqueidentifier NULL,
	[ModuleID] uniqueidentifier REFERENCES stng.Admin_Module(UniqueID),
	[ParentID] NVARCHAR(255),
	[Name] [nvarchar](255) NULL,
	[GroupBy] NVARCHAR(255) NULL,
	[CreatedBy]  VARCHAR(20) REFERENCES stng.Admin_User(EmployeeID),
	[CreatedDate] DATETIME DEFAULT stng.GetDate(),
	[Deleted] BIT DEFAULT 0,
	[DeletedBy] VARCHAR(20) REFERENCES stng.Admin_User(EmployeeID),
	[DeletedDate] DATETIME
)

ALTER TABLE stng.Common_FileMeta ADD Archive BIT DEFAULT 0