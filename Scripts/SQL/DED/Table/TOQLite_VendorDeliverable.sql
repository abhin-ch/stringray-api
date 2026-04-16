/****** Object:  Table [stng].[TOQLite_VendorDeliverable]    Script Date: 3/16/2024 3:26:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[TOQLite_VendorDeliverable](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[TOQLiteID] [uniqueidentifier] NOT NULL,
	[DeliverableID] [uniqueidentifier] NOT NULL,
	[ParentBPDeliverableID] [bigint] NULL,
	[DeliverableCost] [float] NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[LUD] [datetime] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
	[Comment] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[TOQLite_VendorDeliverable] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[TOQLite_VendorDeliverable] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[TOQLite_VendorDeliverable] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[TOQLite_VendorDeliverable]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[TOQLite_VendorDeliverable]  WITH CHECK ADD FOREIGN KEY([DeliverableID])
REFERENCES [stng].[ER_StandardDeliverable] ([UniqueID])
GO

ALTER TABLE [stng].[TOQLite_VendorDeliverable]  WITH CHECK ADD FOREIGN KEY([ParentBPDeliverableID])
REFERENCES [stng].[TOQLite_BPDeliverable] ([UniqueID])
GO

ALTER TABLE [stng].[TOQLite_VendorDeliverable]  WITH CHECK ADD FOREIGN KEY([TOQLiteID])
REFERENCES [stng].[TOQLite_Main] ([UniqueID])
GO

ALTER TABLE [stng].[TOQLite_VendorDeliverable]  WITH CHECK ADD FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[TOQLite_VendorDeliverable]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[TOQLite_VendorDeliverable]  WITH CHECK ADD  CONSTRAINT [CNST_stng_TOQLite_VendorDeliverable_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[TOQLite_VendorDeliverable] CHECK CONSTRAINT [CNST_stng_TOQLite_VendorDeliverable_Deleted]
GO


