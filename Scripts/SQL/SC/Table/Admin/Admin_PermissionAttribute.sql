/****** Object:  Table [stng].[Admin_PermissionAttribute]    Script Date: 10/21/2024 12:18:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_PermissionAttribute](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[PermissionID] [uniqueidentifier] NOT NULL,
	[AttributeID] [uniqueidentifier] NULL,
	[AttributeTypeID] [uniqueidentifier] NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_stng_Admin_PermissionAttribute_Unique] UNIQUE NONCLUSTERED 
(
	[PermissionID] ASC,
	[AttributeID] ASC,
	[AttributeTypeID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_PermissionAttribute] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Admin_PermissionAttribute] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Admin_PermissionAttribute]  WITH CHECK ADD FOREIGN KEY([AttributeID])
REFERENCES [stng].[Admin_Attribute] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_PermissionAttribute]  WITH CHECK ADD FOREIGN KEY([AttributeTypeID])
REFERENCES [stng].[Admin_AttributeType] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_PermissionAttribute]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Per__Delet__09B45E9A] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_PermissionAttribute] CHECK CONSTRAINT [FK__Admin_Per__Delet__09B45E9A]
GO

ALTER TABLE [stng].[Admin_PermissionAttribute]  WITH CHECK ADD FOREIGN KEY([PermissionID])
REFERENCES [stng].[Admin_Permission] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_PermissionAttribute]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Permi__RAB__0B9CA70C] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_PermissionAttribute] CHECK CONSTRAINT [FK__Admin_Permi__RAB__0B9CA70C]
GO

ALTER TABLE [stng].[Admin_PermissionAttribute]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Admin_PermissionAttribute_Check] CHECK  (([AttributeID] IS NOT NULL OR [AttributeTypeID] IS NOT NULL))
GO

ALTER TABLE [stng].[Admin_PermissionAttribute] CHECK CONSTRAINT [CNST_stng_Admin_PermissionAttribute_Check]
GO

ALTER TABLE [stng].[Admin_PermissionAttribute]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Admin_PermissionAttribute_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedBy] IS NOT NULL AND [DeletedOn] IS NOT NULL))
GO

ALTER TABLE [stng].[Admin_PermissionAttribute] CHECK CONSTRAINT [CNST_stng_Admin_PermissionAttribute_Deleted]
GO


