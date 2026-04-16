CREATE TABLE [stng].[TOQLite_Qualification_Map](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[TOQLiteID] [uniqueidentifier] NOT NULL,
	[Qualification] [uniqueidentifier] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[RAD] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_stng_TOQLite_Qualification_Map_Unique] UNIQUE NONCLUSTERED 
(
	[TOQLiteID] ASC,
	[Qualification] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[TOQLite_Qualification_Map] ADD  DEFAULT ([stng].[getbptime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[TOQLite_Qualification_Map]  WITH CHECK ADD FOREIGN KEY([Qualification])
REFERENCES [stng].[TOQLite_Qualification] ([UniqueID])
GO

ALTER TABLE [stng].[TOQLite_Qualification_Map]  WITH CHECK ADD FOREIGN KEY([TOQLiteID])
REFERENCES [stng].[TOQLite_Main] ([UniqueID])
GO

ALTER TABLE [stng].[TOQLite_Qualification_Map]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


