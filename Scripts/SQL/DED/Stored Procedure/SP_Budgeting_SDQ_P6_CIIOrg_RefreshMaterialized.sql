ALTER   PROCEDURE [stngetl].[SP_Budgeting_SDQ_P6_CIIOrg_RefreshMaterialized]
(
    @RunID UNIQUEIDENTIFIER, 
    @SDQUID BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

     ------------------------------------------------------------
    -- 1. Delete rows for this SDQUID if they exist
    ------------------------------------------------------------
    DELETE FROM stngetl.Budgeting_SDQ_P6_CIIOrg_Materialized
    WHERE SDQUID = @SDQUID;

    ------------------------------------------------------------
    -- 2. Rebuild non‑legacy rows
    ------------------------------------------------------------
    WITH initialquery AS (
		  SELECT 
		CONCAT(a.RespOrg,'||',a.MultipleVendor) AS UniqueID,
		b.SDQUID,
		a.RunID,
		a.RespOrg,
		a.MultipleVendor,

		SUM(COALESCE(c.LabourRemainingUnits,0))     AS LabourRemainingUnits,
		SUM(COALESCE(c.LabourRemainingCost,0))      AS LabourRemainingCost,
		SUM(COALESCE(c.NonLabourRemainingCost,0))   AS NonLabourRemainingCost,
		SUM(COALESCE(c.RemainingCost,0))            AS RemainingCost,
		SUM(COALESCE(c.SunkCost,0))                 AS SunkCost,
		SUM(COALESCE(c.RequestCost,0))              AS RequestCost,

		SUM(COALESCE(a.DQWithoutContingency,0))     AS DQWithoutContingency

		FROM stngetl.Budgeting_SDQ_P6 a

		JOIN stng.Budgeting_SDQP6Link b 
			ON a.RunID = b.RunID 
		   AND b.Active = 1

		JOIN stngetl.Budgeting_SDQ_Run d 
			ON b.RunID = d.RunID 
		   AND d.Legacy = 0

		LEFT JOIN (
			SELECT
				TASK_ID,
				runid,
				SUM(COALESCE(LabourRemainingUnits,0))   AS LabourRemainingUnits,
				SUM(COALESCE(LabourRemainingCost,0))    AS LabourRemainingCost,
				SUM(COALESCE(NonLabourRemainingCost,0)) AS NonLabourRemainingCost,
				SUM(COALESCE(RemainingCost,0))          AS RemainingCost,
				SUM(COALESCE(SunkCost,0))               AS SunkCost,
				SUM(COALESCE(RequestCost,0))            AS RequestCost
			FROM stngetl.VV_Budgeting_P6_ActivityResource
			WHERE Baseline = 0
			GROUP BY TASK_ID, runid
		) c
			ON a.TASK_ID = c.TASK_ID
		   AND a.RunID = c.runid

		WHERE 
			a.CV = 0
			AND a.RunID = @RunID
			AND (a.RespOrg IS NOT NULL OR a.MultipleVendor IS NOT NULL)

		GROUP BY 
			CONCAT(a.RespOrg,'||',a.MultipleVendor),
			b.SDQUID,
			a.RunID,
			a.RespOrg,
			a.MultipleVendor
    ),
    bl AS (
        SELECT 
            CONCAT(a.RespOrg,'||',a.MultipleVendor) AS UniqueID,
            b.SDQUID,
            a.RunID,
            SUM(COALESCE(c.BLBudgetedCost,0)) AS BLProjectTotalCost
        FROM stngetl.Budgeting_SDQ_P6 a
        JOIN stng.Budgeting_SDQP6Link b ON a.RunID = b.RunID AND b.Active = 1
        LEFT JOIN stngetl.VV_Budgeting_P6_ActivityResource c 
            ON a.BaselineTaskID = c.task_id AND a.RunID = c.runid AND c.Baseline = 1
        JOIN stngetl.Budgeting_SDQ_Run d ON b.RunID = d.RunID AND d.Legacy = 0
        WHERE a.CV = 0 
          AND a.RunID = @RunID
          AND (a.RespOrg IS NOT NULL OR a.MultipleVendor IS NOT NULL)
        GROUP BY CONCAT(a.RespOrg,'||',a.MultipleVendor), b.SDQUID, a.RunID
    ),
    secondquery AS (
        SELECT 
            a.UniqueID,
            a.SDQUID,
            a.RunID,
            a.RespOrg,
            a.MultipleVendor,
            a.LabourRemainingUnits,
            a.LabourRemainingCost,
            a.NonLabourRemainingCost,
            a.RemainingCost,
            a.SunkCost,
            a.RequestCost,
            COALESCE(b.BLProjectTotalCost,0) AS BLProjectTotalCost,
            a.RequestCost - COALESCE(b.BLProjectTotalCost,0) AS CurrentRequest,
			COALESCE(a.DQWithoutContingency,0) AS DQWithoutContingency
        FROM initialquery a
        LEFT JOIN bl b 
            ON a.UniqueID = b.UniqueID 
           AND a.SDQUID = b.SDQUID 
           AND a.RunID = b.RunID
    )

    ------------------------------------------------------------
    -- 3. Insert refreshed rows
    ------------------------------------------------------------
    INSERT INTO stngetl.Budgeting_SDQ_P6_CIIOrg_Materialized (
        UniqueRowID, UniqueID, SDQUID, RunID, RespOrg, MultipleVendor, G4017ActivityType,
        LabourRemainingUnits, LabourRemainingCost, NonLabourRemainingCost,
        RemainingCost, SunkCost, RequestCost, BLProjectTotalCost, CurrentRequest,
        Legacy,DQWithoutContingency
    )
    SELECT 
        NEWID(),
        UniqueID,
        SDQUID,
        RunID,
        RespOrg,
        MultipleVendor,
        NULL,  -- G4017ActivityType only exists for legacy
        LabourRemainingUnits,
        LabourRemainingCost,
        NonLabourRemainingCost,
        RemainingCost,
        SunkCost,
        RequestCost,
        BLProjectTotalCost,
        CurrentRequest,
        0,
		DQWithoutContingency
    FROM secondquery;

END;
GO