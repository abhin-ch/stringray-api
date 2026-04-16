CREATE TYPE [stng].[Budgeting_MinorChange] AS TABLE(
	UniqueID NVARCHAR(255),
	ChangeType NVARCHAR(255),
	[Comment] [nvarchar](4000) NULL,
	[PCSApply] NVARCHAR(255),
	[PCSComment] NVARCHAR(4000),
	[AdminUpdated] NVARCHAR(255)
)