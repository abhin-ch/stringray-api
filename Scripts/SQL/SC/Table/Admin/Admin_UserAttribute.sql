/****** Object:  Table [stng].[Admin_UserAttribute]    Script Date: 10/21/2024 12:17:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_UserAttribute](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[EmployeeID] [varchar](20) NOT NULL,
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
 CONSTRAINT [CNST_stng_Admin_EmployeeAttribute_Unique] UNIQUE NONCLUSTERED 
(
	[EmployeeID] ASC,
	[AttributeID] ASC,
	[AttributeTypeID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_UserAttribute] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Admin_UserAttribute] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Admin_UserAttribute]  WITH CHECK ADD FOREIGN KEY([AttributeID])
REFERENCES [stng].[Admin_Attribute] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_UserAttribute]  WITH CHECK ADD FOREIGN KEY([AttributeTypeID])
REFERENCES [stng].[Admin_AttributeType] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_UserAttribute]  WITH CHECK ADD FOREIGN KEY([AttributeID])
REFERENCES [stng].[Admin_Attribute] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_UserAttribute]  WITH CHECK ADD FOREIGN KEY([AttributeTypeID])
REFERENCES [stng].[Admin_AttributeType] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_UserAttribute]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Use__Delet__56F3D4A3] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_UserAttribute] CHECK CONSTRAINT [FK__Admin_Use__Delet__56F3D4A3]
GO

ALTER TABLE [stng].[Admin_UserAttribute]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Use__Emplo__57E7F8DC] FOREIGN KEY([EmployeeID])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_UserAttribute] CHECK CONSTRAINT [FK__Admin_Use__Emplo__57E7F8DC]
GO

ALTER TABLE [stng].[Admin_UserAttribute]  WITH CHECK ADD  CONSTRAINT [FK__Admin_UserA__RAB__58DC1D15] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_UserAttribute] CHECK CONSTRAINT [FK__Admin_UserA__RAB__58DC1D15]
GO

ALTER TABLE [stng].[Admin_UserAttribute]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Admin_EmployeeAttribute_Check] CHECK  (([AttributeID] IS NOT NULL OR [AttributeTypeID] IS NOT NULL))
GO

ALTER TABLE [stng].[Admin_UserAttribute] CHECK CONSTRAINT [CNST_stng_Admin_EmployeeAttribute_Check]
GO

ALTER TABLE [stng].[Admin_UserAttribute]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Admin_EmployeeAttribute_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedBy] IS NOT NULL AND [DeletedOn] IS NOT NULL))
GO

ALTER TABLE [stng].[Admin_UserAttribute] CHECK CONSTRAINT [CNST_stng_Admin_EmployeeAttribute_Deleted]
GO


