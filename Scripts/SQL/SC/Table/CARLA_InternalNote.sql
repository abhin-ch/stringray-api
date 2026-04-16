CREATE TABLE [stng].[CARLA_InternalNote](
	[INID] [int] IDENTITY(1,1) NOT NULL,
	[ActivityID] [nvarchar](255) NOT NULL,
	[Content] [nvarchar](4000) NULL,
	[ContentLength] [smallint] NULL,
	[LastModified] [datetime] NULL,
	[CreatedBy] [nvarchar](255) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [stng].[CARLA_InternalNote] ADD  DEFAULT (dateadd(hour,(-5),getdate())) FOR [CreatedDate]
GO