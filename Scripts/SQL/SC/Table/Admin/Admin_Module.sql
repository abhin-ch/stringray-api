/****** Object:  Table [stng].[Admin_Module]    Script Date: 10/21/2024 12:12:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_Module](
	[ModuleID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NULL,
	[Description] [nvarchar](max) NULL,
	[Active] [bit] NULL,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime] NULL,
	[Department] [nvarchar](255) NULL,
	[ShowInCatalog] [bit] NULL,
	[NameShort] [nvarchar](255) NULL,
	[Color] [varchar](50) NULL,
	[Icon] [varchar](50) NULL,
	[Path] [varchar](50) NULL,
 CONSTRAINT [PK_Module] PRIMARY KEY CLUSTERED 
(
	[ModuleID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_Module] ADD  CONSTRAINT [DF__Module__Active__793DFFAF]  DEFAULT ((0)) FOR [Active]
GO

ALTER TABLE [stng].[Admin_Module] ADD  CONSTRAINT [DF__Module__CreatedD__7A3223E8]  DEFAULT (getdate()) FOR [CreatedDate]
GO


