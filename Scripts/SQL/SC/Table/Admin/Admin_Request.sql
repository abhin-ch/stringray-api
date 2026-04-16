/****** Object:  Table [stng].[Admin_Request]    Script Date: 10/21/2024 12:14:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_Request](
	[RequestID] [uniqueidentifier] NOT NULL,
	[RequestorEID] [varchar](20) NOT NULL,
	[AccessTypeID] [uniqueidentifier] NOT NULL,
	[MimicOfEID] [varchar](20) NULL,
	[ReasonGiven] [varchar](1000) NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[OriginalModuleID] [uniqueidentifier] NULL,
PRIMARY KEY CLUSTERED 
(
	[RequestID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_Request] ADD  DEFAULT (newid()) FOR [RequestID]
GO

ALTER TABLE [stng].[Admin_Request] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Admin_Request]  WITH CHECK ADD  CONSTRAINT [FK_AccessTypeID] FOREIGN KEY([AccessTypeID])
REFERENCES [stng].[Admin_Request_Type] ([AccessTypeID])
GO

ALTER TABLE [stng].[Admin_Request] CHECK CONSTRAINT [FK_AccessTypeID]
GO

ALTER TABLE [stng].[Admin_Request]  WITH CHECK ADD  CONSTRAINT [FK_MimicOfEID] FOREIGN KEY([MimicOfEID])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_Request] CHECK CONSTRAINT [FK_MimicOfEID]
GO

ALTER TABLE [stng].[Admin_Request]  WITH CHECK ADD  CONSTRAINT [FK_RAB] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_Request] CHECK CONSTRAINT [FK_RAB]
GO

ALTER TABLE [stng].[Admin_Request]  WITH CHECK ADD  CONSTRAINT [FK_RequestorEID] FOREIGN KEY([RequestorEID])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_Request] CHECK CONSTRAINT [FK_RequestorEID]
GO


