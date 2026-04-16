/****** Object:  Table [stng].[Common_EmailTemplate]    Script Date: 3/7/2024 3:27:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Common_EmailTemplate](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[ModuleID] [uniqueidentifier] NULL,
	[Subject] [nvarchar](max) NULL,
	[Body] [nvarchar](max) NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Name] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[Common_EmailTemplate] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[Common_EmailTemplate] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Common_EmailTemplate]  WITH CHECK ADD FOREIGN KEY([ModuleID])
REFERENCES [stng].[Admin_Module] ([UniqueID])
GO

ALTER TABLE [stng].[Common_EmailTemplate]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Common_EmailTemplate]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


