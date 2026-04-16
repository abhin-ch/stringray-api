CREATE TABLE [stng].[ER_Main](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[ER] [varchar](30) NOT NULL,
	[ProjectID] [varchar](40) NULL,
	[Section] [varchar](50) NULL,
	[Vendor] [uniqueidentifier] NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[LUD] [datetime] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
	[CurrentStatus] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ER] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[ER_Main] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[ER_Main] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[ER_Main] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[ER_Main]  WITH CHECK ADD  CONSTRAINT [CNST_stng_ER_Main_Status] FOREIGN KEY([CurrentStatus])
REFERENCES [stng].[ER_Status] ([UniqueID])
GO

ALTER TABLE [stng].[ER_Main] CHECK CONSTRAINT [CNST_stng_ER_Main_Status]
GO

ALTER TABLE [stng].[ER_Main]  WITH CHECK ADD FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User_Original] ([EmployeeID])
GO

ALTER TABLE [stng].[ER_Main]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User_Original] ([EmployeeID])
GO

ALTER TABLE [stng].[ER_Main]  WITH CHECK ADD FOREIGN KEY([Section])
REFERENCES [stng].[General_Organization] ([PersonGroup])
GO

ALTER TABLE [stng].[ER_Main]  WITH CHECK ADD FOREIGN KEY([Vendor])
REFERENCES [stng].[General_Vendor] ([UniqueID])
GO


