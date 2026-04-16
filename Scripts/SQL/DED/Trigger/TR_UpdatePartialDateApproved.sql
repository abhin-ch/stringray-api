CREATE TRIGGER [stng].[trg_UpdatePartialDateApproved]
ON [stng].[TOQ_StatusLog]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE P
    SET DateApproved = I.CreatedDate
    FROM stng.TOQ_Partial P
    INNER JOIN stng.TOQ_VendorAssigned V ON V.UniqueID = P.VendorAssignedID
    INNER JOIN inserted I ON I.TOQMainID = V.TOQMainID
    INNER JOIN stng.VV_TOQ_Status S ON S.StatusID = I.TOQStatusID
    WHERE P.DateApproved IS NULL 
    AND I.CreatedDate >= P.CreatedDate
    AND S.Value IN ('ACC', 'VDU')
END