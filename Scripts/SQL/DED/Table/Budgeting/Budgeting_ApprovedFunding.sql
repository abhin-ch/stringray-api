

CREATE TABLE [stng].[Budgeting_ApprovedFunding](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[SDQUID] [bigint] NOT NULL,
	[RespOrg] [varchar](50) NOT NULL,
	[MultipleVendor] [varchar](50) NULL,
	[AllocatedFunding] [decimal](24, 2) NULL,
	[RAB] [varchar](20) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Budgeting_ApprovedFunding] ADD  CONSTRAINT [uniqueid]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[Budgeting_ApprovedFunding] ADD  CONSTRAINT [CNST_stng_Budgeting_ApprovedFunding_RAD]  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Budgeting_ApprovedFunding] ADD  CONSTRAINT [CNST_stng_Budgeting_ApprovedFunding_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO


