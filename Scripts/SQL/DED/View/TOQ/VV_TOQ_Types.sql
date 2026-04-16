CREATE OR ALTER VIEW stng.VV_TOQ_Types
AS 
SELECT UniqueID TypeID
	,Label TypeLong
	,Value Type
	,Value1 Description
	,CAST(Value2 AS BIT) ParentType
	,Value3 AsChildSuffix
FROM stng.VV_TOQ_Common WHERE Field = 'Type' AND [Group]= 'Record'