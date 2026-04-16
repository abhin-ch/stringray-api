/****** Object:  Table [stng].[Admin_UserAlternateEmail]    Script Date: 4/1/2025 1:26:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [stng].[Admin_UserAlternateEmail](
	[EmployeeID] [varchar](20) NOT NULL,
	[AlternateEmail] [varchar](100) NOT NULL,
	[RAD] [datetime] NOT NULL,
	[RAB] [varchar](20) NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedBy] [varchar](20) NULL,
	[DeletedOn] [datetime] NULL,
 CONSTRAINT [PK__Admin_Us__A2A2BAAAA90EFA34] PRIMARY KEY CLUSTERED 
(
	[EmployeeID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [CNST_stng_Admin_UserAlternateEmail_Unique] UNIQUE NONCLUSTERED 
(
	[EmployeeID] ASC,
	[AlternateEmail] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [stng].[Admin_UserAlternateEmail] ADD  DEFAULT ([stng].[GetBPTime](getdate())) FOR [RAD]
GO

ALTER TABLE [stng].[Admin_UserAlternateEmail] ADD  DEFAULT ((0)) FOR [Deleted]
GO

ALTER TABLE [stng].[Admin_UserAlternateEmail]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Use__Delet__7sfdf] FOREIGN KEY([DeletedBy])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_UserAlternateEmail] CHECK CONSTRAINT [FK__Admin_Use__Delet__7sfdf]
GO

ALTER TABLE [stng].[Admin_UserAlternateEmail]  WITH CHECK ADD  CONSTRAINT [FK__Admin_Use__Emplosadf1351] FOREIGN KEY([EmployeeID])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_UserAlternateEmail] CHECK CONSTRAINT [FK__Admin_Use__Emplosadf1351]
GO

ALTER TABLE [stng].[Admin_UserAlternateEmail]  WITH CHECK ADD  CONSTRAINT [FK__Admin_UserR__RAB__75] FOREIGN KEY([RAB])
REFERENCES [stng].[Admin_User] ([EmployeeID])
GO

ALTER TABLE [stng].[Admin_UserAlternateEmail] CHECK CONSTRAINT [FK__Admin_UserR__RAB__75]
GO

ALTER TABLE [stng].[Admin_UserAlternateEmail]  WITH CHECK ADD  CONSTRAINT [CNST_stng_Admin_UserAlternateEmail_Temp_Deleted] CHECK  (([Deleted]=(0) OR [Deleted]=(1) AND [DeletedBy] IS NOT NULL AND [DeletedOn] IS NOT NULL))
GO

ALTER TABLE [stng].[Admin_UserAlternateEmail] CHECK CONSTRAINT [CNST_stng_Admin_UserAlternateEmail_Temp_Deleted]
GO


