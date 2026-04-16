/****** Object:  Table [stng].[SST_Mapping]    Script Date: 12/5/2025 11:34:47 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[SST_Mapping](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[SSTID] [uniqueidentifier] NOT NULL,
	[SSTNo] [varchar](30) NOT NULL,
	[SSTChannel] [varchar](5) NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[LUD] [datetime] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_stng_SST_Mapping_Unique] UNIQUE NONCLUSTERED 
(
	[SSTID] ASC,
	[SSTNo] ASC,
	[SSTChannel] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[SST_Mapping] ADD  DEFAULT ([stng].[getbptime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[SST_Mapping] ADD  DEFAULT ([stng].[getbptime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[SST_Mapping] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[SST_Mapping]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[SST_Mapping]  WITH CHECK ADD FOREIGN KEY([SSTID])
REFERENCES [stng].[SST_Main] ([UniqueID])
GO

ALTER TABLE [stng].[SST_Mapping]  WITH CHECK ADD FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[SST_Mapping]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[SST_Mapping]  WITH CHECK ADD  CONSTRAINT [CNST_stng_SST_Mapping_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[SST_Mapping] CHECK CONSTRAINT [CNST_stng_SST_Mapping_Deleted]
GO


