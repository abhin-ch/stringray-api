/****** Object:  Table [stng].[Budgeting_SDQ_ScopeOrTrendID]    Script Date: 1/21/2025 3:26:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Budgeting_SDQ_ScopeOrTrendID](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Value] [nvarchar](50) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


