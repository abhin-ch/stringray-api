/*
Author: Habib Shakibanejad
Description: Field change log, for admin tool managing control options and overriding input fields. 
CreatedDate: 25 March 2024
*/
CREATE OR ALTER VIEW stng.VV_TOQ_FieldChangeLog
AS
SELECT T.UniqueID
	,T.RecordTypeID
	,C.Label RecordType
	,T.ChangeTypeID
	,D.[Group] ChangeTypeGroup
	,D.Field ChangeTypeField
	,T.FieldName
	,T.FromValue
	,T.ToValue
	,T.[Group]
	,T.CreatedDate
	,U.EmpName CreatedBy
FROM stng.TOQ_FieldChangeLog T
INNER JOIN stng.VV_TOQ_Common C ON C.UniqueID = T.RecordTypeID AND C.[Group] = 'Record' AND C.Field = 'Type'
INNER JOIN stng.VV_Common_ValueLabel D ON D.UniqueID = T.RecordTypeID AND D.[Group] = 'FieldChangeLog' AND D.Module = 'Common'
INNER JOIN stng.VV_Admin_UserView U ON U.EmployeeID = T.CreatedBy