CREATE OR ALTER VIEW [stng].[VV_Budgeting_PBRFCommon]
AS 
	SELECT T.UniqueID
		,Label
		,Value
		,Sort
		,Field
		,Value1
		,Value2
	FROM stng.Common_ValueLabel T
	INNER JOIN stng.Admin_Module M ON M.UniqueID = T.ModuleID AND M.NameShort = 'Budgeting'
	WHERE T.[Group] = 'PBRF'
	AND T.Active = 1