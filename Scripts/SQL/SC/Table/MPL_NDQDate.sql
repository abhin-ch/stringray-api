

CREATE TABLE [stng].[MPL_NDQDate](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[ProjectID] [varchar](100) NOT NULL,
	[FK_unique] [uniqueidentifier] NOT NULL,
	[NDQ_Date] [date] NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
 CONSTRAINT [PK_MPL_NDQDate] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[MPL_NDQDate] ADD  CONSTRAINT [DF_MPL_NDQDate_UniqueID]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[MPL_NDQDate] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO


