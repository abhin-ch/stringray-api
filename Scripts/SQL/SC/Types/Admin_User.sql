CREATE TYPE [stng].[Admin_User] AS TABLE(
	EmployeeID INT,
	Email NVARCHAR(255),
	FirstName NVARCHAR(255),
	LastName NVARCHAR(255),
	Title NVARCHAR(255),
	LANID NVARCHAR(255),
	UserPrincipleName NVARCHAR(255)
)