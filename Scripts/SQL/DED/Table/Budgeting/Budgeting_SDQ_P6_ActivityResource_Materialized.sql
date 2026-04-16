CREATE TABLE [stngetl].[Budgeting_SDQ_P6_ActivityResource_Materialized](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[RunID] [uniqueidentifier] NOT NULL,
	[Task_ID] [int] NULL,
	[RoleName] [varchar](100) NULL,
	[Baseline] [int] NULL,
	[LabourRemainingCost] [decimal](18, 2) NULL,
	[LabourRemainingUnits] [decimal](18, 2) NULL,
	[LabourActualCost] [decimal](18, 2) NULL,
	[LabourActualUnits] [decimal](18, 2) NULL,
	[NonLabourRemainingCost] [decimal](18, 2) NULL,
	[NonLabourRemainingUnits] [decimal](18, 2) NULL,
	[NonLabourActualCost] [decimal](18, 2) NULL,
	[NonLabourActualUnits] [decimal](18, 2) NULL,
	[SunkCost] [decimal](18, 2) NULL,
	[RemainingCost] [decimal](18, 2) NULL,
	[RequestCost] [decimal](18, 2) NULL,
	[BLBudgetedCost] [decimal](18, 2) NULL,
 CONSTRAINT [PK_Budgeting_SDQ_P6_ActivityResource_Materialized] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stngetl].[Budgeting_SDQ_P6_ActivityResource_Materialized] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

CREATE NONCLUSTERED INDEX IX_Budgeting_RunID ON stngetl.Budgeting_SDQ_P6_ActivityResource_Materialized (RunID);