CREATE TABLE [stng].[EQDB_Main](
	[EQDBIID] [nvarchar](200) NOT NULL,
	[EQEBOM] [bit] NOT NULL,
	[AMLINSTALLED] [bit] NOT NULL,
	[PredefinedCheck] [bit] NOT NULL,
	[EQDOCCHECK] [bit] NOT NULL,
	[PredefinedComplete] [bit] NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[LUD] [datetime] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
	[EQEBOMReason] [nvarchar](max) NULL,
	[AMLInstalledReason] [nvarchar](max) NULL,
	[PredefinedCheckReason] [nvarchar](max) NULL,
	[EQDocCheckReason] [nvarchar](max) NULL,
	[PredefinedCompleteReason] [nvarchar](max) NULL,
	[OutstandingChanges] [nvarchar](max) NULL,
 CONSTRAINT [PK_EQDB_Main] PRIMARY KEY CLUSTERED 
(
	[EQDBIID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[EQDB_Main] ADD  CONSTRAINT [DF_EQDB_Main_EQEBOM]  DEFAULT ((0)) FOR [EQEBOM]
GO

ALTER TABLE [stng].[EQDB_Main] ADD  CONSTRAINT [DF_EQDB_Main_AMLINSTALLED]  DEFAULT ((0)) FOR [AMLINSTALLED]
GO

ALTER TABLE [stng].[EQDB_Main] ADD  CONSTRAINT [DF_EQDB_Main_PredefinedCheck]  DEFAULT ((0)) FOR [PredefinedCheck]
GO

ALTER TABLE [stng].[EQDB_Main] ADD  CONSTRAINT [DF_EQDB_Main_EQDOCCHECK]  DEFAULT ((0)) FOR [EQDOCCHECK]
GO

ALTER TABLE [stng].[EQDB_Main] ADD  CONSTRAINT [DF_EQDB_Main_PredefinedComplete]  DEFAULT ((0)) FOR [PredefinedComplete]
GO

ALTER TABLE [stng].[EQDB_Main] ADD  DEFAULT ([stng].[getbptime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[EQDB_Main] ADD  DEFAULT ([stng].[getbptime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[EQDB_Main]  WITH CHECK ADD FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[EQDB_Main]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


