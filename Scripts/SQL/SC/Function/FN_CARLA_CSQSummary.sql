/*
Author: Habib Shakibanejad
Description: Aggregate value in number of dates that require updating
CreatedDate: 15 June 2022
RevisedDate:
RevisedBy: 
*/
CREATE OR ALTER   FUNCTION [stng].[FN_CARLA_CSQSummary](@PK_ActivityID VARCHAR(20))
RETURNS @T TABLE(
	ActivityID NVARCHAR(2000),
	Total INT,
	[Type] NVARCHAR(10)
)					  
AS
BEGIN
	INSERT INTO @T 
	SELECT STRING_AGG(A.ActivityID,'@@') AS 'ActivityID' 
		,SUM(CAST(A.Total AS INT)) AS 'Total'
		,A.[Type]
	FROM ( 
		SELECT
			COUNT(*) AS 'Total'
			,'LateStart' AS 'Type'
			,STRING_AGG(FA.ActivityName,'@@') AS 'ActivityID'
		FROM stng.CARLA_FragnetActivity FA 
		LEFT JOIN stng.MPL M ON M.[ProjectID] = FA.ProjShortName
		LEFT JOIN stng.CARLA_ChangeLog CL ON CL.ActivityID = FA.ActivityID AND CL.FieldName = 'StartDate' AND CL.[Key] = 'Actual' AND CL.P6UpdateRequired = 1
		LEFT JOIN stng.CARLA_ChangeLog CL1 ON CL1.ActivityID = FA.ActivityID AND CL1.FieldName = 'StartDate' AND CL1.[Key] = 'Anticipated' AND CL1.P6UpdateRequired = 1
		--LEFT JOIN stng.Fragnet F ON F.FragnetID = FA.FragnetID
		LEFT JOIN (
			SELECT 
				IIF(A.[Status] = 'NotStart',A.StartDate,A.[ActualStartDate]) StartDate
				,A.ActivityID
				,A.FragnetID
			FROM stng.CARLA_FragnetActivity A
		) B ON B.ActivityID = FA.ActivityID AND B.FragnetID = FA.FragnetID
		WHERE M.Status = 'ACTIVE'
		AND FA.FragnetID IN (SELECT A.FragnetID FROM stng.CARLA_FragnetActivity A WHERE A.ActivityID = @PK_ActivityID)
		AND NOT (FA.ActivityName LIKE '% - NR' AND FA.Actualized = 1)
		AND B.StartDate < CAST(GETDATE() AS DATE)
		AND FA.[Status] = 'NotStart'
		--AND (FA.[Resource] NOT IN ('CSQ','NCSQ') OR FA.[Resource] IS NULL)
		AND FA.[NCSQ] IS NULL
		AND CL.NewValue IS NULL
		AND CL1.NewValue IS NULL
		--AND F.FragnetName NOT LIKE '% - NR'
		GROUP BY FA.FragnetID
		UNION
		SELECT 
			COUNT(*)
			,'WarnStart'
			,STRING_AGG(FA.ActivityName,'@@') AS 'ActivityID'
		FROM stng.CARLA_FragnetActivity FA 
		LEFT JOIN stng.MPL M ON M.[ProjectID] = FA.ProjShortName
		LEFT JOIN stng.CARLA_ChangeLog CL ON CL.ActivityID = FA.ActivityID AND CL.FieldName = 'StartDate' AND CL.[Key] = 'Actual' AND CL.P6UpdateRequired = 1
		LEFT JOIN stng.CARLA_ChangeLog CL1 ON CL1.ActivityID = FA.ActivityID AND CL1.FieldName = 'StartDate' AND CL1.[Key] = 'Anticipated' AND CL1.P6UpdateRequired = 1
		--LEFT JOIN stng.Fragnet F ON F.FragnetID = FA.FragnetID
		LEFT JOIN (
			SELECT 
				IIF(A.[Status] = 'NotStart',A.StartDate,A.[ActualStartDate]) StartDate
				,A.ActivityID
				,A.FragnetID
			FROM stng.CARLA_FragnetActivity A
		) B ON B.ActivityID = FA.ActivityID AND B.FragnetID = FA.FragnetID
		WHERE M.Status = 'ACTIVE'
		AND FA.FragnetID IN (SELECT A.FragnetID FROM stng.CARLA_FragnetActivity A WHERE A.ActivityID = @PK_ActivityID)		
		AND NOT (FA.ActivityName LIKE '% - NR' AND FA.Actualized = 1)
		AND ((B.StartDate >= CAST(GETDATE() AS DATE) AND B.StartDate <= CAST(GETDATE() + 3 AS DATE) AND CL1.NewValue IS NULL) OR (CAST(CL1.NewValue AS DATE) >= CAST(GETDATE() AS DATE) AND CAST(CL1.NewValue AS DATE) <= CAST(GETDATE() + 3 AS DATE)))
		AND FA.[Status] = 'NotStart'
		--AND (FA.[Resource] NOT IN ('CSQ','NCSQ') OR FA.[Resource] IS NULL)
		AND FA.[NCSQ] IS NULL
		AND CL.NewValue IS NULL
		--AND F.FragnetName NOT LIKE '% - NR'
		GROUP BY FA.FragnetID
		UNION
		SELECT
			COUNT(*)
			,'LateFinish'
			,STRING_AGG(FA.ActivityName,'@@') AS 'ActivityID'
		FROM stng.CARLA_FragnetActivity FA 
		LEFT JOIN stng.MPL M ON M.[ProjectID] = FA.ProjShortName
		LEFT JOIN stng.CARLA_ChangeLog CL ON CL.ActivityID = FA.ActivityID AND CL.FieldName = 'FinishDate' AND CL.[Key] = 'Actual' AND CL.P6UpdateRequired = 1
		LEFT JOIN stng.CARLA_ChangeLog CL1 ON CL1.ActivityID = FA.ActivityID AND CL1.FieldName = 'FinishDate' AND CL1.[Key] = 'Anticipated' AND CL1.P6UpdateRequired = 1
		--LEFT JOIN stng.Fragnet F ON F.FragnetID = FA.FragnetID
		LEFT JOIN (
			SELECT 
				IIF(A.[Actualized] = 0,A.[ReendDate],A.[ActualEndDate]) FinishDate
				,A.ActivityID
				,A.FragnetID
			FROM stng.CARLA_FragnetActivity A
		) B ON B.ActivityID = FA.ActivityID AND B.FragnetID = FA.FragnetID
		WHERE M.[Status] = 'ACTIVE'
		AND FA.FragnetID IN (SELECT A.FragnetID FROM stng.CARLA_FragnetActivity A WHERE A.ActivityID = @PK_ActivityID)
		AND NOT (FA.ActivityName LIKE '% - NR' AND FA.Actualized = 1)
		AND B.FinishDate < CAST(GETDATE() AS DATE)
		AND FA.[Status] <> 'Actualized'
		AND CL.NewValue IS NULL
		AND CL1.NewValue IS NULL
		--AND F.FragnetName NOT LIKE '% - NR'
		GROUP BY FA.FragnetID
		UNION
		SELECT
			COUNT(*)
			,'WarnFinish'
			,STRING_AGG(FA.ActivityName,'@@') AS 'ActivityID'
		FROM stng.CARLA_FragnetActivity FA 
		LEFT JOIN stng.MPL M ON M.[ProjectID] = FA.ProjShortName
		LEFT JOIN stng.CARLA_ChangeLog CL ON CL.ActivityID = FA.ActivityID AND CL.FieldName = 'FinishDate' AND CL.[Key] = 'Actual' AND CL.P6UpdateRequired = 1
		LEFT JOIN stng.CARLA_ChangeLog CL1 ON CL1.ActivityID = FA.ActivityID AND CL1.FieldName = 'FinishDate' AND CL1.[Key] = 'Anticipated' AND CL1.P6UpdateRequired = 1
		--LEFT JOIN stng.Fragnet F ON F.FragnetID = FA.FragnetID
		LEFT JOIN (
			SELECT 
				IIF(A.[Actualized] = 0,A.[ReendDate],A.[ActualEndDate]) FinishDate
				,A.ActivityID
				,A.FragnetID
			FROM stng.CARLA_FragnetActivity A
		) B ON B.ActivityID = FA.ActivityID AND B.FragnetID = FA.FragnetID
		WHERE M.Status = 'ACTIVE'
		AND FA.FragnetID IN (SELECT A.FragnetID FROM stng.CARLA_FragnetActivity A WHERE A.ActivityID = @PK_ActivityID)
		AND NOT (FA.ActivityName LIKE '% - NR' AND FA.Actualized = 1)
		AND ((B.FinishDate >= CAST(GETDATE() AS DATE) AND B.FinishDate <= CAST(GETDATE() + 3 AS DATE) AND CL1.NewValue IS NULL) OR (CAST(CL1.NewValue AS DATE) >= CAST(GETDATE() AS DATE) AND CAST(CL1.NewValue AS DATE) <= CAST(GETDATE() + 3 AS DATE)))
		AND FA.[Status] <> 'Actualized'
		AND CL.NewValue IS NULL
		--AND F.FragnetName NOT LIKE '% - NR'
		GROUP BY FA.FragnetID
		) A
	GROUP BY A.[Type]
	RETURN 
END
GO