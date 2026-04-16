CREATE TABLE [stng].[TOQ_RAM_BudgetForm_DesignSupport](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[TOQMainID] [uniqueidentifier] NULL,
	[Discipline] [varchar](50) NULL,
	[PDECost] [decimal](18, 2) NULL,
	[VendorCost] [decimal](18, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[TOQ_RAM_BudgetForm_DesignSupport] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[TOQ_RAM_BudgetForm_DesignSupport]  WITH CHECK ADD FOREIGN KEY([TOQMainID])
REFERENCES [stng].[TOQ_Main] ([UniqueID])
GO
