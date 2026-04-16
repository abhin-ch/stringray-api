/****** Object:  Table [stng].[GovernTree_IndustryStandardOrg_Type]    Script Date: 4/17/2024 8:36:46 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[GovernTree_IndustryStandardOrg_Type](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[OrgType] [varchar](100) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedBy] [varchar](20) NULL,
	[DeletedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[OrgType] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardOrg_Type] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardOrg_Type] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardOrg_Type] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardOrg_Type] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [DeletedOn]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardOrg_Type]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardOrg_Type]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardOrg_Type]  WITH CHECK ADD  CONSTRAINT [CNST_stng_GovernTree_IndustryStandardOrg_Type_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedBy] IS NOT NULL AND [DeletedOn] IS NOT NULL))
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardOrg_Type] CHECK CONSTRAINT [CNST_stng_GovernTree_IndustryStandardOrg_Type_Deleted]
GO


