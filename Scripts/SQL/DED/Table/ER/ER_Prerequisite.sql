CREATE TABLE [stng].[ER_Prerequisite](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Prerequisite] [varchar](150) NOT NULL,
	[ERID] [uniqueidentifier] NOT NULL,
	[PrerequisiteType] [uniqueidentifier] NOT NULL,
	[Completed] [bit] NOT NULL,
	[CompletedOn] [datetime] NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_stng_ER_Prerequisite_Unique] UNIQUE NONCLUSTERED 
(
	[Prerequisite] ASC,
	[ERID] ASC,
	[PrerequisiteType] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[ER_Prerequisite] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[ER_Prerequisite] ADD  DEFAULT ((0)) FOR [Completed]
GO

ALTER TABLE [stng].[ER_Prerequisite] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[ER_Prerequisite] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[ER_Prerequisite]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User_Original] ([EmployeeID])
GO

ALTER TABLE [stng].[ER_Prerequisite]  WITH CHECK ADD FOREIGN KEY([PrerequisiteType])
REFERENCES [stng].[ER_Prerequisite_Type] ([UniqueID])
GO

ALTER TABLE [stng].[ER_Prerequisite]  WITH CHECK ADD FOREIGN KEY([ERID])
REFERENCES [stng].[ER_Main_Temp] ([UniqueID])
GO

ALTER TABLE [stng].[ER_Prerequisite]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User_Original] ([EmployeeID])
GO

ALTER TABLE [stng].[ER_Prerequisite]  WITH CHECK ADD  CONSTRAINT [CNST_stng_ER_Prerequisite_Completed] CHECK  (([Completed]=(0) OR [Completed]=(1) AND [CompletedOn] IS NOT NULL))
GO

ALTER TABLE [stng].[ER_Prerequisite] CHECK CONSTRAINT [CNST_stng_ER_Prerequisite_Completed]
GO

ALTER TABLE [stng].[ER_Prerequisite]  WITH CHECK ADD  CONSTRAINT [CNST_stng_ER_Prerequisite_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[ER_Prerequisite] CHECK CONSTRAINT [CNST_stng_ER_Prerequisite_Deleted]
GO


