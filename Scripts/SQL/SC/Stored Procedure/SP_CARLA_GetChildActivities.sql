/*
Author: Habib Shakibanejad
Description: Get activities in each Subfragnet from CSQ Fragnet. 
CreatedDate: 25 May 2022
*/
CREATE OR ALTER PROCEDURE [stng].[SP_CARLA_GetChildActivities](
	@PK_ActivityID	NVARCHAR(255)
)
AS
-- 2. Child Activities (Pre-reqs & CSQs)
WITH Activity (FragnetID,FragnetName,[Resource],ActivityID,CombinedRecordCount,NCSQ,Predecessor,Successor,ActivityName)  
AS (
	SELECT FA.FragnetID
		,(SELECT DISTINCT F.FragnetName FROM stng.CARLA_Fragnet F WHERE F.FragnetID = FA.FragnetID)
		--,FA.ProjShortName
		,STRING_AGG(FA.[Resource],',')
		,STRING_AGG(CONVERT(NVARCHAR(max),FA.ActivityID), ',') WITHIN GROUP (ORDER BY FA.ActivityID)
		,COUNT(*)
		,(SELECT [NCSQ] FROM stng.CARLA_FragnetActivity WHERE ActivityID = @PK_ActivityID)
		,Pred.ReleatedActivity
		,Succ.ReleatedActivity
		,STRING_AGG(CONVERT(NVARCHAR(max),FA.ActivityName), '@@') WITHIN GROUP (ORDER BY FA.ActivityID)
	FROM stng.CARLA_FragnetActivity FA 
	LEFT JOIN stng.MPL M ON M.[ProjectID] = FA.ProjShortName
	LEFT JOIN (
		SELECT ActivityID,STRING_AGG(RelatedActivityID,',') ReleatedActivity,[Type], ProjShortName
		FROM stng.CARLA_RelatedActivity
		GROUP BY [Type], ActivityID, ProjShortName
		HAVING [Type] = 'Predecessor'
	) Pred ON Pred.ActivityID = FA.ActivityID AND Pred.ProjShortName = FA.ProjShortName
	LEFT JOIN (
		SELECT ActivityID,STRING_AGG(RelatedActivityID,',') ReleatedActivity,[Type], ProjShortName
		FROM stng.CARLA_RelatedActivity
		GROUP BY [Type], ActivityID, ProjShortName
		HAVING [Type] = 'Successor'
	) Succ ON Succ.ActivityID = FA.ActivityID AND Succ.ProjShortName = FA.ProjShortName
	WHERE M.Status = 'ACTIVE'
	AND FA.FragnetID IN (SELECT F.FragnetID FROM stng.CARLA_Fragnet F WHERE F.FragnetName NOT LIKE '%CLASS V%' AND F.ParentID IN 
			(SELECT CSQ.ParentID FROM stng.CARLA_Fragnet CSQ WHERE CSQ.FragnetID IN (SELECT A.FragnetID FROM stng.CARLA_FragnetActivity A WHERE A.ActivityID = @PK_ActivityID)))
	AND NOT (FA.ActivityName LIKE '% - NR' AND FA.Actualized = 1)
	GROUP BY FA.FragnetID 
		--,REPLACE(FA.ActivityName,' ','')
		,FA.ProjShortName
		,Pred.ReleatedActivity
		,Succ.ReleatedActivity
)
SELECT DISTINCT A.FragnetID
    ,A.ActivityID
    ,A.FragnetName
    ,A.ActivityName
    ,B.CommitmentDate
    ,FORMAT(B.FinishDate,'dd-MMM-yyyy') 'FinishDate'
    ,IIF(FA.[NCSQ] IN ('CSQ','NCSQ'), NULL,B.StartDate) AS 'StartDate'
    ,IIF(CL1.NewValue='','',FORMAT(CAST(CL1.NewValue AS DATE),'dd-MMM-yyyy')) AS 'StartDateSTNG'
    ,IIF(CL2.NewValue='','',FORMAT(CAST(CL2.NewValue AS DATE),'dd-MMM-yyyy')) AS 'FinishDateSTNG'
    ,IIF(CL1.[Key] = 'Actual',1,0) AS 'StartDateActualized'
    ,IIF(CL2.[Key] = 'Actual',1,0) AS 'FinishDateActualized'
    --,CL1.[Key] AS 'SKey'
    --,CL2.[Key] AS 'FKey'
    ,IIF(FA.[Resource] IS NULL, FA.[NCSQ], A.[Resource]) AS 'Resource'
    ,IIF(U.EmailSent IS NULL, 0, U.EmailSent) AS 'EmailSent'
    ,FA.[Status]
    ,FA.[Actualized]
    ,IIF(A.NCSQ ='CSQ',FORMAT(FA.[EndDate],'yyyyMMdd'),FORMAT(B.FinishDate,'yyyyMMdd')) AS 'EndDateSort' -- This is used for sorting from the FE
    ,CAST(FA.Duration / 8 AS INT) AS 'Duration'
    ,C.[Name] 'CommitmentOwner'
    ,A.Predecessor
    ,A.Successor
