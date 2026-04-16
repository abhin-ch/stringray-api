/****** Object:  Table [stng].[GovernTree_IndustryStandard]    Script Date: 5/27/2024 11:11:48 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[GovernTree_IndustryStandard](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[OrgID] [uniqueidentifier] NOT NULL,
	[IndustryStandard] [varchar](20) NOT NULL,
	[IndustryStandardTitle] [varchar](500) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[LUD] [datetime] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
	[Active] [bit] NOT NULL,
	[IntID] [bigint] IDENTITY(1,1) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
 CONSTRAINT [PK__GovernTr__A2A2BAAA14DCD5FF] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ__GovernTr__FDFCFCC5B6DABCAD] UNIQUE NONCLUSTERED 
(
	[IndustryStandard] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandard] ADD  CONSTRAINT [DF__GovernTre__Uniqu__517AF26F]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandard] ADD  CONSTRAINT [DF__GovernTree___RAD__53633AE1]  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandard] ADD  CONSTRAINT [DF__GovernTree___LUD__554B8353]  DEFAULT ([stng].[GetBPTime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandard] ADD  CONSTRAINT [DF__GovernTre__Activ__5733CBC5]  DEFAULT ((1)) FOR [Active]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandard] ADD  CONSTRAINT [DF_GovernTree_IndustryStandard_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandard]  WITH CHECK ADD  CONSTRAINT [FK__GovernTre__OrgID__526F16A8] FOREIGN KEY([OrgID])
REFERENCES [stng].[General_IndustryStandardOrg] ([UniqueID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandard] CHECK CONSTRAINT [FK__GovernTre__OrgID__526F16A8]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandard]  WITH CHECK ADD  CONSTRAINT [FK__GovernTree___LUB__563FA78C] FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandard] CHECK CONSTRAINT [FK__GovernTree___LUB__563FA78C]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandard]  WITH CHECK ADD  CONSTRAINT [FK__GovernTree___RAB__54575F1A] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandard] CHECK CONSTRAINT [FK__GovernTree___RAB__54575F1A]
GO


