/****** Object:  Table [stng].[Admin_SubRequest]    Script Date: 10/21/2024 12:19:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_SubRequest](
	[SubRequestID] [uniqueidentifier] NOT NULL,
	[RequestID] [uniqueidentifier] NOT NULL,
	[StatusID] [uniqueidentifier] NOT NULL,
	[Comment] [varchar](1000) NULL,
	[ReviewedBy] [varchar](20) NULL,
	[ReviewedOn] [datetime] NULL,
	[ModuleAttributeID] [uniqueidentifier] NOT NULL,
	[RoleID] [uniqueidentifier] NULL,
PRIMARY KEY CLUSTERED 
(
	[SubRequestID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_SubRequest] ADD  DEFAULT (newid()) FOR [SubRequestID]
GO

ALTER TABLE [stng].[Admin_SubRequest]  WITH CHECK ADD  CONSTRAINT [FK_ModuleAttributeID] FOREIGN KEY([ModuleAttributeID])
REFERENCES [stng].[Admin_Attribute] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_SubRequest] CHECK CONSTRAINT [FK_ModuleAttributeID]
GO

ALTER TABLE [stng].[Admin_SubRequest]  WITH CHECK ADD  CONSTRAINT [FK_RequestID] FOREIGN KEY([RequestID])
REFERENCES [stng].[Admin_Request] ([RequestID])
GO

ALTER TABLE [stng].[Admin_SubRequest] CHECK CONSTRAINT [FK_RequestID]
GO

ALTER TABLE [stng].[Admin_SubRequest]  WITH CHECK ADD  CONSTRAINT [FK_ReviewedBy] FOREIGN KEY([ReviewedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_SubRequest] CHECK CONSTRAINT [FK_ReviewedBy]
GO

ALTER TABLE [stng].[Admin_SubRequest]  WITH CHECK ADD  CONSTRAINT [FK_RoleID] FOREIGN KEY([RoleID])
REFERENCES [stng].[Admin_Role] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_SubRequest] CHECK CONSTRAINT [FK_RoleID]
GO

ALTER TABLE [stng].[Admin_SubRequest]  WITH CHECK ADD  CONSTRAINT [FK_StatusID] FOREIGN KEY([StatusID])
REFERENCES [stng].[Admin_SubRequestStatus] ([StatusID])
GO

ALTER TABLE [stng].[Admin_SubRequest] CHECK CONSTRAINT [FK_StatusID]
GO


