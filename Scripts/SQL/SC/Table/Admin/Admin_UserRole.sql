/****** Object:  Table [stng].[Admin_UserRole]    Script Date: 10/21/2024 12:16:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_UserRole](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[EmployeeID] [varchar](20) NOT NULL,
	[RoleID] [uniqueidentifier] NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedBy] [varchar](20) NULL,
	[DeletedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_stng_Admin_UserRole_Unique] UNIQUE NONCLUSTERED 
(
	[EmployeeID] ASC,
	[RoleID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_UserRole] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Admin_UserRole] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Admin_UserRole]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Use__Delet__729BEF18] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_UserRole] CHECK CONSTRAINT [FK__Admin_Use__Delet__729BEF18]
GO

ALTER TABLE [stng].[Admin_UserRole]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Use__Emplo__73901351] FOREIGN KEY([EmployeeID])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_UserRole] CHECK CONSTRAINT [FK__Admin_Use__Emplo__73901351]
GO

ALTER TABLE [stng].[Admin_UserRole]  WITH CHECK ADD FOREIGN KEY([RoleID])
REFERENCES [stng].[Admin_Role] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_UserRole]  WITH CHECK ADD  CONSTRAINT [FK__Admin_UserR__RAB__75785BC3] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_UserRole] CHECK CONSTRAINT [FK__Admin_UserR__RAB__75785BC3]
GO

ALTER TABLE [stng].[Admin_UserRole]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Admin_UserRole_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedBy] IS NOT NULL AND [DeletedOn] IS NOT NULL))
GO

ALTER TABLE [stng].[Admin_UserRole] CHECK CONSTRAINT [CNST_stng_Admin_UserRole_Deleted]
GO


