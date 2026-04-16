

CREATE TABLE stng.Admin_Module(
	ModuleID INT IDENTITY(1,1) PRIMARY KEY,
	[Name] NVARCHAR(255),
	[Description] NVARCHAR(500),
	Active BIT DEFAULT 0,
	[Path] NVARCHAR(255),
	Icon NVARCHAR(255),
	ShowInCatalog BIT,
	Department NVARCHAR(255),
	CreatedBy NVARCHAR(255) NOT NULL,
	[CreatedDate] DATETIME DEFAULT cast(convert(DATETIMEOFFSET,GETDATE()) AT TIME ZONE 'Eastern Standard Time' AS DATETIME)
)

GO
CREATE TABLE [stng].Admin_UserAccess(
	[UAID] [int] IDENTITY(1,1) NOT NULL,
	[ASID] [int] NOT NULL,
	[UserID] [int] NULL,
	[RoleID] [int] NULL,
	[Access] [bit] DEFAULT 1,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] DATETIME DEFAULT cast(convert(DATETIMEOFFSET,GETDATE()) AT TIME ZONE 'Eastern Standard Time' AS DATETIME)
) 
GO
CREATE TABLE [stng].Admin_DelegateAccess(
	[DAID] [int] IDENTITY(1,1) NOT NULL,
	[UAID] [int] NOT NULL,
	[DelegateID] [int] NOT NULL,
	[Access] [bit] DEFAULT 1,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] DATETIME DEFAULT cast(convert(DATETIMEOFFSET,GETDATE()) AT TIME ZONE 'Eastern Standard Time' AS DATETIME)
) 
GO
CREATE TABLE [stng].Admin_AppSecurity(
	[ASID] [int] IDENTITY(1,1) NOT NULL,
	[ModuleID] [int] NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Location] NVARCHAR NULL,
	[Description] NVARCHAR(1000) NULL,
	[Type] [nvarchar](255) NOT NULL,
	[Active] [bit] DEFAULT 1,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] DATETIME DEFAULT cast(convert(datetimeoffset,GETDATE()) at time zone 'Eastern Standard Time' as datetime)
) 
GO
CREATE TABLE stng.Admin_Delegate(
	DelegateID INT IDENTITY(1,1),
	FromUserID INT,
	ToUserID INT,
	[Description] NVARCHAR(500),
	Active BIT DEFAULT 1,
	[ExpireDate] DATETIME DEFAULT DATEADD(day,14,GETDATE()),
	[CreatedBy] NVARCHAR(255) NOT NULL,
	[CreatedDate] DATETIME DEFAULT cast(convert(DATETIMEOFFSET,GETDATE()) AT TIME ZONE 'Eastern Standard Time' AS DATETIME)
)
GO
CREATE TABLE [stng].Admin_Role(
	[RoleID] [int] IDENTITY(1,1) NOT NULL,
	[ModuleID] [int] NULL,
	[Name] [nvarchar](255) NULL,
	[NameShort] [nvarchar](255) NOT NULL,
	[Department] NVARCHAR(255) NULL,
	[Description] [nvarchar](500) NULL,
	[Active] [bit] DEFAULT 1,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] DATETIME DEFAULT cast(convert(datetimeoffset,GETDATE()) at time zone 'Eastern Standard Time' as datetime)
) ON [PRIMARY]
GO
CREATE UNIQUE INDEX uni_nameShort_department ON stng.[Admin_Role] ([NameShort],Department);

GO
CREATE TABLE [stng].Admin_RoleParent(
	[RPID] [int] IDENTITY(1,1),
	[RoleID] [int] NOT NULL,
	[ParentRoleID] [int] NOT NULL,
	[Active] [bit] DEFAULT 1,
	[CreatedBy] [nvarchar](255) NOT NULL,
	[CreatedDate] DATETIME DEFAULT cast(convert(datetimeoffset,GETDATE()) at time zone 'Eastern Standard Time' as datetime)
) 

CREATE TABLE [stng].Admin_ModuleAccess(
	[ModuleAccessID] [bigint] IDENTITY(1,1) PRIMARY KEY,
	[ModuleID] [int] NOT NULL,
	[RoleID] INT NULL,
	[RequestorID] [nvarchar](20) NULL,
	[Reason] [nvarchar](4000) NOT NULL,
	[Approved] [bit] NULL,
	[Archived] [bit] NULL,
	[CreatedBy] [nvarchar](20) NOT NULL,
	[CreatedDate] DATETIME DEFAULT cast(convert(DATETIMEOFFSET,GETDATE()) AT TIME ZONE 'Eastern Standard Time' AS DATETIME)
)

CREATE TABLE [stng].[Admin_AppSecurityLink](
	[ASLID] [int] IDENTITY(1,1),
	[AppSecurityID] [int],
	[AppEndpointID] [int],
	[Active] [bit] DEFAULT 1,
	[CreatedBy] [nvarchar](255),
	[CreatedDate] [datetime] DEFAULT (CONVERT([datetime],(CONVERT([datetimeoffset],getdate()) AT TIME ZONE 'Eastern Standard Time')))
) 

CREATE TYPE [stng].[App_AppSecurity] AS TABLE(
	[Module] [nvarchar](255) NOT NULL,
	[Name] nvarchar(255) NOT NULL,
	Description NVARCHAR(1000) NOT NULL,
	Location NVARCHAR(1000),
	Endpoint NVARCHAR(255)
)


CREATE OR ALTER TRIGGER stng.TR_00_DeleteRole
   ON stng.Admin_Role AFTER DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DELETE FROM stng.Admin_UserRole WHERE stng.Admin_UserRole.RoleID IN (SELECT D.RoleID FROM deleted D)
	DELETE FROM stng.Admin_UserAccess WHERE stng.Admin_UserAccess.RoleID IN (SELECT D.RoleID FROM deleted D)
	DELETE FROM stng.Admin_RoleParent WHERE stng.Admin_RoleParent.RoleID IN (SELECT D.RoleID FROM deleted D)
	DELETE FROM stng.Admin_RoleParent WHERE stng.Admin_RoleParent.ParentRoleID IN (SELECT D.RoleID FROM deleted D)
END
GO

CREATE OR ALTER TRIGGER stng.TR_01_CreateModuleAccess
   ON stng.Admin_Module AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO stng.Admin_AppSecurity(ModuleID,Name,Description,Type,CreatedBy)
	SELECT M.ModuleID,M.Name,CONCAT('Access to ',M.Name,' Module'),'Module',M.CreatedBy FROM inserted M
END
GO

CREATE OR ALTER TRIGGER stng.TR_02_DeleteModule
   ON stng.Admin_Module AFTER DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	UPDATE stng.Admin_Role SET ModuleID = NULL WHERE ModuleID IN (SELECT D.ModuleID FROM deleted D)

	DELETE FROM stng.Admin_UserAccess WHERE ASID IN (SELECT A.ASID FROM stng.Admin_AppSecurity A WHERE A.ModuleID IN (SELECT D.ModuleID FROM deleted D))
	DELETE FROM stng.Admin_AppSecurity WHERE ModuleID IN (SELECT D.ModuleID FROM deleted D)
END