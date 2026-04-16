CREATE TABLE stng.TOQ_ClassVMain
(
	UniqueID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
	ExternalID INT IDENTITY(1,1),
	Name NVARCHAR(255),
	IsReadOnly BIT DEFAULT 0,
	ComplexityLowMultiplier REAL DEFAULT 0.5,
    ComplexityMediumMultiplier REAL DEFAULT 1,
    ComplexityHighMultiplier REAL DEFAULT 1.3
    [PMLowPCT] INT DEFAULT 7,
    [PMMediumPCT] INT DEFAULT 11,
    [PMHighPCT] INT DEFAULT 15,
    [ProjectControlPCT] INT DEFAULT 30,
    [ContingencyPCT] INT DEFAULT 10,
    [Rate] REAL DEFAULT 143,
    [PMPCRate] REAL DEFAULT 130,
	CreatedBy VARCHAR(20),
	CreatedDate DATETIME DEFAULT stng.GetDate(),
)