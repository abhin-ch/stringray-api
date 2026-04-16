CREATE OR ALTER VIEW [stng].[VV_Admin_Modules]
AS


SELECT aa.UniqueID as AttributeID, m.* 
FROM stng.Admin_Module m
JOIN stng.Admin_Attribute aa on aa.Attribute = m.NameShort
JOIN stng.Admin_AttributeType at on at.UniqueID = aa.AttributeType
Where at.AttributeType = 'Module'


GO
