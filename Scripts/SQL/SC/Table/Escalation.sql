CREATE TABLE [stng].[Escalation](
	[ESID] [int] IDENTITY(1,1) NOT NULL,
	[EscalationID] [nvarchar](255) NULL,
	[ProjectID] [nvarchar](255) NULL,
	[Title] [nvarchar](1000) NULL,
	[Type] [nvarchar](255) NULL,
	[ActionWith] [nvarchar](255) NULL,
	[ActionDue] [nvarchar](255) NULL,
	[Scheduled] [bit] NULL,
	[PMCApproval] [bit] NULL,
	[SCApproval] [bit] NULL,
	[StatusID] [int] NULL,
	[CreatedBy] [nvarchar](255) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Escalation] ADD  DEFAULT (dateadd(hour,(-5),getdate())) FOR [CreatedDate]
GO