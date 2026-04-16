CREATE OR ALTER VIEW [stngetl].[VV_Budgeting_SDQ_P6_CIISDS] AS
WITH legacy AS
(
    SELECT 
        a.SDQUID,
        b.RunID,
        a.wbs_code,
        a.WBSName AS wbs_name,
        a.deliverablename AS Deliverable,
        a.DeliverableType,
        a.Budget,
        a.RemainingLaborCost AS LabourRemainingCost,
        a.RemainingNonlaborCost AS NonLabourRemainingCost,
        a.Direct,
        a.Indirect,
        CASE WHEN a.Direct = 'Y' THEN a.Budget ELSE 0 END AS DirectBudget,
        CASE WHEN a.Indirect = 'Y' THEN a.Budget ELSE 0 END AS IndirectBudget,
        CASE WHEN ROCbySDSCode <> 'N/A' THEN TRY_CAST(ROCbySDSCode AS float) * 100 END AS RoC,
        CASE WHEN a.[Start] LIKE '%A' THEN LEFT(a.[Start], LEN(a.[Start]) - 2) ELSE REPLACE(a.[Start], '*', '') END AS CurrentStart,
        CASE WHEN a.[Start] LIKE '%A' THEN 1 ELSE 0 END AS StartActualized,
        CASE WHEN TRY_CONVERT(datetime2, a.[Finish]) IS NOT NULL THEN a.[Finish]
             WHEN a.[Finish] LIKE '%A' THEN LEFT(a.[Finish], LEN(a.[Finish]) - 2)
             ELSE REPLACE(a.[Finish], '*', '') END AS CurrentEnd,
        CASE WHEN a.[Finish] LIKE '%A' THEN 1 ELSE 0 END AS EndActualized,
        -- keep original SDS string so we can build SDSCode deterministically later
        a.SDSCode AS OrigSDSCode,
        SUBSTRING(a.SDSCode,1,1) AS SubPhaseCode,
        SUBSTRING(a.SDSCode,2,1) AS SDSDisciplineCode,
        CASE WHEN d.OverrideValue IS NOT NULL THEN TRY_CAST(d.OverrideValue AS int)
             ELSE TRY_CAST(SUBSTRING(a.SDSCode,3,2) AS int) END AS SDSWP,
        CASE WHEN d.OverrideValue IS NOT NULL
                  AND (SUBSTRING(a.SDSCode,1,1) IN ('1','2')
                       OR (SUBSTRING(a.SDSCode,1,1) = '4'
                           AND (TRY_CAST(d.OverrideValue AS int) IN (1,2)
                                OR TRY_CAST(d.OverrideValue AS int) BETWEEN 10 AND 29)))
             THEN '9'
             ELSE SUBSTRING(a.SDSCode,5,1) END AS SDSUnit
    FROM stng.VV_Budgeting_SDQ_P6_Legacy_ClassIISDS AS a
    INNER JOIN stng.Budgeting_SDQP6Link AS b ON a.SDQUID = b.SDQUID AND b.Active = 1
    INNER JOIN stngetl.Budgeting_SDQ_Run AS c ON b.RunID = c.RunID AND c.Legacy = 1
    LEFT JOIN stng.Budgeting_SDSWP_Override AS d ON d.RunID = c.RunID AND d.wbs_code = CAST(a.CDID AS varchar)
),
initialquery AS
(
    SELECT DISTINCT
        a.SDQUID,
        a.RunID,
        a.wbs_name,
        a.wbs_code,
        a.DeliverableName AS Deliverable,
        a.DeliverableType,
        a.RemainingCost AS Budget,
        a.LabourRemainingCost,
        a.NonLabourRemainingCost,
        a.Direct AS DirectBool,
        CASE WHEN a.Direct = 1 THEN 'Y' END AS Direct,
        CASE WHEN a.Direct = 0 THEN 'Y' END AS Indirect,
        CASE WHEN a.Direct = 1 THEN a.RemainingCost ELSE 0 END AS DirectBudget,
        CASE WHEN a.Direct = 0 THEN a.RemainingCost ELSE 0 END AS IndirectBudget,
        a.CurrentStart,
        a.StartActualized,
        a.CurrentEnd,
        a.EndActualized,
        COALESCE(b.OverrideValue,
                 CASE WHEN (a.Direct = 1 AND a.PhaseCode BETWEEN 0 AND 3)
                           OR (a.Direct = 0 AND a.PhaseCode IN (0,1)) THEN 1
                      ELSE a.PhaseCode END) AS SDSWP,
        CASE WHEN a.Direct = 0 THEN '4'
             WHEN a.PhaseCode IN (0,1) THEN '1'
             WHEN a.PhaseCode = 2 THEN '2'
             WHEN a.PhaseCode = 3 THEN '3'
             ELSE '4' END AS SubPhaseCode,
        a.DisciplineCode,
        a.PhaseCode,
        a.Unit
    FROM stngetl.VV_Budgeting_SDQ_P6_CIIDeliverable_MatView AS a
    LEFT JOIN stng.VV_Budgeting_SDSWP_Override AS b ON a.RunID = b.RunID AND a.wbs_code = b.wbs_code
    WHERE a.RemainingCost > 0 AND a.Legacy = 0 AND a.EndActualized = 0
),
secondquery AS
(
    SELECT iq.*,
        CASE WHEN SubPhaseCode = '1' OR (SubPhaseCode = '4' AND (SDSWP = 1 OR (SDSWP BETWEEN 10 AND 19))) THEN 'Conceptual Engineering (Development)'
             WHEN SubPhaseCode = '2' OR (SubPhaseCode = '4' AND (SDSWP = 2 OR (SDSWP BETWEEN 20 AND 29))) THEN 'Preliminary Engineering (Definition)'
             WHEN SubPhaseCode = '3' OR (SubPhaseCode = '4' AND (SDSWP = 3 OR (SDSWP BETWEEN 30 AND 39))) THEN 'Detailed Engineering (Preparation)'
             WHEN SubPhaseCode = '4' AND (SDSWP = 4 OR (SDSWP BETWEEN 40 AND 69)) THEN 'Engineering Execution Support (Execution/Turnover)'
             WHEN SubPhaseCode = '4' AND (SDSWP = 5 OR (SDSWP BETWEEN 70 AND 99)) THEN 'Design Closeout (Closeout)'
        END AS PhaseC,
        CASE WHEN DirectBool = 0 THEN '0'
             WHEN SubPhaseCode IN ('1','4') THEN '0'
             WHEN DisciplineCode IN (10,13,14) THEN '0'
             WHEN DisciplineCode IN (1,15) THEN '1'
             WHEN DisciplineCode = 12 THEN '8'
             WHEN DisciplineCode = 11 THEN '9'
             WHEN DisciplineCode BETWEEN 2 AND 7 THEN CAST(DisciplineCode AS varchar(10))
        END AS SDSDisciplineCode,
        CASE WHEN SubPhaseCode IN ('0','1','2') OR (SubPhaseCode = '4' AND SDSWP IN (1,2,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29)) THEN '9'
             WHEN Unit IN ('0','1','2','3','4','5','6','7','8','01','02','03','04','05','06','07','08') THEN CAST(CAST(Unit AS INT) AS VARCHAR)
             WHEN Unit IN ('09','9') AND SubPhaseCode NOT IN ('3','4') THEN '9'
             ELSE '0'
        END AS SDSUnit
    FROM initialquery iq
),
thirdquery AS
(
    SELECT *,
        -- deterministic SDSCode
        CONCAT(
            SubPhaseCode,
            SDSDisciplineCode,
            RIGHT('00' + CAST(ISNULL(SDSWP,0) AS varchar(3)), 2),
            SDSUnit
        ) AS SDSCode
    FROM secondquery
),
sdsbudget AS
(
    -- include SDQUID so predicate on SDQUID can be pushed into this aggregation
    SELECT
        SDQUID,
        RunID,
        -- same explicit SDSCode expression
        CONCAT(
            SubPhaseCode,
            SDSDisciplineCode,
            RIGHT('00' + CAST(ISNULL(SDSWP,0) AS varchar(3)), 2),
            SDSUnit
        ) AS SDSCode,
        SUM(Budget) AS Budget
    FROM secondquery
    WHERE DirectBool = 1
    GROUP BY SDQUID, RunID,
        CONCAT(
            SubPhaseCode,
            SDSDisciplineCode,
            RIGHT('00' + CAST(ISNULL(SDSWP,0) AS varchar(3)), 2),
            SDSUnit
        )
),
fourthquery AS
(
    SELECT x.*,
        CASE WHEN x.DirectBool = 1 AND x.SubPhaseCode NOT IN ('4','5')
             THEN (COALESCE(x.Budget,0) / NULLIF(COALESCE(y.Budget,0),0)) * 100
        END AS RoC
    FROM thirdquery x
    LEFT JOIN sdsbudget y
        ON x.SDQUID = y.SDQUID
       AND x.RunID  = y.RunID
       -- compare explicit expressions (avoid unresolved alias)
       AND CONCAT(
            x.SubPhaseCode,
            x.SDSDisciplineCode,
            RIGHT('00' + CAST(ISNULL(x.SDSWP,0) AS varchar(3)), 2),
            x.SDSUnit
           ) = y.SDSCode
),
unioned AS
(
    SELECT x.SDQUID, x.RunID, x.wbs_name, x.wbs_code, x.unit, x.SubPhaseCode, x.SDSWP, x.SDSUnit, x.SDSDisciplineCode, x.SDSCode, x.PhaseCode, x.PhaseC,
           x.LabourRemainingCost, x.NonLabourRemainingCost, x.Deliverable, x.DeliverableType,
           x.DisciplineCode, x.RoC, x.Budget, x.DirectBudget, x.IndirectBudget, x.CurrentStart, x.StartActualized, x.CurrentEnd, x.EndActualized, x.DirectBool, x.Direct, x.Indirect, 0 AS Legacy
    FROM fourthquery x

    UNION

    SELECT l.SDQUID, l.RunID, l.wbs_name, l.wbs_code, NULL AS unit, NULL AS SubPhaseCode, l.SDSWP, NULL AS SDSUnit, NULL AS SDSDisciplineCode,
           -- build SDSCode from the original SDS string present in legacy (OrigSDSCode)
           CONCAT(SUBSTRING(l.OrigSDSCode,1,1), SUBSTRING(l.OrigSDSCode,2,1), RIGHT('00' + CAST(ISNULL(l.SDSWP,0) AS varchar(3)),2), ISNULL(l.SDSUnit,'0')) AS SDSCode,
           NULL AS PhaseCode, NULL AS PhaseC, l.LabourRemainingCost, l.NonLabourRemainingCost, l.Deliverable, l.DeliverableType,
           NULL AS DisciplineCode, l.RoC, l.Budget, l.DirectBudget, l.IndirectBudget, l.CurrentStart, l.StartActualized, l.CurrentEnd, l.EndActualized, 0 AS DirectBool, l.Direct, l.Indirect, 1 AS Legacy
    FROM legacy l
)

SELECT *
FROM unioned;
GO


