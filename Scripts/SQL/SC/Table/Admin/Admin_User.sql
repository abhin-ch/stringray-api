/****** Object:  Table [stng].[Admin_User]    Script Date: 10/21/2024 12:04:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_User](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[Username] [nvarchar](255) NOT NULL,
	[FirstName] [nvarchar](255) NULL,
	[LastName] [nvarchar](255) NULL,
	[FullName]  AS (concat([LastName],', ',[FirstName])),
	[Email] [nvarchar](255) NULL,
	[Active] [bit] NULL,
	[LastLogin] [datetime] NULL,
	[CreatedDate] [datetime] NULL,
	[EmployeeID] [varchar](20) NOT NULL,
	[Title] [nvarchar](255) NULL,
	[LANID] [nvarchar](255) NULL,
	[Tag] [nvarchar](255) NULL,
	[WorkGroup] [varchar](250) NULL,
 CONSTRAINT [PK__Admin_Us__7AD04FF19825B5E9] PRIMARY KEY CLUSTERED 
(
	[EmployeeID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_User] ADD  CONSTRAINT [DF__User__Active__2]  DEFAULT ((1)) FOR [Active]
GO

ALTER TABLE [stng].[Admin_User] ADD  CONSTRAINT [DF__User__CreatedDat__2]  DEFAULT (getdate()) FOR [CreatedDate]
GO


