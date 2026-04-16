CREATE TABLE [stng].[Budgeting_PBRMain](
	[PBRUID] [bigint] IDENTITY(1,1) NOT NULL,
	[PBRID] [bigint] NOT NULL,
	[Revision] [int] NOT NULL,
	[ParentPBRUID] [bigint] NULL,
	[ProjectNo] [varchar](40) NULL,
	[ProjectTitle] [varchar](2000) NULL,
	[StatusID] [uniqueidentifier] NOT NULL,
	[RC] [uniqueidentifier] NULL,
	[ProblemStatement] [varchar](max) NULL,
	[Objective] [varchar](max) NULL,
	[Title] [varchar](max) NULL,
	[CustomerNeed] [uniqueidentifier] NULL,
	[CustomerNeedDate] [datetime] NULL,
	[Section] [varchar](50) NULL,
	[FundingSource] [uniqueidentifier] NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Scope] [varchar](2000) NULL,
	[InformationReferences] [nvarchar](4000) NULL,
	[Station] [nvarchar](255) NULL,
	ProjectType uniqueidentifier,
PRIMARY KEY CLUSTERED 
(
	[PBRUID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_stng_Budgeting_PBRMain_Unique] UNIQUE NONCLUSTERED 
(
	[PBRID] ASC,
	[Revision] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[Budgeting_PBRMain] ADD  DEFAULT ((0)) FOR [Revision]
GO

ALTER TABLE [stng].[Budgeting_PBRMain] ADD  DEFAULT ([stng].[GetDate]()) FOR [RAD]
GO

ALTER TABLE [stng].[Budgeting_PBRMain]  WITH CHECK ADD FOREIGN KEY([CustomerNeed])
REFERENCES [stng].[Common_ValueLabel] ([UniqueID])
GO

ALTER TABLE [stng].[Budgeting_PBRMain]  WITH CHECK ADD FOREIGN KEY([FundingSource])
REFERENCES [stng].[Common_ValueLabel] ([UniqueID])
GO

ALTER TABLE [stng].[Budgeting_PBRMain]  WITH CHECK ADD FOREIGN KEY([ParentPBRUID])
REFERENCES [stng].[Budgeting_PBRMain] ([PBRUID])
GO

ALTER TABLE [stng].[Budgeting_PBRMain]  WITH CHECK ADD FOREIGN KEY([Section])
REFERENCES [stng].[General_Organization] ([PersonGroup])
GO

ALTER TABLE [stng].[Budgeting_PBRMain]  WITH CHECK ADD FOREIGN KEY([StatusID])
REFERENCES [stng].[Common_ValueLabel] ([UniqueID])
GO

ALTER TABLE [stng].[Budgeting_PBRMain]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Budgeting_PBRMain]  WITH CHECK ADD FOREIGN KEY([RC])
REFERENCES [stng].[Common_ValueLabel] ([UniqueID])
GO

ALTER TABLE [stng].[Budgeting_PBRMain]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Budgeting_PBRMain_CustomerNeedDate] CHECK  (([CustomerNeed] IS NOT NULL AND [CustomerNeedDate] IS NOT NULL OR ([CustomerNeed] IS NULL OR [CustomerNeedDate] IS NULL)))
GO

ALTER TABLE [stng].[Budgeting_PBRMain] CHECK CONSTRAINT [CNST_stng_Budgeting_PBRMain_CustomerNeedDate]
GO


alter table stng.Budgeting_PBRMain add constraint CNST_stng_Budgeting_PBRMain_ProjectType_FK foreign key(ProjectType) references stng.Common_ValueLabel(UniqueID)
go
