/****** Object:  Table [stng].[GovernTree_JobAid]    Script Date: 5/8/2024 2:07:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[GovernTree_JobAid](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedBy] [varchar](20) NULL,
	[DeletedOn] [datetime] NULL,
	[DocumentTitle] [varchar](500) NOT NULL,
	[DocumentNoNum] [varchar](100) NULL,
	[Revision] [int] NULL,
	[DocumentStatus] [varchar](100) NULL,
	[JobAidNum] [int] NULL,
	[ReferenceCount] [int] NULL,
	[FormCount] [int] NULL,
	[StandardCount] [int] NULL,
	[JobAidCount] [int] NULL,
	[DCRCount] [int] NULL,
	[UpdateDate] [datetime] NULL,
	[JobAidStatus] [uniqueidentifier] NULL,
 CONSTRAINT [PK__GovernTr__A2A2BAAAC2971937] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[GovernTree_JobAid] ADD  CONSTRAINT [DF__GovernTre__Uniqu__57DDD73B]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[GovernTree_JobAid] ADD  CONSTRAINT [DF__GovernTree___RAD__58D1FB74]  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[GovernTree_JobAid] ADD  CONSTRAINT [DF__GovernTre__Delet__59C61FAD]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[GovernTree_JobAid] ADD  CONSTRAINT [CNST_stng_GovernTree_JobAid_Revision]  DEFAULT ((0)) FOR [Revision]
GO

ALTER TABLE [stng].[GovernTree_JobAid]  WITH CHECK ADD  CONSTRAINT [FK__GovernTre__Delet__5BAE681F] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_JobAid] CHECK CONSTRAINT [FK__GovernTre__Delet__5BAE681F]
GO

ALTER TABLE [stng].[GovernTree_JobAid]  WITH CHECK ADD FOREIGN KEY([JobAidStatus])
REFERENCES [stng].[GovernTree_JobAidStatus] ([UniqueID])
GO

ALTER TABLE [stng].[GovernTree_JobAid]  WITH CHECK ADD  CONSTRAINT [FK__GovernTree___RAB__5CA28C58] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_JobAid] CHECK CONSTRAINT [FK__GovernTree___RAB__5CA28C58]
GO


