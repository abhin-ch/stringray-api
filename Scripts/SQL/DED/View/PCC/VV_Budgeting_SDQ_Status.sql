ALTER VIEW [stng].[VV_Budgeting_SDQ_Status] AS

WITH recurse (ParentStatusID, StatusID, HasAutomaticCheck, UILabel) AS (
    -- Recursive CTE to fetch the status hierarchy
    SELECT 
        ParentStatusID, StatusID, HasAutomaticCheck, UILabel
    FROM stng.Budgeting_SDQ_NextStatus
    WHERE 
        Reversible = 0 
        AND Loopback = 0 
        AND ParentStatusID IS NULL 
        AND Active = 1
 
    UNION ALL
 
    SELECT 
        a.ParentStatusID, a.StatusID, a.HasAutomaticCheck, a.UILabel
    FROM stng.Budgeting_SDQ_NextStatus AS a
    INNER JOIN recurse AS b ON a.ParentStatusID = b.StatusID
    WHERE 
        a.Reversible = 0 
        AND a.Loopback = 0 
        AND a.Active = 1
),
 
initialquery AS (
    -- Fetch parent-child status relationships from the recursive CTE
    SELECT 
        a.ParentStatusID, 
        b.SDQStatus AS ParentStatus, 
        b.SDQStatusLong AS ParentStatusLong,
        a.StatusID, 
        c.SDQStatus AS [Status], 
        c.SDQStatusLong AS StatusLong, 
        a.HasAutomaticCheck, 
        a.UILabel
    FROM 
        recurse AS a
    LEFT JOIN stng.Budgeting_SDQ_Status AS b ON a.ParentStatusID = b.SDQStatusID
    INNER JOIN stng.Budgeting_SDQ_Status AS c ON a.StatusID = c.SDQStatusID
 
    UNION
 
    -- Handle reversible statuses
    SELECT 
        a.ParentStatusID, 
        b.SDQStatus AS ParentStatus, 
        b.SDQStatusLong AS ParentStatusLong,
        a.StatusID, 
        c.SDQStatus AS [Status], 
        c.SDQStatusLong AS StatusLong, 
        a.HasAutomaticCheck, 
        a.UILabel
    FROM stng.Budgeting_SDQ_NextStatus AS a
    LEFT JOIN stng.Budgeting_SDQ_Status AS b ON a.ParentStatusID = b.SDQStatusID
    INNER JOIN stng.Budgeting_SDQ_Status AS c ON a.StatusID = c.SDQStatusID
    WHERE 
        a.Reversible = 1 
        AND a.Active = 1
 
    UNION
 
    -- Handle reverse parent-child relationship for reversible statuses
    SELECT 
        a.StatusID AS ParentStatusID, 
        b.SDQStatus AS ParentStatus, 
        b.SDQStatusLong AS ParentStatusLong,
        a.ParentStatusID AS StatusID, 
        c.SDQStatus AS [Status], 
        c.SDQStatusLong AS StatusLong, 
        a.HasAutomaticCheck, 
        NULL AS UILabel
    FROM stng.Budgeting_SDQ_NextStatus AS a
    INNER JOIN stng.Budgeting_SDQ_Status AS b ON a.StatusID = b.SDQStatusID
    LEFT JOIN stng.Budgeting_SDQ_Status AS c ON a.ParentStatusID = c.SDQStatusID
    WHERE 
        a.Reversible = 1 
        AND a.Active = 1
 
    UNION
 
    -- Handle loopback statuses
    SELECT 
        a.ParentStatusID, 
        b.SDQStatus AS ParentStatus, 
        b.SDQStatusLong AS ParentStatusLong,
        a.StatusID, 
        c.SDQStatus AS [Status], 
        c.SDQStatusLong AS StatusLong, 
        a.HasAutomaticCheck, 
        a.UILabel
    FROM stng.Budgeting_SDQ_NextStatus AS a
    LEFT JOIN stng.Budgeting_SDQ_Status AS b ON a.ParentStatusID = b.SDQStatusID
    INNER JOIN stng.Budgeting_SDQ_Status AS c ON a.StatusID = c.SDQStatusID
    WHERE 
        a.Loopback = 1 
        AND a.Active = 1
)
 
-- Final selection with conditional UILabel formatting
SELECT 
    ParentStatusID, 
    ParentStatus, 
    ParentStatusLong, 
    StatusID, 
    [Status],
    CASE 
        WHEN UILabel IS NOT NULL THEN UILabel 
        ELSE CONCAT('Route to ', StatusLong) 
    END AS StatusLong, 
    HasAutomaticCheck
FROM 
    initialquery;