FROM Activity A
INNER JOIN stng.CARLA_FragnetActivity FA ON FA.ActivityID = (SELECT TOP 1 Item FROM stng.FN_0124_SplitString(A.ActivityID,','))
INNER JOIN (
SELECT O.FragnetID FROM (
	SELECT FA.FragnetID
	FROM stng.CARLA_FragnetActivity FA
	INNER JOIN stng.CARLA_Fragnet F ON F.FragnetID = FA.FragnetID
	WHERE FA.FragnetID IN (SELECT F.FragnetID FROM stng.CARLA_Fragnet F WHERE F.ParentID IN 
		(SELECT CSQ.ParentID FROM stng.CARLA_Fragnet CSQ WHERE CSQ.FragnetID IN (SELECT A.FragnetID FROM stng.CARLA_FragnetActivity A WHERE A.ActivityID = @PK_ActivityID)
	)) AND FA.[NCSQ] IN ('CSQ','NCSQ')
) O 
GROUP BY O.FragnetID ) F ON F.FragnetID = A.FragnetID
LEFT JOIN stng.MPL M ON M.[ProjectID] = FA.ProjShortName
LEFT JOIN stng.CARLA_FragnetUpdate U ON U.ActivityID = FA.ActivityID
LEFT JOIN stng.CARLA_ChangeLog CL1 ON CL1.ActivityID = FA.ActivityID AND CL1.FieldName = 'StartDate' AND CL1.P6UpdateRequired = 1
LEFT JOIN stng.CARLA_ChangeLog CL2 ON CL2.ActivityID = FA.ActivityID AND CL2.FieldName = 'FinishDate' AND CL2.P6UpdateRequired = 1
LEFT JOIN stng.VV_CARLA_GetCommitmentOwner C ON C.[ProjectID] = FA.ProjShortName AND FA.CommitmentOwner = C.CommitmentOwner
LEFT JOIN (
    SELECT 
        FORMAT(A.[EndDate],'dd-MMM-yyyy') CommitmentDate
        ,IIF(A.[Status] = 'NotStart',FORMAT(A.[StartDate],'dd-MMM-yyyy'),FORMAT(A.[ActualStartDate],'dd-MMM-yyyy')) StartDate
        ,IIF(A.[Actualized] = 0,A.[ReendDate],A.[ActualEndDate]) FinishDate
        ,A.ActivityID
        ,A.FragnetID
    FROM stng.CARLA_FragnetActivity A
	WHERE A.FragnetID IN (SELECT FragnetID FROM Activity)
) B ON B.ActivityID = FA.ActivityID AND B.FragnetID = FA.FragnetID
WHERE A.CombinedRecordCount > 0
--AND A.FragnetName NOT LIKE '% - NR'
AND FA.FragnetID = A.FragnetID

-- 3. Sub-Fragnets
SELECT FF.FragnetID,FF.ParentID,FF.FragnetName,
	(SELECT FORMAT(MIN(FA1.[StartDateMIN]),'dd-MMM-yyyy') FROM (
		SELECT FA.FragnetID,
		IIF(FA.[Status] = 'NotStart',FA.[StartDate],FA.[ActualStartDate]) AS 'StartDateMIN'
		FROM stng.CARLA_FragnetActivity FA
	) AS FA1 WHERE FA1.FragnetID = FF.FragnetID) AS 'StartDate',
	(SELECT FORMAT(MAX(FA1.[FinishDateMAX]),'dd-MMM-yyyy') FROM (
		SELECT FA.FragnetID,
		IIF(FA.[Status] = 'Actualized',FA.[ActualEndDate],FA.[ReendDate]) AS 'FinishDateMAX'
		FROM stng.CARLA_FragnetActivity FA
	) AS FA1 WHERE FA1.FragnetID = FF.FragnetID) AS 'FinishDate',
	(SELECT FORMAT(MAX(FA1.[FinishDateMAX]),'yyyyMMdd') FROM (
		SELECT FA.FragnetID,
		IIF(FA.[Status] = 'Actualized',FA.[ActualEndDate],FA.[ReendDate]) AS 'FinishDateMAX'
		FROM stng.CARLA_FragnetActivity FA
	) AS FA1 WHERE FA1.FragnetID = FF.FragnetID) AS 'FinishDateSort'
FROM stng.CARLA_Fragnet FF
INNER JOIN (
SELECT O.FragnetID FROM (
	SELECT FA.FragnetID
	FROM stng.CARLA_FragnetActivity FA
	INNER JOIN stng.CARLA_Fragnet F ON F.FragnetID = FA.FragnetID
	WHERE FA.FragnetID IN (SELECT F.FragnetID FROM stng.CARLA_Fragnet F WHERE F.ParentID IN 
		(SELECT CSQ.ParentID FROM stng.CARLA_Fragnet CSQ WHERE CSQ.FragnetID IN (SELECT A.FragnetID FROM stng.CARLA_FragnetActivity A 
		WHERE A.ActivityID = @PK_ActivityID) 
	)) AND FA.[NCSQ] IN ('CSQ','NCSQ')
	UNION
	SELECT FragnetID FROM stng.CARLA_FragnetActivity WHERE ActivityID = @PK_ActivityID
) O 
GROUP BY O.FragnetID ) A ON A.FragnetID = FF.FragnetID
ORDER BY FinishDateSort ASC
