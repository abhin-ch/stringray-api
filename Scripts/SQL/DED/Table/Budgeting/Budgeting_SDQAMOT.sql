CREATE TABLE [stng].[Budgeting_SDQAMOT](
	[UniqueID] UNIQUEIDENTIFIER DEFAULT NEWID(),
	[SDQUID] [bigint] REFERENCES stng.Budgeting_SDQMain(SDQUID),
	[AMOT] [varchar](4),
	[AMOTOption] [varchar](2),
	[CreatedDate] [datetime] DEFAULT stng.GetDate(),
	[CreatedBy] [varchar](50),
	CONSTRAINT CNST_Budgeting_SDQAMOT UNIQUE([SDQUID],[AMOT],[AMOTOption])
)