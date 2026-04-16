/****** Object:  View [stng].[VV_GovernTree_Main]    Script Date: 11/19/2025 9:22:49 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
















CREATE VIEW [stng].[VV_GovernTree_Main] AS

WITH temp AS (
    SELECT MAX(Revision) AS Revision, FullDocumentNoName FROM [stng].[VV_GovernTree_JobAid] GROUP BY FullDocumentNoName
)
SELECT 
    a.UniqueID, 
    a.DocumentNo, 
    b.Revision, 
    a.ReferenceCount, 
    a.FormCount,
    a.StandardCount,
    a.JobAidCount,
    a.DCRCount,
    b.[Status], 
    b.StatusDate, 
    b.Title, 
    b.[Type],
    b.SubType,
    CONCAT(CASE 
        WHEN b.filetype = 'CAL' THEN 'https://ecm.corp.brucepower.com/OTCS/cs.exe?func=brava.bravaviewer&nodeid=' 
        ELSE 'https://ecm.corp.brucepower.com/OTCS/cs.exe?func=ll&objAction=open&objID='
    END, b.DATAID) AS CSLink,
    NULL AS JobAidNum,
	a.RAD,
	c.ProcessOwner as ProcessOwnerC
	,c.ProcessOwnerID
FROM 
    stng.GovernTree_Main AS a
INNER JOIN 
    stngetl.General_ControlledDoc AS b ON a.DocumentNo = b.[NAME]
LEFT JOIN 
    stng.VV_GovernTree_ProcessOwner AS c ON a.UniqueID = c.GTID
WHERE 
    a.Deleted = 0

UNION

SELECT 
    a.JobAidID, 
    a.FullDocumentNoName, 
    b.Revision, 
    a.ReferenceCount AS ReferenceCount, 
    a.FormCount AS FormCount,
    a.StandardCount AS StandardCount,
    a.DCRCount AS DCRCount,
	a.JobAidCount AS JobAidCount,
    a.JobAidStatusC AS [Status], 
    a.UpdateDate AS StatusDate, 
    a.DocumentTitle, 
    NULL AS [Type], 
    'JOB AID' AS Subtype,
    NULL AS CSLink,
    a.JobAidNum,
	a.RAD,
	c.ProcessOwner as ProcessOwnerC
	,c.ProcessOwnerID
FROM 
    stng.VV_GovernTree_JobAid AS a 
INNER JOIN 
	temp b ON a.FullDocumentNoName = b.FullDocumentNoName AND a.Revision = b.Revision
LEFT JOIN 
    stng.VV_GovernTree_ProcessOwner AS c ON a.JobAidID = c.GTID
GO


