/****** Object:  Table [stng].[DWMS_Type]    Script Date: 8/16/2024 12:51:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[DWMS_Type](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Type] [varchar](50) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[DWMS_Type] ADD  CONSTRAINT [DF_DWMS_Type_UniqueID]  DEFAULT (newid()) FOR [UniqueID]
GO


