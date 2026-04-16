CREATE OR ALTER VIEW stng.VV_TOQ_DeliverableAccount2
AS 
SELECT
T.TMID
,T.BPTOQID
,T.Project
,T.Rev
,T.Status
,T.Type
,T.AwardedVendor
,T.AllVendorTOQNumber
,T.ScopeManagedBy
FROM stng.VV_TOQ_Main T
