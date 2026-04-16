/****** Object:  View [stng].[VV_Metric_Main]    Script Date: 1/13/2026 12:27:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






















ALTER VIEW [stng].[VV_Metric_Main]
AS

with OversightArea as (
SELECT [MetricID]
      ,string_agg(b.OversightArea, '; ') as OversightAreas
	  FROM [stng].[Metric_OversightArea_Map] as a
 inner join stng.Metric_OversightArea as b on a.OversightArea = b.UniqueID and b.Deleted = 0
 group by MetricID
 )

SELECT DISTINCT 
    a.UniqueID,
    a.MeasureName,
    a.Department,
	k.Department as DepartmentC,
    a.Section,
	l.Section as SectionC,
    a.RAD,
    a.RAB,
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
    a.Unit AS Unit,
    f.Unit AS UnitC,
    g.UniqueID AS Period,
    g.Period AS PeriodC,
    h.UniqueID AS MeasureCategory,
    h.MeasureCategory AS MeasureCategoryC,
	i.DataOwner,
    i.DataOwnerC,
	j.MetricOwner,
    j.MetricOwnerC,
    criteria.RedCriteriaC,
    criteria.YellowCriteriaC,
    criteria.GreenCriteriaC,
    criteria.WhiteCriteriaC,
	n.OversightAreas,
	a.ParentMeasure,
	o.MeasureName as ParentMeasureName,
	a.TargetPercent,
	a.YTDTargetPercent,
	a.ActiveStatus,
	p.ActiveStatus as ActiveStatusC,
	a.Archived
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
LEFT JOIN [stng].[Metric_Department] AS k ON a.Department = k.UniqueID
LEFT JOIN [stng].[Metric_Section] AS l ON a.Section = l.UniqueID
LEFT JOIN OversightArea as n on a.UniqueID = n.MetricID
LEFT JOIN [stng].[Metric_Main] as o on a.ParentMeasure = o.UniqueID
LEFT JOIN [stng].[Metric_ActiveStatus] as p on a.[ActiveStatus] = p.UniqueID
WHERE a.Deleted = 0
--and a.Archived = 0;
GO


