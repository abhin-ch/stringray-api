CREATE TABLE [stng].[Metric_ActionsReview](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[MetricID] [uniqueidentifier] NOT NULL,
	[Action] [varchar](max) NULL,
	[Responsibility] [varchar](20) NULL,
	[DueDate] [datetime] NULL,
	[StatusID] [uniqueidentifier] NULL,
	[ReportingYear] [uniqueidentifier] NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedBy] [varchar](20) NULL,
	[DeletedOn] [datetime] NULL,
 CONSTRAINT [PK__Metric_A__A2A2BAAA4F830CE8] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[Metric_ActionsReview] ADD  CONSTRAINT [DF_Metric_ActionsReview_RAD]  DEFAULT ([stng].[getbptime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Metric_ActionsReview] ADD  CONSTRAINT [DF_Metric_ActionsReview_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Metric_ActionsReview]  WITH CHECK ADD  CONSTRAINT [FK__Metric_Ac__Delet__275079D0] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Metric_ActionsReview] CHECK CONSTRAINT [FK__Metric_Ac__Delet__275079D0]
GO

ALTER TABLE [stng].[Metric_ActionsReview]  WITH CHECK ADD  CONSTRAINT [FK__Metric_Acti__RAB__265C5597] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Metric_ActionsReview] CHECK CONSTRAINT [FK__Metric_Acti__RAB__265C5597]
GO

ALTER TABLE [stng].[Metric_ActionsReview]  WITH CHECK ADD  CONSTRAINT [FK__Metric_Action__ReportingYear] FOREIGN KEY([ReportingYear])
REFERENCES [stng].[Metric_Year] ([UniqueID])
GO

ALTER TABLE [stng].[Metric_ActionsReview] CHECK CONSTRAINT [FK__Metric_Action__ReportingYear]
GO

ALTER TABLE [stng].[Metric_ActionsReview]  WITH CHECK ADD  CONSTRAINT [FK__Metric_Action__Responsibility] FOREIGN KEY([Responsibility])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Metric_ActionsReview] CHECK CONSTRAINT [FK__Metric_Action__Responsibility]
GO

ALTER TABLE [stng].[Metric_ActionsReview]  WITH CHECK ADD  CONSTRAINT [FK__Metric_Action__Status] FOREIGN KEY([StatusID])
REFERENCES [stng].[Metric_ActionStatus] ([UniqueID])
GO

ALTER TABLE [stng].[Metric_ActionsReview] CHECK CONSTRAINT [FK__Metric_Action__Status]
GO


