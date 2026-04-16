CREATE TABLE [stng].[CARLA_FragnetUpdate](
	[FUID] [int] IDENTITY(1,1) NOT NULL,
	[ActivityID] [nvarchar](20) NULL,
	[Category] [nvarchar](255) NULL,
	[Status] [nvarchar](255) NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [nvarchar](20) NULL,
	[ModifiedBy] [nvarchar](20) NULL,
	[LastModified] [datetime] NULL,
	[Actualized] [bit] NULL,
	[EmailSent] [tinyint] NULL,
	[RevisedCommitmentDate] [date] NULL,
	[UpdateRequired] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[FUID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[CARLA_FragnetUpdate] ADD  DEFAULT ((0)) FOR [EmailSent]
GO