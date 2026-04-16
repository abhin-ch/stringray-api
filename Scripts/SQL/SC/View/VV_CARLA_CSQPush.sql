/*
CreatedBy: Habib Shakibanejad
CreatedDate: Aug 31, 2022
Description: Grab CSQs within the last three months with their reason codes and status. 
*/
CREATE OR ALTER   VIEW [stng].[VV_CARLA_CSQPush]
AS
SELECT A.ActivityID
    ,A.ActivityName
    ,C.NewValue AS 'Status'
    ,C.CSVNReason AS 'Category'
    ,CONVERT(DATE,C.ChangeDate) AS 'RevisedDate'
    ,CONVERT(DATE,C.CommitmentDate) AS 'CommitmentDate'
FROM stng.ChangeLog C
INNER JOIN stng.FragnetActivity A ON A.ActivityID = C.SParentID AND A.[NCSQ] = 'CSQ'
WHERE C.CreatedDate > DATEADD(month,-3,GETDATE())
AND C.AffectedField = 'Status' AND C.AffectedTable = 'FragnetActivity'
AND C.CSVNReason IS NOT NULL
AND C.NewValue = 'Push Approved'
GO
