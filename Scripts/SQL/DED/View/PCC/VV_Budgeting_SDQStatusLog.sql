CREATE OR ALTER VIEW [stng].[VV_Budgeting_SDQStatusLog]
AS
SELECT UniqueID
	,RecordTypeUID SDQUID
	,S.StatusID
	,V.SDQStatusLong Status
	,V.SDQStatus as StatusValue
	,Comment
	,CreatedBy EmployeeID
	,S.CreatedDate
	,U.EmpName CreatedBy
	,U.EmpName
	FROM stng.Budgeting_StatusLog S 
	INNER JOIN stng.Budgeting_SDQ_Status V ON V.SDQStatusID = S.StatusID
	INNER JOIN stng.VV_Admin_UserView U ON U.EmployeeID = S.CreatedBy
WHERE S.Type = 'SDQ' 
GO