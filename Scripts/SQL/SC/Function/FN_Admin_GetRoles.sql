/*
Author: Habib Shakibanejad
Description: Grab a list of all roles assigned to user
CreatedDate: 13 March 2023
*/
CREATE OR ALTER FUNCTION [stng].[FN_Admin_GetRoles]
(
	@EmployeeID INT
)
RETURNS TABLE 
AS
RETURN
WITH UserRoles AS (
	SELECT UR.RoleID,UR.Active FROM stng.Admin_UserRole UR
	INNER JOIN stng.[Admin_User] U ON U.UserID = UR.UserID
	WHERE U.EmployeeID = @EmployeeID
),
RecursiveRole AS (
	SELECT RP.RoleID, RP.ParentRoleID
	FROM stng.Admin_RoleParent RP
	WHERE ParentRoleID IN (SELECT RoleID FROM UserRoles WHERE Active = 1) AND RP.Active = 1
	UNION ALL
	SELECT RP.RoleID,RP.ParentRoleID
	FROM stng.Admin_RoleParent RP
	INNER JOIN RecursiveRole C ON C.RoleID = RP.ParentRoleID AND RP.Active = 1
)
SELECT DISTINCT R.*
FROM stng.Admin_Role R
INNER JOIN RecursiveRole C ON C.ParentRoleID = R.RoleID OR C.RoleID = R.RoleID
WHERE R.Active = 1
UNION
SELECT DISTINCT R.*
FROM stng.Admin_Role R
INNER JOIN UserRoles UR ON UR.RoleID = R.RoleID AND UR.Active = 1
WHERE R.Active = 1
GO