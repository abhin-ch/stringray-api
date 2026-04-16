/****** Object:  Table [stng].[TOQLite_Revision_Main]    Script Date: 11/19/2025 9:24:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[TOQLite_Revision_Main](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[VendorResponseDate] [date] NULL,
	[PCT50Date] [date] NULL,
	[PCT90Date] [date] NULL,
	[ERLevelDates] [bit] NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[TOQID] [uniqueidentifier] NULL,
	[VendorNotes] [varchar](max) NULL,
	[Scope] [varchar](max) NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[TOQLite_Revision_Main] ADD  DEFAULT ((0)) FOR [ERLevelDates]
GO

ALTER TABLE [stng].[TOQLite_Revision_Main] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[TOQLite_Revision_Main] ADD  CONSTRAINT [DF_TOQLite_Revision_Main_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[TOQLite_Revision_Main]  WITH CHECK ADD  CONSTRAINT [CNST_TOQLite_Revision_Main_TOQID] FOREIGN KEY([TOQID])
REFERENCES [stng].[TOQLite_TOQ_Temp] ([UniqueID])
GO

ALTER TABLE [stng].[TOQLite_Revision_Main] CHECK CONSTRAINT [CNST_TOQLite_Revision_Main_TOQID]
GO

ALTER TABLE [stng].[TOQLite_Revision_Main]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[TOQLite_Revision_Main]  WITH CHECK ADD FOREIGN KEY([UniqueID])
REFERENCES [stng].[TOQLite_Main] ([UniqueID])
GO

ALTER TABLE [stng].[TOQLite_Revision_Main]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


