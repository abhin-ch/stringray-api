CREATE TABLE [stngetl].[Budgeting_SDQ_P6_CIIDeliverable_Materialized](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[SDQUID] [bigint] NOT NULL,
	[RunID] [uniqueidentifier] NOT NULL,
	[wbs_name] [nvarchar](255) NULL,
	[wbs_code] [varchar](50) NULL,
	[DeliverableType] [int] NOT NULL,
	[DeliverableName] [nvarchar](255) NULL,
	[unit] [varchar](50) NULL,
	[Direct] [bit] NULL,
	[PhaseCode] [int] NULL,
	[DisciplineCode] [varchar](10) NULL,
	[CurrentStart] [datetime] NULL,
	[StartActualized] [bit] NULL,
	[CurrentEnd] [datetime] NULL,
	[EndActualized] [bit] NULL,
	[LabourActualUnits] [decimal](18, 6) NULL,
	[LabourActualCost] [decimal](18, 6) NULL,
	[NonLabourActualUnits] [decimal](18, 6) NULL,
	[NonLabourActualCost] [decimal](18, 6) NULL,
	[SunkCost] [decimal](18, 6) NULL,
	[LabourRemainingUnits] [decimal](18, 6) NULL,
	[NonLabourRemainingUnits] [decimal](18, 6) NULL,
	[LabourRemainingCost] [decimal](18, 6) NULL,
	[NonLabourRemainingCost] [decimal](18, 6) NULL,
	[RemainingCost] [decimal](18, 6) NULL,
	[BIMSEstimate] [decimal](18, 6) NULL,
	[BIMSCommit] [decimal](18, 6) NULL,
	[FinalBIMSCommit] [decimal](18, 6) NULL,
	[Legacy] [bit] NOT NULL,
	[LoadDate] [datetime] NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [stngetl].[Budgeting_SDQ_P6_CIIDeliverable_Materialized] ADD  CONSTRAINT [DF_Budgeting_SDQ_P6_CIIDeliverable_Materialized_UniqueID]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stngetl].[Budgeting_SDQ_P6_CIIDeliverable_Materialized] ADD  DEFAULT (getdate()) FOR [LoadDate]
GO


CREATE INDEX IX_Budgeting_SDQ_P6_CIIDeliverable_Materialized_SDQUID_RunID ON stngetl.Budgeting_SDQ_P6_CIIDeliverable_Materialized (SDQUID, RunID);