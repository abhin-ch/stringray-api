CREATE OR ALTER VIEW [stng].[VV_ALR_ISSMain]
AS
SELECT F.ItemNum, F.IStatus, F.RAD AS IRAD, [IRABC] = CASE WHEN F.RAB = 0 THEN 999 ELSE UserId END, F.LUD AS ILUD, F.LUB AS ILUB, UserId, F.ISSID AS ISSIDC, [OutageC] = CASE WHEN A.Outage IS NULL 
             THEN 'N' ELSE A.Outage END, [OutageC2] = CASE WHEN A.Outage IS NULL THEN 'N' ELSE 'Y' END, [Manual] = CASE WHEN F.ISSID IS NULL THEN 'N' ELSE 'Y' END, IIF(A.EmergentWork = 1, 'Y', NULL) AS [EmergentWorkC], IIF(A.WODemand = 1, 'Y', NULL) AS [WODemandC], 
             IIF(A.InventoryDemand = 1, 'Y', NULL) AS [InventoryDemandC], IIF(A.CricSpares = 1, 'Y', NULL) AS [CricSparesC], C.DeliverableC, D .UserId AS UserIdUserAssignment, E.AStatus, F.Comment, A.*
FROM   stng.ALR_ISSMain AS F LEFT JOIN
             stng.ALR_ISSSupportInfo AS A ON A.ISSID = F.ISSID LEFT JOIN
                 (SELECT ParentID AS ISSID, DeliverableC
                 FROM    stng.VV_ALR_Deliverable AS V
                 WHERE V.WMID = 'ISS') AS C ON C.ISSID = F.ISSID LEFT JOIN
                 (SELECT ParentID AS ISSID, UserID
                 FROM    stng.VV_ALR_UserAssignment AS V
                 WHERE V.WMID = 'ISS') AS D ON D .ISSID = F.ISSID LEFT JOIN
                 (SELECT ParentID AS ISSID, AStatus
                 FROM    stng.VV_ALR_DOverallStatus AS V
                 WHERE V.WMID = 'ISS') AS E ON E.ISSID = F.ISSID
GO


