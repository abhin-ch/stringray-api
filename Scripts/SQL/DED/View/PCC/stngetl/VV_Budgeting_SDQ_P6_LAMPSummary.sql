CREATE OR ALTER VIEW [stngetl].[VV_Budgeting_SDQ_P6_LAMPSummary] AS
-- Static CTEs for date ranges and class definitions
WITH dateranges AS (
    SELECT * FROM (VALUES
        (2016, 2018, '1 (2016-2018)'), (2019, 2021, '2 (2019-2021)'),
        (2022, 2024, '3 (2022-2024)'), (2025, 2027, '4 (2025-2027)'),
        (2028, 2030, '5 (2028-2030)'), (2031, 2033, '6 (2031-2033)'), 
        (2034, 2036, '7 (2034-2036)'), (2037, 2039, '8 (2037-2039)'),
	(2040, 2042, '9 (2040-2042)')
    ) AS x(MinYear, MaxYear, DateRange)
),
cpvclasses AS (
    SELECT * FROM (VALUES
        (1, 'Sunk Cost'), (2, 'Class II'),
        (3, 'Class V'),   (4, 'Total')
    ) AS x(CPVClassOrder, CPVClass)
),
-- Step 1: Calculate all base amounts from source tables
base_amounts AS (
    -- Sunk Cost
    SELECT
        b.SDQUID,
        dr.DateRange,
        'Sunk Cost' AS CPVClass,
        SUM(COALESCE(b.SunkCost, 0)) AS Amt
    FROM dateranges AS dr
    JOIN stngetl.VV_Budgeting_SDQ_P6_CIIDeliverable_MatView AS b
        ON b.CurrentStart >= DATEFROMPARTS(dr.MinYear, 1, 1) AND b.CurrentEnd < DATEFROMPARTS(dr.MaxYear + 1, 1, 1)
    GROUP BY b.SDQUID, dr.DateRange

    UNION ALL

    -- Class II (from CII view)
    SELECT
        b.SDQUID,
        dr.DateRange,
        'Class II' AS CPVClass,
        SUM(COALESCE(b.Forecast, 0)) AS Amt
    FROM dateranges AS dr
    JOIN stngetl.VV_Budgeting_SDQ_P6_TotalForecast_CII AS b
        ON b.FirstOfMonth >= DATEFROMPARTS(dr.MinYear, 1, 1) AND b.FirstOfMonth < DATEFROMPARTS(dr.MaxYear + 1, 1, 1)
    GROUP BY b.SDQUID, dr.DateRange

    UNION ALL

    -- Class V (from CV view)
    SELECT
        b.SDQUID,
        dr.DateRange,
        'Class V' AS CPVClass,
        SUM(COALESCE(b.Forecast, 0)) AS Amt
    FROM dateranges AS dr
    JOIN stngetl.VV_Budgeting_SDQ_P6_TotalForecast_CV AS b
        ON b.FirstOfMonth >= DATEFROMPARTS(dr.MinYear, 1, 1) AND b.FirstOfMonth < DATEFROMPARTS(dr.MaxYear + 1, 1, 1)
    GROUP BY b.SDQUID, dr.DateRange
),
-- Step 2: Add the 'Total' calculation
amounts_with_total AS (
    SELECT SDQUID, DateRange, CPVClass, Amt FROM base_amounts
    UNION ALL
    SELECT SDQUID, DateRange, 'Total' AS CPVClass, SUM(Amt) AS Amt
    FROM base_amounts
    GROUP BY SDQUID, DateRange
),
-- Step 3: Identify relationships between current and previous revisions
revision_links AS (
    SELECT
        current_rev.RecordTypeUniqueID AS ParentSDQUID,
        prev_rev.RecordTypeUniqueID AS ChildSDQUID
    FROM stng.VV_Budgeting_SDQMain AS current_rev
    JOIN stng.VV_Budgeting_SDQMain AS prev_rev ON current_rev.ProjectNo = prev_rev.ProjectNo
        AND (current_rev.Phase > prev_rev.Phase OR (current_rev.Phase = prev_rev.Phase AND current_rev.SubRevision > prev_rev.SubRevision))
    WHERE prev_rev.StatusValue IN ('APRE', 'AFRE')
),
-- Step 4: Aggregate amounts from previous revisions and attribute them to the parent SDQUID
previous_revs_summary AS (
    SELECT
        rl.ParentSDQUID,
        a.DateRange,
        a.CPVClass,
        SUM(a.Amt) AS PrevRevsAmt
    FROM revision_links rl
    JOIN amounts_with_total a ON rl.ChildSDQUID = a.SDQUID
    GROUP BY rl.ParentSDQUID, a.DateRange, a.CPVClass
),
-- Step 5: Create a final unpivoted dataset by combining current amounts with previous revision amounts
final_unpivoted_data AS (
    SELECT
        m.RecordTypeUniqueID AS SDQUID,
        m.Phase,
        m.SubRevision,
        m.Revision,
        cv.CPVClass,
        cv.CPVClassOrder,
        dr.DateRange,
        COALESCE(a.Amt, 0) + COALESCE(p.PrevRevsAmt, 0) AS TotalAmt
    FROM stng.VV_Budgeting_SDQMain m
    CROSS JOIN cpvclasses cv
    CROSS JOIN dateranges dr
    LEFT JOIN amounts_with_total a ON m.RecordTypeUniqueID = a.SDQUID AND cv.CPVClass = a.CPVClass AND dr.DateRange = a.DateRange
    LEFT JOIN previous_revs_summary p ON m.RecordTypeUniqueID = p.ParentSDQUID AND cv.CPVClass = p.CPVClass AND dr.DateRange = p.DateRange
)
-- Step 6: PIVOT the final data to create the specified columns
SELECT
    CPVClassOrder, CPVClass, SDQUID, Phase, SubRevision, Revision,
    ISNULL([1 (2016-2018)], 0) AS [1 (2016-2018)],
    ISNULL([2 (2019-2021)], 0) AS [2 (2019-2021)],
    ISNULL([3 (2022-2024)], 0) AS [3 (2022-2024)],
    ISNULL([4 (2025-2027)], 0) AS [4 (2025-2027)],
    ISNULL([5 (2028-2030)], 0) AS [5 (2028-2030)],
    ISNULL([6 (2031-2033)], 0) AS [6 (2031-2033)],
    ISNULL([7 (2034-2036)], 0) AS [7 (2034-2036)],
	ISNULL([8 (2037-2039)], 0) AS [8 (2037-2039)],
	ISNULL([9 (2040-2042)], 0) AS [9 (2040-2042)],
    (ISNULL([1 (2016-2018)], 0) + ISNULL([2 (2019-2021)], 0) + ISNULL([3 (2022-2024)], 0) +
     ISNULL([4 (2025-2027)], 0) + ISNULL([5 (2028-2030)], 0) + ISNULL([6 (2031-2033)], 0) +
     ISNULL([7 (2034-2036)], 0) + ISNULL([8 (2037-2039)], 0) + ISNULL([9 (2040-2042)], 0)) AS Total
FROM (
    SELECT CPVClassOrder, CPVClass, SDQUID, Phase, SubRevision, Revision, DateRange, TotalAmt
    FROM final_unpivoted_data
) AS source_data
PIVOT (
    SUM(TotalAmt)
    FOR DateRange IN ([1 (2016-2018)], [2 (2019-2021)], [3 (2022-2024)], [4 (2025-2027)], [5 (2028-2030)], [6 (2031-2033)], [7 (2034-2036)], [8 (2037-2039)], [9 (2040-2042)])
) AS pvt
GO

