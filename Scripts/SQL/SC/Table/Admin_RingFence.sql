/****** Object:  Table [stng].[Admin_RingFence]    Script Date: 11/12/2024 6:55:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_RingFence](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[User] [varchar](20) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_stng_Admin_RingFence_Unique] UNIQUE NONCLUSTERED 
(
	[User] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_RingFence] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[Admin_RingFence] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Admin_RingFence] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Admin_RingFence]  WITH CHECK ADD  CONSTRAINT [FK__Admin_RingeFence_RAB] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_RingFence] CHECK CONSTRAINT [FK__Admin_RingeFence_RAB]
GO

ALTER TABLE [stng].[Admin_RingFence]  WITH CHECK ADD  CONSTRAINT [FK__Admin_RingFence__DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_RingFence] CHECK CONSTRAINT [FK__Admin_RingFence__DeletedBy]
GO

ALTER TABLE [stng].[Admin_RingFence]  WITH CHECK ADD  CONSTRAINT [FK__Admin_RingFence_User] FOREIGN KEY([User])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_RingFence] CHECK CONSTRAINT [FK__Admin_RingFence_User]
GO

ALTER TABLE [stng].[Admin_RingFence]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Admin_RingFence_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[Admin_RingFence] CHECK CONSTRAINT [CNST_stng_Admin_RingFence_Deleted]
GO


