CREATE TABLE [stng].[EQDB_IndexMain](
	[EQDBIID] [uniqueidentifier] NOT NULL,
	[Location] [varchar](200) NOT NULL,
	[Facility] [varchar](10) NOT NULL,
	[DTFailed] [datetime] NULL,
	[RAD] [datetime] NULL,
	[RAB] [varchar](20) NULL,
	[LUD] [datetime] NULL,
	[LUB] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[EQDBIID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[EQDB_IndexMain] ADD  CONSTRAINT [DF_EQDB_IndexMain_EQDBIID]  DEFAULT (newid()) FOR [EQDBIID]
GO

ALTER TABLE [stng].[EQDB_IndexMain] ADD  DEFAULT ([stng].[getbptime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[EQDB_IndexMain]  WITH CHECK ADD FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[EQDB_IndexMain]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


