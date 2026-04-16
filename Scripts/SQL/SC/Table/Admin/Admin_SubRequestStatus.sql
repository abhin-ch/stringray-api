/****** Object:  Table [stng].[Admin_SubRequestStatus]    Script Date: 10/21/2024 12:19:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_SubRequestStatus](
	[StatusID] [uniqueidentifier] NOT NULL,
	[ActionStatus] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[StatusID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_SubRequestStatus] ADD  DEFAULT (newid()) FOR [StatusID]
GO


