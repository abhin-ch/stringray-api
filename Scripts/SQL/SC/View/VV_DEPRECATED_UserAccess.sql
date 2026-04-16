/*
Author: Habib Shakibanejad
Description: Grab a list of all access privileges on users
CreatedDate: 09 January 2023

DEPRECATED on Feb 27,2023. Refer to FN_Admin_UserAcces

*/
CREATE OR ALTER   VIEW [stng].[VV_Admin_UserAccess]
AS
	SELECT UA.UAID,UA.UserID,AP.Description,UA.RoleID,M.Name AS 'Module',AP.Name,AP.Type,U.EmployeeID
	FROM stng.UserAccess UA
	INNER JOIN stng.AppSecurity AP ON AP.ASID = UA.ASID AND AP.Active = 1
	INNER JOIN stng.Module M ON M.ModuleID = AP.ModuleID
	INNER JOIN stng.[User] U ON U.RoleID = UA.RoleID AND U.Active = 1
	WHERE UA.Access = 1
	UNION
	SELECT UA.UAID,UA.UserID,AP.Description,UA.RoleID,M.Name,AP.Name,AP.Type,U.EmployeeID
	FROM stng.UserAccess UA
	INNER JOIN stng.AppSecurity AP ON AP.ASID = UA.ASID AND AP.Active = 1
	INNER JOIN stng.Module M ON M.ModuleID = AP.ModuleID
	INNER JOIN stng.UserRole UR ON UR.RoleID = UA.RoleID AND UR.Active = 1
	INNER JOIN stng.[User] U ON U.UserID = UR.UserID AND U.Active = 1
	WHERE UA.Access = 1 
	UNION
	SELECT UA.UAID,UA.UserID,AP.Description,UA.RoleID,M.Name,AP.Name,AP.Type,U.EmployeeID
	FROM stng.UserAccess UA
	INNER JOIN stng.AppSecurity AP ON AP.ASID = UA.ASID AND AP.Active = 1
	INNER JOIN stng.Module M ON M.ModuleID = AP.ModuleID
	INNER JOIN stng.[User] U ON U.UserID = UA.UserID AND U.Active = 1
	WHERE UA.Access = 1
GO

