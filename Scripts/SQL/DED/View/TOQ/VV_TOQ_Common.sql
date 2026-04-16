CREATE OR ALTER VIEW [stng].[VV_TOQ_Common]
AS 
	SELECT T.UniqueID
        ,[Group]
		,Label
		,Value
		,Value1
		,Value2
		,Value3
		,Sort
		,Field
	FROM stng.VV_Common_ValueLabel T
	WHERE T.Module = 'TOQ' 
	AND Field != 'Status' 
	AND (Value1 != 'LITE' OR Value1 IS NULL)
	AND Active = 1