/****** Object:  Table [stng].[SST_CSDocs]    Script Date: 12/5/2025 11:30:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[SST_CSDocs](
	[pmnum] [nvarchar](10) NULL,
	[DocNum] [nvarchar](255) NULL,
	[Revision] [int] NULL,
	[Type] [nvarchar](255) NULL,
	[SubType] [nvarchar](255) NULL,
	[IsOSR] [int] NOT NULL
) ON [PRIMARY]
GO


