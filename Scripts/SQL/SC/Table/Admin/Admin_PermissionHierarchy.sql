/****** Object:  Table [stng].[Admin_PermissionHierarchy]    Script Date: 10/21/2024 12:19:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_PermissionHierarchy](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[ParentPermissionID] [uniqueidentifier] NULL,
	[PermissionID] [uniqueidentifier] NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_stng_Admin_PermissionHierarchy_Unique] UNIQUE NONCLUSTERED 
(
	[ParentPermissionID] ASC,
	[PermissionID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_PermissionHierarchy] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Admin_PermissionHierarchy] ADD  CONSTRAINT [CNST_stng_Admin_PermissionHierarchy_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Admin_PermissionHierarchy]  WITH CHECK ADD FOREIGN KEY([ParentPermissionID])
REFERENCES [stng].[Admin_Permission] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_PermissionHierarchy]  WITH CHECK ADD FOREIGN KEY([PermissionID])
REFERENCES [stng].[Admin_Permission] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_PermissionHierarchy]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Permi__RAB__26509D48] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_PermissionHierarchy] CHECK CONSTRAINT [FK__Admin_Permi__RAB__26509D48]
GO

ALTER TABLE [stng].[Admin_PermissionHierarchy]  WITH CHECK ADD  CONSTRAINT [FK_stng_Admin_PermissionHierarchy_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_PermissionHierarchy] CHECK CONSTRAINT [FK_stng_Admin_PermissionHierarchy_DeletedBy]
GO

ALTER TABLE [stng].[Admin_PermissionHierarchy]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Admin_PermissionHierarchy_Different] CHECK  (([ParentPermissionID]<>[PermissionID]))
GO

ALTER TABLE [stng].[Admin_PermissionHierarchy] CHECK CONSTRAINT [CNST_stng_Admin_PermissionHierarchy_Different]
GO

ALTER TABLE [stng].[Admin_PermissionHierarchy]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Admin_PermissionHierarchy_Origin] CHECK  (([PermissionID]='5E7FB06C-EDF5-499C-8F6A-F5DBD2640BCE' AND [ParentPermissionID] IS NULL OR [ParentPermissionID] IS NOT NULL))
GO

ALTER TABLE [stng].[Admin_PermissionHierarchy] CHECK CONSTRAINT [CNST_stng_Admin_PermissionHierarchy_Origin]
GO

ALTER TABLE [stng].[Admin_PermissionHierarchy]  WITH CHECK ADD  CONSTRAINT [FK_stng_Admin_PermissionHierarchy_DeletedCheck] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[Admin_PermissionHierarchy] CHECK CONSTRAINT [FK_stng_Admin_PermissionHierarchy_DeletedCheck]
GO


