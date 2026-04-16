CREATE OR ALTER VIEW [stng].[VV_Budgeting_DVNStatus]
AS 
	SELECT T.UniqueID StatusID
		,[Group] [Type]
		,Label
		,Value
		,Sort 
	FROM stng.Common_ValueLabel T
	INNER JOIN stng.Admin_Module M ON M.UniqueID = T.ModuleID AND M.NameShort = 'Budgeting'
	WHERE T.Field = 'Status' AND T.[Group] = 'DVN'
	AND T.Active = 1