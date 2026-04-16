CREATE TABLE [stng].[CMDS_Status](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Status] [varchar](50) NOT NULL,
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
	[Status] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[CMDS_Status] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[CMDS_Status] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[CMDS_Status] ADD  CONSTRAINT [DF_CMDS_Status_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[CMDS_Status]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[CMDS_Status]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[CMDS_Status]  WITH CHECK ADD  CONSTRAINT [CNST_stng_CMDS_Status_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[CMDS_Status] CHECK CONSTRAINT [CNST_stng_CMDS_Status_Deleted]
GO


