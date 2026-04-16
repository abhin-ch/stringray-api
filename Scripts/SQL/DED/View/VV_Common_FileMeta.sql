CREATE OR ALTER VIEW stng.VV_Common_FileMeta 
AS
SELECT F.*
	,U.LANID
	,U.EmpName EmployeeName
	,M.NameShort Module
FROM stng.Common_FileMeta F
INNER JOIN stng.VV_Admin_UserView U ON U.EmployeeID = F.CreatedBy
INNER JOIN stng.Admin_Module M ON M.UniqueID = F.ModuleID