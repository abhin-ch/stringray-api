SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[TOQ_Binning](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[TOQMainID] [uniqueidentifier] NOT NULL,
	[BinningTypeID] [uniqueidentifier] NOT NULL,
	[Comment] [varchar](255) NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [varchar](20) NULL,
	[Deleted] [bit] NOT NULL,
 CONSTRAINT [PK__TOQ_Binning] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[TOQ_Binning] ADD  CONSTRAINT [DF__TOQ_Binning__Uniqu]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[TOQ_Binning] ADD  CONSTRAINT [DF__TOQ_Binning__Crea]  DEFAULT ([stng].[GetBPTime](getdate())) FOR [CreatedDate]
GO

ALTER TABLE [stng].[TOQ_Binning] ADD  CONSTRAINT [DF__TOQ_Binning__dele]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[TOQ_Binning]  WITH CHECK ADD  CONSTRAINT [FK__TOQ_Binning_Admin_User] FOREIGN KEY([CreatedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[TOQ_Binning] CHECK CONSTRAINT [FK__TOQ_Binning_Admin_User]
GO

ALTER TABLE [stng].[TOQ_Binning]  WITH CHECK ADD  CONSTRAINT [FK__TOQ_Binning_TOQ_BinningType] FOREIGN KEY([BinningTypeID])
REFERENCES [stng].[TOQ_BinningType] ([UniqueID])
GO

ALTER TABLE [stng].[TOQ_Binning] CHECK CONSTRAINT [FK__TOQ_Binning_TOQ_BinningType]
GO

ALTER TABLE [stng].[TOQ_Binning]  WITH CHECK ADD  CONSTRAINT [FK__TOQ_Binning_TOQ_Main] FOREIGN KEY([TOQMainID])
REFERENCES [stng].[TOQ_Main] ([UniqueID])
GO

ALTER TABLE [stng].[TOQ_Binning] CHECK CONSTRAINT [FK__TOQ_Binning_TOQ_Main]
GO