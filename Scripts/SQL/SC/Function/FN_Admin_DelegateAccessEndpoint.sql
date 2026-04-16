/*
Author: Habib Shakibanejad
Description: Grab a list of all endpoint access on delegate
CreatedDate: 07 July 2023
*/
CREATE OR ALTER FUNCTION [stng].[FN_Admin_DelegateAccessEndpoint]
(
	@EmployeeID INT
)
RETURNS TABLE 
AS
RETURN
SELECT DISTINCT DA.Module,S.Name,S.Description Method FROM stng.FN_Admin_DelegateAccess(@EmployeeID) DA
INNER JOIN stng.Admin_UserAccess UA ON UA.UAID = DA.UAID
INNER JOIN stng.Admin_AppSecurityLink L ON L.AppSecurityID = UA.ASID
INNER JOIN stng.Admin_AppSecurity S ON S.ASID = L.AppEndpointID
UNION
SELECT B.Module,B.Name,B.Description FROM stng.FN_Admin_DelegateAccess(@EmployeeID) B
WHERE B.Module = 'Admin' AND B.Type = 'System' AND B.Name = 'SysAdmin'