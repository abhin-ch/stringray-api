CREATE OR ALTER VIEW [stng].[VV_ALR_CRSSMain]
AS
SELECT        F.CRNum, F.CRStatus, F.RAD AS CRAD, [CRABC] = CASE WHEN F.RAB = 0 THEN '999' ELSE UserID END, F.LUD AS CLUD, F.LUB AS LUB, F.CRID AS CRIDC, [OutageC] = CASE WHEN A.Outage IS NULL 
                         THEN 'N' ELSE A.Outage END, [OutageC2] = CASE WHEN A.Outage IS NULL THEN 'N' ELSE 'Y' END, [Manual] = CASE WHEN F.CRID IS NULL THEN 'N' ELSE 'Y' END, IIF(A.EmergentWork = 1, 'Y', NULL) AS [EmergentWorkC], 
                         C.DeliverableC, UserID, E.AStatus, F.Comment, A.*
FROM            stng.ALR_CRSSMain AS F LEFT JOIN
                         stng.ALR_CRSSupportInfo AS A ON A.CRID = F.CRID LEFT JOIN
                             (SELECT        ParentID AS CRID, DeliverableC
                               FROM            stng.VV_ALR_Deliverable AS V
                               WHERE        V.WMID = 'CRSS') AS C ON C.CRID = F.CRID LEFT JOIN
                             (SELECT        ParentID AS CRID, UserID
                               FROM            stng.VV_ALR_UserAssignment AS V
                               WHERE        V.WMID = 'CRSS') AS D ON D .CRID = F.CRID LEFT JOIN
                             (SELECT        ParentID AS CRID, AStatus
                               FROM            stng.VV_ALR_DOverallStatus AS V
                               WHERE        V.WMID = 'CRSS') AS E ON E.CRID = F.CRID
GO