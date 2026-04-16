/*
Author: Habib Shakibanejad
Description: Grab a list of all access privileges on users
CreatedDate: 27 February 2023
*/
CREATE OR ALTER FUNCTION [stng].[FN_Admin_UserAccess]
(
	@EmployeeID VARHCAR(20)
)
RETURNS TABLE 
AS
RETURN
WITH UserRoles AS (
	SELECT UR.RoleID,UR.Active FROM stng.Admin_UserRole UR
	INNER JOIN stng.Admin_User U ON U.UserID = UR.UserID
	INNER JOIN stng.Admin_Role R ON R.RoleID = UR.RoleID AND R.Active = 1
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
SELECT DISTINCT UA.UAID,AP.Description,UA.RoleID,M.NameShort AS 'Module',AP.Name,AP.Type,UA.UserID
FROM stng.Admin_UserAccess UA
INNER JOIN RecursiveRole C ON C.ParentRoleID = UA.RoleID OR C.RoleID = UA.RoleID
INNER JOIN stng.Admin_AppSecurity AP ON AP.ASID = UA.ASID AND AP.Active = 1
INNER JOIN stng.Admin_Module M ON M.ModuleID = AP.ModuleID
WHERE UA.Access = 1
UNION
SELECT DISTINCT UA.UAID,AP.Description,UA.RoleID,M.NameShort,AP.Name,AP.Type,UA.UserID
FROM stng.Admin_UserAccess UA
INNER JOIN stng.Admin_AppSecurity AP ON AP.ASID = UA.ASID AND AP.Active = 1
INNER JOIN stng.Admin_Module M ON M.ModuleID = AP.ModuleID
INNER JOIN stng.Admin_User U ON U.UserID = UA.UserID AND U.Active = 1
WHERE UA.Access = 1 AND U.EmployeeID = @EmployeeID
UNION
SELECT DISTINCT UA.UAID,AP.Description,UA.RoleID,M.NameShort,AP.Name,AP.Type,UA.UserID
FROM stng.Admin_UserAccess UA
INNER JOIN stng.Admin_AppSecurity AP ON AP.ASID = UA.ASID AND AP.Active = 1
INNER JOIN stng.Admin_Module M ON M.ModuleID = AP.ModuleID
INNER JOIN UserRoles UR ON UR.RoleID = UA.RoleID AND UR.Active = 1
WHERE UA.Access = 1