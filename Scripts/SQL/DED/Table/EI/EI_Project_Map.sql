/****** Object:  Table [stng].[EI_Project_Map]    Script Date: 10/15/2024 3:59:53 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[EI_Project_Map](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[EIID] [uniqueidentifier] NOT NULL,
	[Project] [varchar](25) NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[RAD] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_stng_EI_Project_Map_Unique] UNIQUE NONCLUSTERED 
(
	[EIID] ASC,
	[Project] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[EI_Project_Map] ADD  DEFAULT ([stng].[getbptime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[EI_Project_Map]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User_Original] ([EmployeeID])
GO

ALTER TABLE [stng].[EI_Project_Map]  WITH CHECK ADD FOREIGN KEY([EIID])
REFERENCES [stng].[EI_Main] ([UniqueID])
GO


