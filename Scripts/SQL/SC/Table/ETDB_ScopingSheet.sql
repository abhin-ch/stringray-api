CREATE TABLE [stng].[ETDB_ScopingSheet](
	[SSID] [int] IDENTITY(1,1) NOT NULL,
	[SheetID] [nvarchar](255) NULL,
	[ProjectID] [nvarchar](255) NULL,
	[StatusID] [int] NULL,
	[Title] [nvarchar](500) NULL,
	[Description] [nvarchar](1000) NULL,
	[Hours] [smallint] NULL,
	[ActualHours] [smallint] NULL,
	[Position] [int] NULL,
	[NeedDate] [datetime] NULL,
	[AssignedUserID] [nvarchar](255) NULL,
	[Type] [nvarchar](255) NULL,
	[CommitmentID] [nvarchar](255) NULL,
	[External] [bit] NULL,
	[Escalation] [bit] NULL,
	[Emergent] [bit] NULL,
	[Group] [nvarchar](255) NULL,
	[StartDate] [datetime] NULL,
	[DueDate] [datetime] NULL,
	[Issues] [bit] NULL,
	[Initiator] [nvarchar](255) NULL,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime] NULL,
	[SheetNum] [int] NULL,
UNIQUE CLUSTERED 
(
	[SheetID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[ETDB_ScopingSheet] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO