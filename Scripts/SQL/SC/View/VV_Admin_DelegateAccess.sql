/*
Author: Habib Shakibanejad
Description: Grab a list of all access privileges in delegate access
CreatedDate: 20 June 2023
*/
CREATE OR ALTER VIEW [stng].[VV_Admin_DelegateAccess]
AS
SELECT A.[Name]
	,A.[Type]
	,A.[Description]
	,M.[Name] [Module]
	,D.DelegateID
	,D.Access DelegateAccess
	,UA.Access UserAccess
	,D.DAID
	,D.UAID
FROM stng.Admin_DelegateAccess D
INNER JOIN stng.Admin_UserAccess UA ON D.UAID = UA.UAID
INNER JOIN stng.Admin_AppSecurity A ON A.ASID = UA.ASID
INNER JOIN stng.Admin_Module M ON M.ModuleID = A.ModuleID
