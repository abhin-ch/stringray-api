CREATE VIEW [stng].[VV_Metric_Criteria]
AS
SELECT DISTINCT 
    a.UniqueID,
    a.MetricID,
    a.Criteria,
    a.Value1,
    a.Value2,
    a.RAD,
    a.RAB,
    a.LUB,
    a.LUD,
    c.UniqueID as Operator1,
    c.Operator as Operator1C,
    d.UniqueID as Operator2,
    d.Operator as Operator2C,

    RedCriteriaC = 
        CASE 
            WHEN a.Criteria = 'Red' THEN 
                ISNULL(CAST(c.Operator AS NVARCHAR(50)), '') + ' ' + CAST(a.Value1 AS NVARCHAR(50)) + 
                CASE 
                    WHEN a.Value2 IS NOT NULL AND d.Operator IS NOT NULL 
                    THEN ' ' + CAST(d.Operator AS NVARCHAR(50)) + ' ' + CAST(a.Value2 AS NVARCHAR(50))
                    ELSE ''
                END
            ELSE NULL
        END,

    YellowCriteriaC = 
        CASE 
            WHEN a.Criteria = 'Yellow' THEN 
                ISNULL(CAST(c.Operator AS NVARCHAR(50)), '') + ' ' + CAST(a.Value1 AS NVARCHAR(50)) + 
                CASE 
                    WHEN a.Value2 IS NOT NULL AND d.Operator IS NOT NULL 
                    THEN ' ' + CAST(d.Operator AS NVARCHAR(50)) + ' ' + CAST(a.Value2 AS NVARCHAR(50))
                    ELSE ''
                END
            ELSE NULL
        END,

    GreenCriteriaC = 
        CASE 
            WHEN a.Criteria = 'Green' THEN 
                ISNULL(CAST(c.Operator AS NVARCHAR(50)), '') + ' ' + CAST(a.Value1 AS NVARCHAR(50)) + 
                CASE 
                    WHEN a.Value2 IS NOT NULL AND d.Operator IS NOT NULL 
                    THEN ' ' + CAST(d.Operator AS NVARCHAR(50)) + ' ' + CAST(a.Value2 AS NVARCHAR(50))
                    ELSE ''
                END
            ELSE NULL
        END,

    WhiteCriteriaC = 
        CASE 
            WHEN a.Criteria = 'White' THEN 
                ISNULL(CAST(c.Operator AS NVARCHAR(50)), '') + ' ' + CAST(a.Value1 AS NVARCHAR(50)) + 
                CASE 
                    WHEN a.Value2 IS NOT NULL AND d.Operator IS NOT NULL 
                    THEN ' ' + CAST(d.Operator AS NVARCHAR(50)) + ' ' + CAST(a.Value2 AS NVARCHAR(50))
                    ELSE ''
                END
            ELSE NULL
        END

FROM stng.Metric_Criteria AS a 
LEFT JOIN stng.Metric_CriteriaOperators AS c ON a.Operator1 = c.UniqueID
LEFT JOIN stng.Metric_CriteriaOperators AS d ON a.Operator2 = d.UniqueID
where a.Deleted = 0
GO