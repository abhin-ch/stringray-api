CREATE OR ALTER VIEW stng.VV_Budgeting_PBRFStatusLog
AS
SELECT S.UniqueID
	,RecordTypeUID PBRFUID
	,S.StatusID
	,V.Label Status
	,Comment
	,S.CreatedBy EmployeeID
	,S.CreatedDate 
	,U.EmpName CreatedBy
	,U.EmpName
	FROM stng.Budgeting_StatusLog S 
	INNER JOIN stng.VV_Budgeting_PBRFCommon V ON V.UniqueID = S.StatusID AND V.Field ='Status'
	INNER JOIN stng.VV_Admin_UserView U ON U.EmployeeID = S.CreatedBy
WHERE S.Type = 'PBRF' 