CREATE TABLE [stng].[CSA_MgmtMain](
	[CSAMID] [bigint] IDENTITY(1,1) NOT NULL,
	[Item] [varchar](20) NULL,
	[ScopeStatus] [varchar](50) NULL,
	[RepItem] [varchar](20) NULL,
	[Justification] [varchar](max) NULL,
	[AddedScope] [bit] NULL,
	[ClusterLeadItem] [varchar](20) NULL,
	[RAD] [datetime] NULL,
	[RAB] [varchar](20) NULL,
	[LUD] [datetime] NULL,
	[LUB] [varchar](20) NULL,
	[TemporaryOverride] [bit] NOT NULL,
	[EC] [varchar](20) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[CSA_MgmtMain] ADD  CONSTRAINT [DF_CSA_MgmtMain_TemporaryOverride]  DEFAULT ((0)) FOR [TemporaryOverride]
GO

ALTER TABLE [stng].[CSA_MgmtMain]  WITH CHECK ADD FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[CSA_MgmtMain]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


