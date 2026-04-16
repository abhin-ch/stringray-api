/****** Object:  Table [stng].[DWMS_Checker]    Script Date: 8/16/2024 12:49:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[DWMS_Checker](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Checker] [varchar](50) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[DWMS_Checker] ADD  CONSTRAINT [DF_DWMS_Checker_UniqueID]  DEFAULT (newid()) FOR [UniqueID]
GO


