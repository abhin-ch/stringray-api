CREATE TABLE [stng].[TOQLite_VendorDeliverable_Activity](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[VendorDeliverableID] [bigint] NOT NULL,
	[Activity] [varchar](150) NOT NULL,
	[ActivityType] [varchar](50) NOT NULL,
	[ActivityHours] [float] NULL,
	[ActivityStart] [date] NULL,
	[ActivityFinish] [date] NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[LUD] [datetime] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
	[SortOrder] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_stng_TOQLite_VendorDeliverable_Activity_Unique2] UNIQUE NONCLUSTERED 
(
	[VendorDeliverableID] ASC,
	[Activity] ASC,
	[ActivityType] ASC,
	[SortOrder] ASC,
	[Deleted] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[TOQLite_VendorDeliverable_Activity] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[TOQLite_VendorDeliverable_Activity] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[TOQLite_VendorDeliverable_Activity] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[TOQLite_VendorDeliverable_Activity]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[TOQLite_VendorDeliverable_Activity]  WITH CHECK ADD FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[TOQLite_VendorDeliverable_Activity]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[TOQLite_VendorDeliverable_Activity]  WITH CHECK ADD  CONSTRAINT [CNST_stng_TOQLite_VendorDeliverable_Activity_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[TOQLite_VendorDeliverable_Activity] CHECK CONSTRAINT [CNST_stng_TOQLite_VendorDeliverable_Activity_Deleted]
GO


