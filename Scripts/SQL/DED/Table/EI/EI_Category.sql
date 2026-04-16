/****** Object:  Table [stng].[EI_Category]    Script Date: 10/15/2024 4:01:06 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[EI_Category](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Category] [varchar](50) NOT NULL,
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
	[Category] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[EI_Category] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[EI_Category] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[EI_Category] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[EI_Category]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[EI_Category]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User_Original] ([EmployeeID])
GO

ALTER TABLE [stng].[EI_Category]  WITH CHECK ADD  CONSTRAINT [CNST_stng_EI_Category_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[EI_Category] CHECK CONSTRAINT [CNST_stng_EI_Category_Deleted]
GO


