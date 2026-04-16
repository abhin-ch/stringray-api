/*
Author: Habib Shakibanejad
Description: Grab a list of all access privileges on delegate
CreatedDate: 22 March 2023
*/
CREATE OR ALTER FUNCTION [stng].[FN_Admin_DelegateAccess]
(
	@EmployeeID NVARCHAR(255)
)
RETURNS TABLE 
AS
RETURN
SELECT DISTINCT A.[Name]
	,A.[Type]
	,A.[Description]
	,M.[Name] [Module]
	,D.DelegateID
	,D.UAID
	,D.DAID
FROM stng.Admin_DelegateAccess D
INNER JOIN stng.Admin_UserAccess UA ON D.UAID = UA.UAID
INNER JOIN stng.Admin_AppSecurity A ON A.ASID = UA.ASID
INNER JOIN stng.Admin_Module M ON M.ModuleID = A.ModuleID
WHERE DelegateID IN (
		SELECT D.DelegateID FROM stng.Admin_Delegate D 
		WHERE D.ToUserID = (
			SELECT U.UserID FROM stng.Admin_User U WHERE U.EmployeeID = @EmployeeID AND U.Active = 1
		) 
		AND D.Active = 1
		AND CAST(GETDATE() AS DATE) < CAST(D.ExpireDate AS DATE)
	)
AND D.Access = 1 AND A.Active = 1 AND UA.Access = 1