CREATE OR ALTER VIEW stng.VV_TOQ_VendorWorkType
AS
SELECT T.UniqueID
,W.UniqueID WorkTypeID
,W.Label WorkType
,V.UniqueID VendorID
,V.Label Vendor
,T.Tier 
FROM stng.TOQ_VendorWorkType T
INNER JOIN stng.Common_ValueLabel W ON W.UniqueID = T.WorkTypeID
INNER JOIN stng.Common_ValueLabel V ON V.UniqueID = T.VendorID