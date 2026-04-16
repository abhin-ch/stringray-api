CREATE TABLE [stng].[ER_Deliverable_Temp](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[ERID] [uniqueidentifier] NOT NULL,
	[DeliverableID] [uniqueidentifier] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[EstimatedHours] [float] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
	[LUD] [datetime] NOT NULL,
	[Deleted] [bit] NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
	[InHouse] [bit] NOT NULL,
	[Vendor] [uniqueidentifier] NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[ER_Deliverable_Temp] ADD  CONSTRAINT [CNST_stng_ER_Deliverable_Temp2_RAD]  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[ER_Deliverable_Temp] ADD  CONSTRAINT [CNST_stng_ER_Deliverable_Temp2_EstimatedHours]  DEFAULT ((0)) FOR [EstimatedHours]
GO

ALTER TABLE [stng].[ER_Deliverable_Temp] ADD  CONSTRAINT [CNST_stng_ER_Deliverable_Temp2_LUD]  DEFAULT ([stng].[GetBPTime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[ER_Deliverable_Temp] ADD  CONSTRAINT [CNST_stng_ER_Deliverable_Temp2_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[ER_Deliverable_Temp] ADD  CONSTRAINT [DF_ER_Deliverable_Temp_InHouse]  DEFAULT ((0)) FOR [InHouse]
GO

ALTER TABLE [stng].[ER_Deliverable_Temp]  WITH CHECK ADD  CONSTRAINT [FK_stng_ER_Deliverable_DeliverableID2] FOREIGN KEY([DeliverableID])
REFERENCES [stng].[ER_StandardDeliverable] ([UniqueID])
GO

ALTER TABLE [stng].[ER_Deliverable_Temp] CHECK CONSTRAINT [FK_stng_ER_Deliverable_DeliverableID2]
GO

ALTER TABLE [stng].[ER_Deliverable_Temp]  WITH CHECK ADD  CONSTRAINT [FK_stng_ER_Deliverable_Temp2_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User_Original] ([EmployeeID])
GO

ALTER TABLE [stng].[ER_Deliverable_Temp] CHECK CONSTRAINT [FK_stng_ER_Deliverable_Temp2_DeletedBy]
GO

ALTER TABLE [stng].[ER_Deliverable_Temp]  WITH CHECK ADD  CONSTRAINT [FK_stng_ER_Deliverable_Temp2_ERID] FOREIGN KEY([ERID])
REFERENCES [stng].[ER_Main_Temp] ([UniqueID])
GO

ALTER TABLE [stng].[ER_Deliverable_Temp] CHECK CONSTRAINT [FK_stng_ER_Deliverable_Temp2_ERID]
GO

ALTER TABLE [stng].[ER_Deliverable_Temp]  WITH CHECK ADD  CONSTRAINT [FK_stng_ER_Deliverable_Temp2_LUB] FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User_Original] ([EmployeeID])
GO

ALTER TABLE [stng].[ER_Deliverable_Temp] CHECK CONSTRAINT [FK_stng_ER_Deliverable_Temp2_LUB]
GO

ALTER TABLE [stng].[ER_Deliverable_Temp]  WITH CHECK ADD  CONSTRAINT [FK_stng_ER_Deliverable_Temp2_RAB] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User_Original] ([EmployeeID])
GO

ALTER TABLE [stng].[ER_Deliverable_Temp] CHECK CONSTRAINT [FK_stng_ER_Deliverable_Temp2_RAB]
GO

ALTER TABLE [stng].[ER_Deliverable_Temp]  WITH CHECK ADD  CONSTRAINT [CNST_stng_ER_Deliverable_Temp2_DeletedCheck] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[ER_Deliverable_Temp] CHECK CONSTRAINT [CNST_stng_ER_Deliverable_Temp2_DeletedCheck]
GO


