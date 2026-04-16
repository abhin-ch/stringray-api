CREATE OR ALTER VIEW stng.VV_PCC_ref_ChecklistType
AS
SELECT A.UniqueID ChecklistTypeID, A.Value ChecklistType, A.Label ChecklistTypeLong,Sort FROM stng.Common_ValueLabel A 
INNER JOIN stng.Admin_Module M ON M.UniqueID = A.ModuleID AND M.NameShort = 'PCC'
WHERE A.Field = 'ChecklistType' AND A.[Group] = 'SDQ'