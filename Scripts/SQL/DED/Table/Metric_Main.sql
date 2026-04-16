CREATE TABLE [stng].[Metric_Main](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[MeasureCategory] [uniqueidentifier] NULL,
	[MeasureName] [varchar](300) NULL,
	[Department] [varchar](300) NULL,
	[Section] [varchar](100) NULL,
	[Objective] [varchar](max) NULL,
	[Definition] [varchar](max) NULL,
	[RedCriteria] [varchar](10) NULL,
	[WhiteCriteria] [varchar](50) NULL,
	[GreenCriteria] [varchar](50) NULL,
	[YellowCriteria] [varchar](50) NULL,
	[Driver] [varchar](max) NULL,
	[DataSource] [varchar](200) NULL,
	[RedRecoveryDate] [datetime] NULL,
	[MeasureType] [uniqueidentifier] NULL,
	[Unit] [uniqueidentifier] NULL,
	[KPICategorization] [uniqueidentifier] NULL,
	[MonthlyTarget] [varchar](100) NULL,
	[YTDTarget] [varchar](100) NULL,
	[PreviousMonth] [varchar](100) NULL,
	[CurrentMonth] [varchar](100) NULL,
	[MonthlyVariance] [varchar](max) NULL,
	[Frequency] [uniqueidentifier] NULL,
	[Period] [uniqueidentifier] NULL,
	[DataOwner] [varchar](100) NULL,
	[MetricOwner] [varchar](100) NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NULL,
	[DeletedBy] [varchar](20) NULL,
	[DeletedOn] [datetime] NULL,
	[MonthYearID] [uniqueidentifier] NULL,
	[Status] [uniqueidentifier] NULL,
	[ParentMeasure] [uniqueidentifier] NULL,
 CONSTRAINT [PK__Metric_M__A2A2BAAA5C521FE4] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[Metric_Main] ADD  CONSTRAINT [DF_Metric_Main_UniqueID]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[Metric_Main] ADD  CONSTRAINT [DF_Metric_Main_RAD]  DEFAULT ([stng].[getbptime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Metric_Main] ADD  CONSTRAINT [DF_Metric_Main_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Metric_Main]  WITH CHECK ADD  CONSTRAINT [FK__Metric_Ma__Delet__396F2A0B] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Metric_Main] CHECK CONSTRAINT [FK__Metric_Ma__Delet__396F2A0B]
GO

ALTER TABLE [stng].[Metric_Main]  WITH CHECK ADD  CONSTRAINT [FK__Metric_Ma__Frequ__700044E6] FOREIGN KEY([Frequency])
REFERENCES [stng].[Metric_Frequency] ([UniqueID])
GO

ALTER TABLE [stng].[Metric_Main] CHECK CONSTRAINT [FK__Metric_Ma__Frequ__700044E6]
GO

ALTER TABLE [stng].[Metric_Main]  WITH CHECK ADD  CONSTRAINT [FK__Metric_Ma__KPICa__6F0C20AD] FOREIGN KEY([KPICategorization])
REFERENCES [stng].[Metric_KPICategorization] ([UniqueID])
GO

ALTER TABLE [stng].[Metric_Main] CHECK CONSTRAINT [FK__Metric_Ma__KPICa__6F0C20AD]
GO

ALTER TABLE [stng].[Metric_Main]  WITH CHECK ADD  CONSTRAINT [FK__Metric_Ma__Measu__6C2FB402] FOREIGN KEY([MeasureCategory])
REFERENCES [stng].[Metric_MeasureCategory] ([UniqueID])
GO

ALTER TABLE [stng].[Metric_Main] CHECK CONSTRAINT [FK__Metric_Ma__Measu__6C2FB402]
GO

ALTER TABLE [stng].[Metric_Main]  WITH CHECK ADD  CONSTRAINT [FK__Metric_Ma__Measu__6D23D83B] FOREIGN KEY([MeasureType])
REFERENCES [stng].[Metric_MeasureType] ([UniqueID])
GO

ALTER TABLE [stng].[Metric_Main] CHECK CONSTRAINT [FK__Metric_Ma__Measu__6D23D83B]
GO

ALTER TABLE [stng].[Metric_Main]  WITH CHECK ADD  CONSTRAINT [FK__Metric_Ma__Perio__70F4691F] FOREIGN KEY([Period])
REFERENCES [stng].[Metric_Period] ([UniqueID])
GO

ALTER TABLE [stng].[Metric_Main] CHECK CONSTRAINT [FK__Metric_Ma__Perio__70F4691F]
GO

ALTER TABLE [stng].[Metric_Main]  WITH CHECK ADD  CONSTRAINT [FK__Metric_Mai__Unit__6E17FC74] FOREIGN KEY([Unit])
REFERENCES [stng].[Metric_Unit] ([UniqueID])
GO

ALTER TABLE [stng].[Metric_Main] CHECK CONSTRAINT [FK__Metric_Mai__Unit__6E17FC74]
GO

ALTER TABLE [stng].[Metric_Main]  WITH CHECK ADD  CONSTRAINT [FK__Metric_Main__RAB__3A634E44] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Metric_Main] CHECK CONSTRAINT [FK__Metric_Main__RAB__3A634E44]
GO

ALTER TABLE [stng].[Metric_Main]  WITH CHECK ADD  CONSTRAINT [FK__Metric_Status] FOREIGN KEY([Status])
REFERENCES [stng].[Metric_Status] ([UniqueID])
GO

ALTER TABLE [stng].[Metric_Main] CHECK CONSTRAINT [FK__Metric_Status]
GO


