CREATE TABLE [stng].[CARLA_FragnetActivityDetail](
	[FADetailID] [int] IDENTITY(1,1) NOT NULL,
	[ActivityID] [nvarchar](20) NULL,
	[DetailName] [nvarchar](255) NULL,
	[DetailValue] [nvarchar](255) NULL,
	[Type] [nvarchar](255) NULL
) ON [PRIMARY]
GO