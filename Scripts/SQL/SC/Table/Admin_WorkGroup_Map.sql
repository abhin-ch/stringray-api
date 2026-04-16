CREATE TABLE [stng].[Admin_WorkGroup_Map](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[VendorID] [uniqueidentifier] NOT NULL,
	[WorkGroupID] [uniqueidentifier] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[RAD] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_stng_EI_Deliverable_Map_Unique] UNIQUE NONCLUSTERED 
(
	[VendorID] ASC,
	[WorkGroupID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_WorkGroup_Map] ADD  DEFAULT ([stng].[getbptime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Admin_WorkGroup_Map]  WITH CHECK ADD FOREIGN KEY([VendorID])
REFERENCES [stng].[Admin_Attribute] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_WorkGroup_Map]  WITH CHECK ADD FOREIGN KEY([WorkGroupID])
REFERENCES [stng].[Admin_WorkGroup] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_WorkGroup_Map]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


