/****** Object:  Table [stng].[Admin_RolePermission]    Script Date: 10/21/2024 12:17:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_RolePermission](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[PermissionID] [uniqueidentifier] NOT NULL,
	[RoleID] [uniqueidentifier] NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_stng_Admin_RolePermission_unique] UNIQUE NONCLUSTERED 
(
	[PermissionID] ASC,
	[RoleID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_RolePermission] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Admin_RolePermission] ADD  CONSTRAINT [DF_stng_Admin_RolePermission_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Admin_RolePermission]  WITH CHECK ADD FOREIGN KEY([PermissionID])
REFERENCES [stng].[Admin_Permission] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_RolePermission]  WITH CHECK ADD FOREIGN KEY([RoleID])
REFERENCES [stng].[Admin_Role] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_RolePermission]  WITH CHECK ADD  CONSTRAINT [FK__Admin_RoleP__RAB__4E5E8EA2] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_RolePermission] CHECK CONSTRAINT [FK__Admin_RoleP__RAB__4E5E8EA2]
GO

ALTER TABLE [stng].[Admin_RolePermission]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Admin_RolePermission_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[Admin_RolePermission] CHECK CONSTRAINT [CNST_stng_Admin_RolePermission_Deleted]
GO


