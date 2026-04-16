/****** Object:  Table [stng].[SST_HistoricalContentServer]    Script Date: 12/5/2025 11:34:20 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[SST_HistoricalContentServer](
	[dataid] [decimal](19, 0) NULL,
	[master_folder] [nvarchar](255) NULL,
	[parent_folder] [nvarchar](255) NULL,
	[folder] [nvarchar](255) NULL,
	[name] [nvarchar](255) NULL,
	[dcomment] [nvarchar](4000) NULL,
	[createddate] [datetime2](7) NULL,
	[created_by] [nvarchar](255) NULL,
	[modifydate] [datetime2](7) NULL,
	[modify_by] [nvarchar](255) NULL,
	[Facility] [nvarchar](255) NULL,
	[Rec_type] [nvarchar](255) NULL,
	[sub_type] [nvarchar](255) NULL,
	[searchtype] [nvarchar](8) NULL,
	[URL_CREATE] [varchar](114) NOT NULL
) ON [PRIMARY]
GO


