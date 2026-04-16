CREATE TABLE stng.Admin_UserSysAdmin
(
	UserID INT UNIQUE,
	Active BIT DEFAULT 1,
	CreatedDate DATETIME DEFAULT stng.GetDate(),
	CreatedBy NVARCHAR(255),
)