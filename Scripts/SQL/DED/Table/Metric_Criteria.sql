CREATE TABLE [stng].[Metric_Criteria](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[MetricID] [uniqueidentifier] NULL,
	[Criteria] [varchar](50) NULL,
	[Operator1] [uniqueidentifier] NULL,
	[Value1] [decimal](18, 2) NULL,
	[Operator2] [uniqueidentifier] NULL,
	[Value2] [decimal](18, 2) NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[LUB] [varchar](20) NOT NULL,
	[LUD] [datetime] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedBy] [varchar](20) NULL,
	[DeletedOn] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Metric_Criteria] ADD  CONSTRAINT [DF_Metric_CriteriaSelection_RAD]  DEFAULT ([stng].[getbptime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Metric_Criteria] ADD  CONSTRAINT [DF_Metric_Criteria_LUD]  DEFAULT ([stng].[GetBPTime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[Metric_Criteria] ADD  CONSTRAINT [DF_Metric_CriteriaSelection_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Metric_Criteria]  WITH CHECK ADD  CONSTRAINT [FK__Metric_Cr__Delet__5971E549] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Metric_Criteria] CHECK CONSTRAINT [FK__Metric_Cr__Delet__5971E549]
GO

ALTER TABLE [stng].[Metric_Criteria]  WITH CHECK ADD  CONSTRAINT [FK__Metric_Cr__Metri__5E369A66] FOREIGN KEY([MetricID])
REFERENCES [stng].[Metric_Main] ([UniqueID])
GO

ALTER TABLE [stng].[Metric_Criteria] CHECK CONSTRAINT [FK__Metric_Cr__Metri__5E369A66]
GO

ALTER TABLE [stng].[Metric_Criteria]  WITH CHECK ADD  CONSTRAINT [FK__Metric_Crit__LUB__220CA1C6] FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Metric_Criteria] CHECK CONSTRAINT [FK__Metric_Crit__LUB__220CA1C6]
GO

ALTER TABLE [stng].[Metric_Criteria]  WITH CHECK ADD  CONSTRAINT [FK__Metric_Crit__RAB__587DC110] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Metric_Criteria] CHECK CONSTRAINT [FK__Metric_Crit__RAB__587DC110]
GO


