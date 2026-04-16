/****** Object:  Table [stng].[TOQ_CostSummary]    Script Date: 2/7/2025 11:43:37 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[TOQ_CostSummary](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[VendorAssignedID] [uniqueidentifier] NOT NULL,
	[DeliverableCode] [int] NOT NULL,
	[DeliverableTitle] [varchar](255) NULL,
	[TotalHour] [decimal](24, 14) NULL,
	[TotalCost] [decimal](24, 14) NULL,
	[DeliverableStartDate] [date] NULL,
	[DeliverableEndDate] [date] NULL,
	[NewTOQCommitmentDate] [date] NULL,
	[CurrentTOQCommitmentDate] [date] NULL,
	[PriorTOQCommitmentDate] [date] NULL,
	[OriginalTOQCommitmentDate] [date] NULL,
	[PartialOverride] [decimal](24, 14) NULL,
	[DeliverableAccount] [int] NULL,
	[DateExtension_NewStartDate] [date] NULL,
	[DateExtension_NewStartDate_Static] [date] NULL,
	[DateExtension_NewEndDate] [date] NULL,
	[DateExtension_NewEndDate_Static] [date] NULL,
	[DateExtension_NewCommitmentDate_Static] [date] NULL,
	[IsFromRevision] [bit] NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [varchar](50) NOT NULL,
	[UpdateDate] [datetime] NULL,
	[UpdatedBy] [varchar](50) NOT NULL,
	[temp_RVSCSID] [bigint] NULL,
	[temp_VSCSID] [bigint] NULL,
 CONSTRAINT [PK__TOQ_Cost__A2A2BAAA065682DA] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[TOQ_CostSummary] ADD  CONSTRAINT [DF__TOQ_CostS__Uniqu__46941AFF]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[TOQ_CostSummary]  WITH CHECK ADD  CONSTRAINT [FK_TOQ_CostSummary_Deliverables] FOREIGN KEY([DeliverableCode])
REFERENCES [stng].[TOQ_CostSummary_Deliverables] ([DeliverableCode])
GO

ALTER TABLE [stng].[TOQ_CostSummary] CHECK CONSTRAINT [FK_TOQ_CostSummary_Deliverables]
GO

ALTER TABLE [stng].[TOQ_CostSummary]  WITH CHECK ADD  CONSTRAINT [FK_TOQ_CostSummary_VendorAssigned] FOREIGN KEY([VendorAssignedID])
REFERENCES [stng].[TOQ_VendorAssigned] ([UniqueID])
GO

ALTER TABLE [stng].[TOQ_CostSummary] CHECK CONSTRAINT [FK_TOQ_CostSummary_VendorAssigned]
GO
