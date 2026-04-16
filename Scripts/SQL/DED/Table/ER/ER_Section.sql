CREATE TABLE [stng].[ER_Section](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[Section] [varchar](100) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
	[DED] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[ER_Section] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[ER_Section] ADD  CONSTRAINT [DF_ER_Section_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[ER_Section] ADD  CONSTRAINT [DF_ER_Section_DED]  DEFAULT ((0)) FOR [DED]
GO

ALTER TABLE [stng].[ER_Section]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[ER_Section]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


