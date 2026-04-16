/****** Object:  Table [stng].[Admin_EndpointPermission]    Script Date: 10/21/2024 12:11:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_EndpointPermission](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[EndpointID] [uniqueidentifier] NOT NULL,
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
 CONSTRAINT [CNST_stng_Admin_EndpointPermission_Unique] UNIQUE NONCLUSTERED 
(
	[EndpointID] ASC,
	[PermissionID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_EndpointPermission] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Admin_EndpointPermission] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Admin_EndpointPermission]  WITH CHECK ADD  CONSTRAINT [FK__Admin_End__Delet__383A4359] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_EndpointPermission] CHECK CONSTRAINT [FK__Admin_End__Delet__383A4359]
GO

ALTER TABLE [stng].[Admin_EndpointPermission]  WITH CHECK ADD FOREIGN KEY([EndpointID])
REFERENCES [stng].[Admin_Endpoint] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_EndpointPermission]  WITH CHECK ADD FOREIGN KEY([PermissionID])
REFERENCES [stng].[Admin_Permission] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_EndpointPermission]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Endpo__RAB__3C0AD43D] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_EndpointPermission] CHECK CONSTRAINT [FK__Admin_Endpo__RAB__3C0AD43D]
GO

ALTER TABLE [stng].[Admin_EndpointPermission]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Admin_EndpointPermission_Deleted] CHECK  (([Deleted]=(0) OR ([Deleted]=(1) OR [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL)))
GO

ALTER TABLE [stng].[Admin_EndpointPermission] CHECK CONSTRAINT [CNST_stng_Admin_EndpointPermission_Deleted]
GO


