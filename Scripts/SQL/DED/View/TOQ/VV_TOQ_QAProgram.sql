CREATE OR ALTER VIEW stng.VV_TOQ_QAProgram
AS
SELECT A.TOQ_MainID TOQUniqueID
,A.QAProgramID
,B.Value QAValue
,B.Value2 TOQType
FROM stng.TOQ_QAProgram A
INNER JOIN stng.VV_TOQ_Common B ON B.UniqueID = A.QAProgramID AND
B.[Group] = 'Header' AND B.Field = 'QA' AND Value2 = 'STANDARD'
UNION
SELECT A.TOQ_EmergentID
,A.QAProgramID
,B.Value QAValue
,B.Value2 TOQType
FROM stng.TOQ_QAProgram A
INNER JOIN stng.VV_TOQ_Common B ON B.UniqueID = A.QAProgramID AND
B.[Group] = 'Header' AND B.Field = 'QA' AND B.Value2 = 'EMERGENT'