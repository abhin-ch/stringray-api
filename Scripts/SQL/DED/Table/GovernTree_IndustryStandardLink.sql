/****** Object:  Table [stng].[GovernTree_IndustryStandardLink]    Script Date: 5/27/2024 11:12:15 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[GovernTree_IndustryStandardLink](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[GTID] [uniqueidentifier] NOT NULL,
	[IndustryStandard] [uniqueidentifier] NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_stng_GovernTree_IndustryStandardLink_Unique] UNIQUE NONCLUSTERED 
(
	[GTID] ASC,
	[IndustryStandard] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardLink] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardLink]  WITH CHECK ADD  CONSTRAINT [FK__GovernTre__Indus__3A6282ED] FOREIGN KEY([IndustryStandard])
REFERENCES [stng].[GovernTree_IndustryStandard] ([UniqueID])
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardLink] CHECK CONSTRAINT [FK__GovernTre__Indus__3A6282ED]
GO

ALTER TABLE [stng].[GovernTree_IndustryStandardLink]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


