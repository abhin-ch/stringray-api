CREATE TABLE [stng].App_ErrorLog(
	[ErrorId] [int] IDENTITY(1,1) NOT NULL,
	[Number] [int] NULL,
	[Procedure] [nvarchar](255) NULL,
	[Line] [int] NULL,
	[Message] [nvarchar](510) NULL,
	[StackTrace] [nvarchar](4000) NULL,
	[Operation] [tinyint] NULL,
	[CreatedDate] DATETIME DEFAULT stng.GetDate(),
	[SubOp] INT
)