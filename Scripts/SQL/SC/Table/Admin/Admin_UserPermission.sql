/****** Object:  Table [stng].[Admin_UserPermission]    Script Date: 10/21/2024 12:18:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_UserPermission](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[PermissionID] [uniqueidentifier] NOT NULL,
	[EmployeeID] [varchar](20) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_stng_Admin_UserPermission_unique] UNIQUE NONCLUSTERED 
(
	[PermissionID] ASC,
	[EmployeeID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_UserPermission] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Admin_UserPermission] ADD  CONSTRAINT [CNST_Admin_UserPermission_DeletedDef]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Admin_UserPermission]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Use__Emplo__5F891AA4] FOREIGN KEY([EmployeeID])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_UserPermission] CHECK CONSTRAINT [FK__Admin_Use__Emplo__5F891AA4]
GO

ALTER TABLE [stng].[Admin_UserPermission]  WITH CHECK ADD FOREIGN KEY([PermissionID])
REFERENCES [stng].[Admin_Permission] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_UserPermission]  WITH CHECK ADD  CONSTRAINT [FK__Admin_UserP__RAB__61716316] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_UserPermission] CHECK CONSTRAINT [FK__Admin_UserP__RAB__61716316]
GO

ALTER TABLE [stng].[Admin_UserPermission]  WITH CHECK ADD  CONSTRAINT [FK_stng_Admin_UserPermission_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_UserPermission] CHECK CONSTRAINT [FK_stng_Admin_UserPermission_DeletedBy]
GO

ALTER TABLE [stng].[Admin_UserPermission]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Admin_UserPermission_Deleted] CHECK  (([Deleted]=(0) OR ([Deleted]=(1) AND [DeletedOn] IS NOT NULL OR [DeletedBy] IS NOT NULL)))
GO

ALTER TABLE [stng].[Admin_UserPermission] CHECK CONSTRAINT [CNST_stng_Admin_UserPermission_Deleted]
GO


