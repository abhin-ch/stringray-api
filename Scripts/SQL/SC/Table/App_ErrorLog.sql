CREATE TABLE [stng].App_ErrorLog(
	[ErrorId] [int] IDENTITY(1,1) NOT NULL,
	[Number] [int] NULL,
	[Procedure] [nvarchar](255) NULL,
	[Line] [int] NULL,
	[Message] [nvarchar](511) NULL,
	[StackTrace] [nvarchar](4000) NULL,
	[Operation] [tinyint] NULL,
	[CreatedDate] DATETIME DEFAULT cast(convert(DATETIMEOFFSET,GETDATE()) AT TIME ZONE 'Eastern Standard Time' AS DATETIME)
)