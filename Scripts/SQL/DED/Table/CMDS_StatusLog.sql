CREATE TABLE [stng].[CMDS_StatusLog](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[CMDSID] [uniqueidentifier] NOT NULL,
	[StatusID] [uniqueidentifier] NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[CMDS_StatusLog] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[CMDS_StatusLog]  WITH CHECK ADD FOREIGN KEY([CMDSID])
REFERENCES [stng].[CMDS_Goal] ([UniqueID])
GO

ALTER TABLE [stng].[CMDS_StatusLog]  WITH CHECK ADD FOREIGN KEY([StatusID])
REFERENCES [stng].[CMDS_Status] ([UniqueID])
GO

ALTER TABLE [stng].[CMDS_StatusLog]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


