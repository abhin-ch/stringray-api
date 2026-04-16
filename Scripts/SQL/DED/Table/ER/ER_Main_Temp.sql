CREATE TABLE [stng].[ER_Main_Temp](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[ER] [varchar](50) NOT NULL,
	[CurrentStatus] [uniqueidentifier] NOT NULL,
	[TCD50PCT] [date] NULL,
	[TCD90PCT] [date] NULL,
	[Vendor] [uniqueidentifier] NULL,
	[OE] [int] NULL,
	[ExecComment] [varchar](500) NULL,
	[ProjectID] [varchar](20) NULL,
	[ERTCD] [date] NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](50) NOT NULL,
	[LUD] [datetime] NULL,
	[LUB] [varchar](50) NULL,
	[InHouse] [bit] NOT NULL,
	[ExecCommentLUB] [varchar](50) NULL,
	[ExecCommentLUD] [datetime] NULL,
	[ExecStatus] [varchar](5) NULL,
	[OECommentDate] [date] NULL,
	[OEAcceptDate] [date] NULL,
	[SMComment] [varchar](500) NULL,
	[AAComment] [varchar](max) NULL,
	[NewStatus] [bit] NOT NULL,
	[EPDTraining] [bit] NOT NULL,
	[Actual50PCT] [bit] NULL,
	[Actual90PCT] [bit] NULL,
	[SecondOE] [int] NULL,
	[SecondOETCD] [date] NULL,
	[CPDDID] [bigint] NULL,
	[Z299] [bit] NULL,
	[NCA] [bit] NULL,
	[CompFlag] [bit] NULL,
	[CompDate] [datetime] NULL,
	[CentralizedTeamAA] [bit] NOT NULL,
	[CentralizedTeamEXE] [bit] NOT NULL,
	[ProjectIDOverride] [varchar](100) NULL,
	[SecondVENID] [smallint] NULL,
	[OverallCost] [float] NULL,
	[AlternateAssessor] [int] NULL,
	[StandardizationPilot] [bit] NOT NULL,
	[EFIN] [bit] NOT NULL,
	[Section] [varchar](50) NULL,
	[SCR] [varchar](10) NULL,
	[ItemCR] [varchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[ER_Main_Temp] ADD  CONSTRAINT [CNST_stng_ER_Main_Temp_UniqueID]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[ER_Main_Temp]  WITH CHECK ADD  CONSTRAINT [FK_stng_ER_Main_Temp_Status] FOREIGN KEY([CurrentStatus])
REFERENCES [stng].[ER_Status] ([UniqueID])
GO

ALTER TABLE [stng].[ER_Main_Temp] CHECK CONSTRAINT [FK_stng_ER_Main_Temp_Status]
GO

ALTER TABLE [stng].[ER_Main_Temp]  WITH CHECK ADD  CONSTRAINT [FK_stng_ER_Main_Temp_Vendor] FOREIGN KEY([Vendor])
REFERENCES [stng].[General_Vendor] ([UniqueID])
GO

ALTER TABLE [stng].[ER_Main_Temp] CHECK CONSTRAINT [FK_stng_ER_Main_Temp_Vendor]
GO


