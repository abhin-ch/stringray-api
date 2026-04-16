CREATE OR ALTER VIEW [stng].[VV_TOQ_ClassVSummary]
AS 


WITH ClassVHour AS (
    SELECT 
        cv.ClassVMainUniqueID,
        SUM(
            CASE 
                WHEN r.Value = '1' THEN cv.InternalHour 
                WHEN r.Value = '2' THEN cv.ExternalHour
                ELSE 0 
            END * 
            CASE 
                WHEN c.Value = '1' THEN 0.5
                WHEN c.Value = '2' THEN 1
                WHEN c.Value = '3' THEN 1.3
                ELSE 0
            END * COALESCE(cv.Qty, 0)
        ) AS TotalEstHour
    FROM stng.TOQ_ClassV cv
    INNER JOIN stng.VV_TOQ_Common r ON r.UniqueID = cv.[Resource]
    INNER JOIN stng.VV_TOQ_Common c ON c.UniqueID = cv.Complexity
    WHERE cv.Qty IS NOT NULL
    GROUP BY cv.ClassVMainUniqueID
),
ProjectMangMulti AS (
    SELECT 
		Main.UniqueID,
		ComplexityInfo.Label AS Complexity,
		CASE 
			WHEN ComplexityInfo.Value = '1' THEN Main.PMLowPCT
			WHEN ComplexityInfo.Value = '2' THEN Main.PMMediumPCT
			WHEN ComplexityInfo.Value = '3' THEN Main.PMHighPCT
			ELSE 0
		END AS PMPercent,
		CASE 
			WHEN ComplexityInfo.Value = '1' THEN Main.ComplexityLowMultiplier
			WHEN ComplexityInfo.Value = '2' THEN Main.ComplexityMediumMultiplier
			WHEN ComplexityInfo.Value = '3' THEN Main.ComplexityHighMultiplier
			ELSE 0
		END AS Multiplier
	FROM stng.TOQ_ClassVMain Main
	INNER JOIN stng.TOQ_ClassV ClassV ON Main.UniqueID = ClassV.ClassVMainUniqueID
	INNER JOIN stng.TOQ_ClassVTemplate Template ON Template.UniqueID = ClassV.ClassVTemplateUniqueID
	INNER JOIN stng.VV_TOQ_Common WBSDetail ON WBSDetail.UniqueID = Template.WBSDetailID AND WBSDetail.Value = '112' -- Filter Project Management Complexity
	INNER JOIN stng.VV_TOQ_Common ComplexityInfo ON ComplexityInfo.UniqueID = ClassV.Complexity
)
SELECT 
    M.UniqueID,
    M.ContingencyPCT,
    M.Rate,
    M.PMPCRate,
    M.ProjectControlPCT,
    Ch.TotalEstHour,
    P.Complexity AS PMComplexity,
    P.PMPercent,
    P.Multiplier,
    PMHour = ROUND(Ch.TotalEstHour * (P.PMPercent/100.00), 0),
    PMPCHour = ROUND((M.ProjectControlPCT/100.00) * ROUND(Ch.TotalEstHour * (P.PMPercent/100.00), 0), 0),
    TotalHour = Ch.TotalEstHour + 
                ROUND(Ch.TotalEstHour * (P.PMPercent/100.00), 0) + 
                ROUND((M.ProjectControlPCT/100.00) * ROUND(Ch.TotalEstHour * (P.PMPercent/100.00), 0), 0),
    TotalHourContingency = (Ch.TotalEstHour + 
                           ROUND(Ch.TotalEstHour * (P.PMPercent/100.00), 0) + 
                           ROUND((M.ProjectControlPCT/100.00) * ROUND(Ch.TotalEstHour * (P.PMPercent/100.00), 0), 0)) * 
                           (1 + (CAST(M.ContingencyPCT AS REAL)/100)),
    ROUND(
        ((1 + (M.ContingencyPCT / 100.0)) * Ch.TotalEstHour * 
        (ROUND(M.Rate, 0) + P.PMPercent/100.00 * (1 + (M.ProjectControlPCT/100.00)) * M.PMPCRate)),
        0
    ) AS ClassVTotalAmount,
    TOQ.TMID,
    TOQ.UniqueID AS TOQMainID
FROM stng.TOQ_ClassVMain M 
INNER JOIN ClassVHour Ch ON Ch.ClassVMainUniqueID = M.UniqueID
INNER JOIN ProjectMangMulti P ON P.UniqueID = M.UniqueID
LEFT JOIN stng.TOQ_Main TOQ ON TOQ.ClassVUniqueID = M.UniqueID


GO


