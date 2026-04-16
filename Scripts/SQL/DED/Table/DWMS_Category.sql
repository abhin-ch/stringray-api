/****** Object:  Table [stng].[DWMS_Category]    Script Date: 8/16/2024 12:49:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[DWMS_Category](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Category] [varchar](10) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[DWMS_Category] ADD  CONSTRAINT [DF_DWMS_Category_UniqueID]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[DWMS_Category]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


