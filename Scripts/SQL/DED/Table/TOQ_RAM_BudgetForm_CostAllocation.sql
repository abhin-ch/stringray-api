CREATE TABLE [stng].[TOQ_RAM_BudgetForm_CostAllocation](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[TOQMainID] [uniqueidentifier] NULL,
	[Year] [int] NULL,
	[Amount] [decimal](18, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[TOQ_RAM_BudgetForm_CostAllocation] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[TOQ_RAM_BudgetForm_CostAllocation]  WITH CHECK ADD FOREIGN KEY([TOQMainID])
REFERENCES [stng].[TOQ_Main] ([UniqueID])
GO
