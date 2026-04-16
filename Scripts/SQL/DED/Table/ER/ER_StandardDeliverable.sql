CREATE TABLE [stng].[ER_StandardDeliverable](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Deliverable] [varchar](150) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[LUD] [datetime] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
	[Active] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Deliverable] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[ER_StandardDeliverable] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[ER_StandardDeliverable] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[ER_StandardDeliverable] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[ER_StandardDeliverable] ADD  CONSTRAINT [CNST_stng_ER_StandardDeliverable_Active]  DEFAULT ((1)) FOR [Active]
GO

ALTER TABLE [stng].[ER_StandardDeliverable]  WITH CHECK ADD FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User_Original] ([EmployeeID])
GO

ALTER TABLE [stng].[ER_StandardDeliverable]  WITH CHECK ADD FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User_Original] ([EmployeeID])
GO


