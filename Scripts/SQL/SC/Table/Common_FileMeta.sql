CREATE TABLE [stng].[Common_FileMeta](
	[FileMetaID] [int] IDENTITY(1,1) NOT NULL,
	[UUID] [uniqueidentifier] NULL,
	[ModuleID] [int] NULL,
	[ParentID] [nvarchar](255) NULL,
	[Name] [nvarchar](255) NULL,
	[GroupBy] [nvarchar](255) NULL,
	[CreatedBy] [nvarchar](255) NULL,
	[CreatedDate] [datetime] NULL,
	[Deleted] [bit] NULL,
	[DeletedBy] [varchar](50) NULL,
	[DeletedDate] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Common_FileMeta] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [stng].[Common_FileMeta] ADD  DEFAULT ((0)) FOR [Deleted]
GO