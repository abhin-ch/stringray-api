/****** Object:  Table [stng].[Budgeting_DVNMain]    Script Date: 10/25/2024 5:03:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Budgeting_DVNMain](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[DVNID] [bigint] NULL,
	[SDQUID] [bigint] NULL,
	[StatusID] [uniqueidentifier] NULL,
	[Cause] [nvarchar](4000) NULL,
	[ScopeTrend] [nvarchar](255) NULL,
	[Reason] [uniqueidentifier] NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_Budgeting_DVNMain_Unique] UNIQUE NONCLUSTERED 
(
	[SDQUID] ASC,
	[DVNID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Budgeting_DVNMain] ADD  DEFAULT ([stng].[GetDate]()) FOR [CreatedDate]
GO

ALTER TABLE [stng].[Budgeting_DVNMain]  WITH CHECK ADD FOREIGN KEY([CreatedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Budgeting_DVNMain]  WITH CHECK ADD FOREIGN KEY([Reason])
REFERENCES [stng].[Common_ValueLabel] ([UniqueID])
GO

ALTER TABLE [stng].[Budgeting_DVNMain]  WITH CHECK ADD FOREIGN KEY([SDQUID])
REFERENCES [stng].[Budgeting_SDQMain] ([SDQUID])
GO

ALTER TABLE [stng].[Budgeting_DVNMain]  WITH CHECK ADD FOREIGN KEY([StatusID])
REFERENCES [stng].[Common_ValueLabel] ([UniqueID])
GO


