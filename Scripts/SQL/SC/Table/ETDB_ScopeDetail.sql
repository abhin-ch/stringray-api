CREATE TABLE [stng].[ETDB_ScopeDetail](
	[SDID] [int] IDENTITY(1,1) NOT NULL,
	[SheetID] [nvarchar](255) NULL,
	[StateID] [nvarchar](255) NULL,
	[Type] [nvarchar](255) NULL,
	[Number] [nvarchar](255) NULL,
	[Description] [nvarchar](2000) NULL,
	[Comment] [nvarchar](255) NULL,
	[Position] [int] NULL,
	[Hours] [int] NULL,
	[EstimatedHours] [int] NULL,
	[AssignedUserID] [nvarchar](255) NULL,
	[Issues] [bit] NULL,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [stng].[ETDB_ScopeDetail] ADD  DEFAULT ((0)) FOR [Issues]
GO

ALTER TABLE [stng].[ETDB_ScopeDetail] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO