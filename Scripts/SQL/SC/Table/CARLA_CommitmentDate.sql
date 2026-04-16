CREATE TABLE [stng].[CARLA_CommitmentDate](
	[ActivityID] [nvarchar](255) NULL,
	[CommitmentDate] [date] NULL,
	[SnapshotDate] [date] NULL
) ON [PRIMARY]
GO

ALTER TABLE [stng].[CARLA_CommitmentDate] ADD  DEFAULT (CONVERT([datetime],(CONVERT([datetimeoffset],getdate()) AT TIME ZONE 'Eastern Standard Time'))) FOR [SnapshotDate]
GO