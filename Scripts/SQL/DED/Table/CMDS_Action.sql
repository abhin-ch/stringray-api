CREATE TABLE [stng].[CMDS_Action](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[CMDSID] [uniqueidentifier] NOT NULL,
	[Action] [varchar](2000) NULL,
	[ActionTCD] [date] NULL,
	[ActionAssignedTo] [varchar](20) NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[LUD] [datetime] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
	[ActionStatus] [uniqueidentifier] NULL,
 CONSTRAINT [PK_CMDS_Action] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[CMDS_Action] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[CMDS_Action] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[CMDS_Action] ADD  CONSTRAINT [DF_CMDS_Action_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[CMDS_Action]  WITH CHECK ADD FOREIGN KEY([ActionStatus])
REFERENCES [stng].[CMDS_ActionStatus] ([UniqueID])
GO

ALTER TABLE [stng].[CMDS_Action]  WITH CHECK ADD FOREIGN KEY([CMDSID])
REFERENCES [stng].[CMDS_Goal] ([UniqueID])
GO

ALTER TABLE [stng].[CMDS_Action]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[CMDS_Action]  WITH CHECK ADD FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[CMDS_Action]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[CMDS_Action]  WITH CHECK ADD  CONSTRAINT [CNST_stng_CMDS_Action_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[CMDS_Action] CHECK CONSTRAINT [CNST_stng_CMDS_Action_Deleted]
GO


