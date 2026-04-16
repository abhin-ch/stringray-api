CREATE TABLE [stng].[ECRA_PerceptionComment](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[EC] [varchar](100) NOT NULL,
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

ALTER TABLE [stng].[ECRA_PerceptionComment] ADD  DEFAULT ([stng].[getbptime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[ECRA_PerceptionComment] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[ECRA_PerceptionComment]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[ECRA_PerceptionComment]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[ECRA_PerceptionComment]  WITH CHECK ADD  CONSTRAINT [CNST_stng_ECRA_PerceptionComment_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[ECRA_PerceptionComment] CHECK CONSTRAINT [CNST_stng_ECRA_PerceptionComment_Deleted]
GO


