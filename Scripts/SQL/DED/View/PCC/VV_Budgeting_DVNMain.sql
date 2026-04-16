CREATE OR ALTER VIEW [stng].[VV_Budgeting_DVNMain]
AS
WITH lateststatuses AS
(
	SELECT DVNUID, MAX(CreatedDate) AS CurrentDVNStatusDate
	FROM stng.VV_Budgeting_DVNStatusLog
	GROUP BY DVNUID
)
SELECT 'DVN' as [Type]
	,CONCAT('DVN','-',D.UniqueID) as UniqueID
	,D.UniqueID as RecordTypeUniqueID
	,D.DVNID
	,D.StatusID
	,S.Label Status
	,S.Value StatusValue
	,D.Cause
	,D.CreatedBy
	,D.CreatedDate
	,U.EmpName RequestedBy
	,D.Reason
	,D.ScopeTrend
	,D.SDQUID
	,Q.ProjectNo
	,Q.ProjectTitle
	,Q.PCSID
	,Q.PCS
	,Q.OE
	,Q.OEID
	,F.Label FundingSource
	,F.UniqueID FundingSourceID
	,Q.SM
	,Q.SMID
	,Q.DM
	,Q.DMID
	,L.CurrentDVNStatusDate CurrentStatusDate
FROM stng.Budgeting_DVNMain D
LEFT JOIN lateststatuses L ON L.DVNUID = D.UniqueID
INNER JOIN stng.VV_Common_ValueLabel S ON S.UniqueID = D.StatusID
INNER JOIN stng.VV_Budgeting_SDQMain Q ON Q.RecordTypeUniqueID = D.SDQUID
LEFT JOIN stng.VV_Common_ValueLabel F ON F.UniqueID = Q.FundingSourceID
LEFT JOIN stng.VV_Admin_UserView U ON U.EmployeeID = D.CreatedBy