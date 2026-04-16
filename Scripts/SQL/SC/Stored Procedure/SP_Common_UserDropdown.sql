/****** Object:  StoredProcedure [stng].[SP_Common_UserDropdown]    Script Date: 10/27/2024 11:28:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*
Author: Habib Shakibanejad
Description: Add various queries here for the user dropdown component
CreatedDate: 09 Sept 2023
RevisedDate:
RevisedBy: 
*/
ALTER   PROCEDURE [stng].[SP_Common_UserDropdown](
	 @Operation TINYINT
	,@SubOp		TINYINT = NULL
	,@EmployeeID INT = NULL
	,@Value1 NVARCHAR(255) = NULL
	,@Value2 NVARCHAR(255) = NULL
	,@Value3 NVARCHAR(255) = NULL
	,@Value4 NVARCHAR(255) = NULL
	,@Value5 NVARCHAR(255) = NULL
	,@Value6 NVARCHAR(max) = NULL
	,@Num1 INT = NULL
	,@Num2 INT = NULL
	,@Num3 INT = NULL
	,@IsTrue1 BIT = NULL
	,@IsTrue2 BIT = NULL
	,@Date1 DATETIME = NULL
	,@Date2 DATETIME = NULL
) AS 
BEGIN
	/*
	Operations:
		1 - GET Users
        2 - GET Verifiers (Budgeting)
		3 - 
        4 - 
		5 - 
		6 - 
		7 - 
		8 - 
		9 - 
		10 - 
		11 - 
		12 - 
		13 - 
		14 - 
		15 - 
		16 - 
		17 - 
		18 - 
		19 - 
		20 - 
		21 - 
		22 - 
		23 - 
		24 -
		25 - 
	*/ 
	
	-- GET Users
	IF(@Operation = 1) 
	SELECT EmpName label, EmployeeID value, LANID 'lanid' FROM stng.VV_Admin_Users
	WHERE EmpName != '' and EmpName is not null and EmployeeID is not null
	ORDER BY EmpName

	-- GET Verifiers (Budgeting)
	IF(@Operation = 2) SELECT EmpName label, V.EmployeeID value FROM stng.VV_Admin_UserRole V
		INNER JOIN stng.VV_Admin_Users U ON U.EmployeeID = V.EmployeeID
			WHERE V.[Role] LIKE '%PCS Lead%'

	IF(@Operation = 3) 
		SELECT top 20
		concat(EmpName, ' (', EmployeeID, ')') label, EmployeeID value 
		--EmpName label, EmployeeID value 
		FROM stng.VV_Admin_Users 
		WHERE (FirstName like @Value1 + '%' or LastName like @Value1 +'%' or EmpName like @Value1 + '%') and Active = 1
		ORDER BY EmpName
		option(optimize for (@Value1 unknown));

	IF(@Operation = 4) 
		SELECT 
		concat(EmpName, ' (', EmployeeID, ')') label, EmployeeID value 
		--EmpName label, EmployeeID value
		FROM stng.VV_Admin_Users
		WHERE concat(EmpName, ' (', EmployeeID, ')') = @Value1 and Active = 1
		ORDER BY EmpName
		option(optimize for (@Value1 unknown));
	
END