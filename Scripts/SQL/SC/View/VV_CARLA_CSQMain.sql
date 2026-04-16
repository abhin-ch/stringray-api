/*
Author: Habib Shakibanejad
Description: Grab CSQs
CreatedDate: 20 Feb 2022
RevisedDate:
RevisedBy: 
*/
CREATE OR ALTER VIEW [stng].[VV_CARLA_CSQMain]
AS 
WITH Projects AS (
	SELECT FA.ProjShortName FROM stng.CARLA_FragnetActivity FA
	WHERE (FA.ProjShortName LIKE 'CS-[0-9][0-9][0-9][0-9][0-9]'
		OR FA.ProjShortName = 'CS-PMCIND' 
		OR FA.ProjShortName = 'CS-PMCENG'
		OR FA.ProjShortName = 'CS-PMOSUP')
	GROUP BY FA.ProjShortName
), 
ParentCSQ AS 
(			-- Grab all parent CSQ
	SELECT B.ActivityID,B.FragnetName,B.FragnetID,B.ParentID FROM ( 
		SELECT A.*,
			ROW_NUMBER() OVER(PARTITION BY A.ParentID ORDER BY A.EndDate ASC) AS RN
		FROM (
			SELECT FA.FragnetID
				,FA.ActivityID
				,FA.EndDate
				,FF.FragnetName
				,FF.ParentID
			FROM stng.CARLA_FragnetActivity FA
			LEFT JOIN stng.VV_MPL_SC M ON M.[ProjectID] = FA.ProjShortName
			CROSS APPLY (
				SELECT TOP 1 F.FragnetID AS 'ParentID',F.FragnetName FROM stng.CARLA_Fragnet F 
				WHERE F.FragnetID = (SELECT TOP 1 ParentID FROM stng.CARLA_Fragnet S 
				WHERE S.FragnetID = FA.FragnetID)
			) AS FF
			LEFT JOIN stng.CARLA_Fragnet F ON F.FragnetID = FA.FragnetID
			WHERE FA.Actualized = 0
			AND M.Status = 'ACTIVE' 
			AND (FA.[NCSQ] = 'CSQ' OR FA.[NCSQ] = 'NCSQ')
			AND FA.ActivityName NOT LIKE '%Amendment%'
			AND F.FragnetName NOT LIKE '%Amendment%'
			AND FA.EndDate IS NOT NULL -- Bring in only baselined
			AND FF.FragnetName NOT LIKE '%CLASS V%'
			--AND FA.EndDate >= CAST(GETDATE() AS DATE)
			--AND FF.FragnetName NOT LIKE '% - NR'
			--AND FA.ActivityName NOT LIKE '% - NR'
			AND FA.ProjShortName IN (SELECT P.ProjShortName FROM Projects P)
		) A 
	) B
	WHERE B.RN = 1
	UNION
	SELECT FA.ActivityID,F.FragnetName,F.FragnetID,F.ParentID FROM stng.CARLA_FragnetActivity FA
	LEFT JOIN stng.CARLA_Fragnet F ON F.FragnetID = FA.FragnetID
	INNER JOIN stng.VV_MPL_SC M ON M.[ProjectID] = FA.ProjShortName
	WHERE (FA.ActivityName LIKE '%Amendment%' OR F.FragnetName LIKE '%Amendment%')
	AND M.Status = 'ACTIVE'
	AND (FA.[NCSQ] = 'CSQ' OR FA.[NCSQ] = 'NCSQ')
	AND FA.Actualized = 0
	AND FA.EndDate IS NOT NULL -- Bring in only baselined
	AND F.FragnetName NOT LIKE '%CLASS V%'
	--AND F.FragnetName NOT LIKE '% - NR'
	--AND FA.EndDate >= CAST(GETDATE() AS DATE)
	AND FA.ProjShortName IN (SELECT P.ProjShortName FROM Projects P)
),
Main AS 
(
	-- 1. Parents CSQs
	SELECT DISTINCT--FA.[ProjID]
		FA.[ProjShortName] AS 'ProjectID'
		,FA.[ActivityID]
		,FA.[ActivityName]
		,FA.[FragnetID]
		,FA.[NCSQ]
		,FA.[EndDate] AS 'CommitmentDate'
		,SubF.[FragnetName] AS 'SubFragnetName'
		,CSQ.FragnetName
		,(SELECT TOP 1 ActivityName FROM stng.CARLA_FragnetActivity WHERE FragnetID = FA.FragnetID AND Actualized = 0 ORDER BY EndDate) AS 'NextActivityName'
		,(SELECT TOP 1 [Resource] FROM stng.CARLA_FragnetActivity WHERE FragnetID = FA.FragnetID AND Actualized = 0 ORDER BY EndDate) AS 'NextActivityOwner'
		,(SELECT TOP 1 CAST(ActualEndDate AS DATE) FROM stng.CARLA_FragnetActivity WHERE FragnetID = FA.FragnetID AND Actualized = 0 ORDER BY EndDate) AS 'NextActivityFinishDate'
		--,IIF(EXISTS (SELECT ESC.Title FROM [stng].[Escalation] AS ESC WHERE ESC.CommitmentID = FA.ActivityID), 1, 0) AS 'Escalation'
		,M.ProjectName
		,M.[Portfolio]
		,M.PCS
		,M.ProjectManager
		,M.ProjectPlanner
		,M.ProgramManager
		,M.MaterialBuyer
		,M.ContractAdmin
		,M.ServiceBuyer
		,M.BuyerAnalyst
		,M.CSFLM
		--,M.ContractSpecialist
		,M.FastTrack
		,M.CostAnalyst
		,DATEDIFF(DAY,FA.[ActualEndDate],FA.EndDate) AS 'Variance'
		,U.Category
		,U.UpdateRequired
		,U.[Status]
		,stng.FN_CARLA_GetSDSNumber(CSQ.FragnetName) AS 'SDS'
		,IIF(U.EmailSent IS NULL, 0, U.EmailSent) AS 'EmailSent'
		,U.RevisedCommitmentDate AS 'RevisedDate'	
		,C.Name AS 'CommitmentOwner'
		,C.LANID AS 'CommitmentOwnerLANID'
		,FA.[EndDate] -- REQUIRED FOR ORDER BY
		,FORMAT(FA.[EndDate],'yyyyMMdd') AS 'DateSort'
		--,(SELECT ISNULL(MAX(CASE 
		--		WHEN A.[Type] = 'LateStart' THEN '3. Late'
		--		WHEN A.[Type] = 'LateFinish' THEN '3. Late'
		--		WHEN A.[Type] = 'WarnStart' THEN '2. Caution'
		--		WHEN A.[Type] = 'WarnFinish' THEN '2. Caution'
		--		END),'1. Good') AS 'Type'
		--	FROM (
		--	SELECT TOP 1 FN.Type FROM stng.FN_0035_CSQSummary(FA.ActivityID) FN ORDER BY FN.[Type]
		--	) A
		--) AS 'QualityCheckCount'
		,(SELECT COUNT(*) FROM stng.Common_ChangeLog C WHERE C.AffectedField = 'Status' AND C.AffectedTable = 'FragnetUpdate' 
		AND C.NewValue = 'Push Required' AND C.ParentID = FA.ActivityID) AS 'Pushed'
		,M.ProjectType
	FROM stng.CARLA_FragnetActivity FA
	INNER JOIN stng.CARLA_Fragnet SubF ON SubF.FragnetID = FA.FragnetID
	INNER JOIN ParentCSQ CSQ ON CSQ.ActivityID = FA.ActivityID
	INNER JOIN Projects P ON P.ProjShortName = FA.ProjShortName
	LEFT JOIN stng.VV_MPL_SC M ON M.ProjectID = FA.ProjShortName
	LEFT JOIN stng.CARLA_FragnetUpdate U ON U.ActivityID = FA.ActivityID
	LEFT JOIN stng.VV_CARLA_GetCommitmentOwner AS C ON C.ProjectID = FA.ProjShortName AND C.CommitmentOwner = FA.CommitmentOwner
	WHERE FA.EndDate IS NOT NULL -- Bring in only baselined
	AND SubF.FragnetName NOT LIKE '%CLASS V%'
	--AND SubF.FragnetName NOT LIKE '% - NR'
	--ORDER BY DateSort  
) SELECT * FROM Main M 
