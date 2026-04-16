CREATE TABLE [stng].[TOQ_Rework](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[ReworkDetails] [varchar](500) NULL,
	[TurnaroundTimeline] [datetime] NULL,
	[BPEffortEstimate] [int] NULL,
	[Type] [varchar](50) NULL,
	[VendorResponse] [varchar](50) NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [varchar](255) NULL,
	[UpdateDate] [datetime] NULL,
	[UpdatedBy] [varchar](255) NULL,
 CONSTRAINT [PK__TOQ_Rewo__A2A2BAAA4E3F2575] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[TOQ_Rework] ADD  CONSTRAINT [DF__TOQ_Rewor__Uniqu__4EF456D6]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[TOQ_Rework] ADD  CONSTRAINT [DF__TOQ_Rewor__Creat__4FE87B0F]  DEFAULT ([stng].[GetDate]()) FOR [CreatedDate]
GO