/****** Object:  Table [stng].[DWMS_Status]    Script Date: 8/16/2024 12:51:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[DWMS_Status](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Status] [varchar](50) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[DWMS_Status] ADD  CONSTRAINT [DF_DWMS_Status_UniqueID]  DEFAULT (newid()) FOR [UniqueID]
GO


