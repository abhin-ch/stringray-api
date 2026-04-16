CREATE OR ALTER VIEW [stng].[VV_TOQ_VendorSubmissionIncludeRemoved]
AS
	WITH VendorLatestStatus AS (
		SELECT 
			VendorAssignedID,
			C.Label AS Status
		FROM (
			SELECT 
				VendorAssignedID,
				StatusID,
				ROW_NUMBER() OVER (PARTITION BY VendorAssignedID ORDER BY CreatedDate DESC) AS RN
			FROM stng.TOQ_VendorStatusLog
		) A
		LEFT JOIN stng.VV_TOQ_VendorSubmissionStatus C ON C.StatusID = A.StatusID
		WHERE A.RN = 1
	),
	VendorSubmissionDates AS (
		SELECT VendorAssignedID, MIN(CreatedDate) AS SubmissionDate
		FROM (
			SELECT 
				VendorAssignedID,
				CreatedDate,
				Status,
				LAG(Status) OVER (PARTITION BY VendorAssignedID ORDER BY CreatedDate) AS PreviousStatus
			FROM stng.VV_TOQ_VendorStatusLog
		) X
		WHERE Status = 'Submitted' AND PreviousStatus = 'Not Submitted'
		GROUP BY VendorAssignedID
	)
	SELECT 
		A.Label AS Vendor,
		CASE 
			WHEN V.DeleteRecord = 1 THEN 'Removed'
			ELSE S.Status
		END AS SubmissionStatus,
		Q.ReasonForTOQID AS TOQReasonID,
		T.ClassVTotalAmount AS ClassV,
		CS.CostSummary,
		T.ClassVTotalAmount - CS.CostSummary AS [Difference],
		T.TMID,
		V.*,
	CASE WHEN CAST(L.SubmissionDate AS DATE) > CAST(T.VendorSubmissionDate AS DATE) THEN 'Yes' ELSE NULL END AS SubmittedLate
	FROM stng.TOQ_VendorAssigned V
	LEFT JOIN stng.Common_ValueLabel A ON A.UniqueID = V.VendorID
	LEFT JOIN VendorLatestStatus S ON S.VendorAssignedID = V.UniqueID
	LEFT JOIN (
		SELECT 
			VendorAssignedID,
			STRING_AGG(CAST(ReasonForTOQID AS NVARCHAR(max)), ',') AS ReasonForTOQID
		FROM stng.TOQ_VendorTOQReason
		GROUP BY VendorAssignedID
	) Q ON Q.VendorAssignedID = V.UniqueID
	LEFT JOIN (
		SELECT 
			VendorAssignedID,
			SUM(TotalCost) AS CostSummary
		FROM stng.VV_TOQ_CostSummary
		GROUP BY VendorAssignedID
	) CS ON CS.VendorAssignedID = V.UniqueID
	LEFT JOIN VendorSubmissionDates L ON L.VendorAssignedID = V.UniqueID
	LEFT JOIN stng.TOQ_Main T ON T.UniqueID = V.TOQMainID

--SELECT * FROM stng.VV_TOQ_VendorSubmission
GO