/****** Object:  Table [stng].[GovernTree_IndustryStandardSectionPersonnel]    Script Date: 5/27/2024 11:13:08 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[GovernTree_IndustryStandardSectionPersonnel](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Personnel] [varchar](20) NOT NULL,
	[PersonnelType] [uniqueidentifier] NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedBy] [varchar](20) NULL,
	[DeletedOn] [datetime] NULL,
	[IndustryStandardSection] [uniqueidentifier] NOT NULL,
	[IntID] [bigint] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK__GovernTr__A2A2BAAA1110D6C0] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_GovernTree_IndustryStandardSectionPersonnel_Unique] UNIQUE NONCLUSTERED 
(
	[Personnel] ASC,
	[PersonnelType] ASC,
	[IndustryStandardSection] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSectionPersonnel] ADD  CONSTRAINT [DF__GovernTre__Uniqu__2F7AE026]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSectionPersonnel] ADD  CONSTRAINT [DF__GovernTree___RAD__32574CD1]  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSectionPersonnel] ADD  CONSTRAINT [DF__GovernTre__Delet__343F9543]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSectionPersonnel] ADD  CONSTRAINT [DF__GovernTre__Delet__3627DDB5]  DEFAULT ([stng].[GetBPTime](getdate())) FOR [DeletedOn]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSectionPersonnel]  WITH CHECK ADD  CONSTRAINT [FK__GovernTre__Delet__3533B97C] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSectionPersonnel] CHECK CONSTRAINT [FK__GovernTre__Delet__3533B97C]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSectionPersonnel]  WITH CHECK ADD  CONSTRAINT [FK__GovernTre__Perso__306F045F] FOREIGN KEY([Personnel])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSectionPersonnel] CHECK CONSTRAINT [FK__GovernTre__Perso__306F045F]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSectionPersonnel]  WITH CHECK ADD  CONSTRAINT [FK__GovernTre__Perso__31632898] FOREIGN KEY([PersonnelType])
REFERENCES [stng].[GovernTree_IndustryStandardPersonnel_Type] ([UniqueID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSectionPersonnel] CHECK CONSTRAINT [FK__GovernTre__Perso__31632898]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSectionPersonnel]  WITH CHECK ADD  CONSTRAINT [FK__GovernTree___RAB__334B710A] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSectionPersonnel] CHECK CONSTRAINT [FK__GovernTree___RAB__334B710A]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSectionPersonnel]  WITH CHECK ADD  CONSTRAINT [FK_GovernTree_IndustryStandardSectionPersonnel_IndustryStandardSection] FOREIGN KEY([IndustryStandardSection])
REFERENCES [stng].[GovernTree_IndustryStandardSection] ([UniqueID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSectionPersonnel] CHECK CONSTRAINT [FK_GovernTree_IndustryStandardSectionPersonnel_IndustryStandardSection]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSectionPersonnel]  WITH CHECK ADD  CONSTRAINT [CNST_GovernTree_IndustryStandardSectionPersonnel_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [deletedon] IS NOT NULL AND [deletedby] IS NOT NULL))
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSectionPersonnel] CHECK CONSTRAINT [CNST_GovernTree_IndustryStandardSectionPersonnel_Deleted]
GO


