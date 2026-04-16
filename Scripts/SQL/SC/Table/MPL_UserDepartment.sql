

CREATE TABLE [stng].[MPL_UserDepartment](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Department] [varchar](100) NOT NULL,
	[EmployeeID] [varchar](20) NOT NULL,
	[RAD] [datetime] NOT NULL,
 CONSTRAINT [PK_MPL_UserDepartment] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[MPL_UserDepartment] ADD  CONSTRAINT [DF_MPL_UserDepartment_UniqueID]  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[MPL_UserDepartment] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO


