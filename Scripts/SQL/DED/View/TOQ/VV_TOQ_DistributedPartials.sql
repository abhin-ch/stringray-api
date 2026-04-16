ALTER VIEW [stng].[VV_TOQ_DistributedPartials] AS
WITH RankedDeliverables AS (
    SELECT 
        UniqueID,
        VendorAssignedID,
        DeliverableStartDate,
        DeliverableEndDate,
        TotalCost,
        SUM(TotalCost) OVER (PARTITION BY VendorAssignedID ORDER BY DeliverableStartDate, UniqueID) AS RunningTotalCost
    FROM [stng].[TOQ_CostSummary]
),
PartialRequest AS (
	SELECT
    VendorAssignedID,
    SUM(PartialRequestAmount) AS PartialRequestAmount
	FROM
		[stng].[TOQ_Partial]
	GROUP BY
		VendorAssignedID
),
DistributedAmount AS (
    SELECT
        d.UniqueID,
        d.VendorAssignedID,
        d.DeliverableStartDate,
        d.DeliverableEndDate,
        d.TotalCost,
        CASE
            WHEN p.PartialRequestAmount >= d.RunningTotalCost THEN d.TotalCost
            WHEN p.PartialRequestAmount > (d.RunningTotalCost - d.TotalCost) THEN p.PartialRequestAmount - (d.RunningTotalCost - d.TotalCost)
            ELSE 0
        END AS DistributedPartial
    FROM
        RankedDeliverables d
    JOIN
        PartialRequest p
    ON
        d.VendorAssignedID = p.VendorAssignedID
)
SELECT * FROM DistributedAmount;
GO