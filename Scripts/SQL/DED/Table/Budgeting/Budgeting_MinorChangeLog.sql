CREATE TABLE [stng].[Budgeting_MinorChangeLog](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[SDQUID] [bigint] NULL,
	[ChangeTypeID] [uniqueidentifier] NULL,
	[Comment] [nvarchar](4000) NULL,
	[RAB] [varchar](20) NULL,
	[RAD] [datetime] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Budgeting_MinorChangeLog] ADD  DEFAULT ([stng].[GetDate]()) FOR [RAD]
GO

ALTER TABLE [stng].[Budgeting_MinorChangeLog] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Budgeting_MinorChangeLog]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Budgeting_MinorChangeLog]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Budgeting_MinorChangeLog]  WITH CHECK ADD  CONSTRAINT [FK_stng_Budgeting_MinorChangeLog_ChangeTypeID] FOREIGN KEY([ChangeTypeID])
REFERENCES [stng].[Budgeting_MinorChangeType] ([UniqueID])
GO

ALTER TABLE [stng].[Budgeting_MinorChangeLog] CHECK CONSTRAINT [FK_stng_Budgeting_MinorChangeLog_ChangeTypeID]
GO

ALTER TABLE [stng].[Budgeting_MinorChangeLog]  WITH CHECK ADD  CONSTRAINT [FK_stng_Budgeting_MinorChangeLog_SDQUID] FOREIGN KEY([SDQUID])
REFERENCES [stng].[Budgeting_SDQMain] ([SDQUID])
GO

ALTER TABLE [stng].[Budgeting_MinorChangeLog] CHECK CONSTRAINT [FK_stng_Budgeting_MinorChangeLog_SDQUID]
GO

ALTER TABLE [stng].[Budgeting_MinorChangeLog]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Budgeting_MinorChangeLog_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[Budgeting_MinorChangeLog] CHECK CONSTRAINT [CNST_stng_Budgeting_MinorChangeLog_Deleted]
GO


