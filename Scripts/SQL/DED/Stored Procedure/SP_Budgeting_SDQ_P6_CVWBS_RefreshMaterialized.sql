CREATE OR ALTER PROCEDURE stngetl.SP_Budgeting_SDQ_P6_CVWBS_RefreshMaterialized
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
    DELETE FROM stngetl.Budgeting_SDQ_P6_CVWBS_Materialized
    WHERE SDQUID = @SDQUID;

   ------------------------------------------------------------
    -- 2. Insert rows into P6_CVWBS_Materialized
    ------------------------------------------------------------
    WITH lvl6wbs AS (
        SELECT DISTINCT 
            b.SDQUID,
            a.RunID,
            a.wbs_name,
            a.wbs_code,
            a.activityid,
            a.DeliverableType,
            a.Unit,
            c.DeliverableName,
            c.Direct,
            a.PhaseCode,
            CASE 
                WHEN c.Direct = 0 THEN '0'
                WHEN a.PhaseCode IN (0,1) THEN '0'
                ELSE a.DisciplineCode 
            END AS DisciplineCode,
            a.CurrentStart,
            a.StartActualized,
            a.CurrentEnd,
            a.EndActualized,
            COALESCE(d.LabourActualUnits,0)        AS LabourActualUnits,
            COALESCE(d.LabourActualCost,0)         AS LabourActualCost,
            COALESCE(d.NonLabourActualUnits,0)     AS NonLabourActualUnits,
            COALESCE(d.NonLabourActualCost,0)      AS NonLabourActualCost,
            COALESCE(d.SunkCost,0)                 AS SunkCost,
            COALESCE(d.LabourRemainingUnits,0)     AS LabourRemainingUnits,
            COALESCE(d.NonLabourRemainingUnits,0)  AS NonLabourRemainingUnits,
            COALESCE(d.LabourRemainingCost,0)      AS LabourRemainingCost,
            COALESCE(d.NonLabourRemainingCost,0)   AS NonLabourRemainingCost,
            COALESCE(d.RemainingCost,0)            AS RemainingCost
        FROM stngetl.Budgeting_SDQ_P6 a
        JOIN stng.Budgeting_SDQP6Link b ON a.RunID = b.RunID AND b.Active = 1
        LEFT JOIN stngetl.VV_Budgeting_P6_ActivityResource d 
            ON a.task_id = d.task_id AND a.RunID = d.runid AND d.Baseline = 0
        JOIN stngetl.Budgeting_SDQ_Run f ON b.RunID = f.RunID AND f.Legacy = 0
        CROSS APPLY (
            SELECT * 
            FROM stng.FN_Budgeting_SDQ_StandardDeliverable(b.SDQUID) f 
            WHERE a.DeliverableType = f.DeliverableID
        ) c
        WHERE a.CV = 1 AND a.wbs_lvl = 6 AND a.RunID = @RunID
    ),

    lvl6wbssum AS (
        SELECT 
            SDQUID,
            RunID,
            wbs_name,
            wbs_code,
            DeliverableType,
            Unit,
            DeliverableName,
            Direct,
            PhaseCode,
            DisciplineCode,
            MIN(CurrentStart) AS CurrentStart,
            CAST(MAX(CAST(StartActualized AS TINYINT)) AS BIT) AS StartActualized,
            MAX(CurrentEnd) AS CurrentEnd,
            CAST(MIN(CAST(EndActualized AS TINYINT)) AS BIT) AS EndActualized,
            SUM(LabourActualUnits) AS LabourActualUnits,
            SUM(LabourActualCost) AS LabourActualCost,
            SUM(NonLabourActualUnits) AS NonLabourActualUnits,
            SUM(NonLabourActualCost) AS NonLabourActualCost,
            SUM(SunkCost) AS SunkCost,
            SUM(LabourRemainingUnits) AS LabourRemainingUnits,
            SUM(NonLabourRemainingUnits) AS NonLabourRemainingUnits,
            SUM(LabourRemainingCost) AS LabourRemainingCost,
            SUM(NonLabourRemainingCost) AS NonLabourRemainingCost,
            SUM(RemainingCost) AS RemainingCost
        FROM lvl6wbs
        GROUP BY SDQUID, RunID, wbs_name, wbs_code,
                 DeliverableType, Unit, DeliverableName, Direct, PhaseCode, DisciplineCode
    ),
    childwbs AS (
        SELECT DISTINCT 
            b.SDQUID,
            a.RunID,
            a.wbslvl6,
            a.activityid,
            COALESCE(d.LabourActualUnits,0)        AS LabourActualUnits,
            COALESCE(d.LabourActualCost,0)         AS LabourActualCost,
            COALESCE(d.NonLabourActualUnits,0)     AS NonLabourActualUnits,
            COALESCE(d.NonLabourActualCost,0)      AS NonLabourActualCost,
            COALESCE(d.SunkCost,0)                 AS SunkCost,
            COALESCE(d.LabourRemainingUnits,0)     AS LabourRemainingUnits,
            COALESCE(d.NonLabourRemainingUnits,0)  AS NonLabourRemainingUnits,
            COALESCE(d.LabourRemainingCost,0)      AS LabourRemainingCost,
            COALESCE(d.NonLabourRemainingCost,0)   AS NonLabourRemainingCost,
            COALESCE(d.RemainingCost,0)            AS RemainingCost,
            COALESCE(e.BLBudgetedCost,0)           AS BLBudgetedCost
        FROM stngetl.Budgeting_SDQ_P6 a
        JOIN stng.Budgeting_SDQP6Link b ON a.RunID = b.RunID AND b.Active = 1
        JOIN stngetl.Budgeting_SDQ_Run c ON b.RunID = c.RunID AND c.Legacy = 0
        LEFT JOIN stngetl.VV_Budgeting_P6_ActivityResource d 
            ON a.task_id = d.task_id AND a.RunID = d.runid AND d.Baseline = 0
        LEFT JOIN stngetl.VV_Budgeting_P6_ActivityResource e 
            ON a.BaselineTaskID = e.task_id AND a.RunID = e.runid AND e.Baseline = 1
        WHERE a.CV = 0 AND a.wbs_lvl > 6 AND a.RunID = @RunID
    ),
    childwbssum AS (
        SELECT 
            SDQUID,
            RunID,
            wbslvl6,
            SUM(LabourActualUnits) AS LabourActualUnits,
            SUM(LabourActualCost) AS LabourActualCost,
            SUM(NonLabourActualUnits) AS NonLabourActualUnits,
            SUM(NonLabourActualCost) AS NonLabourActualCost,
            SUM(SunkCost) AS SunkCost,
            SUM(LabourRemainingUnits) AS LabourRemainingUnits,
            SUM(NonLabourRemainingUnits) AS NonLabourRemainingUnits,
            SUM(LabourRemainingCost) AS LabourRemainingCost,
            SUM(NonLabourRemainingCost) AS NonLabourRemainingCost,
            SUM(RemainingCost) AS RemainingCost,
            SUM(BLBudgetedCost) AS BLBudgetedCost
        FROM childwbs
        GROUP BY SDQUID, RunID, wbslvl6
    ),

    initialquery AS (
        SELECT 
            a.SDQUID,
            a.RunID,
            a.wbs_name,
            a.wbs_code,
            a.DeliverableType,
            a.DeliverableName,
            a.unit,
            a.direct,
            a.phasecode,
            a.disciplinecode,
            a.CurrentStart,
            a.StartActualized,
            a.CurrentEnd,
            a.EndActualized,
            SUM(a.LabourActualUnits + COALESCE(b.LabourActualUnits,0)) AS LabourActualUnits,
            SUM(a.LabourActualCost + COALESCE(b.LabourActualCost,0)) AS LabourActualCost,
            SUM(a.NonLabourActualUnits + COALESCE(b.NonLabourActualUnits,0)) AS NonLabourActualUnits,
            SUM(a.NonLabourActualCost + COALESCE(b.NonLabourActualCost,0)) AS NonLabourActualCost,
            SUM(a.SunkCost + COALESCE(b.SunkCost,0)) AS SunkCost,
            SUM(a.LabourRemainingUnits + COALESCE(b.LabourRemainingUnits,0)) AS LabourRemainingUnits,
            SUM(a.NonLabourRemainingUnits + COALESCE(b.NonLabourRemainingUnits,0)) AS NonLabourRemainingUnits,
            SUM(a.LabourRemainingCost + COALESCE(b.LabourRemainingCost,0)) AS LabourRemainingCost,
            SUM(a.NonLabourRemainingCost + COALESCE(b.NonLabourRemainingCost,0)) AS NonLabourRemainingCost,
            SUM(a.RemainingCost + COALESCE(b.RemainingCost,0)) AS RemainingCost,
            SUM(COALESCE(b.BLBudgetedCost,0)) AS BLBudgetedCost
        FROM lvl6wbssum a
        LEFT JOIN childwbssum b 
            ON a.RunID = b.RunID AND a.wbs_code = b.wbslvl6
        GROUP BY a.SDQUID, a.RunID, a.wbs_name, a.wbs_code,
                 a.DeliverableType, a.DeliverableName, a.unit, a.direct,
                 a.phasecode, a.DisciplineCode,
                 a.CurrentStart, a.StartActualized, a.CurrentEnd, a.EndActualized
    )

    ------------------------------------------------------------
    -- 3. Insert refreshed rows
    ------------------------------------------------------------
    INSERT INTO stngetl.Budgeting_SDQ_P6_CVWBS_Materialized (
        UniqueRowID, SDQUID, RunID, wbs_name, wbs_code, DeliverableType, DeliverableName,
        unit, Direct, PhaseCode, DisciplineCode,
        CurrentStart, StartActualized, CurrentEnd, EndActualized,
        LabourActualUnits, LabourActualCost, NonLabourActualUnits, NonLabourActualCost,
        SunkCost, LabourRemainingUnits, NonLabourRemainingUnits,
        LabourRemainingCost, NonLabourRemainingCost, RemainingCost,
        BLBudgetedCost,
        Legacy
    )
    SELECT 
        NEWID(),
        SDQUID, RunID, wbs_name, wbs_code, DeliverableType, DeliverableName,
        unit, Direct, PhaseCode, DisciplineCode,
        CurrentStart, StartActualized, CurrentEnd, EndActualized,
        LabourActualUnits, LabourActualCost, NonLabourActualUnits, NonLabourActualCost,
        SunkCost, LabourRemainingUnits, NonLabourRemainingUnits,
        LabourRemainingCost, NonLabourRemainingCost, RemainingCost,
        BLBudgetedCost,
        0
    FROM initialquery;

END;
GO
