CREATE TABLE [stng].[CARLA_FragnetActivity](
	[ProjectID] [decimal](10, 0) NULL,
	[ProjShortName] [nvarchar](40) NULL,
	[ActivityID] [nvarchar](40) NULL,
	[ActivityName] [nvarchar](120) NULL,
	[FragnetID] [decimal](10, 0) NULL,
	[NCSQ] [nvarchar](60) NULL,
	[StartDate] [datetime2](0) NULL,
	[BLStartDate] [datetime2](0) NULL,
	[EndDate] [datetime2](0) NULL,
	[ReendDate] [datetime2](0) NULL,
	[ActualStartDate] [datetime2](0) NULL,
	[ActualEndDate] [datetime2](0) NULL,
	[Actualized] [float] NULL,
	[Resource] [nvarchar](255) NULL,
	[CommitmentOwner] [nvarchar](60) NULL,
	[Status] [nvarchar](12) NULL,
	[RemainingHours] [decimal](17, 6) NULL,
	[BudgetedHours] [decimal](17, 6) NULL,
	[Duration] [decimal](17, 6) NULL
) ON [PRIMARY]
GO