/****** Object:  Table [stng].[Admin_Role]    Script Date: 10/21/2024 12:14:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_Role](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Role] [varchar](50) NOT NULL,
	[RoleDescription] [varchar](max) NOT NULL,
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
	[Role] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_Role] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[Admin_Role] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Admin_Role] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Admin_Role] ADD  CONSTRAINT [CNST_stng_Admin_Role_LUD]  DEFAULT ([stng].[GetBPTime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[Admin_Role]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Rol__Delet__15261146] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_Role] CHECK CONSTRAINT [FK__Admin_Rol__Delet__15261146]
GO

ALTER TABLE [stng].[Admin_Role]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Role___RAB__161A357F] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_Role] CHECK CONSTRAINT [FK__Admin_Role___RAB__161A357F]
GO

ALTER TABLE [stng].[Admin_Role]  WITH CHECK ADD  CONSTRAINT [FK_stng_Admin_Role_LUB] FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_Role] CHECK CONSTRAINT [FK_stng_Admin_Role_LUB]
GO

ALTER TABLE [stng].[Admin_Role]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Admin_Role_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[Admin_Role] CHECK CONSTRAINT [CNST_stng_Admin_Role_Deleted]
GO


