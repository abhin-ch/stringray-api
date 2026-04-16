/****** Object:  Table [stng].[SST_Comment]    Script Date: 12/5/2025 11:30:19 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[SST_Comment](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[SSTID] [uniqueidentifier] NOT NULL,
	[CommentType] [uniqueidentifier] NOT NULL,
	[Comment] [varchar](max) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[SST_Comment] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[SST_Comment] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[SST_Comment]  WITH CHECK ADD FOREIGN KEY([CommentType])
REFERENCES [stng].[SST_StateType] ([UniqueID])
GO

ALTER TABLE [stng].[SST_Comment]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[SST_Comment]  WITH CHECK ADD FOREIGN KEY([SSTID])
REFERENCES [stng].[SST_Main] ([UniqueID])
GO

ALTER TABLE [stng].[SST_Comment]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[SST_Comment]  WITH CHECK ADD  CONSTRAINT [stng_SST_Comment_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[SST_Comment] CHECK CONSTRAINT [stng_SST_Comment_Deleted]
GO


