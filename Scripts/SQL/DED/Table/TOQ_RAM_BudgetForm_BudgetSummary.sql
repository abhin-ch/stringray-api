CREATE TABLE [stng].[TOQ_RAM_BudgetForm_BudgetSummary](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[TOQMainID] [uniqueidentifier] NULL,
	[PreviouslyApprovedBudget] [decimal](18, 2) NULL,
	[SpentToDate] [decimal](18, 2) NULL,
	[Balance] [decimal](18, 2) NULL,
	[Material] [decimal](18, 2) NULL,
	[DraftingSupport] [decimal](18, 2) NULL,
	[Installation] [decimal](18, 2) NULL,
	[FTL] [decimal](18, 2) NULL,
	[ProjectMgmtControls] [decimal](18, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[TOQ_RAM_BudgetForm_BudgetSummary] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[TOQ_RAM_BudgetForm_BudgetSummary]  WITH CHECK ADD FOREIGN KEY([TOQMainID])
REFERENCES [stng].[TOQ_Main] ([UniqueID])
GO

ALTER TABLE [stng].[TOQ_RAM_BudgetForm_BudgetSummary]  WITH CHECK ADD FOREIGN KEY([TOQMainID])
REFERENCES [stng].[TOQ_Main] ([UniqueID])
GO
