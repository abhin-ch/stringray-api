CREATE TABLE [stng].[ER_Resource](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[ERID] [uniqueidentifier] NOT NULL,
	[Resource] [varchar](20) NOT NULL,
	[ResourceType] [uniqueidentifier] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[Deleted] [bit] NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[ER_Resource] ADD  CONSTRAINT [CNST_stng_ER_Resource_RAD]  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[ER_Resource] ADD  CONSTRAINT [CNST_stng_ER_Resource_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[ER_Resource]  WITH CHECK ADD  CONSTRAINT [FK_stng_ER_Resource_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[ER_Resource] CHECK CONSTRAINT [FK_stng_ER_Resource_DeletedBy]
GO

ALTER TABLE [stng].[ER_Resource]  WITH CHECK ADD  CONSTRAINT [FK_stng_ER_Resource_ERID] FOREIGN KEY([ERID])
REFERENCES [stng].[ER_Main_Temp] ([UniqueID])
GO

ALTER TABLE [stng].[ER_Resource] CHECK CONSTRAINT [FK_stng_ER_Resource_ERID]
GO

ALTER TABLE [stng].[ER_Resource]  WITH CHECK ADD  CONSTRAINT [FK_stng_ER_Resource_RAB] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[ER_Resource] CHECK CONSTRAINT [FK_stng_ER_Resource_RAB]
GO

ALTER TABLE [stng].[ER_Resource]  WITH CHECK ADD  CONSTRAINT [FK_stng_ER_Resource_Resource] FOREIGN KEY([Resource])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[ER_Resource] CHECK CONSTRAINT [FK_stng_ER_Resource_Resource]
GO

ALTER TABLE [stng].[ER_Resource]  WITH CHECK ADD  CONSTRAINT [FK_stng_ER_Resource_ResourceType] FOREIGN KEY([ResourceType])
REFERENCES [stng].[ER_Resource_Type] ([UniqueID])
GO

ALTER TABLE [stng].[ER_Resource] CHECK CONSTRAINT [FK_stng_ER_Resource_ResourceType]
GO

ALTER TABLE [stng].[ER_Resource]  WITH CHECK ADD  CONSTRAINT [CNST_stng_ER_Resource_DeletedCheck] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[ER_Resource] CHECK CONSTRAINT [CNST_stng_ER_Resource_DeletedCheck]
GO


