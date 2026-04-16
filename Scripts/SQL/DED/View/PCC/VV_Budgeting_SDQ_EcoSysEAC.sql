CREATE OR ALTER view [stng].[VV_Budgeting_SDQ_EcoSysEAC] as
    WITH PreAggregatedEAC AS (
		SELECT ProjectID, SUM(EcoSysEAC) AS SumEcoSysEAC
		FROM stng.Budgeting_SDQ_EcosysEAC
		GROUP BY ProjectID
	)
	SELECT 
		a.SDQUID, 
		b.ProjectID,
		COALESCE(a.EcoSysEACSnap, b.SumEcoSysEAC) AS EcoSysEAC,
		CASE WHEN a.EcoSysEACSnap IS NULL THEN 1 ELSE 0 END AS IsLive,
		b.SumEcoSysEAC AS EcoSysEACLive
	FROM stng.Budgeting_SDQMain AS a
	LEFT JOIN PreAggregatedEAC AS b ON a.ProjectNo = b.ProjectID OR a.ProjectNo = CONCAT('ENG-', b.ProjectID)
	WHERE a.DeleteRecord = 0;
GO
