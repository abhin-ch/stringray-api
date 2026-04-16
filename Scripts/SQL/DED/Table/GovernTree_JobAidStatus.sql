/****** Object:  Table [stng].[GovernTree_JobAidStatus]    Script Date: 5/13/2024 12:01:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[GovernTree_JobAidStatus](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[JAStatus] [varchar](50) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[JAStatus] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[GovernTree_JobAidStatus] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[GovernTree_JobAidStatus] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[GovernTree_JobAidStatus] ADD  CONSTRAINT [DF_GovernTree_JobAidStatus_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[GovernTree_JobAidStatus]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_JobAidStatus]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_JobAidStatus]  WITH CHECK ADD  CONSTRAINT [CNST_stng_GovernTree_JobAidStatus_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[GovernTree_JobAidStatus] CHECK CONSTRAINT [CNST_stng_GovernTree_JobAidStatus_Deleted]
GO


