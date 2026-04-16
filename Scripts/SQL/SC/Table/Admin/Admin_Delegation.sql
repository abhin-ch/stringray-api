/****** Object:  Table [stng].[Admin_Delegation]    Script Date: 10/21/2024 12:06:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_Delegation](
	[UniqueID] [uniqueidentifier] NOT NULL,
	[Delegator] [varchar](20) NOT NULL,
	[Delegatee] [varchar](20) NOT NULL,
	[Active] [bit] NOT NULL,
	[ExpireDate] [datetime] NOT NULL,
	[CreatedBy] [varchar](20) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[Indefinite] [bit] NOT NULL,
	[Deleted] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UniqueID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_Delegation] ADD  DEFAULT (newid()) FOR [UniqueID]
GO

ALTER TABLE [stng].[Admin_Delegation] ADD  DEFAULT ((1)) FOR [Active]
GO

ALTER TABLE [stng].[Admin_Delegation] ADD  DEFAULT ([stng].[GetDate]()) FOR [CreatedDate]
GO

ALTER TABLE [stng].[Admin_Delegation] ADD  DEFAULT ((0)) FOR [Indefinite]
GO

ALTER TABLE [stng].[Admin_Delegation] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Admin_Delegation]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Del__Creat__3DA903EC] FOREIGN KEY([CreatedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_Delegation] CHECK CONSTRAINT [FK__Admin_Del__Creat__3DA903EC]
GO

ALTER TABLE [stng].[Admin_Delegation]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Del__Deleg__3E9D2825] FOREIGN KEY([Delegator])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_Delegation] CHECK CONSTRAINT [FK__Admin_Del__Deleg__3E9D2825]
GO

ALTER TABLE [stng].[Admin_Delegation]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Del__Deleg__3F914C5E] FOREIGN KEY([Delegatee])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_Delegation] CHECK CONSTRAINT [FK__Admin_Del__Deleg__3F914C5E]
GO

ALTER TABLE [stng].[Admin_Delegation]  WITH CHECK ADD  CONSTRAINT [not_equal] CHECK  (([Delegator]<>[Delegatee]))
GO

ALTER TABLE [stng].[Admin_Delegation] CHECK CONSTRAINT [not_equal]
GO


