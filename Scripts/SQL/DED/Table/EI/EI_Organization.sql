/****** Object:  Table [stng].[EI_Organization]    Script Date: 10/15/2024 4:00:12 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[EI_Organization](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Organization] [varchar](500) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Organization] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[EI_Organization] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[EI_Organization] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[EI_Organization] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[EI_Organization]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[EI_Organization]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[EI_Organization]  WITH CHECK ADD  CONSTRAINT [CNST_stng_EI_Organization_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[EI_Organization] CHECK CONSTRAINT [CNST_stng_EI_Organization_Deleted]
GO


