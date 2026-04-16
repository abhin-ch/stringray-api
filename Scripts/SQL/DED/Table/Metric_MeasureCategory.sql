/****** Object:  Table [stng].[Metric_MeasureCategory]    Script Date: 9/11/2024 12:13:22 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Metric_MeasureCategory](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[MeasureCategory] [varchar](100) NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedBy] [varchar](20) NULL,
	[DeletedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Metric_MeasureCategory] ADD  CONSTRAINT [DF_Metric_MeasureCategory_UniqueID]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[Metric_MeasureCategory] ADD  CONSTRAINT [DF_Metric_MeasureCategory_RAD]  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Metric_MeasureCategory] ADD  CONSTRAINT [DF_Metric_MeasureCategory_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Metric_MeasureCategory]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Metric_MeasureCategory]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


