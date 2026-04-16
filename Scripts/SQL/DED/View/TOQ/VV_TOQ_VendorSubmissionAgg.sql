CREATE OR ALTER VIEW [stng].[VV_TOQ_VendorSubmissionAgg]
AS
WITH VendorWithLatestStatus AS (
    SELECT 
        VendorAssignedID,
        T.TMID,
        S.Value AS Status,
        ROW_NUMBER() OVER(PARTITION BY TMID, L.VendorAssignedID ORDER BY L.CreatedDate DESC) AS RN
    FROM stng.TOQ_VendorStatusLog L
    INNER JOIN stng.TOQ_VendorAssigned V ON V.UniqueID = L.VendorAssignedID
    INNER JOIN stng.TOQ_Main T ON T.UniqueID = V.TOQMainID
    INNER JOIN stng.VV_TOQ_VendorSubmissionStatus S ON S.StatusID = L.StatusID 
    WHERE V.DeleteRecord = 0
),
TotalVendorsSubmitted AS (
    SELECT COUNT(*) AS TotalVendorsSubmitted, TMID 
    FROM VendorWithLatestStatus
    WHERE RN = 1 AND Status != 'NOTSUB'
    GROUP BY TMID
),
TotalVendors AS (
    SELECT COUNT(V.UniqueID) AS TotalVendors, T.TMID 
    FROM stng.TOQ_VendorAssigned V 
    INNER JOIN stng.TOQ_Main T ON T.UniqueID = V.TOQMainID
    WHERE V.DeleteRecord = 0
    GROUP BY T.TMID
),
TotalVendorsSubmittedNoBid AS (
    SELECT COUNT(*) AS TotalVendorsSubmittedNoBid, TMID 
    FROM VendorWithLatestStatus
    WHERE RN = 1 AND Status = 'NOBID'
    GROUP BY TMID
),
TotalVendorsEditable AS (
    SELECT COUNT(*) AS TotalVendorsEditable, TMID 
    FROM VendorWithLatestStatus
    WHERE RN = 1 AND Status = 'SUBEDIT'
    GROUP BY TMID
)
SELECT 
    B.TMID,
    ISNULL(A.TotalVendorsSubmitted,0) AS TotalVendorsSubmitted,
    B.TotalVendors,
    CASE 
        WHEN D.TotalVendorsEditable > 0 THEN 'IP'
        WHEN A.TotalVendorsSubmitted = B.TotalVendors AND ISNULL(C.TotalVendorsSubmittedNoBid,0) != B.TotalVendors THEN 'CO'
        WHEN A.TotalVendorsSubmitted < B.TotalVendors THEN 'IP'
        WHEN A.TotalVendorsSubmitted = B.TotalVendors AND ISNULL(C.TotalVendorsSubmittedNoBid,0) = B.TotalVendors THEN 'NB'
        ELSE 'NS'
    END AS VSSCode
FROM TotalVendors B
LEFT JOIN TotalVendorsSubmitted A ON B.TMID = A.TMID
LEFT JOIN TotalVendorsSubmittedNoBid C ON C.TMID = A.TMID
LEFT JOIN TotalVendorsEditable D ON D.TMID = A.TMID

GO
