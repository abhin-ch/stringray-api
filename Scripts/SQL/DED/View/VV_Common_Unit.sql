CREATE OR ALTER VIEW stng.VV_Common_Unit
AS 
	SELECT T.UniqueID
		,[Group] [Field]
		,Label Unit
		,Value1 SiteID
		,Value
		,Sort
	FROM stng.Common_ValueLabel T
	INNER JOIN stng.Admin_Module M ON M.UniqueID = T.ModuleID AND M.NameShort = 'Common'
	WHERE T.Field = 'SiteID' AND T.[Group] = 'Unit'
	AND T.Active = 1
