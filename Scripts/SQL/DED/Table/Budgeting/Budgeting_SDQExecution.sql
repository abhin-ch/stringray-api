CREATE TABLE [stng].[Budgeting_SDQExecution](
	[UniqueID] UNIQUEIDENTIFIER DEFAULT NEWID(),
	[SDQUID] [bigint] REFERENCES [stng].[Budgeting_SDQMain] ([SDQUID]),
	[Execution] [uniqueidentifier] REFERENCES [stng].[Common_ValueLabel] ([UniqueID]),
	[CreatedDate] [datetime] DEFAULT stng.GetDate(),
	[CreatedBy] [varchar](20) REFERENCES [stng].[Admin_User] ([EmployeeID])
	CONSTRAINT CNST_stng_Budgeting_SDQExecution_Unique unique(SDQUID,Execution)
)