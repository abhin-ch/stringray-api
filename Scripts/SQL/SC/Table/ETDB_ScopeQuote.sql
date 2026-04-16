CREATE TABLE [stng].[ETDB_ScopeQuote](
	[SQID] [int] IDENTITY(1,1) NOT NULL,
	[SheetID] [nvarchar](255) NULL,
	[Price] [nvarchar](255) NULL,
	[Notes] [nvarchar](255) NULL,
	[FiftyDate] [datetime] NULL,
	[FinalDate] [datetime] NULL,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO

ALTER TABLE [stng].[ETDB_ScopeQuote] ADD  DEFAULT (getdate()) FOR [CreatedDate]
GO