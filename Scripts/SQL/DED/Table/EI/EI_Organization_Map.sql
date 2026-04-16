/****** Object:  Table [stng].[EI_Organization_Map]    Script Date: 10/15/2024 3:59:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[EI_Organization_Map](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[EIID] [uniqueidentifier] NOT NULL,
	[Organization] [uniqueidentifier] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[RAD] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_stng_EI_Organization_Map_Unique] UNIQUE NONCLUSTERED 
(
	[EIID] ASC,
	[Organization] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[EI_Organization_Map] ADD  DEFAULT ([stng].[getbptime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[EI_Organization_Map]  WITH CHECK ADD FOREIGN KEY([Organization])
REFERENCES [stng].[EI_Organization] ([UniqueID])
GO

ALTER TABLE [stng].[EI_Organization_Map]  WITH CHECK ADD FOREIGN KEY([EIID])
REFERENCES [stng].[EI_Main] ([UniqueID])
GO

ALTER TABLE [stng].[EI_Organization_Map]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


