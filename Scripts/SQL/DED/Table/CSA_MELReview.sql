CREATE TABLE [stng].[CSA_MELReview](
	[CSAMID] [bigint] IDENTITY(1,1) NOT NULL,
	[CSAID] [bigint] NULL,
	[SiteID] [varchar](10) NULL,
	[Location] [varchar](100) NULL,
	[Equipment_Name] [varchar](max) NULL,
	[MANUFACTURER] [varchar](100) NULL,
	[Model_Number] [varchar](100) NULL,
	[ParentItem] [varchar](20) NULL,
	[Crit_Cat] [varchar](10) NULL,
	[SPV] [varchar](10) NULL,
	[Repair_Strat] [varchar](10) NULL,
	[Verified] [bit] NULL,
	[Approved] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[CSAMID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


