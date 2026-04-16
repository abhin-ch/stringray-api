/****** Object:  Table [stng].[DWMS_Source]    Script Date: 8/16/2024 12:51:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[DWMS_Source](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Source] [varchar](max) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[DWMS_Source] ADD  CONSTRAINT [DF_DWMS_Source_UniqueID]  DEFAULT (newid()) FOR [UniqueID]
GO


