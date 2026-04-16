CREATE OR ALTER VIEW [stng].[VV_ETDB_ScopingSheet]
AS 
SELECT SSID 
	,S.SheetID
	,S.Title 
	,S.Description
	,S.ProjectID
	,S.Hours
	,V.Label AS 'Status'
	,S.Position
	,CAST(S.NeedDate AS DATE) AS 'NeedDate'
	,S.AssignedUserID
	,CAST(S.CreatedDate AS DATE) AS 'CreatedDate' 
	,IIF(S.[Type] = 'Scheduled','Yes','No') AS 'Scheduled'
	,S.CommitmentID
	,IIF(S.[External] = 1,'External','Internal') AS 'TDSType'
	,S.Escalation
	,IIF(S.Emergent = 1,'Yes','No') AS 'Emergent'
	,S.[Group]
	,CAST(S.StartDate AS DATE) AS 'Start' 
	,CAST(S.DueDate AS DATE) AS 'Due' 
	,S.Issues
	,S.ActualHours
	,S.Initiator
	,C.Body AS 'LatestComment',
	AU.FullName as 'LatestCommentBy'
	,M.PCS
	,M.ProjectManager
	,S.StatusID
	,F.Qty AS 'Attachments'
	,IIF(F.Qty > 0,'Yes','No') AS 'HasAttachments'
	,S.CreatedBy
	,U.FullName AS Assigned
	,M.Status ProjectStatus
	,M.CSFLM
	,FA.[EndDate] AS 'CommitmentDate'
FROM stng.ETDB_ScopingSheet S
LEFT JOIN stng.VV_MPL_SC AS M ON M.[ProjectID] = S.ProjectID
LEFT JOIN (SELECT B.Body,B.ParentID,B.CreatedBy FROM (
	SELECT *,ROW_NUMBER() OVER (PARTITION BY ParentID ORDER BY CreatedDate DESC) RN FROM (
		SELECT C.ParentID,C.Body,C.CreatedDate,C.CreatedBy FROM stng.Common_Comment C WHERE C.ParentTable = 'ScopingSheet' 
		UNION
		SELECT C.RelatedID,C.Body,C.CreatedDate,C.CreatedBy FROM stng.Common_Comment C WHERE C.ParentTable = 'ScopeDetail'
	) A 
) AS B WHERE B.RN = 1) C ON C.ParentID = S.SheetID
 LEFT JOIN  stng.Admin_User AU ON C.CreatedBy = AU.EmployeeID
LEFT JOIN stng.Common_ValueLabel V ON V.Value = S.StatusID AND V.Field = 'Status' AND V.[Group] = 'TDS'
LEFT JOIN (
	SELECT F.ParentID,COUNT(*) Qty FROM stng.Common_FileMeta F 
	LEFT JOIN stng.Admin_Module MD ON MD.ModuleID = F.ModuleID AND MD.[NameShort] = 'ETDB' 
	WHERE F.GroupBy = 'TDS' AND Deleted = 0
	GROUP BY F.ParentID
) F ON F.ParentID = CONCAT('CS-',S.SheetID)
CROSS APPLY ( 
	SELECT STRING_AGG(U.FullName,';') AS FullName FROM (SELECT FullName,UserID FROM stng.Admin_User U UNION SELECT 'Kinectrics',0) U
	INNER JOIN string_split(S.AssignedUserID,',') A ON A.value = U.UserID
) U
LEFT JOIN stng.CARLA_FragnetActivity FA ON FA.ActivityID = S.CommitmentID 
GO