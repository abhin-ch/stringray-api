CREATE OR ALTER VIEW [stng].[VV_ALR_DOverallStatus]
AS
WITH DeliverableAssignment AS (SELECT        WMID, ParentID, SUM(CASE WHEN (AStatus = 'INP' AND DeleteRecord = 0) THEN 1 ELSE 0 END) AS InProgress, SUM(CASE WHEN (AStatus = 'COM' AND DeleteRecord = 0) THEN 1 ELSE 0 END)
                                                                                                   AS Complete, SUM(CASE WHEN (AStatus = 'ONH' AND DeleteRecord = 0) THEN 1 ELSE 0 END) AS OnHold, SUM(CASE WHEN (AStatus = 'CAN' AND DeleteRecord = 0) THEN 1 ELSE 0 END) 
                                                                                                  AS Cancelled
                                                                         FROM            stng.VV_ALR_UserAssignment AS V
                                                                         GROUP BY WMID, ParentID)
    SELECT        WMID, ParentID, CASE WHEN V.InProgress = 0 AND V.OnHold = 0 AND V.Complete = 0 THEN NULL WHEN V.InProgress = 0 AND V.OnHold = 0 AND 
                              V.Complete > 0 THEN 'COM' WHEN V.OnHold > 0 THEN 'ONH' WHEN V.InProgress > 0 THEN 'INP' ELSE 'CAN' END AS AStatus
     FROM            DeliverableAssignment AS V
GO