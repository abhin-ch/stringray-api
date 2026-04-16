/****** Object:  Table [stng].[EI_Main]    Script Date: 1/6/2026 9:20:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[EI_Main](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[InsightTitle] [varchar](max) NULL,
	[InsightDetails] [varchar](max) NULL,
	[Section] [varchar](50) NULL,
	[QualityRating] [uniqueidentifier] NULL,
	[Status] [uniqueidentifier] NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[LUD] [datetime] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
	[Outcome] [uniqueidentifier] NULL,
	[FocusArea] [uniqueidentifier] NULL,
	[CR] [varchar](100) NULL,
	[SubmissionDate] [date] NULL,
	[QualityScore] [decimal](10, 2) NULL,
	[ObservedGroup] [nvarchar](100) NULL,
	[ErrorDetected] [bit] NOT NULL,
 CONSTRAINT [PK_EI_Main] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[EI_Main] ADD  CONSTRAINT [DF_EI_Main_UniqueID]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[EI_Main] ADD  DEFAULT ([stng].[getbptime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[EI_Main] ADD  DEFAULT ([stng].[getbptime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[EI_Main] ADD  CONSTRAINT [DF_EI_Main_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[EI_Main] ADD  CONSTRAINT [DF_EI_Main_ErrorDetected]  DEFAULT ((0)) FOR [ErrorDetected]
GO

ALTER TABLE [stng].[EI_Main]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[EI_Main]  WITH CHECK ADD FOREIGN KEY([FocusArea])
REFERENCES [stng].[EI_FocusArea] ([UniqueID])
GO

ALTER TABLE [stng].[EI_Main]  WITH CHECK ADD FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[EI_Main]  WITH CHECK ADD FOREIGN KEY([Outcome])
REFERENCES [stng].[EI_Outcome] ([UniqueID])
GO

ALTER TABLE [stng].[EI_Main]  WITH CHECK ADD FOREIGN KEY([QualityRating])
REFERENCES [stng].[EI_QualityRating] ([UniqueID])
GO

ALTER TABLE [stng].[EI_Main]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[EI_Main]  WITH CHECK ADD FOREIGN KEY([Section])
REFERENCES [stng].[General_Organization] ([PersonGroup])
GO

ALTER TABLE [stng].[EI_Main]  WITH CHECK ADD FOREIGN KEY([Status])
REFERENCES [stng].[EI_Status] ([UniqueID])
GO

ALTER TABLE [stng].[EI_Main]  WITH CHECK ADD  CONSTRAINT [CNST_stng_EI_Main_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[EI_Main] CHECK CONSTRAINT [CNST_stng_EI_Main_Deleted]
GO


