CREATE TABLE [stng].[TOQ_EmergentStatusLog](
	[UniqueID] UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
	[TOQ_EmergentID] UNIQUEIDENTIFIER REFERENCES stng.TOQ_Emergent(UniqueID),
	[TOQ_EmergentStatusID] UNIQUEIDENTIFIER REFERENCES stng.Common_ValueLabel(UniqueID),
	[Comment] [varchar](255) NULL,
	[CreatedDate] [datetime] DEFAULT stng.GetDate(),
	[CreatedBy] [varchar](10) NULL
)
