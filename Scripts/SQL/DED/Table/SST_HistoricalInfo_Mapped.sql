/****** Object:  Table [stng].[SST_HistoricalInfo_Mapped]    Script Date: 1/15/2026 9:43:10 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[SST_HistoricalInfo_Mapped](
	[SSTID] [uniqueidentifier] NOT NULL,
	[SSTNo] [nvarchar](100) NULL,
	[SSTChannel] [nvarchar](100) NULL,
	[Result] [nvarchar](100) NULL,
	[DocName] [nvarchar](300) NULL,
	[SSTDate] [datetime] NULL,
	[dataid] [int] NOT NULL,
	[MaximoLink] [nvarchar](200) NULL,
 CONSTRAINT [PKHistMapped] PRIMARY KEY CLUSTERED 
(
	[SSTID] ASC,
	[dataid] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


