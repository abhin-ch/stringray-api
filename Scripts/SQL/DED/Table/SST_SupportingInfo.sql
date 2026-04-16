/****** Object:  Table [stng].[SST_SupportingInfo]    Script Date: 12/5/2025 11:37:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[SST_SupportingInfo](
	[SSTNoActual] [nvarchar](100) NULL,
	[SSTno] [nvarchar](100) NULL,
	[pmnum] [nvarchar](10) NULL,
	[description] [nvarchar](100) NULL,
	[facility] [nvarchar](8) NULL,
	[unit] [nvarchar](12) NULL,
	[frequency] [float] NULL,
	[frequnit] [nvarchar](8) NULL,
	[planningctr] [nvarchar](10) NULL,
	[PRAReq] [nvarchar](3) NULL,
	[soe] [nvarchar](3) NULL,
	[reactivitymgmt] [float] NULL,
	[cnsc] [float] NULL,
	[Cat1] [nvarchar](50) NULL,
	[Cat2] [nvarchar](50) NULL,
	[Cat3] [nvarchar](50) NULL,
	[Cat4] [nvarchar](50) NULL,
	[Cat5] [nvarchar](50) NULL,
	[usi] [nvarchar](max) NULL,
	[ucr] [nvarchar](10) NULL,
	[jpnum] [nvarchar](12) NULL,
	[SPV] [varchar](3) NOT NULL,
	[LastCompletedWO] [nvarchar](20) NULL,
	[lastwocompdate] [datetime2](7) NULL,
	[lastWOCompletionCode] [nvarchar](12) NULL,
	[CurrentWOPMDueDate] [datetime2](7) NULL,
	[EarliestNextDueDate] [datetime2](7) NULL,
	[JPWorkAssets] [nvarchar](max) NULL,
	[DOCNUM] [nvarchar](max) NULL,
	[RSE] [nvarchar](max) NULL,
	[RDE] [nvarchar](max) NULL,
	[RCE] [nvarchar](max) NULL,
	[STRATEGY_OWNER] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


