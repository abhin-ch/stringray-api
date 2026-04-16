/****** Object:  Table [stng].[Admin_EndpointAttribute]    Script Date: 10/21/2024 12:10:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_EndpointAttribute](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[EndpointID] [uniqueidentifier] NOT NULL,
	[AttributeID] [uniqueidentifier] NULL,
	[AttributeTypeID] [uniqueidentifier] NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_EndpointAttribute] ADD  DEFAULT ([stng].[getbptime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Admin_EndpointAttribute] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Admin_EndpointAttribute]  WITH CHECK ADD FOREIGN KEY([AttributeID])
REFERENCES [stng].[Admin_Attribute] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_EndpointAttribute]  WITH CHECK ADD FOREIGN KEY([AttributeTypeID])
REFERENCES [stng].[Admin_AttributeType] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_EndpointAttribute]  WITH CHECK ADD  CONSTRAINT [FK__Admin_End__Delet__17CD73C7] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_EndpointAttribute] CHECK CONSTRAINT [FK__Admin_End__Delet__17CD73C7]
GO

ALTER TABLE [stng].[Admin_EndpointAttribute]  WITH CHECK ADD FOREIGN KEY([EndpointID])
REFERENCES [stng].[Admin_Endpoint] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_EndpointAttribute]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Endpo__RAB__15E52B55] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_EndpointAttribute] CHECK CONSTRAINT [FK__Admin_Endpo__RAB__15E52B55]
GO

ALTER TABLE [stng].[Admin_EndpointAttribute]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Admin_EndpointAttribute_Check] CHECK  (([AttributeID] IS NOT NULL OR [AttributeTypeID] IS NOT NULL))
GO

ALTER TABLE [stng].[Admin_EndpointAttribute] CHECK CONSTRAINT [CNST_stng_Admin_EndpointAttribute_Check]
GO

ALTER TABLE [stng].[Admin_EndpointAttribute]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Admin_EndpointAttribute_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedBy] IS NOT NULL AND [DeletedOn] IS NOT NULL))
GO

ALTER TABLE [stng].[Admin_EndpointAttribute] CHECK CONSTRAINT [CNST_stng_Admin_EndpointAttribute_Deleted]
GO


