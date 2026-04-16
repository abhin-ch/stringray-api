CREATE OR ALTER VIEW stng.VV_TOQ_QAProgram_STANDARD
AS
SELECT UniqueID value,Label label,Value name,Sort,CAST(IIF(Value3 = 'Legacy',1,0) AS BIT) IsLegacy FROM stng.VV_TOQ_Common A 
WHERE A.[Group] = 'Header' AND A.Field = 'QA' AND Value2 = 'STANDARD'