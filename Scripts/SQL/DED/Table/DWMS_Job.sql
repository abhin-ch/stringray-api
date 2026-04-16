/****** Object:  Table [stng].[DWMS_Job]    Script Date: 8/16/2024 12:50:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[DWMS_Job](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[DWMSID] [bigint] IDENTITY(1,1) NOT NULL,
	[Project] [varchar](max) NULL,
	[Source] [varchar](max) NULL,
	[SourceNum] [varchar](10) NULL,
	[Type] [varchar](50) NULL,
	[Rev] [varchar](10) NULL,
	[SubJob] [varchar](50) NULL,
	[SubJobNum] [varchar](50) NULL,
	[Disciple] [varchar](50) NULL,
	[Unit] [varchar](10) NULL,
	[Category] [varchar](10) NULL,
	[Drafter] [varchar](50) NULL,
	[Checker] [varchar](50) NULL,
	[Customer] [varchar](50) NULL,
	[ReceivedDate] [date] NULL,
	[AssessedDate] [date] NULL,
	[StartedDate] [date] NULL,
	[RequiredDate] [date] NULL,
	[CompletedDate] [date] NULL,
	[TCD] [date] NULL,
	[Estimate] [varchar](10) NULL,
	[Actual] [varchar](10) NULL,
	[PercentComplete] [varchar](10) NULL,
	[Status] [varchar](50) NULL,
	[Comments] [varchar](max) NULL,
	[Description] [varchar](max) NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Owner] [varchar](20) NULL,
	[FS] [bit] NULL,
	[UnitID] [int] NULL,
	[Docs] [int] NULL,
	[MELIssues] [bit] NULL,
	[MELDone] [bit] NULL,
	[MELAct] [bit] NULL,
	[SCRs] [varchar](250) NULL,
	[ReturnedDate] [date] NULL,
	[TCDRevs] [int] NULL,
	[Est] [varchar](50) NULL,
	[ONLEst] [nchar](10) NULL,
	[RelFactor] [int] NULL,
	[SC1] [nchar](20) NULL,
	[SC2] [nchar](10) NULL,
	[SC3] [nchar](10) NULL,
	[DEO] [int] NULL,
	[CE] [int] NULL,
	[SC] [int] NULL,
	[90DA] [bit] NULL,
	[HLoc] [varchar](50) NULL,
	[PPStatus] [int] NULL,
	[Commission] [varchar](50) NULL,
	[AFS] [int] NULL,
	[DCNModified] [int] NULL,
	[DCNClosed] [int] NULL,
	[P0Due] [nchar](10) NULL,
	[P1Due] [int] NULL,
	[P2Due] [int] NULL,
	[P0Comp] [int] NULL,
	[P1Comp] [int] NULL,
	[P2Comp] [int] NULL,
	[DCP] [varchar](250) NULL,
	[HL] [varchar](250) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[DWMS_Job] ADD  CONSTRAINT [DF_DWMS_Job_UniqueID]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[DWMS_Job]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[DWMS_Job]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


