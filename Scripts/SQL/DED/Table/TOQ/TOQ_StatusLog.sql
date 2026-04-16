CREATE TABLE [stng].[TOQ_StatusLog](
	[UniqueID] UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
	[TOQMainID] UNIQUEIDENTIFIER REFERENCES stng.TOQ_Main(UniqueID),
	[TOQStatusID] UNIQUEIDENTIFIER REFERENCES stng.Common_ValueLabel(UniqueID),
	[Comment] [varchar](4000) NULL,
	[CreatedDate] [datetime] DEFAULT stng.GetDate(),
	[CreatedBy] [varchar](255) NULL
)

CREATE NONCLUSTERED INDEX IX_TOQ_StatusLog_TOQMainID
ON Stng.TOQ_StatusLog (TOQMainID)