CREATE OR ALTER TABLE [stng].[TOQ_CostSummary_Deliverables](
	[DeliverableCode] [int] NOT NULL,
	[EngineeringDeliverable] [nvarchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[DeliverableCode] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


