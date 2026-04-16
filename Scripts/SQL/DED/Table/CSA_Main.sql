CREATE TABLE [stng].[CSA_Main](
	[CSAID] [bigint] IDENTITY(1,1) NOT NULL,
	[Item] [varchar](50) NULL,
	[CSAStatus] [varchar](5) NULL,
	[INID] [varchar](20) NULL,
	[VERID] [varchar](20) NULL,
	[APPID] [varchar](20) NULL,
	[RAD] [datetime] NULL,
	[RAB] [varchar](50) NULL,
	[LUD] [datetime] NULL,
	[LUB] [varchar](50) NULL,
	[Permit] [varchar](50) NULL,
	[AR] [varchar](50) NULL,
	[AMOT] [varchar](50) NULL,
	[EC] [varchar](50) NULL,
	[RootItem] [varchar](50) NULL,
	[ItemDesc] [varchar](max) NULL,
	[BOMUpdateRequired] [bit] NOT NULL,
	[Manufacturer] [varchar](500) NULL,
	[Model] [varchar](500) NULL,
	[CritCat] [varchar](10) NULL,
	[SPV] [bit] NULL,
	[CurrentCSARevision] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CSAID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[CSA_Main] ADD  CONSTRAINT [CNST_dems_TT_0155_CSAMain_BOMUpdateRequired]  DEFAULT ((0)) FOR [BOMUpdateRequired]
GO


