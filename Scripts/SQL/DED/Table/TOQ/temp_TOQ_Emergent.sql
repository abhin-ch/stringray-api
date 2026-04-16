CREATE TABLE [temp].[TOQ_Emergent](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Project] [varchar](20) NULL,
	[Title] [varchar](255) NULL,
	[RequestAmount] [decimal](12, 2) NULL,
	[FundingSource] [uniqueidentifier] NULL,
	[SectionManager] [varchar](20) NULL,
	[VendorTOQNumber] [varchar](25) NULL,
	[ContractNumber] [varchar](25) NULL,
	[ScopeOfWork] [varchar](2000) NULL,
	[QA] [varchar](255) NULL,
	[VendorID] [uniqueidentifier] NULL,
	[VendorWorkTypeID] [uniqueidentifier] NULL,
	[DeleteDate] [datetime] NULL,
	[DeleteRecord] [int] NULL,
	[DeleteBy] [varchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [varchar](20) NULL
) ON [PRIMARY]
GO

ALTER TABLE [temp].[TOQ_Emergent]  WITH CHECK ADD FOREIGN KEY([UniqueID])
REFERENCES [stng].[TOQ_Main] ([UniqueID])
GO