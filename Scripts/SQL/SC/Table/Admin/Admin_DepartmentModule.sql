/****** Object:  Table [stng].[Admin_DepartmentModule]    Script Date: 10/21/2024 12:07:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_DepartmentModule](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[AttributeDeptID] [uniqueidentifier] NOT NULL,
	[AttributeModID] [uniqueidentifier] NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_stng_Admin_DepartmentModule_Unique] UNIQUE NONCLUSTERED 
(
	[AttributeDeptID] ASC,
	[AttributeModID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_DepartmentModule] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Admin_DepartmentModule]  WITH CHECK ADD FOREIGN KEY([AttributeDeptID])
REFERENCES [stng].[Admin_Attribute] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_DepartmentModule]  WITH CHECK ADD FOREIGN KEY([AttributeModID])
REFERENCES [stng].[Admin_Attribute] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_DepartmentModule]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Depar__RAB__1E9A6CE7] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_DepartmentModule] CHECK CONSTRAINT [FK__Admin_Depar__RAB__1E9A6CE7]
GO


