/****** Object:  Table [stng].[TOQLite_Revision_BPDeliverable]    Script Date: 11/19/2025 9:23:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[TOQLite_Revision_BPDeliverable](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[TOQLiteID] [uniqueidentifier] NOT NULL,
	[MappedID] [bigint] NOT NULL,
	[DeliverableID] [uniqueidentifier] NOT NULL,
	[DeliverableHours] [float] NOT NULL,
	[Deliverable50PCT] [date] NULL,
	[Deliverable90PCT] [date] NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[LUD] [datetime] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[TOQLite_Revision_BPDeliverable] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[TOQLite_Revision_BPDeliverable] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[TOQLite_Revision_BPDeliverable] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[TOQLite_Revision_BPDeliverable]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[TOQLite_Revision_BPDeliverable]  WITH CHECK ADD FOREIGN KEY([DeliverableID])
REFERENCES [stng].[ER_StandardDeliverable] ([UniqueID])
GO

ALTER TABLE [stng].[TOQLite_Revision_BPDeliverable]  WITH CHECK ADD FOREIGN KEY([TOQLiteID])
REFERENCES [stng].[TOQLite_Main] ([UniqueID])
GO

ALTER TABLE [stng].[TOQLite_Revision_BPDeliverable]  WITH CHECK ADD FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[TOQLite_Revision_BPDeliverable]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[TOQLite_Revision_BPDeliverable]  WITH CHECK ADD  CONSTRAINT [CNST_stng_TOQLite_Revision_BPDeliverable_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[TOQLite_Revision_BPDeliverable] CHECK CONSTRAINT [CNST_stng_TOQLite_Revision_BPDeliverable_Deleted]
GO


