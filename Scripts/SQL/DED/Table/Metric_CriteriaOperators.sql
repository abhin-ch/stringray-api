/****** Object:  Table [stng].[Metric_CriteriaOperators]    Script Date: 10/16/2024 8:28:46 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Metric_CriteriaOperators](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Operator] [varchar](50) NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedBy] [varchar](20) NULL,
	[DeletedOn] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Metric_CriteriaOperators] ADD  CONSTRAINT [DF_Metric_CriteriaOperator_UniqueID]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[Metric_CriteriaOperators] ADD  CONSTRAINT [DF_Metric_CriteriaOperator_RAD]  DEFAULT ([stng].[getbptime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Metric_CriteriaOperators] ADD  CONSTRAINT [DF_Metric_CriteriaOperator_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Metric_CriteriaOperators]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Metric_CriteriaOperators]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


