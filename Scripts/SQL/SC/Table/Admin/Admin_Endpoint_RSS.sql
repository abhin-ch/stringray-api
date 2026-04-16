/****** Object:  Table [stng].[Admin_Endpoint_RSS]    Script Date: 10/21/2024 12:10:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_Endpoint_RSS](
	[UniqueID] [bigint] IDENTITY(1,1) NOT NULL,
	[EndpointID] [uniqueidentifier] NOT NULL,
	[ExpressionID] [uniqueidentifier] NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_stng_Admin_Endpoint_RSS_Unique] UNIQUE NONCLUSTERED 
(
	[EndpointID] ASC,
	[ExpressionID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_Endpoint_RSS] ADD  DEFAULT ([stng].[getbptime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Admin_Endpoint_RSS] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Admin_Endpoint_RSS]  WITH CHECK ADD  CONSTRAINT [FK__Admin_End__Delet__51E506C3] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_Endpoint_RSS] CHECK CONSTRAINT [FK__Admin_End__Delet__51E506C3]
GO

ALTER TABLE [stng].[Admin_Endpoint_RSS]  WITH CHECK ADD FOREIGN KEY([EndpointID])
REFERENCES [stng].[Admin_Endpoint] ([UniqueID])
GO

ALTER TABLE [stng].[Admin_Endpoint_RSS]  WITH CHECK ADD FOREIGN KEY([ExpressionID])
REFERENCES [stng].[Expression_Main] ([ExpressionID])
GO

ALTER TABLE [stng].[Admin_Endpoint_RSS]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Endpo__RAB__4FFCBE51] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_Endpoint_RSS] CHECK CONSTRAINT [FK__Admin_Endpo__RAB__4FFCBE51]
GO

ALTER TABLE [stng].[Admin_Endpoint_RSS]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Admin_Endpoint_RSS_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedBy] IS NOT NULL AND [DeletedOn] IS NOT NULL))
GO

ALTER TABLE [stng].[Admin_Endpoint_RSS] CHECK CONSTRAINT [CNST_stng_Admin_Endpoint_RSS_Deleted]
GO


