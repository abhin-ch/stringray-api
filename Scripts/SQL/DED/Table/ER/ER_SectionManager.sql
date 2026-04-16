CREATE TABLE [stng].[ER_SectionManager](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[Section] [bigint] NOT NULL,
	[SM] [varchar](20) NULL,
	[Primary] [bit] NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[ER_SectionManager] ADD  CONSTRAINT [DF_ER_SectionManager_Primary]  DEFAULT ((0)) FOR [Primary]
GO

ALTER TABLE [stng].[ER_SectionManager] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[ER_SectionManager] ADD  CONSTRAINT [DF_ER_SectionManager_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[ER_SectionManager]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[ER_SectionManager]  WITH CHECK ADD FOREIGN KEY([Section])
REFERENCES [stng].[ER_Section] ([UniqueID])
GO

ALTER TABLE [stng].[ER_SectionManager]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[ER_SectionManager]  WITH CHECK ADD FOREIGN KEY([SM])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


