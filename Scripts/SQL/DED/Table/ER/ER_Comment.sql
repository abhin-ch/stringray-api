CREATE TABLE [stng].[ER_Comment](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[ERID] [uniqueidentifier] NOT NULL,
	[Comment] [varchar](max) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[ER_Comment] ADD  DEFAULT ([stng].[getbptime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[ER_Comment] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[ER_Comment]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User_Original] ([EmployeeID])
GO

ALTER TABLE [stng].[ER_Comment]  WITH CHECK ADD FOREIGN KEY([ERID])
REFERENCES [stng].[ER_Main_Temp] ([UniqueID])
GO

ALTER TABLE [stng].[ER_Comment]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User_Original] ([EmployeeID])
GO

ALTER TABLE [stng].[ER_Comment]  WITH CHECK ADD  CONSTRAINT [CNST_stng_ER_Comment_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[ER_Comment] CHECK CONSTRAINT [CNST_stng_ER_Comment_Deleted]
GO


