/****** Object:  Table [stng].[Metric_DataInputs]    Script Date: 9/11/2024 12:12:23 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Metric_DataInputs](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[MetricID] [uniqueidentifier] NOT NULL,
	[JanuaryActual] [varchar](10) NULL,
	[FebruaryActual] [varchar](10) NULL,
	[MarchActual] [varchar](10) NULL,
	[AprilActual] [varchar](10) NULL,
	[MayActual] [varchar](10) NULL,
	[JuneActual] [varchar](10) NULL,
	[JulyActual] [varchar](10) NULL,
	[AugustActual] [varchar](10) NULL,
	[SeptemberActual] [varchar](10) NULL,
	[OctoberActual] [varchar](10) NULL,
	[NovemberActual] [varchar](10) NULL,
	[DecemberActual] [varchar](10) NULL,
	[Variance] [varchar](20) NULL,
	[JanuaryTarget] [varchar](10) NULL,
	[FebruaryTarget] [varchar](10) NULL,
	[MarchTarget] [varchar](10) NULL,
	[AprilTarget] [varchar](10) NULL,
	[MayTarget] [varchar](10) NULL,
	[JuneTarget] [varchar](10) NULL,
	[JulyTarget] [varchar](10) NULL,
	[AugustTarget] [varchar](10) NULL,
	[SeptemberTarget] [varchar](10) NULL,
	[OctoberTarget] [varchar](10) NULL,
	[NovemberTarget] [varchar](10) NULL,
	[DecemberTarget] [varchar](10) NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedBy] [varchar](20) NULL,
	[DeletedOn] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Metric_DataInputs] ADD  CONSTRAINT [DF_Metric_DataInputs_RAD]  DEFAULT ([stng].[getbptime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Metric_DataInputs] ADD  CONSTRAINT [DF_Metric_DataInputs_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Metric_DataInputs]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Metric_DataInputs]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


