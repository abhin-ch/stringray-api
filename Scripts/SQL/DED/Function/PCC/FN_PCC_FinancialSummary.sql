ALTER FUNCTION [stng].[FN_PCC_FinancialSummary](@SDQUID INT)
RETURNS TABLE
AS
RETURN
(
    WITH Header AS
    (
        SELECT 
            H.CurrentRequest,
            H.PreviouslyApproved,
            H.RequestedScope,
            H.RequestedTrend,
            H.TotalPartialApproval
        FROM stng.FN_Budgeting_SDQ_HeaderCost(@SDQUID) H
    ),
    Prev AS
    (
        SELECT P.PreviousRevisionEAC
        FROM stng.FN_Budgeting_SDQ_PreviousRevisionEAC(@SDQUID) P
    ),
    Wbs AS
    (
        SELECT SUM(A.RemainingCost) AS FutureClassV
        FROM stngetl.Budgeting_SDQ_P6_CVWBS_Materialized A
        WHERE A.SDQUID = @SDQUID
    ),
    ClassII AS
    (
        SELECT 
            SUM(D.SunkCost)        AS SunkCost,
            SUM(D.RemainingCost)   AS AdditionalRequired
        FROM stngetl.VV_Budgeting_SDQ_P6_CIIDeliverable_MatView D
        WHERE D.SDQUID = @SDQUID
    )
    SELECT 
        @SDQUID                              AS SDQUID,
        CI.SunkCost,
        CI.AdditionalRequired,
        H.CurrentRequest,
        H.PreviouslyApproved,
        H.RequestedScope,
        H.RequestedTrend,
        H.TotalPartialApproval,
        COALESCE(W.FutureClassV, 0)          AS FutureClassV,
        (CI.SunkCost + CI.AdditionalRequired + COALESCE(W.FutureClassV, 0)) AS CurrentSDQEAC,
        (H.PreviouslyApproved + H.CurrentRequest) AS TotalRequest,
        P.PreviousRevisionEAC
    FROM ClassII CI
    CROSS JOIN Header H
    CROSS JOIN Wbs W
    CROSS JOIN Prev P
);
