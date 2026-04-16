CREATE OR ALTER VIEW stng.VV_TOQ_Status
AS 
	SELECT T.UniqueID StatusID
		,[Group] [Type]
		,Label
		,Value
		,Sort 
		,Value3 as Legacy
	FROM stng.Common_ValueLabel T
	INNER JOIN stng.Admin_Module M ON M.UniqueID = T.ModuleID AND M.NameShort = 'TOQ'
	WHERE T.Field = 'Status' 
	AND T.Active = 1