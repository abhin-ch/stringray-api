CREATE SEQUENCE TOQ_ID
START WITH 1
INCREMENT BY 1

CREATE TABLE [stng].[TOQ_Main] (
    [UniqueID] UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
    [TMID] INT DEFAULT NEXT VALUE FOR TOQ_ID,
	[BPTOQID] [varchar](50) NOT NULL,
	[Rev] [smallint] NOT NULL,
	[RequestFrom] [varchar](50) NOT NULL,
	[StatusID] [uniqueidentifier] NULL,
	[StatusDate] [datetime] NOT NULL,
	[ClassVUniqueID] [uniqueidentifier] NULL,
	[Title] [varchar](100) NULL,
	[TDSNo] [varchar](100) NULL,
	[Comment] [nvarchar](2000) NULL,
	[Project] [varchar](10) NULL,
	[InternalID] [int] NULL,
	[VendorSubmissionDate] [datetime] NULL,
	[VendorClarificationDate] [datetime] NULL,
	[EBSRoutingOption] [tinyint] NULL,
	[DeleteRecord] [bigint] NULL,
	[DeleteBy] [varchar](50) NULL,
	[DeleteDate] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [varchar](50) NOT NULL,
	[ERPUpdated] [bit] NULL,
	[PPSD] [date] NULL,
	[ContractType] [varchar](25) NULL,
	[Resource] [varchar](2500) NULL,
	[ScopeOfWork] [varchar](2000) NULL,
	[TDSRev] [varchar](50) NULL,
	[ParentUniqueID] [uniqueidentifier] NULL,
	[TypeID] [uniqueidentifier] NULL,
	[ScopeManagedBy] [uniqueidentifier] NULL,
	[Phase] [uniqueidentifier] NULL,
	[Customer] [varchar](10) NULL,
	[VendorWorkTypeID] [uniqueidentifier] NULL,
	[WorkTypeID] [uniqueidentifier] NULL,
	[VendorStartDate] [datetime] NULL,
	[PartialEmergent] [varchar](1) NULL,
	[EmergentID] [varchar](20) NULL,
	[VendorSubWorkTypeID] [uniqueidentifier] NULL,
	[LinkedSDQ] [int] NULL,
	[JustificationForNaLinkedSDQ] [varchar](2500) NULL,
	[temp_CVID] [bigint] NULL,
	[temp_PEID] [bigint] NULL,
	[temp_SVNID] [bigint] NULL,
	[UpdatedBy] [nvarchar](20) NULL,
	[UpdatedDate] [datetime] NULL,
	[ClassVTotalAmount] [decimal](18, 2) NULL,
 CONSTRAINT [PK__TOQ_Main__A2A2BAAA4CB496DA] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[TOQ_Main] ADD  CONSTRAINT [DF__TOQ_Main__Unique__2799C73C]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[TOQ_Main] ADD  CONSTRAINT [DF__TOQ_Main__TMID__0856F164]  DEFAULT (NEXT VALUE FOR [TOQ_ID]) FOR [TMID]
GO

ALTER TABLE [stng].[TOQ_Main] ADD  CONSTRAINT [DF__TOQ_Main__Delete__2C5E7C59]  DEFAULT ((0)) FOR [DeleteRecord]
GO

ALTER TABLE [stng].[TOQ_Main] ADD  CONSTRAINT [DF__TOQ_Main__Create__2D52A092]  DEFAULT ([stng].[GetDate]()) FOR [CreatedDate]
GO

ALTER TABLE [stng].[TOQ_Main] ADD  CONSTRAINT [DF__TOQ_Main__ERPUpd__2E46C4CB]  DEFAULT ((0)) FOR [ERPUpdated]
GO

ALTER TABLE [stng].[TOQ_Main]  WITH CHECK ADD  CONSTRAINT [FK__TOQ_Main__ClassV__0446695E] FOREIGN KEY([ClassVUniqueID])
REFERENCES [stng].[TOQ_ClassVMain] ([UniqueID])
GO

ALTER TABLE [stng].[TOQ_Main] CHECK CONSTRAINT [FK__TOQ_Main__ClassV__0446695E]
GO

ALTER TABLE [stng].[TOQ_Main]  WITH CHECK ADD  CONSTRAINT [FK__TOQ_Main__Parent__4FA7B896] FOREIGN KEY([ParentUniqueID])
REFERENCES [stng].[TOQ_Main] ([UniqueID])
GO

ALTER TABLE [stng].[TOQ_Main] CHECK CONSTRAINT [FK__TOQ_Main__Parent__4FA7B896]
GO

ALTER TABLE [stng].[TOQ_Main]  WITH CHECK ADD  CONSTRAINT [FK__TOQ_Main__Phase__15A5FF8A] FOREIGN KEY([Phase])
REFERENCES [stng].[Common_ValueLabel] ([UniqueID])
GO

ALTER TABLE [stng].[TOQ_Main] CHECK CONSTRAINT [FK__TOQ_Main__Phase__15A5FF8A]
GO

ALTER TABLE [stng].[TOQ_Main]  WITH CHECK ADD  CONSTRAINT [FK__TOQ_Main__ScopeM__14B1DB51] FOREIGN KEY([ScopeManagedBy])
REFERENCES [stng].[Common_ValueLabel] ([UniqueID])
GO

ALTER TABLE [stng].[TOQ_Main] CHECK CONSTRAINT [FK__TOQ_Main__ScopeM__14B1DB51]
GO

ALTER TABLE [stng].[TOQ_Main]  WITH CHECK ADD  CONSTRAINT [FK__TOQ_Main__TOQSta__3E7D2C94] FOREIGN KEY([StatusID])
REFERENCES [stng].[Common_ValueLabel] ([UniqueID])
GO

ALTER TABLE [stng].[TOQ_Main] CHECK CONSTRAINT [FK__TOQ_Main__TOQSta__3E7D2C94]
GO

ALTER TABLE [stng].[TOQ_Main]  WITH CHECK ADD  CONSTRAINT [FK__TOQ_Main__TypeID__13BDB718] FOREIGN KEY([TypeID])
REFERENCES [stng].[Common_ValueLabel] ([UniqueID])
GO

ALTER TABLE [stng].[TOQ_Main] CHECK CONSTRAINT [FK__TOQ_Main__TypeID__13BDB718]
GO

ALTER TABLE [stng].[TOQ_Main]  WITH CHECK ADD  CONSTRAINT [FK__TOQ_Main__Vendor__14A7B9B0] FOREIGN KEY([VendorSubWorkTypeID])
REFERENCES [stng].[Common_ValueLabel] ([UniqueID])
GO

ALTER TABLE [stng].[TOQ_Main] CHECK CONSTRAINT [FK__TOQ_Main__Vendor__14A7B9B0]
GO

ALTER TABLE [stng].[TOQ_Main]  WITH CHECK ADD  CONSTRAINT [FK__TOQ_Main__Vendor__73A5ED41] FOREIGN KEY([VendorWorkTypeID])
REFERENCES [stng].[Common_ValueLabel] ([UniqueID])
GO

ALTER TABLE [stng].[TOQ_Main] CHECK CONSTRAINT [FK__TOQ_Main__Vendor__73A5ED41]
GO

ALTER TABLE [stng].[TOQ_Main]  WITH CHECK ADD  CONSTRAINT [FK__TOQ_Main__WorkTy__6E4219A6] FOREIGN KEY([WorkTypeID])
REFERENCES [stng].[Common_ValueLabel] ([UniqueID])
GO

ALTER TABLE [stng].[TOQ_Main] CHECK CONSTRAINT [FK__TOQ_Main__WorkTy__6E4219A6]
GO

ALTER TABLE [stng].[TOQ_Main]  WITH CHECK ADD  CONSTRAINT [CK_TOQ_Main] CHECK  (([EBSRoutingOption]=(3) OR [EBSRoutingOption]=(2) OR [EBSRoutingOption]=(1)))
GO

ALTER TABLE [stng].[TOQ_Main] CHECK CONSTRAINT [CK_TOQ_Main]
GO


