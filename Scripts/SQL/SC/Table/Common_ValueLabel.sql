CREATE TABLE [stng].[Common_ValueLabel](
	[VLID] [int] IDENTITY(1,1) NOT NULL,
	[ModuleID] [int] NOT NULL,
	[Group] [nvarchar](255) NOT NULL,
	[Field] [nvarchar](255) NOT NULL,
	[Label] [nvarchar](255) NULL,
	[Value] [nvarchar](255) NULL,
	[Sort] [smallint] NULL,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime] NULL,
	[Active] [bit] NULL,
	[Value1] [nvarchar](255) NULL,
	[Value2] [nvarchar](255) NULL
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Common_ValueLabel] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO

ALTER TABLE [stng].[Common_ValueLabel] ADD  DEFAULT ((1)) FOR [Active]
GO