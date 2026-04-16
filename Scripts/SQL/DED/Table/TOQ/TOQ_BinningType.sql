SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[TOQ_BinningType](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[BinShort] [varchar](5) NOT NULL,
	[Bin] [varchar](50) NOT NULL,
	[Sort] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[TOQ_BinningType] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[TOQ_BinningType] ADD  DEFAULT (stng.GetBPTime(GETDATE())) FOR [CreatedDate]
GO

ALTER TABLE [stng].[TOQ_BinningType] ADD  CONSTRAINT [DF__TOQ_BinningType__Deleted]  DEFAULT (0) FOR [Deleted]
GO

ALTER TABLE [stng].[TOQ_BinningType]  WITH CHECK ADD  CONSTRAINT [FK__TOQ_BinningType_Admin_User] FOREIGN KEY([CreatedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[TOQ_BinningType] CHECK CONSTRAINT [FK__TOQ_BinningType_Admin_User]
GO