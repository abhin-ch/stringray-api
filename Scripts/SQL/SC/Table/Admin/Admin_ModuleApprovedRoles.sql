/****** Object:  Table [stng].[Admin_ModuleApprovedRoles]    Script Date: 10/21/2024 12:16:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_ModuleApprovedRoles](
	[RoleID] [uniqueidentifier] NOT NULL,
	[ModuleAttributeID] [uniqueidentifier] NOT NULL,
	[RequestID] [uniqueidentifier] NOT NULL,
	[RAB] [varchar](20) NULL,
	[RAD] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[RoleID] ASC,
	[ModuleAttributeID] ASC,
	[RequestID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_ModuleApprovedRoles]  WITH CHECK ADD FOREIGN KEY([ModuleAttributeID])
REFERENCES [stng].[Admin_Attribute] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_ModuleApprovedRoles]  WITH CHECK ADD FOREIGN KEY([RequestID])
REFERENCES [stng].[Admin_Request] ([RequestID])
GO

ALTER TABLE [stng].[Admin_ModuleApprovedRoles]  WITH CHECK ADD FOREIGN KEY([RoleID])
REFERENCES [stng].[Admin_Role] ([UniqueID])
ON DELETE CASCADE
GO


