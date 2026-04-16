CREATE TABLE [stng].[SST_HeaderTimes](
	[SSTID] [uniqueidentifier] NOT NULL,
	[ImpairmentCount] [nvarchar](100) NULL,
	[ImpairmentUnit] [nvarchar](10) NULL,
	[ImpairmentNA] [bit] NOT NULL,
	[ChannelRejectionCount] [nvarchar](100) NULL,
	[ChannelRejectionUnit] [nvarchar](10) NULL,
	[ChannelRejectionNA] [bit] NOT NULL,
	[LUD] [datetime] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SSTID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[SST_HeaderTimes] ADD  DEFAULT ((0)) FOR [ImpairmentCount]
GO

ALTER TABLE [stng].[SST_HeaderTimes] ADD  DEFAULT ((0)) FOR [ImpairmentNA]
GO

ALTER TABLE [stng].[SST_HeaderTimes] ADD  DEFAULT ((0)) FOR [ChannelRejectionCount]
GO

ALTER TABLE [stng].[SST_HeaderTimes] ADD  DEFAULT ((0)) FOR [ChannelRejectionNA]
GO

ALTER TABLE [stng].[SST_HeaderTimes] ADD  DEFAULT ([stng].[getbptime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[SST_HeaderTimes]  WITH CHECK ADD FOREIGN KEY([SSTID])
REFERENCES [stng].[SST_Main] ([UniqueID])
GO

ALTER TABLE [stng].[SST_HeaderTimes]  WITH CHECK ADD FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


