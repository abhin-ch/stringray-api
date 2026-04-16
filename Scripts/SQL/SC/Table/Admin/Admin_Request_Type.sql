/****** Object:  Table [stng].[Admin_Request_Type]    Script Date: 10/21/2024 12:14:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_Request_Type](
	[AccessTypeID] [uniqueidentifier] NOT NULL,
	[TypeName] [varchar](50) NOT NULL,
	[ShortName] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Admin_Access_Type] PRIMARY KEY CLUSTERED 
(
	[AccessTypeID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


