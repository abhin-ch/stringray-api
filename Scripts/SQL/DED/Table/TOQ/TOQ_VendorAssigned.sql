CREATE TABLE [stng].[TOQ_VendorAssigned](
	[UniqueID] UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
	[VendorID] UNIQUEIDENTIFIER REFERENCES stng.Common_ValueLabel(UniqueID),
	[TOQMainID] UNIQUEIDENTIFIER REFERENCES stng.TOQ_Main(UniqueID),
	[VSS] [smallint] DEFAULT 1,
	[TOQNumber] [varchar](100) NULL,
	[ProjectManager] [varchar](100) NULL,
	[Location] [varchar](255) NULL,
	[Email] [varchar](100) NULL,
	[Phone] [varchar](50) NULL,
	[TOQStartDate] [date] NULL,
	[TOQEndDate] [date] NULL,
	[ContractNumber] [varchar](100) NULL,
	[ReasonForTOQID] UNIQUEIDENTIFIER REFERENCES stng.Common_ValueLabel(UniqueID),
	[CreatedDate] [datetime] DEFAULT stng.GetDate(),
	[CreatedBy] [varchar](50) NOT NULL,
	[VendorTOQTitle] [varchar](255) NULL,
	[TOQEndDateRecord] [date] NULL,
	[OrderNumber] [varchar](255) NULL,
	[TOQVendorRev] [varchar](50) NULL,
	[PEID] [bigint] NULL,
	[LinkToEmergentTOQ] [int] DEFAULT 0,
	[PartialRequestAmount] [bigint] NULL,
	[LiteEREstimateAssumption] [varchar](2500) NULL,
	FundingTypeID UNIQUEIDENTIFIER REFERENCES stng.Common_ValueLabel(UniqueID)
)
ALTER TABLE stng.TOQ_VendorAssigned ADD Awarded BIT DEFAULT 0

CREATE NONCLUSTERED INDEX IX_TOQ_VendorAssigned_Awarded
ON [stng].[TOQ_VendorAssigned] ([Awarded])
INCLUDE ([TOQMainID])