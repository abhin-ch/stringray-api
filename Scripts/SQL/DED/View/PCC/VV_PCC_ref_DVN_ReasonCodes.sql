CREATE OR ALTER VIEW stng.VV_PCC_ref_DVN_ReasonCodes
AS
SELECT UniqueID ReasonCodeID, Value1 Department, Value2 ScopeTrend, Label ReasonCodeLabel,Value,Sort,Active FROM stng.VV_Common_ValueLabel 
WHERE Module = 'PCC' 
AND [Group] = 'DVN'
AND Field = 'Reason'
