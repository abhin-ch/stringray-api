/****** Object:  Table [stng].[GovernTree_Form]    Script Date: 5/13/2024 11:50:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[GovernTree_Form](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[GTID] [uniqueidentifier] NOT NULL,
	[FormNo] [varchar](250) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_stng_GovernTree_Form_Unique] UNIQUE NONCLUSTERED 
(
	[GTID] ASC,
	[FormNo] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[GovernTree_Form] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[GovernTree_Form]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


