CREATE OR ALTER VIEW [stng].[VV_ALR_Deliverable]
AS
SELECT        WMID, ParentID, DeliverableC = STUFF
                             ((SELECT DISTINCT ',' + DeliverableC
                                 FROM            stng.VV_ALR_UserAssignment
                                 WHERE        WMID = TempTable.WMID AND ParentID = TempTable.ParentID AND DeleteRecord = 0 FOR XML PATH(''), TYPE ).value('.[1]', 'nvarchar(max)'), 1, 1, '')
FROM            stng.VV_ALR_UserAssignment AS TempTable
WHERE        DeleteRecord = 0
GROUP BY WMID, ParentID