/*
Author: Habib Shakibanejad
CreatedDate: 03 March 2024
*/
CREATE OR ALTER VIEW stng.VV_Budgeting_MinorChangeType
AS
SELECT 
	S.UniqueID
	,'SDQ' RecordType
	,S.Label
	,S.Value
	,S.Sort
FROM stng.VV_Budgeting_SDQCommon S WHERE S.Field = 'MinorChangeType' 
UNION
SELECT 
	P.UniqueID
	,'PBRF'
	,P.Label
	,P.Value
	,P.Sort
FROM stng.VV_Budgeting_PBRFCommon P WHERE P.Field = 'MinorChangeType' 