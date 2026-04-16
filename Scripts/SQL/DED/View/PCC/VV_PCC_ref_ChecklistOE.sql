CREATE OR ALTER VIEW [stng].[VV_PCC_ref_ChecklistOE]
AS
SELECT A.UniqueID QuestionID
	,B.ChecklistTypeID
	,CAST(A.Value AS INT) QuestionOrder
	,A.Value1 Category
	,A.Label Question,Sort 
FROM stng.Common_ValueLabel A 
INNER JOIN stng.Admin_Module M ON M.UniqueID = A.ModuleID AND M.NameShort = 'PCC'
CROSS APPLY 
(
	SELECT A.ChecklistTypeID FROM stng.VV_PCC_ref_ChecklistType A WHERE A.ChecklistType = 'OE'
) B
WHERE A.Field = 'OEChecklist' AND A.[Group] = 'SDQ'