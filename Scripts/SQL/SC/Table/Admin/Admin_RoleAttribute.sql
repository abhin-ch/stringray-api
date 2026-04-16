/****** Object:  Table [stng].[Admin_RoleAttribute]    Script Date: 10/21/2024 12:17:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_RoleAttribute](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[RoleID] [uniqueidentifier] NOT NULL,
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
 CONSTRAINT [CNST_stng_Admin_RoleAttribute_Unique] UNIQUE NONCLUSTERED 
(
	[RoleID] ASC,
	[AttributeID] ASC,
	[AttributeTypeID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_RoleAttribute] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Admin_RoleAttribute] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Admin_RoleAttribute]  WITH CHECK ADD FOREIGN KEY([AttributeID])
REFERENCES [stng].[Admin_Attribute] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_RoleAttribute]  WITH CHECK ADD FOREIGN KEY([AttributeTypeID])
REFERENCES [stng].[Admin_AttributeType] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_RoleAttribute]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Rol__Delet__3C3FDE67] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_RoleAttribute] CHECK CONSTRAINT [FK__Admin_Rol__Delet__3C3FDE67]
GO

ALTER TABLE [stng].[Admin_RoleAttribute]  WITH CHECK ADD FOREIGN KEY([RoleID])
REFERENCES [stng].[Admin_Role] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_RoleAttribute]  WITH CHECK ADD  CONSTRAINT [FK__Admin_RoleA__RAB__3E2826D9] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_RoleAttribute] CHECK CONSTRAINT [FK__Admin_RoleA__RAB__3E2826D9]
GO

ALTER TABLE [stng].[Admin_RoleAttribute]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Admin_RoleAttribute_Check] CHECK  (([AttributeID] IS NOT NULL OR [AttributeTypeID] IS NOT NULL))
GO

ALTER TABLE [stng].[Admin_RoleAttribute] CHECK CONSTRAINT [CNST_stng_Admin_RoleAttribute_Check]
GO

ALTER TABLE [stng].[Admin_RoleAttribute]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Admin_RoleAttribute_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedBy] IS NOT NULL AND [DeletedOn] IS NOT NULL))
GO

ALTER TABLE [stng].[Admin_RoleAttribute] CHECK CONSTRAINT [CNST_stng_Admin_RoleAttribute_Deleted]
GO


