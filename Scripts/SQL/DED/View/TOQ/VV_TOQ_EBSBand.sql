ALTER   VIEW [stng].[VV_TOQ_EBSBand]
AS
SELECT 
	T.UniqueID as TOQMainID
	,T.TMID
	,T.BPTOQID
	,T.TDSNo
	,T.Type
	,T.Status
	,T.Resource
	,B.BandRate 
	,C.Label AwardedVendor
	,V.TOQNumber as VendorTOQNumber
	,V.CreatedBy
	,V.TOQStartDate AwardedStartDate
	,V.TOQEndDate AwardedEndDate
FROM stng.VV_TOQ_Main T
LEFT JOIN stng.TOQ_Band B ON T.UniqueID = B.TOQMainID
LEFT JOIN stng.TOQ_VendorAssigned V ON V.TOQMainID = T.UniqueID AND V.Awarded = 1
LEFT JOIN stng.Common_ValueLabel C ON C.UniqueID = V.VendorID
GO