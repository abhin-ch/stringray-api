
CREATE TABLE [stng].[Budgeting_SDQMain](
	[SDQUID] [bigint] IDENTITY(1,1) NOT NULL,
	[SDQID] [bigint] NOT NULL,
	[Revision] [int] NOT NULL,
	[ProjectNo] [nvarchar](40) NOT ULL,
	[FundingSource] [uniqueidentifier] NULL,
	[BusinessDriver] [uniqueidentifier] NULL,
	[Verifier] [varchar](20) NULL,
	[TargetDMApprovalDate] [date] NULL,
	[TargetExecutionWindow] [varchar](200) NULL,
	[Complexity] [uniqueidentifier] NULL,
	[ProblemStatement] [varchar](2500) NULL,
	[ProblemStatementLong] [varchar](max) NULL,
	[CurrentScopeDefinition] [varchar](2500) NULL,
	[CurrentScopeDefinitionLong] [varchar](max) NULL,
	[Assumption] [varchar](2500) NULL,
	[AssumptionLong] [varchar](max) NULL,
	[Risk] [varchar](2500) NULL,
	[RiskLong] [varchar](max) NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[StatusID] [uniqueidentifier] NULL,
	[VarianceComment] [varchar](2500) NULL,
	[Phase] [uniqueidentifier] NULL,
	[PreviouslyApproved] [int] NULL,
	[RequestedScope] [int] NULL,
	[NoTOQFunding] [bit] NULL,
	[ProjectType] [uniqueidentifier] NULL,
	[PMAnticipatedApprovalDate] [date] NULL,
	[AnticipatedProgMApprovalDate] [date] NULL,
	[SDQApprovalSetID] [uniqueidentifier] NULL,
	[Legacy] [bit] NULL,
	[LAMP3] [float] NULL,
	[DeleteRecord] [bit] NULL,
	[EcoSysEACSnap] [decimal](23, 2) NULL,
	[CustomerApprovalID] [uniqueidentifier] NULL,
	[LAMP4Baseline] [bit] NULL,
	[StatusID_New] [uniqueidentifier] NULL,
	[RevisionHeader] [nvarchar](255) NULL,
 CONSTRAINT [PK__Budgetin__DCDE92DF82C4B112] PRIMARY KEY CLUSTERED 
(
	[SDQUID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_stng_Budgeting_SDQMain_Unique] UNIQUE NONCLUSTERED 
(
	[SDQID] ASC,
	[Phase] ASC,
	[Revision] ASC,
	[ProjectNo] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[Budgeting_SDQMain] ADD  CONSTRAINT [DF__Budgeting__Revis__1CAA64D9]  DEFAULT ((0)) FOR [Revision]
GO

ALTER TABLE [stng].[Budgeting_SDQMain] ADD  CONSTRAINT [DF__Budgeting_S__RAD__1D9E8912]  DEFAULT ([stng].[GetDate]()) FOR [RAD]
GO

ALTER TABLE [stng].[Budgeting_SDQMain] ADD  CONSTRAINT [CNST_stng_Budgeting_SDQMain_Legacy]  DEFAULT ((0)) FOR [Legacy]
GO

ALTER TABLE [stng].[Budgeting_SDQMain] ADD  CONSTRAINT [CNST_stng_Budgeting_SDQMain_DeleteRecord]  DEFAULT ((0)) FOR [DeleteRecord]
GO

ALTER TABLE [stng].[Budgeting_SDQMain] ADD  CONSTRAINT [CNST_stng_Budgeting_SDQMain_LAMP4Baseline]  DEFAULT ((0)) FOR [LAMP4Baseline]
GO

ALTER TABLE [stng].[Budgeting_SDQMain]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Budgeting_SDQMain_ProjectType_FK] FOREIGN KEY([ProjectType])
REFERENCES [stng].[Common_ValueLabel] ([UniqueID])
GO

ALTER TABLE [stng].[Budgeting_SDQMain] CHECK CONSTRAINT [CNST_stng_Budgeting_SDQMain_ProjectType_FK]
GO

ALTER TABLE [stng].[Budgeting_SDQMain]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Budgeting_SDQMain_Status_FK] FOREIGN KEY([StatusID])
REFERENCES [stng].[Budgeting_SDQ_Status] ([SDQStatusID])
GO

ALTER TABLE [stng].[Budgeting_SDQMain] CHECK CONSTRAINT [CNST_stng_Budgeting_SDQMain_Status_FK]
GO

ALTER TABLE [stng].[Budgeting_SDQMain]  WITH CHECK ADD  CONSTRAINT [FK__Budgeting__Busin__0C09E8BC] FOREIGN KEY([BusinessDriver])
REFERENCES [stng].[Common_ValueLabel] ([UniqueID])
GO

ALTER TABLE [stng].[Budgeting_SDQMain] CHECK CONSTRAINT [FK__Budgeting__Busin__0C09E8BC]
GO

ALTER TABLE [stng].[Budgeting_SDQMain]  WITH CHECK ADD  CONSTRAINT [FK__Budgeting__Busin__7FD91C01] FOREIGN KEY([BusinessDriver])
REFERENCES [stng].[Common_ValueLabel] ([UniqueID])
GO

ALTER TABLE [stng].[Budgeting_SDQMain] CHECK CONSTRAINT [FK__Budgeting__Busin__7FD91C01]
GO

ALTER TABLE [stng].[Budgeting_SDQMain]  WITH CHECK ADD  CONSTRAINT [FK__Budgeting__Compl__00CD403A] FOREIGN KEY([Complexity])
REFERENCES [stng].[Common_ValueLabel] ([UniqueID])
GO

ALTER TABLE [stng].[Budgeting_SDQMain] CHECK CONSTRAINT [FK__Budgeting__Compl__00CD403A]
GO

ALTER TABLE [stng].[Budgeting_SDQMain]  WITH CHECK ADD  CONSTRAINT [FK__Budgeting__Compl__0CFE0CF5] FOREIGN KEY([Complexity])
REFERENCES [stng].[Common_ValueLabel] ([UniqueID])
GO

ALTER TABLE [stng].[Budgeting_SDQMain] CHECK CONSTRAINT [FK__Budgeting__Compl__0CFE0CF5]
GO

ALTER TABLE [stng].[Budgeting_SDQMain]  WITH CHECK ADD  CONSTRAINT [FK__Budgeting__Fundi__01C16473] FOREIGN KEY([FundingSource])
REFERENCES [stng].[Common_ValueLabel] ([UniqueID])
GO

ALTER TABLE [stng].[Budgeting_SDQMain] CHECK CONSTRAINT [FK__Budgeting__Fundi__01C16473]
GO

ALTER TABLE [stng].[Budgeting_SDQMain]  WITH CHECK ADD  CONSTRAINT [FK__Budgeting__Fundi__0DF2312E] FOREIGN KEY([FundingSource])
REFERENCES [stng].[Common_ValueLabel] ([UniqueID])
GO

ALTER TABLE [stng].[Budgeting_SDQMain] CHECK CONSTRAINT [FK__Budgeting__Fundi__0DF2312E]
GO

ALTER TABLE [stng].[Budgeting_SDQMain]  WITH CHECK ADD  CONSTRAINT [FK__Budgeting__Statu__02B588AC] FOREIGN KEY([StatusID_New])
REFERENCES [stng].[Common_ValueLabel] ([UniqueID])
GO

ALTER TABLE [stng].[Budgeting_SDQMain] CHECK CONSTRAINT [FK__Budgeting__Statu__02B588AC]
GO

ALTER TABLE [stng].[Budgeting_SDQMain]  WITH CHECK ADD  CONSTRAINT [FK__Budgeting__Statu__0EE65567] FOREIGN KEY([StatusID_New])
REFERENCES [stng].[Common_ValueLabel] ([UniqueID])
GO

ALTER TABLE [stng].[Budgeting_SDQMain] CHECK CONSTRAINT [FK__Budgeting__Statu__0EE65567]
GO

ALTER TABLE [stng].[Budgeting_SDQMain]  WITH CHECK ADD  CONSTRAINT [FK__Budgeting__Verif__03A9ACE5] FOREIGN KEY([Verifier])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Budgeting_SDQMain] CHECK CONSTRAINT [FK__Budgeting__Verif__03A9ACE5]
GO

