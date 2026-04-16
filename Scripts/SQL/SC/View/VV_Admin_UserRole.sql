/*
CreatedBy: Habib Shakibanejad
CreatedDate: 26 Feb 2023
Description: Used to grab all users within a role,userroles, and parentroles
*/
CREATE OR ALTER VIEW [stng].[VV_Admin_UserRole]
AS
WITH UserRoles AS (
	SELECT UR.RoleID,U.EmployeeID,U.UserID FROM stng.Admin_UserRole UR
	INNER JOIN stng.[Admin_User] U ON U.UserID = UR.UserID
	WHERE UR.Active = 1
),
RecursiveRole AS (
	SELECT RP.RoleID, RP.ParentRoleID,A.EmployeeID, 1 Level,A.RoleID UserRoleID,A.UserID
	FROM stng.Admin_RoleParent RP
	CROSS APPLY (SELECT RoleID,EmployeeID,UserID FROM UserRoles) A
	WHERE RP.ParentRoleID = A.RoleID AND RP.Active = 1
	UNION ALL
	SELECT RP.RoleID,RP.ParentRoleID,C.EmployeeID,C.Level + 1,C.UserRoleID,C.UserID
	FROM stng.Admin_RoleParent RP
	INNER JOIN RecursiveRole C ON C.RoleID = RP.ParentRoleID AND RP.Active = 1
)
SELECT DISTINCT R.RoleID
	,C.UserID
	,R.ModuleID
	,R.NameShort
	,R.Department
	,R.Name
	,R.Description
	,C.EmployeeID
	,C.ParentRoleID
	,C.Level
	,C.UserRoleID
	,R2.NameShort ParentRoleName
	,R2.Name ParentRoleNameShort
	,NULL URID
FROM stng.Admin_Role R
INNER JOIN RecursiveRole C ON C.RoleID = R.RoleID
INNER JOIN stng.Admin_Role R2 ON R2.RoleID = C.UserRoleID
WHERE R.Active = 1
UNION
SELECT DISTINCT R.RoleID
	,C.UserID
	,R.ModuleID
	,R.NameShort
	,R.Department
	,R.Name
	,R.Description
	,U.EmployeeID
	,NULL -- ParentRoleID
	,0 -- Level
	,R.RoleID
	,R.NameShort
	,R.Name 
	,C.URID
FROM stng.Admin_UserRole C
INNER JOIN stng.Admin_Role R ON R.RoleID = C.RoleID AND R.Active = 1
INNER JOIN stng.Admin_User U ON U.UserID = C.UserID
WHERE C.Active = 1
GO