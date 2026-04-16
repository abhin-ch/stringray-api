CREATE OR ALTER function [stng].[FN_Budgeting_SDQ_EACTrendGraph] 
(
	@SDQUID bigint
)
returns @ReturnTbl table
(
	SDQUID bigint,
	Phase int,
	Revision int,
	[Label] varchar(200),
	LAMP3 int,
	EcoSysEAC int,
	EAC int,
	LAMP4 INT,
	EcoSysEAC_ENG INT
)
begin	

	-- Get ProjectNo from the current SDQUID
	WITH ProjectData AS (
		SELECT 
			A.ProjectNo,
			A.LAMP4,
			A.RecordTypeUniqueID AS SDQUID
		FROM stng.VV_Budgeting_SDQMain A
		WHERE A.RecordTypeUniqueID = @SDQUID
	),
	Lamp4 AS (
		SELECT 
			@SDQUID AS SDQUID,
			E.EAC
		FROM stng.VV_Budgeting_SDQ_CustomerApproval_2 E
		INNER JOIN stng.VV_Budgeting_SDQMain B ON E.SDQUID = B.RecordTypeUniqueID
		INNER JOIN ProjectData P ON B.ProjectNo = P.ProjectNo
		WHERE B.LAMP4Baseline = 'Y' AND P.LAMP4 = 'Y'
	)
 	INSERT INTO @ReturnTbl(SDQUID, Phase, Revision, [Label], LAMP3, EcoSysEAC, EAC, LAMP4, EcoSysEAC_ENG)	
	-- Previous Revision
	SELECT 
		a.PrevSDQUID AS SDQUID,
		a.PrevSDQPhase AS Phase,
		a.PrevSDQRevision AS Revision,
		CONCAT(a.PrevSDQPhase, '.', a.PrevSDQRevision, ' ', b.PhaseDescShort) AS [Label],
		c.LAMP3,
		ISNULL(d.EcoSysEAC, 0) AS EcoSysEAC,
		d.EAC,
		e.EAC AS LAMP4,
		g.EcoSysEAC AS EcoSysEAC_ENG
	FROM stng.VV_Budgeting_SDQ_PreviousRevision a
	INNER JOIN stng.Budgeting_SDQ_Phase b ON a.PrevSDQPhase = b.Phase
	INNER JOIN stng.Budgeting_SDQMain c ON a.PrevSDQUID = c.SDQUID
	LEFT JOIN stngetl.VV_Budgeting_SDQ_P6_EAC_2 d ON a.PrevSDQUID = d.SDQUID
	LEFT JOIN stng.Budgeting_SDQ_EcosysEAC_ENG g ON CONCAT('ENG-', g.ProjectId) = c.ProjectNo
	LEFT JOIN Lamp4 e ON e.SDQUID = a.SDQUID
	WHERE a.SDQUID = @SDQUID
 
	UNION
 
	-- Current Revision
	SELECT 
		a.SDQUID,
		b.Phase,
		a.Revision,
		CONCAT(b.Phase, '.', a.Revision, ' ', b.PhaseDescShort) AS [Label],
		a.LAMP3,
		ISNULL(d.EcoSysEAC, 0) AS EcoSysEAC,
		d.EAC,
		e.EAC AS LAMP4,
		g.EcoSysEAC AS EcoSysEAC_ENG
	FROM stng.Budgeting_SDQMain a
	INNER JOIN stng.Budgeting_SDQ_Phase b ON a.Phase = b.SDQPhaseID
	LEFT JOIN stngetl.VV_Budgeting_SDQ_P6_EAC_2 d ON a.SDQUID = d.SDQUID
	LEFT JOIN stng.Budgeting_SDQ_EcosysEAC_ENG g ON CONCAT('ENG-', g.ProjectId) = a.ProjectNo
	LEFT JOIN Lamp4 e ON e.SDQUID = a.SDQUID
	WHERE a.SDQUID = @SDQUID;
 
	RETURN;
END