ALTER TABLE [stng].[Budgeting_SDQMain]  WITH CHECK ADD  CONSTRAINT [FK__Budgeting__Verif__0FDA79A0] FOREIGN KEY([Verifier])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Budgeting_SDQMain] CHECK CONSTRAINT [FK__Budgeting__Verif__0FDA79A0]
GO

ALTER TABLE [stng].[Budgeting_SDQMain]  WITH CHECK ADD  CONSTRAINT [FK__Budgeting_S__RAB__049DD11E] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Budgeting_SDQMain] CHECK CONSTRAINT [FK__Budgeting_S__RAB__049DD11E]
GO

ALTER TABLE [stng].[Budgeting_SDQMain]  WITH CHECK ADD  CONSTRAINT [FK__Budgeting_S__RAB__10CE9DD9] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Budgeting_SDQMain] CHECK CONSTRAINT [FK__Budgeting_S__RAB__10CE9DD9]
GO

ALTER TABLE [stng].[Budgeting_SDQMain]  WITH CHECK ADD  CONSTRAINT [FK_stng_Budgeting_SDQMain_SDQApprovalSetID] FOREIGN KEY([SDQApprovalSetID])
REFERENCES [stng].[Budgeting_SDQ_Approval_Set] ([SDQApprovalSetID])
GO

ALTER TABLE [stng].[Budgeting_SDQMain] CHECK CONSTRAINT [FK_stng_Budgeting_SDQMain_SDQApprovalSetID]
GO


