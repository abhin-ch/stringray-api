CREATE OR ALTER view [stngetl].[VV_Budgeting_SDQ_P6_SDSSummary_CII] as
	-- New P6 Data
	SELECT 
		SDQUID, 
		SDSCode, 
		PhaseC AS Phase, 
		MIN(CurrentStart) AS [Start], 
		MAX(CurrentEnd) AS [End], 
		SUM(Budget) AS Budget, 
		SUM(CASE WHEN DirectBool = 1 THEN Budget ELSE 0 END) AS DirectBudget,
		SUM(CASE WHEN DirectBool = 0 THEN Budget ELSE 0 END) AS IndirectBudget
	FROM stngetl.VV_Budgeting_SDQ_P6_CIISDS
	WHERE Legacy = 0
	GROUP BY SDQUID, SDSCode, PhaseC

	UNION ALL

	-- Legacy P6 Snapshot (only use this data if there is no P6 Upload)
	SELECT 
		l.SDID AS SDQUID, 
		l.SDSCode, 
		l.PhaseC AS Phase,
		l.minStartDate AS [Start], 
		l.maxEndDate AS [End],
		l.BudgetSum AS Budget, 
		l.DirectBudgetSum AS DirectBudget, 
		l.IndirectBudgetSum AS IndirectBudget
	FROM stng.Budgeting_SDQ_P6_Legacy_SDSSummary_ClassII l
	WHERE NOT EXISTS (
		SELECT 1
		FROM stngetl.Budgeting_SDQ_P6 AS a
		INNER JOIN stng.Budgeting_SDQP6Link AS b ON a.RunID = b.RunID AND b.Active = 1
		INNER JOIN stngetl.Budgeting_SDQ_Run AS f ON b.RunID = f.RunID AND f.Legacy = 0
		WHERE b.SDQUID = l.SDID 
	);
GO