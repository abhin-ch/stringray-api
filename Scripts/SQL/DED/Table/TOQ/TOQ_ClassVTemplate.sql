CREATE TABLE stng.TOQ_ClassVTemplate
(
	UniqueID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
	WBSID UNIQUEIDENTIFIER REFERENCES stng.Common_ValueLabel(UniqueID),
	WBSDetailID UNIQUEIDENTIFIER REFERENCES stng.Common_ValueLabel(UniqueID),
	InternalHour INT,
	ExternalHour INT
)

-- Make sure the WBS and WBSDetail records have been interted prior to executing the following
INSERT INTO stng.TOQ_ClassVTemplate(WBSID,WBSDetailID)
SELECT W.UniqueID,C.UniqueID FROM stng.VV_TOQ_Common C
CROSS APPLY (SELECT A.UniqueID FROM stng.VV_TOQ_Common A WHERE A.[Group] = 'ClassV' AND A.Field='WBS' AND A.Value = 1) W  
WHERE C.[Group] = 'ClassV' AND C.Field='WBSDetail' AND C.Value IN (1,2,3,4)
UNION
SELECT W.UniqueID,C.UniqueID FROM stng.VV_TOQ_Common C
CROSS APPLY (SELECT A.UniqueID FROM stng.VV_TOQ_Common A WHERE A.[Group] = 'ClassV' AND A.Field='WBS' AND A.Value = 2) W  
WHERE C.[Group] = 'ClassV' AND C.Field='WBSDetail' AND C.Value IN (5,6,7,8,9,10,11,12)
UNION
SELECT W.UniqueID,C.UniqueID FROM stng.VV_TOQ_Common C
CROSS APPLY (SELECT A.UniqueID FROM stng.VV_TOQ_Common A WHERE A.[Group] = 'ClassV' AND A.Field='WBS' AND A.Value = 3) W  
WHERE C.[Group] = 'ClassV' AND C.Field='WBSDetail' AND C.Value IN (13,14,15,16,17,18,19,20)
UNION
SELECT W.UniqueID,C.UniqueID FROM stng.VV_TOQ_Common C
CROSS APPLY (SELECT A.UniqueID FROM stng.VV_TOQ_Common A WHERE A.[Group] = 'ClassV' AND A.Field='WBS' AND A.Value = 4) W  
WHERE C.[Group] = 'ClassV' AND C.Field='WBSDetail' AND C.Value IN (21,22,23,24,25,26)
UNION
SELECT W.UniqueID,C.UniqueID FROM stng.VV_TOQ_Common C
CROSS APPLY (SELECT A.UniqueID FROM stng.VV_TOQ_Common A WHERE A.[Group] = 'ClassV' AND A.Field='WBS' AND A.Value = 5) W  
WHERE C.[Group] = 'ClassV' AND C.Field='WBSDetail' AND C.Value IN (27,28,29,30)
UNION
SELECT W.UniqueID,C.UniqueID FROM stng.VV_TOQ_Common C
CROSS APPLY (SELECT A.UniqueID FROM stng.VV_TOQ_Common A WHERE A.[Group] = 'ClassV' AND A.Field='WBS' AND A.Value = 6) W  
WHERE C.[Group] = 'ClassV' AND C.Field='WBSDetail' AND C.Value IN (31,32,33,34,35)
UNION
SELECT W.UniqueID,C.UniqueID FROM stng.VV_TOQ_Common C
CROSS APPLY (SELECT A.UniqueID FROM stng.VV_TOQ_Common A WHERE A.[Group] = 'ClassV' AND A.Field='WBS' AND A.Value = 7) W  
WHERE C.[Group] = 'ClassV' AND C.Field='WBSDetail' AND C.Value IN (36,37,38,39,40,41,42,43,44)
UNION
SELECT W.UniqueID,C.UniqueID FROM stng.VV_TOQ_Common C
CROSS APPLY (SELECT A.UniqueID FROM stng.VV_TOQ_Common A WHERE A.[Group] = 'ClassV' AND A.Field='WBS' AND A.Value = 8) W  
WHERE C.[Group] = 'ClassV' AND C.Field='WBSDetail' AND C.Value IN (45,46,47,48,49,50)
UNION
SELECT W.UniqueID,C.UniqueID FROM stng.VV_TOQ_Common C
CROSS APPLY (SELECT A.UniqueID FROM stng.VV_TOQ_Common A WHERE A.[Group] = 'ClassV' AND A.Field='WBS' AND A.Value = 9) W  
WHERE C.[Group] = 'ClassV' AND C.Field='WBSDetail' AND C.Value IN (51,52,53,54,55,56,57,58,59,60) 
UNION
SELECT W.UniqueID,C.UniqueID FROM stng.VV_TOQ_Common C
CROSS APPLY (SELECT A.UniqueID FROM stng.VV_TOQ_Common A WHERE A.[Group] = 'ClassV' AND A.Field='WBS' AND A.Value = 10) W  
WHERE C.[Group] = 'ClassV' AND C.Field='WBSDetail' AND C.Value IN (61,62,63,64,65,66,67,68,69)
UNION
SELECT W.UniqueID,C.UniqueID FROM stng.VV_TOQ_Common C
CROSS APPLY (SELECT A.UniqueID FROM stng.VV_TOQ_Common A WHERE A.[Group] = 'ClassV' AND A.Field='WBS' AND A.Value = 11) W  
WHERE C.[Group] = 'ClassV' AND C.Field='WBSDetail' AND C.Value IN (70,71,72,73,74,75,76,77)
UNION
SELECT W.UniqueID,C.UniqueID FROM stng.VV_TOQ_Common C
CROSS APPLY (SELECT A.UniqueID FROM stng.VV_TOQ_Common A WHERE A.[Group] = 'ClassV' AND A.Field='WBS' AND A.Value = 12) W  
WHERE C.[Group] = 'ClassV' AND C.Field='WBSDetail' AND C.Value IN (78,79,80,81,82,83,84)
UNION
SELECT W.UniqueID,C.UniqueID FROM stng.VV_TOQ_Common C
CROSS APPLY (SELECT A.UniqueID FROM stng.VV_TOQ_Common A WHERE A.[Group] = 'ClassV' AND A.Field='WBS' AND A.Value = 13) W  
WHERE C.[Group] = 'ClassV' AND C.Field='WBSDetail' AND C.Value IN (85,86,87,88,89)
UNION
SELECT W.UniqueID,C.UniqueID FROM stng.VV_TOQ_Common C
CROSS APPLY (SELECT A.UniqueID FROM stng.VV_TOQ_Common A WHERE A.[Group] = 'ClassV' AND A.Field='WBS' AND A.Value = 14) W  
WHERE C.[Group] = 'ClassV' AND C.Field='WBSDetail' AND C.Value IN (90,91,92)
UNION
SELECT W.UniqueID,C.UniqueID FROM stng.VV_TOQ_Common C
CROSS APPLY (SELECT A.UniqueID FROM stng.VV_TOQ_Common A WHERE A.[Group] = 'ClassV' AND A.Field='WBS' AND A.Value = 15) W  
WHERE C.[Group] = 'ClassV' AND C.Field='WBSDetail' AND C.Value IN (93,94,95,96,97,98,99,100)
UNION
SELECT W.UniqueID,C.UniqueID FROM stng.VV_TOQ_Common C
CROSS APPLY (SELECT A.UniqueID FROM stng.VV_TOQ_Common A WHERE A.[Group] = 'ClassV' AND A.Field='WBS' AND A.Value = 16) W  
WHERE C.[Group] = 'ClassV' AND C.Field='WBSDetail' AND C.Value IN (101,102,103)
UNION
SELECT W.UniqueID,C.UniqueID FROM stng.VV_TOQ_Common C
CROSS APPLY (SELECT A.UniqueID FROM stng.VV_TOQ_Common A WHERE A.[Group] = 'ClassV' AND A.Field='WBS' AND A.Value = 17) W  
WHERE C.[Group] = 'ClassV' AND C.Field='WBSDetail' AND C.Value IN (104,105,106,107,108,109,110,111)
UNION
SELECT W.UniqueID,C.UniqueID FROM stng.VV_TOQ_Common C
CROSS APPLY (SELECT A.UniqueID FROM stng.VV_TOQ_Common A WHERE A.[Group] = 'ClassV' AND A.Field='WBS' AND A.Value = 18) W  
WHERE C.[Group] = 'ClassV' AND C.Field='WBSDetail' AND C.Value IN (112,113)
UNION
SELECT W.UniqueID,C.UniqueID FROM stng.VV_TOQ_Common C
CROSS APPLY (SELECT A.UniqueID FROM stng.VV_TOQ_Common A WHERE A.[Group] = 'ClassV' AND A.Field='WBS' AND A.Value = 19) W  
WHERE C.[Group] = 'ClassV' AND C.Field='WBSDetail' AND C.Value IN (114)
UNION
SELECT W.UniqueID,C.UniqueID FROM stng.VV_TOQ_Common C
CROSS APPLY (SELECT A.UniqueID FROM stng.VV_TOQ_Common A WHERE A.[Group] = 'ClassV' AND A.Field='WBS' AND A.Value = 20) W  
WHERE C.[Group] = 'ClassV' AND C.Field='WBSDetail' AND C.Value IN (115)
