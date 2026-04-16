CREATE TABLE [stng].[CSA_BOMDetails](
	[CSABID] [bigint] IDENTITY(1,1) NOT NULL,
	[CSAID] [bigint] NULL,
	[BOM_CID] [varchar](max) NULL,
	[SafetyStock] [int] NULL,
	[CriticalFlag] [varchar](5) NULL,
	[BOMComment] [varchar](max) NULL,
	[ITEMNUM] [varchar](50) NULL,
	[RootCATID] [varchar](50) NULL,
	[RAD] [datetime] NULL,
	[RAB] [varchar](50) NULL,
	[LUD] [datetime] NULL,
	[LUB] [varchar](50) NULL,
	[ROP] [int] NULL,
	[TMAX] [int] NULL,
	[bom_level] [int] NULL,
	[cid_owner] [varchar](50) NULL,
	[bom_qty] [float] NULL,
	[bom_path] [varchar](max) NULL,
	[currentrop] [float] NULL,
	[currentaup] [float] NULL,
	[currenttmax] [float] NULL,
	[currentcriticalcode] [varchar](10) NULL,
	[currentsafetystock] [float] NULL,
	[manuf] [varchar](100) NULL,
	[model] [varchar](100) NULL,
	[part] [varchar](100) NULL,
	[ITEMDESC] [varchar](max) NULL,
	[bom_cid_status] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[CSABID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


