/****** Object:  Table [stng].[Admin_Attribute]    Script Date: 10/21/2024 12:06:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_Attribute](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Attribute] [varchar](50) NOT NULL,
	[AttributeType] [uniqueidentifier] NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
	[LUD] [datetime] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_stng_Admin_Attribute_Unique] UNIQUE NONCLUSTERED 
(
	[Attribute] ASC,
	[AttributeType] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_Attribute] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[Admin_Attribute] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Admin_Attribute] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Admin_Attribute] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[Admin_Attribute]  WITH CHECK ADD FOREIGN KEY([AttributeType])
REFERENCES [stng].[Admin_AttributeType] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_Attribute]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Att__Delet__6C23FBB3] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_Attribute] CHECK CONSTRAINT [FK__Admin_Att__Delet__6C23FBB3]
GO

ALTER TABLE [stng].[Admin_Attribute]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Attri__RAB__6D181FEC] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_Attribute] CHECK CONSTRAINT [FK__Admin_Attri__RAB__6D181FEC]
GO

ALTER TABLE [stng].[Admin_Attribute]  WITH CHECK ADD  CONSTRAINT [FK_stng_Admin_Attribute_LUB] FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_Attribute] CHECK CONSTRAINT [FK_stng_Admin_Attribute_LUB]
GO

ALTER TABLE [stng].[Admin_Attribute]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Admin_Attribute_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[Admin_Attribute] CHECK CONSTRAINT [CNST_stng_Admin_Attribute_Deleted]
GO


