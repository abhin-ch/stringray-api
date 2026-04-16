CREATE TABLE [stng].[Budgeting_MinorChangeType](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Type] [varchar](1000) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Type] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Budgeting_MinorChangeType] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[Budgeting_MinorChangeType] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Budgeting_MinorChangeType] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Budgeting_MinorChangeType]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Budgeting_MinorChangeType]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Budgeting_MinorChangeType]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Budgeting_MinorChangeType_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[Budgeting_MinorChangeType] CHECK CONSTRAINT [CNST_stng_Budgeting_MinorChangeType_Deleted]
GO


