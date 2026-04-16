/****** Object:  Table [stng].[Admin_Endpoint]    Script Date: 10/21/2024 12:08:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_Endpoint](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Endpoint] [varchar](200) NOT NULL,
	[HTTPVerb] [varchar](15) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
	[LUD] [datetime] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_stng_Admin_Endpoint_Unique] UNIQUE NONCLUSTERED 
(
	[Endpoint] ASC,
	[HTTPVerb] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_Endpoint] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[Admin_Endpoint] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Admin_Endpoint] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Admin_Endpoint] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[Admin_Endpoint]  WITH CHECK ADD  CONSTRAINT [FK__Admin_End__Delet__74B941B4] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_Endpoint] CHECK CONSTRAINT [FK__Admin_End__Delet__74B941B4]
GO

ALTER TABLE [stng].[Admin_Endpoint]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Endpo__LUB__102C51FF] FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_Endpoint] CHECK CONSTRAINT [FK__Admin_Endpo__LUB__102C51FF]
GO

ALTER TABLE [stng].[Admin_Endpoint]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Endpo__RAB__75AD65ED] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_Endpoint] CHECK CONSTRAINT [FK__Admin_Endpo__RAB__75AD65ED]
GO

ALTER TABLE [stng].[Admin_Endpoint]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Admin_Endpoint_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[Admin_Endpoint] CHECK CONSTRAINT [CNST_stng_Admin_Endpoint_Deleted]
GO

ALTER TABLE [stng].[Admin_Endpoint]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Admin_Endpoint_HTTPVerb] CHECK  (([HTTPVerb]='PATCH' OR [HTTPVerb]='DELETE' OR [HTTPVerb]='PUT' OR [HTTPVerb]='POST' OR [HTTPVerb]='GET'))
GO

ALTER TABLE [stng].[Admin_Endpoint] CHECK CONSTRAINT [CNST_stng_Admin_Endpoint_HTTPVerb]
GO


