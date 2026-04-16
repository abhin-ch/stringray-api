CREATE TABLE [stng].[Common_ChangeLog](
	[CLID] [int] IDENTITY(1,1) NOT NULL,
	[ParentID] [nvarchar](255) NULL,
	[AffectedField] [nvarchar](255) NULL,
	[AffectedTable] [nvarchar](255) NULL,
	[NewValue] [nvarchar](4000) NULL,
	[NewDate] [datetime] NULL,
	[PreviousValue] [nvarchar](4000) NULL,
	[PreviousDate] [datetime] NULL,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Common_ChangeLog] ADD  DEFAULT (dateadd(hour,(-5),getdate())) FOR [CreatedDate]
GO