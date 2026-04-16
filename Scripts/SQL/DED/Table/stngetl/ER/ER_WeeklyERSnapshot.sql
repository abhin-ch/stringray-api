/****** Object:  Table [stngetl].[ER_WeeklyERSnapshot]    Script Date: 1/29/2026 9:13:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stngetl].[ER_WeeklyERSnapshot](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[snap_dt] [datetime] NULL,
	[ER] [nvarchar](50) NULL,
	[ERID] [nvarchar](50) NULL,
	[SectionName] [nvarchar](50) NULL,
	[DepartmentName] [nvarchar](50) NULL,
	[WONUM] [nvarchar](200) NULL,
	[KPI_ID] [int] NULL,
	[ERWO] [varchar](50) NULL,
	[MilestoneOwner] [varchar](50) NULL,
	[WMCriteria] [varchar](10) NULL,
	[WOHeader] [varchar](50) NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
	[Comment] [varchar](max) NULL,
	[Exception] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stngetl].[ER_WeeklyERSnapshot] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stngetl].[ER_WeeklyERSnapshot] ADD  DEFAULT ((0)) FOR [Exception]
GO

ALTER TABLE [stngetl].[ER_WeeklyERSnapshot]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stngetl].[ER_WeeklyERSnapshot]  WITH CHECK ADD  CONSTRAINT [CNST_stng_ER_WeeklyERSnapshot_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stngetl].[ER_WeeklyERSnapshot] CHECK CONSTRAINT [CNST_stng_ER_WeeklyERSnapshot_Deleted]
GO


