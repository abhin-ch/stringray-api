/*
Author: Habib Shakibanejad
Description: Get remaining activities that required updating after the automate feature has processed. 
CreatedDate: 08 July 2022
*/
CREATE OR ALTER PROCEDURE [stng].[SP_CARLA_GetRemainingDates](
	@ActivityID	NVARCHAR(255)
	,@NewDiff		INT
)
AS
SET @ActivityID = (SELECT TOP 1 Item FROM stng.FN_0124_SplitString(@ActivityID,','));
WITH Activity (FragnetID,FragnetName,[Resource],ActivityID,CombinedRecordCount,NCSQ,Predecessor,Successor)  
AS (
	SELECT FA.FragnetID
		,(SELECT DISTINCT F.FragnetName FROM stng.CARLA_Fragnet F WHERE F.FragnetID = FA.FragnetID) AS 'FragnetName'
		--,FA.ProjShortName
		,STRING_AGG(FA.[Resource],',')
		,STRING_AGG(CONVERT(NVARCHAR(max),FA.ActivityID), ',') WITHIN GROUP (ORDER BY FA.ActivityID)
		,COUNT(*)
		,(SELECT [NCSQ] FROM stng.CARLA_FragnetActivity WHERE ActivityID = @ActivityID)
		,Pred.ReleatedActivity
		,Succ.ReleatedActivity
	FROM stng.CARLA_FragnetActivity FA 
	LEFT JOIN stng.MPL M ON M.[ProjectID] = FA.ProjShortName	
	LEFT JOIN (
		SELECT ActivityID,STRING_AGG(RelatedActivityID,',') ReleatedActivity,[Type] 
		FROM stng.CARLA_RelatedActivity
		GROUP BY [Type], ActivityID
		HAVING [Type] = 'Predecessor'
	) Pred ON Pred.ActivityID = FA.ActivityID
	LEFT JOIN (
		SELECT ActivityID,STRING_AGG(RelatedActivityID,',') ReleatedActivity,[Type] 
		FROM stng.CARLA_RelatedActivity
		GROUP BY [Type], ActivityID
		HAVING [Type] = 'Successor'
	) Succ ON Succ.ActivityID = FA.ActivityID
	WHERE M.Status = 'ACTIVE'
	AND FA.FragnetID = (SELECT FA.FragnetID FROM stng.CARLA_FragnetActivity FA WHERE FA.ActivityID = @ActivityID)
	AND NOT FA.Actualized = 1
	GROUP BY FA.FragnetID 
		--,REPLACE(FA.ActivityName,' ','')
		,FA.ProjShortName
		,Pred.ReleatedActivity
		,Succ.ReleatedActivity
)
SELECT * FROM (
SELECT DISTINCT A.FragnetID
	,A.ActivityID
	,A.FragnetName
	,FA.ActivityName
	,B.CommitmentDate
	,FORMAT(B.FinishDate, 'dd-MMM-yyyy') AS 'FinishDate' 
	,FORMAT(B.FinishDate, 'dd-MMM-yyyy') AS 'FinishDateSTNG' 
	,IIF(FA.[Status] = 'NotStart',FORMAT(B.StartDate, 'dd-MMM-yyyy'),FORMAT(FA.[ActualStartDate], 'dd-MMM-yyyy')) AS 'StartDate' 
	,IIF(FA.[Status] = 'NotStart',FORMAT(B.StartDate, 'dd-MMM-yyyy'),FORMAT(FA.[ActualStartDate], 'dd-MMM-yyyy')) AS 'StartDateSTNG'
	,'StartDateActualized' = 
		CASE WHEN CL1.[Key] IS NOT NULL AND CL1.[Key] = 'Actual' THEN CAST(1 AS BIT)
			WHEN FA.[Status] = 'Active' THEN CAST(1 AS BIT)
			ELSE 0
		END
	,CAST(IIF(CL2.[Key] = 'Actual',1,0) AS BIT) AS 'FinishDateActualized'
	,IIF(FA.[Resource] IS NULL, FA.[NCSQ], A.[Resource]) AS 'Resource'
	,IIF(U.EmailSent IS NULL, 0, U.EmailSent) AS 'EmailSent'
	,FA.[Status]
	,FA.[Actualized]
	,CAST(FA.Duration / 8 AS INT) AS 'Duration'
	,B.StartDate AS 'Order'
	,FA.EndDate AS 'CommitmentDateOrder'
FROM Activity A
INNER JOIN stng.CARLA_FragnetActivity FA ON FA.ActivityID = (SELECT TOP 1 Item FROM stng.FN_0124_SplitString(A.ActivityID,','))
LEFT JOIN stng.CARLA_FragnetUpdate U ON U.ActivityID = FA.ActivityID
LEFT JOIN stng.CARLA_ChangeLog CL1 ON CL1.ActivityID = FA.ActivityID AND CL1.FieldName = 'StartDate' AND CL1.P6UpdateRequired = 1
LEFT JOIN stng.CARLA_ChangeLog CL2 ON CL2.ActivityID = FA.ActivityID AND CL2.FieldName = 'FinishDate' AND CL2.P6UpdateRequired = 1
LEFT JOIN (
	SELECT 
		FORMAT(A.[EndDate],'dd-MMM-yyyy') CommitmentDate
		,stng.FN_CARLA_GetDate(IIF(A.[Status] = 'NotStart',A.[StartDate],A.[ActualStartDate]),@NewDiff) AS 'StartDate'
		,stng.FN_CARLA_GetDate(IIF(A.[Actualized] = 0,A.[ReendDate],A.[ActualEndDate]),@NewDiff) AS 'FinishDate'
		,A.ActivityID
		,A.FragnetID
	FROM stng.CARLA_FragnetActivity A
	WHERE A.FragnetID = (SELECT FA.FragnetID FROM stng.CARLA_FragnetActivity FA WHERE FA.ActivityID = @ActivityID)
) B ON B.ActivityID = FA.ActivityID AND B.FragnetID = FA.FragnetID
WHERE A.CombinedRecordCount > 0
--AND A.FragnetName NOT LIKE '% - NR'
AND FA.FragnetID = A.FragnetID
--AND B.StartDate <= CAST(GETDATE() AS DATE)
AND FA.Actualized = 0
) A
WHERE (A.StartDate <= CAST(GETDATE() AS DATE) AND A.StartDateActualized = 0) OR (A.FinishDate <= GETDATE() AND A.StartDateActualized = 1)
ORDER BY A.[Order],A.[Resource]
