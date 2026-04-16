/****** Object:  Table [stng].[Budgeting_LinkedTOQ_Mapping]    Script Date: 1/14/2025 10:58:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Budgeting_LinkedTOQ_Mapping](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[SDQUID] [bigint] NOT NULL,
	[TOQID] [uniqueidentifier] NOT NULL,
	[AllocatedFunding] [decimal](24, 2) NULL,
	[RAB] [varchar](20) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Budgeting_LinkedTOQ_Mapping] ADD  CONSTRAINT [CNST_stng_Budgeting_LinkedTOQ_Mapping_RAD]  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Budgeting_LinkedTOQ_Mapping] ADD  CONSTRAINT [CNST_stng_Budgeting_LinkedTOQ_Mapping_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Budgeting_LinkedTOQ_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_stng_Budgeting_LinkedTOQ_Mapping_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Budgeting_LinkedTOQ_Mapping] CHECK CONSTRAINT [FK_stng_Budgeting_LinkedTOQ_Mapping_DeletedBy]
GO

ALTER TABLE [stng].[Budgeting_LinkedTOQ_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_stng_Budgeting_LinkedTOQ_Mapping_RAB] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Budgeting_LinkedTOQ_Mapping] CHECK CONSTRAINT [FK_stng_Budgeting_LinkedTOQ_Mapping_RAB]
GO

ALTER TABLE [stng].[Budgeting_LinkedTOQ_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_stng_Budgeting_LinkedTOQ_Mapping_SDQUID] FOREIGN KEY([SDQUID])
REFERENCES [stng].[Budgeting_SDQMain] ([SDQUID])
GO

ALTER TABLE [stng].[Budgeting_LinkedTOQ_Mapping] CHECK CONSTRAINT [FK_stng_Budgeting_LinkedTOQ_Mapping_SDQUID]
GO

ALTER TABLE [stng].[Budgeting_LinkedTOQ_Mapping]  WITH CHECK ADD  CONSTRAINT [FK_stng_Budgeting_LinkedTOQ_Mapping_TOQID] FOREIGN KEY([TOQID])
REFERENCES [stng].[TOQ_Main] ([UniqueID])
GO

ALTER TABLE [stng].[Budgeting_LinkedTOQ_Mapping] CHECK CONSTRAINT [FK_stng_Budgeting_LinkedTOQ_Mapping_TOQID]
GO

ALTER TABLE [stng].[Budgeting_LinkedTOQ_Mapping]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Budgeting_LinkedTOQ_Mapping_DeletedCheck] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[Budgeting_LinkedTOQ_Mapping] CHECK CONSTRAINT [CNST_stng_Budgeting_LinkedTOQ_Mapping_DeletedCheck]
GO


