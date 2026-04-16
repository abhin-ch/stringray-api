CREATE TABLE [stng].App_TokenCache(
	[Id] [nvarchar](449) PRIMARY KEY CLUSTERED NOT NULL,
	[Value] [varbinary](max) NOT NULL,
	[ExpiresAtTime] [datetimeoffset](7) NOT NULL,
	[SlidingExpirationInSeconds] [bigint] NULL,
	[AbsoluteExpiration] [datetimeoffset](7) NULL
)



CREATE TABLE [stng].[CARLA_RelatedActivity](
	[ActivityID] [nvarchar](40) NULL,
	[RelatedActivityID] [nvarchar](40) NULL,
	[ProjShortName] [nvarchar](40) NULL,
	[Type] [nvarchar](11) NULL
) ON [PRIMARY]
GO

CREATE TABLE [stng].[CARLA_FragnetActivityDetail](
	[FADetailID] [int] IDENTITY(1,1) NOT NULL,
	[ActivityID] [nvarchar](20) NULL,
	[DetailName] [nvarchar](255) NULL,
	[DetailValue] [nvarchar](255) NULL,
	[Type] [nvarchar](255) NULL
)
GO

CREATE TABLE [stng].ETDB_ScopeDetail(
	[SDID] [int] IDENTITY(1,1) NOT NULL,
	[SheetID] [nvarchar](255) NULL,
	[StateID] [nvarchar](255) NULL,
	[Type] [nvarchar](255) NULL,
	[Number] [nvarchar](255) NULL,
	[Description] [nvarchar](2000) NULL,
	[Comment] [nvarchar](255) NULL,
	[Position] [int] NULL,
	[Hours] [int] NULL,
	[EstimatedHours] [int] NULL,
	[AssignedUserID] NVARCHAR(255),
	[Issues] [bit] DEFAULT 0,
	[CreatedBy] NVARCHAR(255) NOT NULL,
	[CreatedDate] DATETIME DEFAULT DATEADD(HOUR,(-5),GETDATE())
)

CREATE TABLE [stng].ETDB_ScopingSheet(
	SSID INT IDENTITY(1,1),
	SheetID NVARCHAR(255) UNIQUE CLUSTERED,
	[ProjectID] [nvarchar](255) NULL,
	[SheetNum] INT,
	[StatusID] INT,
	[Title] [nvarchar](500) NULL,
	[Description] [nvarchar](1000) NULL,
	[Hours] SMALLINT NULL,
	[ActualHours] SMALLINT NULL,
	[Position] [int] NULL,
	[NeedDate] DATETIME NULL,
	[AssignedUserID] NVARCHAR(255) NULL,
	[Type] [nvarchar](255) NULL,
	[CommitmentID] [nvarchar](255) NULL,
	[External] [bit] NULL,
	[Escalation] [bit] NULL,
	[Emergent] [bit] NULL,
	[Group] [nvarchar](255) NULL,
	[StartDate] DATETIME,
	[DueDate] DATETIME,
	[Issues] [bit] NULL,
	[Initiator] [nvarchar](255) NULL,
	[CreatedBy] NVARCHAR(255) NOT NULL,
	[CreatedDate] DATETIME DEFAULT DATEADD(HOUR,(-5),GETDATE())
)

CREATE TABLE [stng].Common_ChangeLog(
	[CLID] INT IDENTITY(1,1),
	[ParentID] [nvarchar](255),
	[AffectedField] [nvarchar](255) NULL,
	[AffectedTable] [nvarchar](255) NULL,
	[NewValue] [nvarchar](1000),
	[NewDate] DATETIME,
	[PreviousValue] [nvarchar](1000) NULL,
	[PreviousDate] DATETIME,
	[CreatedBy] NVARCHAR(255) NOT NULL,
	[CreatedDate] DATETIME DEFAULT DATEADD(HOUR,(-5),GETDATE())
)



CREATE TYPE [stng].[ETDB_ScopeDetail] AS TABLE(
	[SDID] BIGINT,
	[Number] [nvarchar](255) NULL,
	[Type] [nvarchar](255) NULL,
	[Description] [nvarchar](1000) NULL,
	[EstimatedHours] [int] NULL
)

CREATE TABLE [stng].[ItemLinkMap](
	ILMID INT IDENTITY(1,1),
	[EscalationID] [nvarchar](255) NULL,
	[FragnetID] [nvarchar](255) NULL,
	[ScopingSheetID] [nvarchar](255) NULL,
	[PODetailID] [nvarchar](255) NULL
) 

CREATE TABLE [stng].ETDB_ScopeQuote(
	SQID INT IDENTITY(1,1),
	[SheetID] [nvarchar](255) NULL,
	[Price] [nvarchar](255) NULL,
	[Notes] [nvarchar](255) NULL,
	[FiftyDate] DATETIME NULL,
	[FinalDate] DATETIME NULL,
	CreatedBy NVARCHAR(255) NOT NULL,
	[CreatedDate] DATETIME DEFAULT CONVERT([datetime],(CONVERT([datetimeoffset],getdate()) AT TIME ZONE 'Eastern Standard Time'))
)


CREATE TABLE [stng].CARLA_ChangeLog(
	[CCLID] [int] IDENTITY(1,1) NOT NULL,
	[ActivityID] [nvarchar](20) NULL,
	[FieldName] [nvarchar](40) NULL,
	[NewValue] [nvarchar](255) NULL,
	[PreviousValue] [nvarchar](255) NULL,
	[P6UpdateRequired] [bit] DEFAULT 1,
	[Key] [nvarchar](255) NULL,
	[FKID] [nvarchar](255) NULL,
	[CreatedBy] [nvarchar](255) NULL,
	[CreatedDate] DATETIME DEFAULT CONVERT([datetime],(CONVERT([datetimeoffset],getdate()) AT TIME ZONE 'Eastern Standard Time'))
) ON [PRIMARY]
GO

CREATE TABLE [stng].[Common_MaximoItemLink](
	[Number] [nvarchar](255) NULL,
	[MaximoID] [nvarchar](255) NULL,
	[Table] [nvarchar](255) NULL,
	[Type] [nvarchar](255) NULL
) ON [PRIMARY]
GO

CREATE TABLE stng.CARLA_CommitmentDate(
	ActivityID NVARCHAR(255),
	CommitmentDate DATE,
	SnapshotDate DATE DEFAULT CONVERT([datetime],(CONVERT([datetimeoffset],getdate()) AT TIME ZONE 'Eastern Standard Time'))
)
