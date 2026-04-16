CREATE TABLE [stng].Admin_UserRole(
	[URID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[RoleID] [int] NOT NULL,
	[Default] BIT DEFAULT 0,
	[Active] [bit] DEFAULT 1,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] DATETIME DEFAULT cast(convert(DATETIMEOFFSET,GETDATE()) AT TIME ZONE 'Eastern Standard Time' AS DATETIME)
) 