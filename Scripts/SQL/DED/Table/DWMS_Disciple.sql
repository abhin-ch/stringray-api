/****** Object:  Table [stng].[DWMS_Disciple]    Script Date: 8/16/2024 12:49:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[DWMS_Disciple](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Disciple] [varchar](50) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[DWMS_Disciple] ADD  CONSTRAINT [DF_DWMS_Disciple_UniqueID]  DEFAULT (newid()) FOR [UniqueID]
GO


