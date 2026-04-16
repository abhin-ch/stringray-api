/****** Object:  Table [stng].[GovernTree_IndustryStandardSection]    Script Date: 5/27/2024 11:12:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[GovernTree_IndustryStandardSection](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[IndustryStandardSection] [varchar](20) NOT NULL,
	[IndustryStandardID] [uniqueidentifier] NOT NULL,
	[IndustryStandardSectionTitle] [varchar](500) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[LUD] [datetime] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
	[Active] [bit] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
 CONSTRAINT [PK__GovernTr__A2A2BAAA939F5923] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ__GovernTr__1B5CACB08C8FDA59] UNIQUE NONCLUSTERED 
(
	[IndustryStandardSection] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSection] ADD  CONSTRAINT [DF__GovernTre__Uniqu__5B045CA9]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSection] ADD  CONSTRAINT [DF__GovernTree___RAD__5CECA51B]  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSection] ADD  CONSTRAINT [DF__GovernTree___LUD__5ED4ED8D]  DEFAULT ([stng].[GetBPTime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSection] ADD  CONSTRAINT [DF__GovernTre__Activ__60BD35FF]  DEFAULT ((1)) FOR [Active]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSection] ADD  CONSTRAINT [DF_GovernTree_IndustryStandardSection_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSection]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSection]  WITH CHECK ADD  CONSTRAINT [FK__GovernTre__Indus__5BF880E2] FOREIGN KEY([IndustryStandardID])
REFERENCES [stng].[GovernTree_IndustryStandard] ([UniqueID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSection] CHECK CONSTRAINT [FK__GovernTre__Indus__5BF880E2]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSection]  WITH CHECK ADD  CONSTRAINT [FK__GovernTree___LUB__5FC911C6] FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSection] CHECK CONSTRAINT [FK__GovernTree___LUB__5FC911C6]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSection]  WITH CHECK ADD  CONSTRAINT [FK__GovernTree___RAB__5DE0C954] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSection] CHECK CONSTRAINT [FK__GovernTree___RAB__5DE0C954]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSection]  WITH CHECK ADD  CONSTRAINT [CNST_stng_GovernTree_IndustryStandardSection_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardSection] CHECK CONSTRAINT [CNST_stng_GovernTree_IndustryStandardSection_Deleted]
GO


