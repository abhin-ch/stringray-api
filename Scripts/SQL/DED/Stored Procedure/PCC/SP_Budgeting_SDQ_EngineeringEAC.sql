CREATE OR ALTER PROCEDURE [stng].[SP_Budgeting_SDQ_EngineeringEAC]
    @SDQUID BIGINT
AS
BEGIN
    SET NOCOUNT ON;
 
    IF EXISTS (
        SELECT 1
        FROM stng.Budgeting_SDQP6Link AS a
        INNER JOIN stngetl.Budgeting_SDQ_Run AS b ON a.RunID = b.RunID AND b.Legacy = 1
        WHERE a.SDQUID = @SDQUID AND a.Active = 1
    )
    BEGIN
        SELECT CDPhaseName, PGType, Cost
        FROM stng.Budgeting_SDQ_P6_Legacy_PDFChartData
        WHERE SDID = @SDQUID;
    END
    ELSE
    BEGIN
        WITH initialquery AS (
            SELECT a.*
            FROM stngetl.Budgeting_SDQ_P6 AS a
            INNER JOIN stng.Budgeting_SDQP6Link AS b ON a.RunID = b.RunID AND b.Active = 1
            WHERE b.SDQUID = @SDQUID AND a.PhaseCode IS NOT NULL
        ),
        secondquery AS (
            SELECT a.PhaseCode, b.SunkCost AS Cost, 'Actual' AS PGType
            FROM initialquery AS a
            INNER JOIN stngetl.Budgeting_SDQ_P6_ActivityResource_Materialized AS b 
                ON a.RunID = b.RunID AND a.task_id = b.TASK_ID
            WHERE b.Baseline = 0 AND b.SunkCost <> 0 AND a.CV = 0
 
            UNION ALL
 
            SELECT a.PhaseCode, b.RemainingCost AS Cost, 'Remaining Cost' AS PGType
            FROM initialquery AS a
            INNER JOIN stngetl.Budgeting_SDQ_P6_ActivityResource_Materialized AS b 
                ON a.RunID = b.RunID AND a.task_id = b.TASK_ID
            WHERE b.Baseline = 0 AND b.RemainingCost <> 0 AND a.CV = 0
 
            UNION ALL
 
            SELECT a.PhaseCode, b.RemainingCost AS Cost, 'Class V' AS PGType
            FROM initialquery AS a
            INNER JOIN stngetl.Budgeting_SDQ_P6_ActivityResource_Materialized AS b 
                ON a.RunID = b.RunID AND a.task_id = b.TASK_ID
            WHERE b.Baseline = 0 AND b.RemainingCost <> 0 AND a.CV = 1
 
            UNION ALL
 
            SELECT a.PhaseCode, b.BLBudgetedCost AS Cost, 'Baseline' AS PGType
            FROM initialquery AS a
            INNER JOIN stngetl.Budgeting_SDQ_P6_ActivityResource_Materialized AS b 
                ON a.RunID = b.RunID AND a.BaselineTaskID = b.TASK_ID
            WHERE b.Baseline = 1 AND b.BLBudgetedCost <> 0
        ),
        thirdquery AS (
            SELECT a.PhaseCode, b.PhaseDescShort, a.PGType, SUM(a.Cost) AS Cost
            FROM secondquery AS a
            INNER JOIN stng.Budgeting_SDQ_Phase AS b ON a.PhaseCode = b.Phase
            GROUP BY a.PhaseCode, b.PhaseDescShort, a.PGType
        ),
        eac AS (
            SELECT c.Phase AS PhaseCode, c.PhaseDescShort, 'EAC' AS PGType, a.EAC AS Cost
            FROM stngetl.VV_Budgeting_SDQ_P6_EAC_2 AS a
            INNER JOIN stng.Budgeting_SDQMain AS b ON a.SDQUID = b.SDQUID
            INNER JOIN stng.Budgeting_SDQ_Phase AS c ON b.Phase = c.SDQPhaseID
            WHERE a.SDQUID = @SDQUID
        )
 
        SELECT PhaseDescShort AS CDPhaseName, PGType, Cost
        FROM (
            SELECT PhaseDescShort, PGType, Cost FROM thirdquery
            UNION ALL
            SELECT PhaseDescShort, PGType, Cost FROM eac
        ) AS combined;
    END
END
