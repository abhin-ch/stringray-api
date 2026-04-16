/****** Object:  Table [stng].[Admin_Permission]    Script Date: 10/21/2024 12:11:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_Permission](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Permission] [varchar](50) NOT NULL,
	[PermissionDescription] [varchar](max) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
	[LUD] [datetime] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Permission] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_Permission] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[Admin_Permission] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Admin_Permission] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Admin_Permission] ADD  CONSTRAINT [CNST_stng_Admin_Permission_LUD_Default]  DEFAULT ([stng].[GetBPTime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[Admin_Permission]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Per__Delet__7F36D027] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_Permission] CHECK CONSTRAINT [FK__Admin_Per__Delet__7F36D027]
GO

ALTER TABLE [stng].[Admin_Permission]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Permi__RAB__002AF460] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_Permission] CHECK CONSTRAINT [FK__Admin_Permi__RAB__002AF460]
GO

ALTER TABLE [stng].[Admin_Permission]  WITH CHECK ADD  CONSTRAINT [FK_stng_Admin_Permission_LUB] FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_Permission] CHECK CONSTRAINT [FK_stng_Admin_Permission_LUB]
GO

ALTER TABLE [stng].[Admin_Permission]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Admin_Permission_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[Admin_Permission] CHECK CONSTRAINT [CNST_stng_Admin_Permission_Deleted]
GO


