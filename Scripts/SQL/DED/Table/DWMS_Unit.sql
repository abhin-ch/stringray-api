/****** Object:  Table [stng].[DWMS_Unit]    Script Date: 8/16/2024 12:51:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[DWMS_Unit](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Unit] [varchar](10) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[DWMS_Unit] ADD  CONSTRAINT [DF_DWMS_Unit_UniqueID]  DEFAULT (newid()) FOR [UniqueID]
GO


