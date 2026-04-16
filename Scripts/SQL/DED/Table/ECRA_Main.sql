CREATE TABLE [stng].[ECRA_Main](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[EC] [nvarchar](100) NOT NULL,
	[Proficiency] [int] NULL,
	[FirstTime] [bit] NULL,
	[FirstInAWhile] [bit] NULL,
	[FastTrack] [bit] NULL,
	[ManagerRiskPerceptionImpact] [int] NULL,
	[ManagerRiskPerceptionProbability] [int] NULL,
	[DisciplineType] [uniqueidentifier] NULL,
	[Details] [nvarchar](max) NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[LUD] [datetime] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
 CONSTRAINT [PK_ECRA_Main] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[ECRA_Main] ADD  CONSTRAINT [DF_ECRA_Main_UniqueID]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[ECRA_Main] ADD  DEFAULT ([stng].[getbptime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[ECRA_Main] ADD  DEFAULT ([stng].[getbptime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[ECRA_Main] ADD  CONSTRAINT [DF_ECRA_Main_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[ECRA_Main]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[ECRA_Main]  WITH CHECK ADD FOREIGN KEY([DisciplineType])
REFERENCES [stng].[ECRA_Discipline] ([UniqueID])
GO

ALTER TABLE [stng].[ECRA_Main]  WITH CHECK ADD FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[ECRA_Main]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[ECRA_Main]  WITH CHECK ADD  CONSTRAINT [CNST_stng_ECRA_Main_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[ECRA_Main] CHECK CONSTRAINT [CNST_stng_ECRA_Main_Deleted]
GO


