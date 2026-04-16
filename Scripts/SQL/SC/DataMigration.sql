
UPDATE stng.Common_Comment SET CreatedBy = U.EmployeeID
FROM stng.Admin_User U 
WHERE CreatedBy = U.LANID

UPDATE stng.Common_ChangeLog SET CreatedBy = U.EmployeeID
FROM stng.Admin_User U 
WHERE CreatedBy = U.LANID

INSERT INTO stng.Common_Comment(ParentID,ParentTable,Body,Pinned,CreatedBy,CreatedDate)
SELECT C.FK_ParentID,'ScopingSheet',C.Body,C.Pinned,C.FK_Username,C.CreatedDate FROM temp.Comments C WHERE ParentTable ='ScopingSheets'

INSERT INTO stng.Common_Comment(ParentID,ParentTable,RelatedTable,RelatedID,RelatedType,Body,Pinned,CreatedBy,CreatedDate)
SELECT C.ItemNum,'ScopeDetail','ScopingSheet',D.FK_SheetID,D.Type,C.Body,C.Pinned,C.FK_Username,C.CreatedDate FROM temp.Comments C 
INNER JOIN temp.ScopeDetails D ON CAST(D.PK_ID AS NVARCHAR) = C.FK_ParentID AND C.ParentTable ='ScopeDetails'
WHERE ParentTable ='ScopeDetails'

INSERT INTO stng.Common_ChangeLog(ParentID,AffectedField,AffectedTable,NewValue,CreatedBy,CreatedDate)
SELECT A.FK_ParentID,A.AffectedField,'ScopingSheet',A.NewValue,A.FK_Username,A.CreatedDate FROM temp.ChangeLog A WHERE (A.AffectedTable = 'ScopingSheets'
AND A.AffectedField !='Description')

INSERT INTO stng.Common_ChangeLog(ParentID,AffectedField,AffectedTable,NewValue,CreatedBy,CreatedDate)
SELECT A.FK_ParentID,A.AffectedField,'ScopeDetail',A.NewValue,A.FK_Username,A.CreatedDate FROM temp.ChangeLog A 
INNER JOIN temp.ScopeDetails D ON CAST(D.PK_ID AS NVARCHAR) = A.FK_ParentID AND A.AffectedTable ='ScopeDetails'
WHERE A.AffectedTable = 'ScopeDetails'

INSERT INTO stng.ETDB_ScopingSheet(SheetID,ProjectID,StatusID,Title,Description,Hours,ActualHours,Position,
NeedDate,Type,CommitmentID,[External],Escalation,Emergent,[Group],StartDate,DueDate,Issues,Initiator,CreatedBy,CreatedDate)
SELECT S.PK_SheetID,S.FK_ProjectID,S.Status,S.Title,S.Description,S.Hours,S.ActualHours,S.Position,
S.NeedDate,S.Type,S.CommitmentID,S.[External],S.Escalation,S.Emergent,S.[Group],S.Start,S.Due,S.Issues,S.Initiator,'SYSTEM',S.CreatedDate FROM temp.ScopingSheets S

INSERT INTO stng.ETDB_ScopeDetail(SheetID,StateID,Type,Number,Description,Comment,Position,Hours,EstimatedHours,Issues,CreatedBy)
SELECT D.FK_SheetID,D.State,D.Type,D.Number,D.Description,D.Comment,D.Position,D.Hours,D.EstimatedHours,D.Flagged,'SYSTEM' FROM temp.ScopeDetails D

SELECT * FROM stng.Common_ChangeLog
SELECT * FROM stng.ETDB_ScopeDetail
SELECT * FROM stng.ETDB_ScopingSheet
SELECT StatusID FROM stng.ETDB_ScopingSheet  GROUP BY StatusID ORDER BY StatusID
SELECT * FROM stng.Common_ValueLabel WHERE [Group] = 'TDS'

UPDATE stng.ETDB_ScopingSheet SET StatusID = CASE 
WHEN StatusID = 1 THEN 17 --review required
WHEN StatusID = 2 THEN 5 --complete
WHEN StatusID = 3 THEN 6 --Cancelled
WHEN StatusID = 4 THEN 1 --baselined
WHEN StatusID = 5 THEN 4 --on hold
WHEN StatusID = 7 THEN 1 --pending shceudling
WHEN StatusID = 10 THEN 16 --pending submission
WHEN StatusID = 11 THEN 14 --pending quote
WHEN StatusID = 12 THEN 15 --quote submitted
WHEN StatusID = 13 THEN 1 --emergent
WHEN StatusID = 19 THEN 17 --baselined review
WHEN StatusID = 20 THEN 10 --pending pmc response
WHEN StatusID = 25 THEN 3 --end-tech review required
END;

UPDATE stng.ETDB_ScopingSheet SET AssignedUserID = U.UserID
FROM stng.Admin_User U
INNER JOIN temp.ScopingSheets S ON S.Assigned = CONCAT(U.FirstName, ' ',U.LastName)
INNER JOIN stng.ETDB_ScopingSheet E ON E.SheetID = S.PK_SheetID
WHERE S.[Status] = 2 OR S.[Status] = 3

--Update legacy assigned
UPDATE stng.ETDB_ScopingSheet SET AssignedUserID = A.UserID FROM
(
	SELECT S.PK_SheetID,STRING_AGG(U.Name,',') Name,STRING_AGG(U.UserID,',') UserID
	FROM temp.ScopingSheets S
	CROSS APPLY (
		SELECT value Name,U.FullName,UserID FROM string_split(S.Assigned,',') N
		LEFT JOIN stng.Admin_User U ON LTRIM(N.value) = CONCAT(U.FirstName,' ',U.LastName)
	) U
	GROUP BY S.PK_SheetID
) A
WHERE SheetID = A.PK_SheetID
AND AssignedUserID IS NULL