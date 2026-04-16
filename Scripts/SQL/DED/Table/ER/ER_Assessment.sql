CREATE TABLE [stng].[ER_Assessment](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Assessment] [varchar](50) NOT NULL,
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
	[Assessment] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[ER_Assessment] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[ER_Assessment] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[ER_Assessment] ADD  CONSTRAINT [DF_ER_Assessment_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[ER_Assessment]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User_Original] ([EmployeeID])
GO

ALTER TABLE [stng].[ER_Assessment]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User_Original] ([EmployeeID])
GO

ALTER TABLE [stng].[ER_Assessment]  WITH CHECK ADD  CONSTRAINT [CNST_stng_ER_Assessment_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[ER_Assessment] CHECK CONSTRAINT [CNST_stng_ER_Assessment_Deleted]
GO


