CREATE OR ALTER FUNCTION [stng].[FN_Budgeting_SDQ_HeaderCost]
(
    @SDQUID BIGINT
)
RETURNS TABLE
AS
RETURN
(
    WITH AllApprovals AS
    (
        SELECT a.SDQUID, SUM(b.ApprovalAmount) AS ApprovalAmount
        FROM stng.Budgeting_SDQ_CustomerApproval_Mapping a
        INNER JOIN stng.Budgeting_SDQ_CustomerApproval_2 b 
            ON a.CustomerApprovalID = b.CustomerApprovalID AND a.Active = 1
        WHERE b.Approved = 1
        GROUP BY a.SDQUID
    ),
    PastRevApprovals AS
    (
        SELECT a.SDQUID, SUM(a.PreviouslyApprovedManual + ISNULL(b.ApprovalAmount,0)) AS PreviouslyApproved
        FROM stng.VV_Budgeting_SDQ_PreviousRevision a
        LEFT JOIN AllApprovals b ON a.PrevSDQUID = b.SDQUID
        WHERE a.SDQUID = @SDQUID
        GROUP BY a.SDQUID
    ),
    TotalRequest AS
    (
        SELECT b.SDQUID, ROUND(SUM(ISNULL(ar.RemainingCost,0) + ISNULL(ar.SunkCost,0)),0) AS RequestCost
        FROM stngetl.Budgeting_SDQ_P6 p
        INNER JOIN stng.Budgeting_SDQP6Link b ON p.RunID = b.RunID AND b.Active = 1
        INNER JOIN stngetl.Budgeting_SDQ_Run r ON b.RunID = r.RunID AND r.Legacy = 0
        LEFT JOIN stngetl.Budgeting_SDQ_P6_ActivityResource_Materialized ar 
               ON p.task_id = ar.task_id AND p.RunID = ar.runid AND ar.Baseline = 0
        WHERE p.CV = 0 AND b.SDQUID = @SDQUID
        GROUP BY b.SDQUID

        UNION ALL

        SELECT l.SDQUID, ROUND(SUM(ISNULL(l.RemainingCost,0) + ISNULL(l.SunkCost,0)),0)
        FROM stng.VV_Budgeting_SDQ_P6_Legacy_ClassIIDeliverable l
        INNER JOIN stng.Budgeting_SDQP6Link b ON l.SDQUID = b.SDQUID AND b.Active = 1
        INNER JOIN stngetl.Budgeting_SDQ_Run r ON b.RunID = r.RunID AND r.Legacy = 1
        WHERE l.SDQUID = @SDQUID
        GROUP BY l.SDQUID
    )
    SELECT 
        m.RequestedScope,
        COALESCE(m.PreviouslyApproved,p.PreviouslyApproved,0) AS PreviouslyApproved,
        COALESCE(ca.CurrentRequest, CAST(t.RequestCost - COALESCE(m.PreviouslyApproved,p.PreviouslyApproved,0) - ISNULL(ca.PriorPartialApproval,0) AS INT)) AS CurrentRequest,
        COALESCE(ca.RequestedTrend, CAST(t.RequestCost - COALESCE(m.PreviouslyApproved,p.PreviouslyApproved,0) - m.RequestedScope - ISNULL(ca.PriorPartialApproval,0) AS INT)) AS RequestedTrend,
	ca.TotalPartialApproval
    FROM stng.Budgeting_SDQMain m
    LEFT JOIN PastRevApprovals p ON m.SDQUID = p.SDQUID
    LEFT JOIN TotalRequest t ON m.SDQUID = t.SDQUID
    LEFT JOIN stng.VV_Budgeting_SDQ_CustomerApproval_2 ca ON ca.SDQUID = m.SDQUID
    WHERE m.SDQUID = @SDQUID
);