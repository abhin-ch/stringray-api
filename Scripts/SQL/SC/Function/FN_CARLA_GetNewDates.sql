-- =============================================
-- Author:		Habib Shakibanejad
-- Create date: 25 July 2022
-- Description:	Return a table with new schedule dates for subfragnet
-- =============================================
CREATE OR ALTER         FUNCTION [stng].[FN_CARLA_GetNewDates]
(	
	@ActivityID VARCHAR(255),
	@NewDiff INT,
	@NewValue DATE,
	@FADetails stng.CARLA_FADetails READONLY,
	@Field VARCHAR(10)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT A.ActivityID
	,A.NewStartDate
	,A.NewFinishDate
	,FORMAT(A.StartDate,'dd-MMM-yyyy') AS 'StartDate'
	,FORMAT(A.FinishDate,'dd-MMM-yyyy') AS 'FinishDate'
	,A.FragnetID
	,A.ActivityName
	,A.CommitmentDate 
	,A.DateLimit
	,A.Duration
	FROM (
		SELECT FA.ActivityID
			,'NewStartDate' =
				CASE WHEN @NewValue IS NULL THEN NULL
					WHEN FA.[Status] = 'Active' THEN NULL
				ELSE FORMAT(stng.FN_CARLA_GetDate(IIF(FA.[Status] = 'NotStart',FA.[StartDate],FA.[ActualStartDate]),@NewDiff),'dd-MMM-yyyy')
				END
			--,stng.FN_0037_GetDate(IIF(FA.[Actualized] = 0,FA.[ReendDate],FA.[ActualEndDate]),@NewDiff - 1 - IIF(FA.Duration IS NULL,0,(FA.Duration/8))) AS 'NewStartDate'
			,'NewFinishDate' = 
				CASE WHEN @NewValue IS NULL THEN NULL
				ELSE FORMAT(stng.FN_CARLA_GetDate(IIF(FA.[Actualized] = 0,FA.[ReendDate],FA.[ActualEndDate]),@NewDiff),'dd-MMM-yyyy') 
				END
			--,@NewDiff - (FA.Duration/8)
			,'DateSort' =
				CASE WHEN @NewValue IS NULL THEN '9999-01-01'
				ELSE stng.FN_CARLA_GetDate(IIF(FA.[Status] = 'NotStart',FA.[StartDate],FA.[ActualStartDate]),@NewDiff) 
				END
			,IIF(FA.[Status] = 'NotStart',FA.[StartDate],FA.[ActualStartDate]) 'StartDate'
			,IIF(FA.[Actualized] = 0,FA.[ReendDate],FA.[ActualEndDate]) 'FinishDate'
			,FA.FragnetID
			,FA.ActivityName
			,FA.EndDate AS CommitmentDate
			,'DateLimit' = 
			CASE WHEN @Field = 'Start' THEN IIF(FA2.[Status] = 'NotStart',FA2.[StartDate],FA2.[ActualStartDate])
			WHEN @Field = 'Finish' THEN IIF(FA2.[Actualized] = 0,FA2.[ReendDate],FA2.[ActualEndDate])
			END
			--,IIF(FA2.[Status] = 'NotStart',FA2.[StartDate],FA2.[ActualStartDate]) 'PKStart'
			--,IIF(FA2.[Actualized] = 0,FA2.[ReendDate],FA2.[ActualEndDate]) 'PKFinish'
			,FA.Duration
		FROM stng.CARLA_FragnetActivity FA 
		LEFT JOIN stng.CARLA_FragnetActivity FA2 ON FA2.ActivityID = @ActivityID
		WHERE FA.FragnetID IN (SELECT A.DetailValue FROM @FADetails A)
		--INNER JOIN (SELECT O.FragnetID FROM (
		--	SELECT FA.FragnetID
		--	FROM stng.CARLA_FragnetActivity FA
		--	INNER JOIN stng.Fragnet F ON F.FragnetID = FA.FragnetID
		--	WHERE FA.FragnetID IN (SELECT F.FragnetID FROM stng.Fragnet F WHERE F.ParentID IN 
		--		(SELECT CSQ.ParentID FROM stng.Fragnet CSQ WHERE CSQ.FragnetID IN (SELECT A.FragnetID FROM stng.CARLA_FragnetActivity A WHERE A.ActivityID = @PK_ActivityID)
		--	)) AND FA.[N/CSQ] IN ('CSQ','NCSQ')
		--) O 
		--GROUP BY O.FragnetID ) A ON A.FragnetID = FA.FragnetID
		AND FA.Actualized = 0
	) A
)
GO