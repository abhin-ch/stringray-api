/****** Object:  Table [stng].[Metric_DataInputs_Targets]    Script Date: 10/25/2024 8:19:25 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Metric_DataInputs_Targets](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[MetricID] [uniqueidentifier] NOT NULL,
	[JanuaryTarget] [decimal](10, 2) NULL,
	[FebruaryTarget] [decimal](10, 2) NULL,
	[MarchTarget] [decimal](10, 2) NULL,
	[AprilTarget] [decimal](10, 2) NULL,
	[MayTarget] [decimal](10, 2) NULL,
	[JuneTarget] [decimal](10, 2) NULL,
	[JulyTarget] [decimal](10, 2) NULL,
	[AugustTarget] [decimal](10, 2) NULL,
	[SeptemberTarget] [decimal](10, 2) NULL,
	[OctoberTarget] [decimal](10, 2) NULL,
	[NovemberTarget] [decimal](10, 2) NULL,
	[DecemberTarget] [decimal](10, 2) NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedBy] [varchar](20) NULL,
	[DeletedOn] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Metric_DataInputs_Targets] ADD  CONSTRAINT [DF_Metric_DataInputs_Targets_RAD]  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Metric_DataInputs_Targets] ADD  CONSTRAINT [DF_Metric_DataInputs_Targets_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Metric_DataInputs_Targets]  WITH CHECK ADD  CONSTRAINT [FK__Metric_Da__Delet__34FF7AA9] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Metric_DataInputs_Targets] CHECK CONSTRAINT [FK__Metric_Da__Delet__34FF7AA9]
GO

ALTER TABLE [stng].[Metric_DataInputs_Targets]  WITH CHECK ADD  CONSTRAINT [FK__Metric_Data__RAB__35F39EE2] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Metric_DataInputs_Targets] CHECK CONSTRAINT [FK__Metric_Data__RAB__35F39EE2]
GO


