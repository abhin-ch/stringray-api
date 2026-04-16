CREATE TABLE [stng].[Common_EmailTemplate](
	[EmailTemplateID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[Content] [nvarchar](max) NULL,
	[CreatedBy] [nvarchar](255) NULL,
	[CreatedDate] [datetime] NULL,
	[ModuleID] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[Common_EmailTemplate] ADD  DEFAULT (dateadd(hour,(-5),getdate())) FOR [CreatedDate]
GO