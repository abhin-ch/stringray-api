CREATE TABLE [stng].[ER_FieldChangeLog](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[ERID] [uniqueidentifier] NOT NULL,
	[FieldName] [varchar](150) NOT NULL,
	[ChangedFromStr] [varchar](max) NULL,
	[ChangedToStr] [varchar](max) NULL,
	[ChangedFromNum] [float] NULL,
	[ChangedToNum] [float] NULL,
	[ChangedFromDate] [datetime] NULL,
	[ChangedToDate] [datetime] NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [stng].[ER_FieldChangeLog] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[ER_FieldChangeLog]  WITH CHECK ADD FOREIGN KEY([ERID])
REFERENCES [stng].[ER_Main_Temp] ([UniqueID])
GO

ALTER TABLE [stng].[ER_FieldChangeLog]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User_Original] ([EmployeeID])
GO


