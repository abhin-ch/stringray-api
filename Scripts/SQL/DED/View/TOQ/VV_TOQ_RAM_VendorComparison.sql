ALTER VIEW [stng].[VV_TOQ_RAM_VendorComparison] AS
	WITH vendor_totals AS (
		SELECT 
			vs.TOQMainID,
			vs.VendorID,
			SUM(cs.TotalCost) as VendorTOQDollarValue,
			SUM(cs.TotalHour) as VendorHours
		FROM stng.VV_TOQ_VendorSubmission vs
		LEFT JOIN stng.TOQ_CostSummary cs 
			ON cs.VendorAssignedID = vs.UniqueID
		Where vs.DeleteRecord = 0
		GROUP BY vs.TOQMainID, vs.VendorID
	)
	SELECT 
		ram.*,
		vs.Vendor,
		vs.SubmissionStatus,
		vs.TOQNumber as VendorTOQNumber,
		COALESCE(vt.VendorTOQDollarValue, 0) as VendorTOQDollarValue,
		COALESCE(ram.OverrideVendorHours, vt.VendorHours) as VendorHours
	FROM stng.TOQ_RAM_VendorComparison ram
	LEFT JOIN stng.VV_TOQ_VendorSubmission vs 
		ON vs.TOQMainID = ram.TOQMainID 
		AND vs.VendorID = ram.VendorID
	LEFT JOIN vendor_totals vt
		ON vt.TOQMainID = ram.TOQMainID 
		AND vt.VendorID = ram.VendorID
	Where vs.DeleteRecord = 0
GO