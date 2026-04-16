CREATE TABLE [stng].[TOQ_RAM_AllFields](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[TOQMainID] [uniqueidentifier] NOT NULL,
	[PreviouslyRAMApproved] [bit] NULL,
	[DateOfRevision] [date] NULL,
	[Location] [varchar](20) NULL,
	[BriefStatementofScope] [varchar](500) NULL,
	[FundingSource] [varchar](50) NULL,
	[BudgetHolderHaveApprovedFunding] [bit] NULL,
	[ConfirmProjectBudgetFormHasBeenPrepared] [bit] NULL,
	[HasRequiredScopeofWorkBeenOfferedInternally] [bit] NULL,
	[ReasonForGoingExternal] [nvarchar](500) NULL,
	[PreviousSimilarProjectsExperience] [varchar](500) NULL,
	[RecommendedResourcingStrategy] [varchar](500) NULL,
	[EBSNotes] [varchar](500) NULL,
	[EBSApprovalQuorum] [varchar](500) NULL,
	[EBSApprovalDate] [date] NULL,
	[EBSRAMLock] [bit] NULL,
	[ScopeChangeToExistingProject] [bit] NULL,
	[ExistingProjectID] [int] NULL,
	[VendorLowestCostOption] [bit] NULL,
	[ExplainRationalForVendor] [varchar](500) NULL,
	[VendorBucketOwner] [bit] NULL,
	[ExplainRationalForVendorBucketOwner] [varchar](500) NULL,
	[LowestCostVendorRejectedOnTechnicalBasis] [bit] NULL,
	[ExplainRationalForVendorRejected] [varchar](500) NULL,
	[ReasonForRevision] [varchar](50) NULL,
	[AdditionalInfoForRevision] [varchar](500) NULL,
	[ComparisonEBSNotes] [varchar](500) NULL,
	[ComparisonEBSApprovalQuorum] [varchar](500) NULL,
	[ComparisonEBSApprovalDate] [date] NULL,
	[ComparisonEBSRAMLock] [bit] NULL,
	[CompetitiveBid] [bit] NULL,
 CONSTRAINT [PK__TOQ_RAM___A2A2BAAA1F9C7CA0] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[TOQ_RAM_AllFields] ADD  CONSTRAINT [DF__TOQ_RAM_A__Uniqu__44A0E595]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[TOQ_RAM_AllFields]  WITH CHECK ADD  CONSTRAINT [FK__TOQ_RAM_A__TOQMa__459509CE] FOREIGN KEY([TOQMainID])
REFERENCES [stng].[TOQ_Main] ([UniqueID])
GO

ALTER TABLE [stng].[TOQ_RAM_AllFields] CHECK CONSTRAINT [FK__TOQ_RAM_A__TOQMa__459509CE]
GO


