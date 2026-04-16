/****** Object:  Table [stng].[SST_HeaderCosts]    Script Date: 1/14/2026 1:41:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[SST_HeaderCosts](
	[SSTID] [uniqueidentifier] NOT NULL,
	[PreDoseCost] [float] NULL,
	[Dose] [float] NULL,
	[DoseMREM] [float] NULL,
	[SingleExecutionCost] [float] NULL,
	[LUD] [datetime] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SSTID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[SST_HeaderCosts] ADD  DEFAULT ((0)) FOR [PreDoseCost]
GO

ALTER TABLE [stng].[SST_HeaderCosts] ADD  DEFAULT ((0)) FOR [Dose]
GO

ALTER TABLE [stng].[SST_HeaderCosts] ADD  DEFAULT ((0)) FOR [DoseMREM]
GO

ALTER TABLE [stng].[SST_HeaderCosts] ADD  DEFAULT ((0)) FOR [SingleExecutionCost]
GO

ALTER TABLE [stng].[SST_HeaderCosts] ADD  DEFAULT ([stng].[getbptime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[SST_HeaderCosts]  WITH CHECK ADD FOREIGN KEY([SSTID])
REFERENCES [stng].[SST_Main] ([UniqueID])
GO

ALTER TABLE [stng].[SST_HeaderCosts]  WITH CHECK ADD FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


