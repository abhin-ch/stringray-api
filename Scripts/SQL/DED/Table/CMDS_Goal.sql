CREATE TABLE [stng].[CMDS_Goal](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Title] [varchar](max) NULL,
	[Description] [varchar](max) NULL,
	[Section] [uniqueidentifier] NULL,
	[WorkProgram] [uniqueidentifier] NULL,
	[GoalLevel] [uniqueidentifier] NULL,
	[Owner] [varchar](20) NULL,
	[Status] [uniqueidentifier] NULL,
	[TCD] [date] NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[CompletionNotes] [varchar](max) NULL,
	[Year] [uniqueidentifier] NULL,
	[Quarter] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
 CONSTRAINT [PK_CMDS_Goal] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[CMDS_Goal] ADD  CONSTRAINT [DF_CMDS_Goal_UniqueID]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[CMDS_Goal] ADD  DEFAULT ([stng].[getbptime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[CMDS_Goal] ADD  CONSTRAINT [DF_CMDS_Goal_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[CMDS_Goal]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[CMDS_Goal]  WITH CHECK ADD FOREIGN KEY([GoalLevel])
REFERENCES [stng].[CMDS_GoalLevel] ([UniqueID])
GO

ALTER TABLE [stng].[CMDS_Goal]  WITH CHECK ADD FOREIGN KEY([Owner])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[CMDS_Goal]  WITH CHECK ADD FOREIGN KEY([Quarter])
REFERENCES [stng].[CMDS_Date] ([UniqueID])
GO

ALTER TABLE [stng].[CMDS_Goal]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[CMDS_Goal]  WITH CHECK ADD FOREIGN KEY([Section])
REFERENCES [stng].[CMDS_AssignedSection] ([UniqueID])
GO

ALTER TABLE [stng].[CMDS_Goal]  WITH CHECK ADD FOREIGN KEY([Status])
REFERENCES [stng].[CMDS_Status] ([UniqueID])
GO

ALTER TABLE [stng].[CMDS_Goal]  WITH CHECK ADD FOREIGN KEY([WorkProgram])
REFERENCES [stng].[CMDS_WorkProgram] ([UniqueID])
GO

ALTER TABLE [stng].[CMDS_Goal]  WITH CHECK ADD FOREIGN KEY([Year])
REFERENCES [stng].[CMDS_Date] ([UniqueID])
GO

ALTER TABLE [stng].[CMDS_Goal]  WITH CHECK ADD  CONSTRAINT [CNST_stng_CMDS_Goal_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[CMDS_Goal] CHECK CONSTRAINT [CNST_stng_CMDS_Goal_Deleted]
GO


