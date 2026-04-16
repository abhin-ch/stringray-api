/****** Object:  View [stng].[VV_Metric_DataInputs_Variance]    Script Date: 10/25/2024 8:18:47 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [stng].[VV_Metric_DataInputs_Variance] AS
WITH LatestTargets AS (
    SELECT 
        t.[MeasureInfoID],
        t.[MetricID],
        t.[JanuaryTarget],
        t.[FebruaryTarget],
        t.[MarchTarget],
        t.[AprilTarget],
        t.[MayTarget],
        t.[JuneTarget],
        t.[JulyTarget],
        t.[AugustTarget],
        t.[SeptemberTarget],
        t.[OctoberTarget],
        t.[NovemberTarget],
        t.[DecemberTarget],
        t.[RAD],
        t.[RAB],
        t.[RABc],
        t.[Deleted],
        t.[DeletedBy],
        t.[DeletedOn],
        ROW_NUMBER() OVER (PARTITION BY t.[MetricID], MONTH(t.[RAD]) ORDER BY t.[RAD] DESC) AS TargetRank
    FROM stng.[VV_Metric_DataInputs_Targets] t
    WHERE t.[Deleted] = 0
),
LatestActuals AS (
    SELECT 
        a.[MeasureInfoID],
        a.[MetricID],
        a.[JanuaryActual],
        a.[FebruaryActual],
        a.[MarchActual],
        a.[AprilActual],
        a.[MayActual],
        a.[JuneActual],
        a.[JulyActual],
        a.[AugustActual],
        a.[SeptemberActual],
        a.[OctoberActual],
        a.[NovemberActual],
        a.[DecemberActual],
        a.[RAD],
        a.[RAB],
        a.[RABc],
        a.[Deleted],
        a.[DeletedBy],
        a.[DeletedOn],
        ROW_NUMBER() OVER (PARTITION BY a.[MetricID], MONTH(a.[RAD]) ORDER BY a.[RAD] DESC) AS ActualRank
    FROM stng.[VV_Metric_DataInputs_Actuals] a
    WHERE a.[Deleted] = 0
)

SELECT 
    t.[MeasureInfoID],
    t.[MetricID],
    CASE 
        WHEN MONTH(t.[RAD]) = 1 THEN t.[JanuaryTarget]
        WHEN MONTH(t.[RAD]) = 2 THEN t.[FebruaryTarget]
        WHEN MONTH(t.[RAD]) = 3 THEN t.[MarchTarget]
        WHEN MONTH(t.[RAD]) = 4 THEN t.[AprilTarget]
        WHEN MONTH(t.[RAD]) = 5 THEN t.[MayTarget]
        WHEN MONTH(t.[RAD]) = 6 THEN t.[JuneTarget]
        WHEN MONTH(t.[RAD]) = 7 THEN t.[JulyTarget]
        WHEN MONTH(t.[RAD]) = 8 THEN t.[AugustTarget]
        WHEN MONTH(t.[RAD]) = 9 THEN t.[SeptemberTarget]
        WHEN MONTH(t.[RAD]) = 10 THEN t.[OctoberTarget]
        WHEN MONTH(t.[RAD]) = 11 THEN t.[NovemberTarget]
        WHEN MONTH(t.[RAD]) = 12 THEN t.[DecemberTarget]
    END AS TargetForMonth,
    
    CASE 
        WHEN MONTH(a.[RAD]) = 1 THEN a.[JanuaryActual]
        WHEN MONTH(a.[RAD]) = 2 THEN a.[FebruaryActual]
        WHEN MONTH(a.[RAD]) = 3 THEN a.[MarchActual]
        WHEN MONTH(a.[RAD]) = 4 THEN a.[AprilActual]
        WHEN MONTH(a.[RAD]) = 5 THEN a.[MayActual]
        WHEN MONTH(a.[RAD]) = 6 THEN a.[JuneActual]
        WHEN MONTH(a.[RAD]) = 7 THEN a.[JulyActual]
        WHEN MONTH(a.[RAD]) = 8 THEN a.[AugustActual]
        WHEN MONTH(a.[RAD]) = 9 THEN a.[SeptemberActual]
        WHEN MONTH(a.[RAD]) = 10 THEN a.[OctoberActual]
        WHEN MONTH(a.[RAD]) = 11 THEN a.[NovemberActual]
        WHEN MONTH(a.[RAD]) = 12 THEN a.[DecemberActual]
    END AS ActualForMonth,
    
    ABS(CASE 
        WHEN MONTH(t.[RAD]) = MONTH(a.[RAD]) THEN 
            (CASE 
                WHEN MONTH(t.[RAD]) = 1 THEN t.[JanuaryTarget] - a.[JanuaryActual]
                WHEN MONTH(t.[RAD]) = 2 THEN t.[FebruaryTarget] - a.[FebruaryActual]
                WHEN MONTH(t.[RAD]) = 3 THEN t.[MarchTarget] - a.[MarchActual]
                WHEN MONTH(t.[RAD]) = 4 THEN t.[AprilTarget] - a.[AprilActual]
                WHEN MONTH(t.[RAD]) = 5 THEN t.[MayTarget] - a.[MayActual]
                WHEN MONTH(t.[RAD]) = 6 THEN t.[JuneTarget] - a.[JuneActual]
                WHEN MONTH(t.[RAD]) = 7 THEN t.[JulyTarget] - a.[JulyActual]
                WHEN MONTH(t.[RAD]) = 8 THEN t.[AugustTarget] - a.[AugustActual]
                WHEN MONTH(t.[RAD]) = 9 THEN t.[SeptemberTarget] - a.[SeptemberActual]
                WHEN MONTH(t.[RAD]) = 10 THEN t.[OctoberTarget] - a.[OctoberActual]
                WHEN MONTH(t.[RAD]) = 11 THEN t.[NovemberTarget] - a.[NovemberActual]
                WHEN MONTH(t.[RAD]) = 12 THEN t.[DecemberTarget] - a.[DecemberActual]
            END)
        ELSE 0 
    END) AS MonthlyVariance,
    
    t.[RAD],
    t.[RAB],
    t.[RABc],
    t.[Deleted],
    t.[DeletedBy],
    t.[DeletedOn]
FROM LatestTargets t
JOIN LatestActuals a ON t.[MetricID] = a.[MetricID] 
AND MONTH(t.[RAD]) = MONTH(a.[RAD])
WHERE t.TargetRank = 1 AND a.ActualRank = 1
--ORDER BY t.[RAD] DESC;
GO


