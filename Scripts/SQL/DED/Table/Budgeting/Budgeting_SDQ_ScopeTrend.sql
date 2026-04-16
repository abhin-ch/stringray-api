/****** Object:  Table [stng].[Budgeting_SDQ_ScopeTrend]    Script Date: 1/21/2025 3:26:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Budgeting_SDQ_ScopeTrend](
	[RunID] [uniqueidentifier] NOT NULL,
	[ActivityID] [nvarchar](50) NOT NULL,
	[ScopeOrTrendID] [uniqueidentifier] NULL,
PRIMARY KEY CLUSTERED 
(
	[RunID] ASC,
	[ActivityID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Budgeting_SDQ_ScopeTrend] ADD  DEFAULT (NULL) FOR [ScopeOrTrendID]
GO

ALTER TABLE [stng].[Budgeting_SDQ_ScopeTrend]  WITH CHECK ADD  CONSTRAINT [CNST_stng_BSDQST_RunID_FK] FOREIGN KEY([RunID])
REFERENCES [stngetl].[Budgeting_SDQ_Run] ([RunID])
GO

ALTER TABLE [stng].[Budgeting_SDQ_ScopeTrend] CHECK CONSTRAINT [CNST_stng_BSDQST_RunID_FK]
GO

ALTER TABLE [stng].[Budgeting_SDQ_ScopeTrend]  WITH CHECK ADD  CONSTRAINT [CNST_stng_BSDQST_ScopeOrTrendID_FK] FOREIGN KEY([ScopeOrTrendID])
REFERENCES [stng].[Budgeting_SDQ_ScopeOrTrendID] ([UniqueID])
GO

ALTER TABLE [stng].[Budgeting_SDQ_ScopeTrend] CHECK CONSTRAINT [CNST_stng_BSDQST_ScopeOrTrendID_FK]
GO


