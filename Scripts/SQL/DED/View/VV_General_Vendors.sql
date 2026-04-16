CREATE OR ALTER VIEW stng.VV_General_Vendors
AS 
SELECT UniqueID VendorID,Label Vendor,Value VendorCode,Sort FROM stng.VV_Common_ValueLabel A 
WHERE A.Field = 'Vendor' AND [Group] = 'Vendor' AND Module = 'Admin' AND Active = 1