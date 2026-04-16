CREATE OR ALTER VIEW stng.VV_TOQ_QAProgram_EMERGENT
AS
SELECT UniqueID value,Label label,Value name,Sort FROM stng.VV_TOQ_Common A 
WHERE A.[Group] = 'Header' AND A.Field = 'QA' AND Value2 = 'EMERGENT'