CREATE TABLE [stng].[ER_Deliverable](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[ERID] [uniqueidentifier] NOT NULL,
	[DeliverableID] [uniqueidentifier] NOT NULL,
	[DeliverableHours] [float] NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[LUD] [datetime] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
	[Vendor] [uniqueidentifier] NULL,
	[InHouse] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[ER_Deliverable] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[ER_Deliverable] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[ER_Deliverable] ADD  CONSTRAINT [DF_ER_Deliverable_InHouse]  DEFAULT ((0)) FOR [InHouse]
GO

ALTER TABLE [stng].[ER_Deliverable]  WITH CHECK ADD FOREIGN KEY([DeliverableID])
REFERENCES [stng].[ER_StandardDeliverable] ([UniqueID])
GO

ALTER TABLE [stng].[ER_Deliverable]  WITH CHECK ADD FOREIGN KEY([ERID])
REFERENCES [stng].[ER_Main] ([UniqueID])
GO

ALTER TABLE [stng].[ER_Deliverable]  WITH CHECK ADD FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User_Original] ([EmployeeID])
GO

ALTER TABLE [stng].[ER_Deliverable]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User_Original] ([EmployeeID])
GO


