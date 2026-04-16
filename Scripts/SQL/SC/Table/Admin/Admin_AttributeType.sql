/****** Object:  Table [stng].[Admin_AttributeType]    Script Date: 10/21/2024 12:05:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_AttributeType](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[AttributeType] [varchar](50) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
	[Supersedence] [bit] NOT NULL,
	[LUD] [datetime] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[AttributeType] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_AttributeType] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[Admin_AttributeType] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Admin_AttributeType] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Admin_AttributeType] ADD  DEFAULT ((0)) FOR [Supersedence]
GO

ALTER TABLE [stng].[Admin_AttributeType] ADD  CONSTRAINT [CNST_stng_Admin_AttributeType_LUD]  DEFAULT ([stng].[getbptime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[Admin_AttributeType]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Att__Delet__60B24907] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_AttributeType] CHECK CONSTRAINT [FK__Admin_Att__Delet__60B24907]
GO

ALTER TABLE [stng].[Admin_AttributeType]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Attri__RAB__61A66D40] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_AttributeType] CHECK CONSTRAINT [FK__Admin_Attri__RAB__61A66D40]
GO

ALTER TABLE [stng].[Admin_AttributeType]  WITH CHECK ADD  CONSTRAINT [FK_stng_Admin_AttributeType_LUB] FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_AttributeType] CHECK CONSTRAINT [FK_stng_Admin_AttributeType_LUB]
GO

ALTER TABLE [stng].[Admin_AttributeType]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Admin_AttributeType_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[Admin_AttributeType] CHECK CONSTRAINT [CNST_stng_Admin_AttributeType_Deleted]
GO


