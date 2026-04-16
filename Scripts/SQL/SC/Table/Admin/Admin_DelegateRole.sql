/****** Object:  Table [stng].[Admin_DelegateRole]    Script Date: 10/21/2024 12:13:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_DelegateRole](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[DelegateUID] [uniqueidentifier] NOT NULL,
	[RoleUID] [uniqueidentifier] NOT NULL,
	[Enabled] [bit] NOT NULL,
	[CreatedBy] [varchar](20) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_DelegateRole] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[Admin_DelegateRole] ADD  DEFAULT ((1)) FOR [Enabled]
GO

ALTER TABLE [stng].[Admin_DelegateRole] ADD  DEFAULT ([stng].[GetDate]()) FOR [CreatedDate]
GO

ALTER TABLE [stng].[Admin_DelegateRole]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Del__Creat__4CEB477C] FOREIGN KEY([CreatedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_DelegateRole] CHECK CONSTRAINT [FK__Admin_Del__Creat__4CEB477C]
GO

ALTER TABLE [stng].[Admin_DelegateRole]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Del__Creat__4DDF6BB5] FOREIGN KEY([CreatedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_DelegateRole] CHECK CONSTRAINT [FK__Admin_Del__Creat__4DDF6BB5]
GO

ALTER TABLE [stng].[Admin_DelegateRole]  WITH CHECK ADD FOREIGN KEY([DelegateUID])
REFERENCES [stng].[Admin_Delegation] ([UniqueID])
GO


