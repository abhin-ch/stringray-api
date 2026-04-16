/****** Object:  View [stng].[VV_Metric_Export]    Script Date: 12/3/2024 8:14:26 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER view [stng].[VV_Metric_Export] as
SELECT DISTINCT 
    a.UniqueID,
    a.MeasureName,
    a.Department,
    a.Section,
    variance.TargetForMonth AS MonthlyTarget,
    variance.TargetForMonth AS YTDTarget,
    
    CASE 
        WHEN MONTH(GETDATE()) = 1 THEN actuals_previous.[DecemberActual]
        WHEN MONTH(GETDATE()) = 2 THEN actuals_previous.[JanuaryActual]
        WHEN MONTH(GETDATE()) = 3 THEN actuals_previous.[FebruaryActual]
        WHEN MONTH(GETDATE()) = 4 THEN actuals_previous.[MarchActual]
        WHEN MONTH(GETDATE()) = 5 THEN actuals_previous.[AprilActual]
        WHEN MONTH(GETDATE()) = 6 THEN actuals_previous.[MayActual]
        WHEN MONTH(GETDATE()) = 7 THEN actuals_previous.[JuneActual]
        WHEN MONTH(GETDATE()) = 8 THEN actuals_previous.[JulyActual]
        WHEN MONTH(GETDATE()) = 9 THEN actuals_previous.[AugustActual]
        WHEN MONTH(GETDATE()) = 10 THEN actuals_previous.[SeptemberActual]
        WHEN MONTH(GETDATE()) = 11 THEN actuals_previous.[OctoberActual]
        WHEN MONTH(GETDATE()) = 12 THEN actuals_previous.[NovemberActual]
    END AS PreviousMonth,

    variance.ActualForMonth AS CurrentMonth,
    variance.MonthlyVariance,
    a.RAD,
    a.RAB,
    a.Deleted,
    a.DeletedBy,
    a.DeletedOn,
    a.Objective,
    a.Definition,
    a.RedCriteria,
    a.WhiteCriteria,
    a.GreenCriteria,
    a.YellowCriteria,
    a.Driver,
    a.DataSource,
    a.RedRecoveryDate,
    c.UniqueID AS Frequency,
    c.Frequency AS FrequencyC,
    d.UniqueID AS MeasureType,
    d.MeasureType AS MeasureTypeC,
    e.UniqueID AS KPICategorization,
    e.KPICategorization AS KPICategorizationC,
    f.UniqueID AS Unit,
    f.Unit AS UnitC,
    g.UniqueID AS Period,
    g.Period AS PeriodC,
    h.UniqueID AS MeasureCategory,
    h.MeasureCategory AS MeasureCategoryC,
    i.DataOwnerC,
    j.MetricOwnerC,
    criteria.RedCriteriaC,
    criteria.YellowCriteriaC,
    criteria.GreenCriteriaC,
    criteria.WhiteCriteriaC
FROM stng.Metric_Main AS a 
LEFT JOIN stng.Metric_Frequency AS c ON a.Frequency = c.UniqueID
LEFT JOIN stng.Metric_MeasureType AS d ON a.MeasureType = d.UniqueID
LEFT JOIN stng.Metric_KPICategorization AS e ON a.KPICategorization = e.UniqueID
LEFT JOIN stng.Metric_Unit AS f ON a.Unit = f.UniqueID
LEFT JOIN stng.Metric_Period AS g ON a.Period = g.UniqueID
LEFT JOIN stng.Metric_MeasureCategory AS h ON a.MeasureCategory = h.UniqueID
LEFT JOIN stng.VV_Metric_DataOwner AS i ON a.UniqueID = i.MetricID AND i.OwnershipTypeC = 'Primary'
LEFT JOIN stng.VV_Metric_MetricOwner AS j ON a.UniqueID = j.MetricID AND j.OwnershipTypeC = 'Primary'
LEFT JOIN (
    SELECT 
        MetricID,
        MAX(CASE WHEN Criteria = 'Red' THEN RedCriteriaC END) AS RedCriteriaC,
        MAX(CASE WHEN Criteria = 'Yellow' THEN YellowCriteriaC END) AS YellowCriteriaC,
        MAX(CASE WHEN Criteria = 'Green' THEN GreenCriteriaC END) AS GreenCriteriaC,
        MAX(CASE WHEN Criteria = 'White' THEN WhiteCriteriaC END) AS WhiteCriteriaC
    FROM stng.VV_Metric_Criteria
    GROUP BY MetricID
) AS criteria ON a.UniqueID = criteria.MetricID
LEFT JOIN stng.VV_Metric_DataInputs_Variance AS variance ON a.UniqueID = variance.MetricID
LEFT JOIN stng.VV_Metric_DataInputs_Actuals AS actuals_previous 
    ON a.UniqueID = actuals_previous.MetricID
WHERE a.Deleted = 0
GO


