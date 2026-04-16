
CREATE OR ALTER VIEW [stng].[VV_Common_VendorIDAttributeID]
AS
with generalvendors as (
	SELECT UniqueID VendorID,Label Vendor FROM stng.VV_Common_ValueLabel A 
	WHERE A.Field = 'Vendor' AND [Group] = 'Vendor' AND Module = 'Admin' AND Active = 1
)
select aa.Attribute Vendor, aa.UniqueID AttributeID, gv.VendorID from stng.Admin_Attribute aa
join generalvendors gv on aa.Attribute = gv.Vendor
where aa.AttributeType = (select UniqueID from stng.Admin_AttributeType where AttributeType = 'Vendor')
GO



