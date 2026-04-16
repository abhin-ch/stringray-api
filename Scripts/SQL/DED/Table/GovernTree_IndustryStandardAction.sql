/****** Object:  Table [stng].[GovernTree_IndustryStandardAction]    Script Date: 5/27/2024 11:11:57 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[GovernTree_IndustryStandardAction](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[ActionTitle] [varchar](500) NOT NULL,
	[IndustryStandardSectionID] [uniqueidentifier] NOT NULL,
	[ActionOwner] [varchar](50) NOT NULL,
	[TCD] [date] NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[LUD] [datetime] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
	[Active] [bit] NOT NULL,
	[ActionStatus] [uniqueidentifier] NULL,
	[IntID] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK__GovernTr__A2A2BAAA3389DA38] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardAction] ADD  CONSTRAINT [DF__GovernTre__Uniqu__179934F4]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardAction] ADD  CONSTRAINT [DF__GovernTree___RAD__188D592D]  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardAction] ADD  CONSTRAINT [DF__GovernTree___LUD__19817D66]  DEFAULT ([stng].[GetBPTime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardAction] ADD  CONSTRAINT [DF__GovernTre__Activ__1A75A19F]  DEFAULT ((1)) FOR [Active]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardAction]  WITH CHECK ADD  CONSTRAINT [FK__GovernTre__Actio__23FF0BD9] FOREIGN KEY([ActionStatus])
REFERENCES [stng].[GovernTree_IndustryStatus] ([UniqueID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardAction] CHECK CONSTRAINT [FK__GovernTre__Actio__23FF0BD9]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardAction]  WITH CHECK ADD  CONSTRAINT [FK__GovernTre__Indus__078CEA5D] FOREIGN KEY([IndustryStandardSectionID])
REFERENCES [stng].[GovernTree_IndustryStandardSection] ([UniqueID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardAction] CHECK CONSTRAINT [FK__GovernTre__Indus__078CEA5D]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardAction]  WITH CHECK ADD  CONSTRAINT [FK__GovernTree___LUB__1C5DEA11] FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardAction] CHECK CONSTRAINT [FK__GovernTree___LUB__1C5DEA11]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardAction]  WITH CHECK ADD  CONSTRAINT [FK__GovernTree___LUB__1D520E4A] FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardAction] CHECK CONSTRAINT [FK__GovernTree___LUB__1D520E4A]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardAction]  WITH CHECK ADD  CONSTRAINT [FK__GovernTree___LUB__1E463283] FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardAction] CHECK CONSTRAINT [FK__GovernTree___LUB__1E463283]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardAction]  WITH CHECK ADD  CONSTRAINT [FK__GovernTree___LUB__1F3A56BC] FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardAction] CHECK CONSTRAINT [FK__GovernTree___LUB__1F3A56BC]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardAction]  WITH CHECK ADD  CONSTRAINT [FK__GovernTree___RAB__202E7AF5] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardAction] CHECK CONSTRAINT [FK__GovernTree___RAB__202E7AF5]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardAction]  WITH CHECK ADD  CONSTRAINT [FK__GovernTree___RAB__21229F2E] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardAction] CHECK CONSTRAINT [FK__GovernTree___RAB__21229F2E]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardAction]  WITH CHECK ADD  CONSTRAINT [FK__GovernTree___RAB__2216C367] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardAction] CHECK CONSTRAINT [FK__GovernTree___RAB__2216C367]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardAction]  WITH CHECK ADD  CONSTRAINT [FK__GovernTree___RAB__230AE7A0] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardAction] CHECK CONSTRAINT [FK__GovernTree___RAB__230AE7A0]
GO


