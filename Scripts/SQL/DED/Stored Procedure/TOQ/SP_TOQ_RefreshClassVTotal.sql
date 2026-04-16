CREATE OR ALTER PROCEDURE [stng].[SP_TOQ_RefreshClassVTotal]
    @Value1 UNIQUEIDENTIFIER
AS
BEGIN
    UPDATE M
    SET M.ClassVTotalAmount = S.ClassVTotalAmount
    FROM stng.TOQ_Main M
    CROSS APPLY (
        SELECT ClassVTotalAmount
        FROM stng.VV_TOQ_ClassVSummary
        WHERE UniqueID = M.ClassVUniqueID
    ) S
    WHERE M.ClassVUniqueID = @Value1;
END