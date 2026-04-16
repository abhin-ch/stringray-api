/****** Object:  Table [stng].[GovernTree_Actions]    Script Date: 10/8/2025 9:34:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[GovernTree_Actions](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[PHID] [bigint] NOT NULL,
	[Action] [varchar](max) NULL,
	[Responsibility] [varchar](20) NULL,
	[DueDate] [datetime] NULL,
	[StatusID] [uniqueidentifier] NULL,
	[ProcessHealthSection] [varchar](50) NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedBy] [varchar](20) NULL,
	[DeletedOn] [datetime] NULL,
 CONSTRAINT [PK__GovernTree_A__A2A2BAAA4F830CE8] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[GovernTree_Actions] ADD  CONSTRAINT [DF_GovernTree_Actions_RAD]  DEFAULT ([stng].[getbptime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[GovernTree_Actions] ADD  CONSTRAINT [DF_GovernTree_Actions_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[GovernTree_Actions]  WITH CHECK ADD  CONSTRAINT [FK__GovernTree_Act__Delet__275079D0] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_Actions] CHECK CONSTRAINT [FK__GovernTree_Act__Delet__275079D0]
GO

ALTER TABLE [stng].[GovernTree_Actions]  WITH CHECK ADD  CONSTRAINT [FK__GovernTree_Acti__RAB__265C5597] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_Actions] CHECK CONSTRAINT [FK__GovernTree_Acti__RAB__265C5597]
GO

ALTER TABLE [stng].[GovernTree_Actions]  WITH CHECK ADD  CONSTRAINT [FK__GovernTree_Actions__Responsibility] FOREIGN KEY([Responsibility])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_Actions] CHECK CONSTRAINT [FK__GovernTree_Actions__Responsibility]
GO

ALTER TABLE [stng].[GovernTree_Actions]  WITH CHECK ADD  CONSTRAINT [FK__GovernTree_Actions__Status] FOREIGN KEY([StatusID])
REFERENCES [stng].[GovernTree_ActionStatus] ([UniqueID])
GO

ALTER TABLE [stng].[GovernTree_Actions] CHECK CONSTRAINT [FK__GovernTree_Actions__Status]
GO


