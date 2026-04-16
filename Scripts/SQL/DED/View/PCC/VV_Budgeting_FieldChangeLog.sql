/*
Author: Habib Shakibanejad
Description: Field change log
CreatedDate: 29 Feb 2024
*/
CREATE OR ALTER VIEW stng.VV_Budgeting_FieldChangeLog
AS 
SELECT B.UniqueID
	,B.RecordType
	,B.RecordTypeUniqueID
	,C.Label ChangeType
	,C.Field ChangeTypeGroup
	,B.FieldName
	,B.FromValue
	,B.ToValue
	,B.[Group]
	,B.CreatedDate
	,U.EmpName CreatedBy
FROM stng.Budgeting_FieldChangeLog B
INNER JOIN stng.VV_Common_ValueLabel C ON C.UniqueID = B.TypeID AND C.[Group] = 'FieldChangeLog'
INNER JOIN stng.VV_Admin_UserView U ON U.EmployeeID = B.CreatedBy