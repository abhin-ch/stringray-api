CREATE OR ALTER VIEW stng.VV_PCC_ref_ChecklistPlanner
AS
SELECT A.UniqueID ChecklistTypeID, CAST(A.Value AS INT) QuestionOrder,A.Value1 Category, A.Label Question,Sort FROM stng.Common_ValueLabel A 
INNER JOIN stng.Admin_Module M ON M.UniqueID = A.ModuleID AND M.NameShort = 'PCC'
WHERE A.Field = 'PlannerChecklist' AND A.[Group] = 'SDQ'