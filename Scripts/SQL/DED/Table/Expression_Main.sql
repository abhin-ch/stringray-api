/****** Object:  Table [stng].[Expression_Main]    Script Date: 10/21/2024 12:08:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Expression_Main](
	[ExpressionID] [uniqueidentifier] NOT NULL,
	[ExpressionName] [varchar](50) NOT NULL,
	[Expression] [varchar](1000) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[LUD] [datetime] NOT NULL,
	[LUB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime] NULL,
	[DeletedBy] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[ExpressionID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ExpressionName] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Expression_Main] ADD  DEFAULT (newid()) FOR [ExpressionID]
GO

ALTER TABLE [stng].[Expression_Main] ADD  DEFAULT ([stng].[getbptime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Expression_Main] ADD  DEFAULT ([stng].[getbptime](getdate())) FOR [LUD]
GO

ALTER TABLE [stng].[Expression_Main] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Expression_Main]  WITH CHECK ADD  CONSTRAINT [FK__Expressio__Delet__232A17DA] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Expression_Main] CHECK CONSTRAINT [FK__Expressio__Delet__232A17DA]
GO

ALTER TABLE [stng].[Expression_Main]  WITH CHECK ADD  CONSTRAINT [FK__Expression___LUB__2141CF68] FOREIGN KEY([LUB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Expression_Main] CHECK CONSTRAINT [FK__Expression___LUB__2141CF68]
GO

ALTER TABLE [stng].[Expression_Main]  WITH CHECK ADD  CONSTRAINT [FK__Expression___RAB__1F5986F6] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Expression_Main] CHECK CONSTRAINT [FK__Expression___RAB__1F5986F6]
GO

ALTER TABLE [stng].[Expression_Main]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Expression_Main_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedOn] IS NOT NULL AND [DeletedBy] IS NOT NULL))
GO

ALTER TABLE [stng].[Expression_Main] CHECK CONSTRAINT [CNST_stng_Expression_Main_Deleted]
GO


