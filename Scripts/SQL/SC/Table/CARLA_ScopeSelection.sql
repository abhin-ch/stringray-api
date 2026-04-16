
CREATE TABLE [stng].[CARLA_ScopeSelection](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[ActivityID] [varchar](100) NOT NULL,
	[ScopeType] [varchar](100) NOT NULL,
	[Reference_ID] [varchar](100) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Active] [bit] NULL,
 CONSTRAINT [PK_CARLA_ScopeSelection] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[CARLA_ScopeSelection] ADD  CONSTRAINT [DF_CARLA_ScopeSelection_UniqueID]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[CARLA_ScopeSelection] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO


