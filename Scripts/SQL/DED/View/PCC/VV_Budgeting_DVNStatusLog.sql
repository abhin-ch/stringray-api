CREATE OR ALTER VIEW VV_Budgeting_DVNStatusLog
AS
SELECT UniqueID
	,RecordTypeUID DVNUID
	,S.StatusID
	,V.Label Status
	,V.Value StatusCode
	,Comment
	,CreatedBy EmployeeID
	,S.CreatedDate
	,U.EmpName CreatedBy
	,U.EmpName
	FROM stng.Budgeting_StatusLog S 
	INNER JOIN stng.VV_Budgeting_DVNStatus V ON V.StatusID = S.StatusID
	INNER JOIN stng.VV_Admin_UserView U ON U.EmployeeID = S.CreatedBy
WHERE S.Type = 'DVN' 