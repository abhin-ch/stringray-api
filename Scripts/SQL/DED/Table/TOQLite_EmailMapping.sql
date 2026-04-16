/****** Object:  Table [stng].[TOQLite_EmailMapping]    Script Date: 3/7/2024 3:26:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[TOQLite_EmailMapping](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[StatusFrom] [uniqueidentifier] NOT NULL,
	[StatusTo] [uniqueidentifier] NOT NULL,
	[Template] [uniqueidentifier] NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
 CONSTRAINT [PK_TOQLite_EmailMapping] PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[TOQLite_EmailMapping] ADD  DEFAULT ([stng].[getbptime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[TOQLite_EmailMapping]  WITH CHECK ADD FOREIGN KEY([StatusFrom])
REFERENCES [stng].[TOQLite_Status] ([UniqueID])
GO

ALTER TABLE [stng].[TOQLite_EmailMapping]  WITH CHECK ADD FOREIGN KEY([StatusTo])
REFERENCES [stng].[TOQLite_Status] ([UniqueID])
GO

ALTER TABLE [stng].[TOQLite_EmailMapping]  WITH CHECK ADD FOREIGN KEY([Template])
REFERENCES [stng].[Common_EmailTemplate] ([UniqueID])
GO

ALTER TABLE [stng].[TOQLite_EmailMapping]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO


