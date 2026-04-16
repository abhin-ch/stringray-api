CREATE TABLE [stng].[CARLA_ChangeLog](
	[CCLID] [int] IDENTITY(1,1) NOT NULL,
	[ActivityID] [nvarchar](20) NULL,
	[FieldName] [nvarchar](40) NULL,
	[NewValue] [nvarchar](255) NULL,
	[PreviousValue] [nvarchar](255) NULL,
	[CreatedBy] [nvarchar](255) NULL,
	[CreatedDate] [datetime] NULL,
	[P6UpdateRequired] [bit] NULL,
	[Key] [nvarchar](255) NULL,
	[FKID] [nvarchar](255) NULL
) ON [PRIMARY]
GO

ALTER TABLE [stng].[CARLA_ChangeLog] ADD  DEFAULT (dateadd(hour,(-5),getdate())) FOR [CreatedDate]
GO

ALTER TABLE [stng].[CARLA_ChangeLog] ADD  DEFAULT ((1)) FOR [P6UpdateRequired]
GO