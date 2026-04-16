CREATE OR ALTER VIEW [stng].[VV_Budgeting_SDQCommon]
AS 
	SELECT T.UniqueID
		,Label
		,Value
		,Value1
		,Sort
		,Field
	FROM stng.VV_Common_ValueLabel T
	WHERE T.[Group] = 'SDQ' 
	AND T.Module = 'Budgeting'
	AND Active = 1
