/****** Object:  Table [stng].[GovernTree_IndustryStandardDescription]    Script Date: 5/13/2024 11:51:48 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[GovernTree_IndustryStandardDescription](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Description] [varchar](200) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedBy] [varchar](20) NULL,
	[DeletedOn] [datetime] NULL,
	[IndustryStandardSection] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK__GovernTr__A2A2BAAA084B6D60] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardDescription] ADD  CONSTRAINT [DF__GovernTre__Uniqu__418481C8]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardDescription] ADD  CONSTRAINT [DF__GovernTree___RAD__4278A601]  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardDescription] ADD  CONSTRAINT [DF__GovernTre__Delet__436CCA3A]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardDescription]  WITH CHECK ADD  CONSTRAINT [FK__GovernTre__Delet__464936E5] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardDescription] CHECK CONSTRAINT [FK__GovernTre__Delet__464936E5]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardDescription]  WITH CHECK ADD  CONSTRAINT [FK__GovernTree___RAB__48317F57] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardDescription] CHECK CONSTRAINT [FK__GovernTree___RAB__48317F57]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardDescription]  WITH CHECK ADD  CONSTRAINT [FK_GovernTree_IndustryStandardDescription_IndustryStandardSection] FOREIGN KEY([IndustryStandardSection])
REFERENCES [stng].[GovernTree_IndustryStandardSection] ([UniqueID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardDescription] CHECK CONSTRAINT [FK_GovernTree_IndustryStandardDescription_IndustryStandardSection]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardDescription]  WITH CHECK ADD  CONSTRAINT [CNST_GovernTree_IndustryStandardDescription_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [deletedon] IS NOT NULL AND [deletedby] IS NOT NULL))
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardDescription] CHECK CONSTRAINT [CNST_GovernTree_IndustryStandardDescription_Deleted]
GO


