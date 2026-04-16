CREATE TABLE [stng].[General_MPLOrganizationMap](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[PersonGroup] [varchar](50) NOT NULL,
	[MPLDiscipline] [varchar](100) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[LUD] [datetime] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
	[WBSCode] [nvarchar](255) NULL,
	[P6Code] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[General_MPLOrganizationMap] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[General_MPLOrganizationMap] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[General_MPLOrganizationMap]  WITH CHECK ADD FOREIGN KEY([PersonGroup])
REFERENCES [stng].[General_Organization] ([PersonGroup])
GO

ALTER TABLE [stng].[General_MPLOrganizationMap]  WITH CHECK ADD FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[General_MPLOrganizationMap]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO
