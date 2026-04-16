CREATE TABLE [stng].[TOQ_EmergentLink](
	[UniqueID] UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
	[TOQ_EmergentID] UNIQUEIDENTIFIER REFERENCES stng.TOQ_Emergent(UniqueID),
	[TOQ_MainID] UNIQUEIDENTIFIER REFERENCES stng.TOQ_Main(UniqueID),
	[EmergentParentID] UNIQUEIDENTIFIER REFERENCES stng.TOQ_Emergent(UniqueID),
	[CreatedDate] [datetime] DEFAULT stng.GetDate(),
	[CreatedBy] [varchar](10)
)