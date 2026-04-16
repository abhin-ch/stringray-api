/****** Object:  Table [stng].[Admin_DelegatePermission]    Script Date: 10/21/2024 12:12:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_DelegatePermission](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[DelegateUID] [uniqueidentifier] NOT NULL,
	[PermissionUID] [uniqueidentifier] NOT NULL,
	[Enabled] [bit] NOT NULL,
	[CreatedBy] [varchar](20) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_DelegatePermission] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[Admin_DelegatePermission] ADD  DEFAULT ((1)) FOR [Enabled]
GO

ALTER TABLE [stng].[Admin_DelegatePermission] ADD  DEFAULT ([stng].[GetDate]()) FOR [CreatedDate]
GO

ALTER TABLE [stng].[Admin_DelegatePermission]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Del__Creat__454A25B4] FOREIGN KEY([CreatedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_DelegatePermission] CHECK CONSTRAINT [FK__Admin_Del__Creat__454A25B4]
GO

ALTER TABLE [stng].[Admin_DelegatePermission]  WITH CHECK ADD FOREIGN KEY([DelegateUID])
REFERENCES [stng].[Admin_Delegation] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_DelegatePermission]  WITH CHECK ADD FOREIGN KEY([PermissionUID])
REFERENCES [stng].[Admin_Permission] ([UniqueID])
GO


