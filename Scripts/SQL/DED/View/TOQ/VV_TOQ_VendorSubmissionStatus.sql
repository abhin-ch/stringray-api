CREATE OR ALTER VIEW stng.VV_TOQ_VendorSubmissionStatus
AS 
SELECT UniqueID StatusID,Label,Value,Sort,Active FROM stng.VV_Common_ValueLabel 
WHERE Module = 'TOQ' AND [Group] = 'VendorSubmission' AND Field = 'Status'