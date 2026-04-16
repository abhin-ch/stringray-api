CREATE OR ALTER function [stngetl].[FN_Budgeting_SDQ_P6_LAMPSummary]
(
    @SDQUID bigint
)
RETURNS @tbl TABLE
(
    Revision varchar(100),
    CPVClass varchar(100),
    [1 (2016-2018)] int,
    [2 (2019-2021)] int,
    [3 (2022-2024)] int,
    [4 (2025-2027)] int,
    [5 (2028-2030)] int,
    [6 (2031-2033)] int,
    [7 (2034-2036)] int,
    [8 (2037-2039)] int,
    [9 (2040-2042)] int,
    Total int
)
BEGIN

    -- Check if the linked schedule is legacy
    IF EXISTS
    (
        SELECT *
        FROM stngetl.Budgeting_SDQ_Run AS a
        INNER JOIN stng.Budgeting_SDQP6Link AS b ON a.RunID = b.RunID
        WHERE b.SDQUID = @SDQUID AND a.Legacy = 1
    )
    BEGIN
        -- Legacy Data Logic
        INSERT INTO @tbl
        (Revision, CPVClass, [1 (2016-2018)], [2 (2019-2021)], [3 (2022-2024)], [4 (2025-2027)], [5 (2028-2030)], [6 (2031-2033)], [7 (2034-2036)], [8 (2037-2039)], [9 (2040-2042)], Total)
        SELECT
            a.SDQRevision,
            a.CPVClass,
            a.[1_2016_2018],
            a.[2_2019_2021],
            a.[3_2022_2024],
            a.[4_2025_2027],
            a.[5_2028_2030],
            a.[6_2031_2033],
            a.[7_2034_2036],
            NULL,
            NULL,
            a.Total
        FROM stng.VV_Budgeting_SDQ_P6_Legacy_SDSSummary_LAMP AS a
        WHERE a.SDQUID = @SDQUID
    END
    ELSE
    BEGIN
        -- Non-Legacy Data Logic: Select non-legacy data and union the latest available legacy data from the same project
        DECLARE @NonLegacyData TABLE
        (
            Revision varchar(100),
            CPVClass varchar(100),
            [1 (2016-2018)] int,
            [2 (2019-2021)] int,
            [3 (2022-2024)] int,
            [4 (2025-2027)] int,
            [5 (2028-2030)] int,
            [6 (2031-2033)] int,
            [7 (2034-2036)] int,
            [8 (2037-2039)] int,
            [9 (2040-2042)] int,
            Total int
        );

        -- 1. Select the current non-legacy data into the temporary table
        INSERT INTO @NonLegacyData
        (Revision, CPVClass, [1 (2016-2018)], [2 (2019-2021)], [3 (2022-2024)], [4 (2025-2027)], [5 (2028-2030)], [6 (2031-2033)], [7 (2034-2036)], [8 (2037-2039)], [9 (2040-2042)], Total)
        SELECT
            a.Revision,
            a.CPVClass,
            a.[1 (2016-2018)],
            a.[2 (2019-2021)],
            a.[3 (2022-2024)],
            a.[4 (2025-2027)],
            a.[5 (2028-2030)],
            a.[6 (2031-2033)],
            a.[7 (2034-2036)],
            a.[8 (2037-2039)],
            a.[9 (2040-2042)],
            a.Total
        FROM [stngetl].[VV_Budgeting_SDQ_P6_LAMPSummary] AS a
        WHERE a.SDQUID = @SDQUID;

        -- Insert first half into the final @tbl
        INSERT INTO @tbl
        SELECT * FROM @NonLegacyData;

        -- 2. Select the latest legacy data from the same project, if available.
        --    AND excludes revisions already present in @NonLegacyData.
        INSERT INTO @tbl
        (Revision, CPVClass, [1 (2016-2018)], [2 (2019-2021)], [3 (2022-2024)], [4 (2025-2027)], [5 (2028-2030)], [6 (2031-2033)], [7 (2034-2036)], [8 (2037-2039)], [9 (2040-2042)], Total)
        SELECT
            lgcy.SDQRevision,
            lgcy.CPVClass,
            lgcy.[1_2016_2018],
            lgcy.[2_2019_2021],
            lgcy.[3_2022_2024],
            lgcy.[4_2025_2027],
            lgcy.[5_2028_2030],
            lgcy.[6_2031_2033],
            lgcy.[7_2034_2036],
            NULL,
            NULL,
            lgcy.Total
        FROM stng.VV_Budgeting_SDQ_P6_Legacy_SDSSummary_LAMP AS lgcy
        WHERE lgcy.SDQUID = (
            -- Subquery to find the UniqueID of the single, latest eligible legacy revision on the same project
            SELECT TOP 1
                legacy_main.[RecordTypeUniqueID]
            FROM
                [stng].[VV_Budgeting_SDQMain] AS current_main
            INNER JOIN
                [stng].[VV_Budgeting_SDQMain] AS legacy_main ON current_main.ProjectNo = legacy_main.ProjectNo
            INNER JOIN
                stng.Budgeting_SDQP6Link AS legacy_link ON legacy_main.[RecordTypeUniqueID] = legacy_link.SDQUID
            INNER JOIN
                stngetl.Budgeting_SDQ_Run AS legacy_run ON legacy_link.RunID = legacy_run.RunID
            WHERE
                current_main.[RecordTypeUniqueID] = @SDQUID -- Anchor to the current non-legacy item
                AND legacy_run.Legacy = 1      -- Filter to only include legacy items
                AND legacy_main.StatusValue != 'CANC'
            ORDER BY TRY_CAST(legacy_main.Revision AS decimal(10, 2)) DESC
        )
        AND NOT EXISTS (
            SELECT 1
            FROM @NonLegacyData AS nld
            WHERE TRY_CAST(nld.Revision AS decimal(10, 2)) = TRY_CAST(lgcy.SDQRevision AS decimal(10, 2))
        );
    END

    RETURN;
END