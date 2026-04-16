CREATE TABLE [stng].[TOQLite_Main](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[ERID] [uniqueidentifier] NOT NULL,
	[Revision] [int] NOT NULL,
	[ProjectNo] [varchar](40) NULL,
	[CurrentStatus] [uniqueidentifier] NOT NULL,
	[Section] [varchar](50) NOT NULL,
	[VendorID] [uniqueidentifier] NULL,
	[VendorResponseDate] [date] NULL,
	[PCT50Date] [date] NULL,
	[PCT90Date] [date] NULL,
	[ERLevelDates] [bit] NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[LUD] [datetime] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
	[TOQID] [uniqueidentifier] NULL,
	[VendorNotes] [varchar](max) NULL,
	[ERInstance] [int] NOT NULL,
	[Scope] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[TOQLite_Main] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[TOQLite_Main] ADD  DEFAULT ((0)) FOR [Revision]
GO

ALTER TABLE [stng].[TOQLite_Main] ADD  DEFAULT ((0)) FOR [ERLevelDates]
GO

ALTER TABLE [stng].[TOQLite_Main] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[TOQLite_Main] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[TOQLite_Main] ADD  CONSTRAINT [DF_TOQLite_Main_Instance]  DEFAULT ((0)) FOR [ERInstance]
GO

ALTER TABLE [stng].[TOQLite_Main]  WITH CHECK ADD  CONSTRAINT [CNST_TOQLite_Main_TOQID] FOREIGN KEY([TOQID])
REFERENCES [stng].[TOQLite_TOQ_Temp] ([UniqueID])
GO

ALTER TABLE [stng].[TOQLite_Main] CHECK CONSTRAINT [CNST_TOQLite_Main_TOQID]
GO

ALTER TABLE [stng].[TOQLite_Main]  WITH CHECK ADD  CONSTRAINT [CNST_TOQLite_Main_TOQID1] FOREIGN KEY([TOQID])
REFERENCES [stng].[TOQLite_TOQ_Temp] ([UniqueID])
GO

ALTER TABLE [stng].[TOQLite_Main] CHECK CONSTRAINT [CNST_TOQLite_Main_TOQID1]
GO

ALTER TABLE [stng].[TOQLite_Main]  WITH CHECK ADD FOREIGN KEY([CurrentStatus])
REFERENCES [stng].[TOQLite_Status] ([UniqueID])
GO

ALTER TABLE [stng].[TOQLite_Main]  WITH CHECK ADD FOREIGN KEY([Section])
REFERENCES [stng].[General_Organization] ([PersonGroup])
GO

ALTER TABLE [stng].[TOQLite_Main]  WITH CHECK ADD FOREIGN KEY([VendorID])
REFERENCES [stng].[General_Vendor] ([UniqueID])
GO

ALTER TABLE [stng].[TOQLite_Main]  WITH CHECK ADD FOREIGN KEY([ERID])
REFERENCES [stng].[ER_Main] ([UniqueID])
GO

ALTER TABLE [stng].[TOQLite_Main]  WITH CHECK ADD FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[TOQLite_Main]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


