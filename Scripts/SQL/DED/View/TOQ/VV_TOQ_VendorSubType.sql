CREATE OR ALTER VIEW stng.VV_TOQ_VendorSubWorkType
AS
SELECT S.UniqueID,S.Label SubWorkType,W.Label WorkType,S.Value1 WorkTypeValue,S.Sort
FROM stng.VV_TOQ_Common S
LEFT JOIN stng.VV_TOQ_Common W ON W.Value = S.Value1
WHERE S.Field = 'SubWorkType' AND S.[Group] = 'Vendor'