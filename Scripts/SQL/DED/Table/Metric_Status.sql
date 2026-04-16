/****** Object:  Table [stng].[Metric_Status]    Script Date: 10/16/2024 8:29:00 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Metric_Status](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Status] [varchar](50) NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedBy] [varchar](20) NULL,
	[DeletedOn] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Metric_Status] ADD  CONSTRAINT [DF_Metric_Status_UniqueID]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[Metric_Status] ADD  CONSTRAINT [DF_Metric_Status_RAD]  DEFAULT ([stng].[getbptime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Metric_Status] ADD  CONSTRAINT [DF_Metric_Status_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Metric_Status]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Metric_Status]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


