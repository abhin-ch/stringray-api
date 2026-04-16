/****** Object:  Table [stng].[GovernTree_ActionStatus]    Script Date: 10/8/2025 9:35:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[GovernTree_ActionStatus](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[ActionStatus] [varchar](20) NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedBy] [varchar](20) NULL,
	[DeletedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[GovernTree_ActionStatus] ADD  CONSTRAINT [DF_GovernTree_ActionStatus_UniqueID]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[GovernTree_ActionStatus] ADD  CONSTRAINT [DF_GovernTree_ActionStatus_RAD]  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[GovernTree_ActionStatus] ADD  CONSTRAINT [DF_GovernTree_ActionStatus_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[GovernTree_ActionStatus]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_ActionStatus]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


