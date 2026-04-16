/*
Author: Habib Shakibanejad
Description: Grab a list of all endpoint access on user
CreatedDate: 07 July 2023
*/
CREATE OR ALTER FUNCTION [stng].[FN_Admin_UserAccessEndpoint]
(
	@EmployeeID VARCHAR(20)
)
RETURNS TABLE 
AS
RETURN
SELECT DISTINCT A.Module,S.Name,S.Description Method FROM stng.FN_Admin_UserAccess(@EmployeeID) A
INNER JOIN stng.Admin_UserAccess B ON (B.UAID = A.UAID OR B.UserID = A.UserID)
INNER JOIN stng.Admin_AppSecurityLink L ON L.AppSecurityID = B.ASID
INNER JOIN stng.Admin_AppSecurity S ON S.ASID = L.AppEndpointID
UNION
SELECT B.Module,B.Name,B.Description FROM stng.FN_Admin_UserAccess(@EmployeeID) B
WHERE B.Module = 'Admin' AND B.Type = 'System' AND B.Name = 'SysAdmin'
