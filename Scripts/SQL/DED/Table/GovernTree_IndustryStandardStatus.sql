/****** Object:  Table [stng].[GovernTree_IndustryStandardStatus]    Script Date: 4/17/2024 8:37:58 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[GovernTree_IndustryStandardStatus](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Status] [varchar](200) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedBy] [varchar](20) NULL,
	[DeletedOn] [datetime] NULL,
	[IndustryStandardSection] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_GovernTree_IndustryStandardStatus_Unique] UNIQUE NONCLUSTERED 
(
	[Status] ASC,
	[IndustryStandardSection] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardStatus] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardStatus] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardStatus] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardStatus] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [DeletedOn]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardStatus]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardStatus]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardStatus]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardStatus]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardStatus]  WITH CHECK ADD  CONSTRAINT [FK_GovernTree_IndustryStandardStatus_IndustryStandardSection] FOREIGN KEY([IndustryStandardSection])
REFERENCES [stng].[GovernTree_IndustryStandardSection] ([UniqueID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardStatus] CHECK CONSTRAINT [FK_GovernTree_IndustryStandardStatus_IndustryStandardSection]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardStatus]  WITH CHECK ADD  CONSTRAINT [CNST_GovernTree_IndustryStandardStatus_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [deletedon] IS NOT NULL AND [deletedby] IS NOT NULL))
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardStatus] CHECK CONSTRAINT [CNST_GovernTree_IndustryStandardStatus_Deleted]
GO


