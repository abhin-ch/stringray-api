/****** Object:  Table [stng].[Metric_DataInputs_Actuals]    Script Date: 10/25/2024 8:19:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Metric_DataInputs_Actuals](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[MetricID] [uniqueidentifier] NOT NULL,
	[JanuaryActual] [decimal](10, 2) NULL,
	[FebruaryActual] [decimal](10, 2) NULL,
	[MarchActual] [decimal](10, 2) NULL,
	[AprilActual] [decimal](10, 2) NULL,
	[MayActual] [decimal](10, 2) NULL,
	[JuneActual] [decimal](10, 2) NULL,
	[JulyActual] [decimal](10, 2) NULL,
	[AugustActual] [decimal](10, 2) NULL,
	[SeptemberActual] [decimal](10, 2) NULL,
	[OctoberActual] [decimal](10, 2) NULL,
	[NovemberActual] [decimal](10, 2) NULL,
	[DecemberActual] [decimal](10, 2) NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedBy] [varchar](20) NULL,
	[DeletedOn] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Metric_DataInputs_Actuals] ADD  CONSTRAINT [DF_Metric_DataInputs_Actuals_RAD]  DEFAULT ([stng].[getbptime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Metric_DataInputs_Actuals] ADD  CONSTRAINT [DF_Metric_DataInputs_Actuals_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Metric_DataInputs_Actuals]  WITH CHECK ADD  CONSTRAINT [FK__Metric_Da__Delet__20F881FC] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Metric_DataInputs_Actuals] CHECK CONSTRAINT [FK__Metric_Da__Delet__20F881FC]
GO

ALTER TABLE [stng].[Metric_DataInputs_Actuals]  WITH CHECK ADD  CONSTRAINT [FK__Metric_Data__RAB__20045DC3] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Metric_DataInputs_Actuals] CHECK CONSTRAINT [FK__Metric_Data__RAB__20045DC3]
GO


