CREATE TABLE [stng].[ER_Constant](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[ConstantName] [varchar](100) NOT NULL,
	[ConstantType] [varchar](50) NOT NULL,
	[ConstantStr] [varchar](200) NULL,
	[ConstantNum] [float] NULL,
	[ConstantBool] [bit] NULL,
	[ConstantDate] [datetime] NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[LUD] [datetime] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ConstantName] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[ER_Constant] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[ER_Constant] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[ER_Constant] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[ER_Constant]  WITH CHECK ADD FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User_Original] ([EmployeeID])
GO

ALTER TABLE [stng].[ER_Constant]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User_Original] ([EmployeeID])
GO

ALTER TABLE [stng].[ER_Constant]  WITH CHECK ADD  CONSTRAINT [CNST_stng_ER_Constant_ConstantType] CHECK  (([ConstantType]='DATE' OR [ConstantType]='BOOL' OR [ConstantType]='NUM' OR [ConstantType]='STR'))
GO

ALTER TABLE [stng].[ER_Constant] CHECK CONSTRAINT [CNST_stng_ER_Constant_ConstantType]
GO

ALTER TABLE [stng].[ER_Constant]  WITH CHECK ADD  CONSTRAINT [CNST_stng_ER_Constant_ProperConstant] CHECK  (([ConstantType]='STR' AND [ConstantStr] IS NOT NULL OR [ConstantType]='NUM' AND [ConstantNum] IS NOT NULL OR [ConstantType]='BOOL' AND [ConstantBool] IS NOT NULL OR [ConstantType]='DATE' AND [ConstantDate] IS NOT NULL))
GO

ALTER TABLE [stng].[ER_Constant] CHECK CONSTRAINT [CNST_stng_ER_Constant_ProperConstant]
GO


