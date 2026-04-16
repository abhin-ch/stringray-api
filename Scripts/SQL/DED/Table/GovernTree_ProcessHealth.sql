/****** Object:  Table [stng].[GovernTree_ProcessHealth]    Script Date: 9/19/2024 12:45:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[GovernTree_ProcessHealth](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[GTID] [uniqueidentifier] NOT NULL,
	[Governance] [varchar](350) NULL,
	[Compliance] [varchar](350) NULL,
	[Excellence] [varchar](350) NULL,
	[Comment] [varchar](max) NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NULL,
	[DeletedBy] [varchar](20) NULL,
	[DeletedOn] [datetime] NULL,
	[Quarter] [varchar](20) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[GovernTree_ProcessHealth] ADD  CONSTRAINT [DF_Table_1_RAD]  DEFAULT ([stng].[GetBPTime](getdate())) FOR [Compliance]
GO

ALTER TABLE [stng].[GovernTree_ProcessHealth] ADD  CONSTRAINT [DF_GovernTree_ProcessHealth_RAD]  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[GovernTree_ProcessHealth]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_ProcessHealth]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


