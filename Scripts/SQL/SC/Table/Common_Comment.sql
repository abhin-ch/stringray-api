CREATE TABLE [stng].[Common_Comment](
	[CommentID] [int] IDENTITY(1,1) NOT NULL,
	[ParentID] [nvarchar](255) NULL,
	[ParentTable] [nvarchar](255) NULL,
	[RelatedID] [nvarchar](255) NULL,
	[RelatedType] [nvarchar](255) NULL,
	[Body] [nvarchar](2000) NULL,
	[Pinned] [bit] NULL,
	[ModifiedDate] [datetime] NULL,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime] NULL,
	[RelatedTable] [nvarchar](255) NULL
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Common_Comment] ADD  DEFAULT ((0)) FOR [Pinned]
GO

ALTER TABLE [stng].[Common_Comment] ADD  DEFAULT (dateadd(hour,(-5),getdate())) FOR [CreatedDate]
GO