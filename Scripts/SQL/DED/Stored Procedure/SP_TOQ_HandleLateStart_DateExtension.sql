CREATE OR ALTER PROCEDURE [stng].[SP_TOQ_HandleLateStart_DateExtension]
    @TOQMainID uniqueidentifier,
    @EmployeeID varchar(10),
    @Comment varchar(max),
    @ErrorDescription varchar(max) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AwardedVendorID uniqueidentifier
    DECLARE @TOQStartDate date
    DECLARE @CurrentDate date
    DECLARE @BusinessDaysLate int
    DECLARE @TOQType VARCHAR(50)
    DECLARE @TOQTypeShort VARCHAR(50)
    DECLARE @StatusVDU UNIQUEIDENTIFIER
    DECLARE @DateExtensionIsRun bit

    -- Get awarded vendor's Information
    SELECT 
        @AwardedVendorID = va.UniqueID,
        @TOQStartDate = va.TOQStartDate,
        @TOQType = m.TypeID,
        @TOQTypeShort = cvl.Value,
        @CurrentDate = CAST(stng.GetDate() AS date)
    FROM stng.TOQ_VendorAssigned va
    INNER JOIN stng.TOQ_Main m ON m.UniqueID = va.TOQMainID
    INNER JOIN [stng].[Common_ValueLabel] cvl ON cvl.UniqueID = m.TypeID
    WHERE va.TOQMainID = @TOQMainID AND va.Awarded = 1

    -- Get VDU Status ID
    SELECT @StatusVDU = UniqueID 
    FROM [stng].[Common_ValueLabel] 
    WHERE Field = 'Status' AND Value = 'VDU' AND [GROUP] = 'STD'

    -- If current date is after TOQ start date and TOQ Type is standard
    IF @CurrentDate > @TOQStartDate AND @TOQTypeShort = 'STD'
    BEGIN
        -- First check if there's a higher Rev for the same BPTOQID
        IF EXISTS (
            SELECT 1
            FROM stng.TOQ_Main t1
            INNER JOIN stng.TOQ_Main t2 ON t1.BPTOQID = t2.BPTOQID
            WHERE t1.UniqueID = @TOQMainID
            AND t2.Rev > t1.Rev
        )
        BEGIN
            SET @ErrorDescription = 'Cannot proceed - A higher revision exists for this TOQ.'
            -- Continue to normal ACC logic
            SET @DateExtensionIsRun = 0
        END
        ELSE
        BEGIN
			-- Exit SubOp 2
			SET @DateExtensionIsRun = 1

            -- Calculate business days late
            SELECT @BusinessDaysLate = COUNT(*) 
            FROM stng.Common_WorkDate
            WHERE Date > @TOQStartDate 
            AND Date <= @CurrentDate
            AND IsWorkday = 1

            -- Update Status of TOQ to VDU instead of ACC
            UPDATE stng.TOQ_Main 
            SET StatusID = @StatusVDU,
                UpdatedDate = stng.GetDate(),
                UpdatedBy = @EmployeeID 
            WHERE UniqueID = @TOQMainID

            -- Add status log entry to TOQ Log about late approval
            INSERT INTO stng.TOQ_StatusLog(TOQMainID,TOQStatusID,CreatedBy,Comment) 
            VALUES (@TOQMainID, @StatusVDU, @EmployeeID, 'TOQ was approved ' + CAST(@BusinessDaysLate AS varchar) + ' business days late. ' + ISNULL(@Comment,''))

            -- Add status log entry to TOQ Vendor Submission Log about late approval
            INSERT INTO stng.TOQ_VendorStatusLog(VendorAssignedID,Comment,CreatedBy,StatusID)
            VALUES(
                @AwardedVendorID,
                'TOQ was approved ' + CAST(@BusinessDaysLate AS varchar) + ' business days late. ' + ISNULL(@Comment,''),
                @EmployeeID,
                (SELECT StatusID FROM stng.VV_TOQ_VendorSubmissionStatus WHERE Value = 'SUBDATEEDIT')
            )

            -- Update TOQ Start Date to current date
            UPDATE [stng].[TOQ_VendorAssigned] 
            SET TOQStartDate = @CurrentDate,
                TOQEndDate = CASE 
                    WHEN TOQEndDate IS NOT NULL THEN (
                        SELECT TOP 1 Date
                        FROM (
                            SELECT TOP (@BusinessDaysLate + 1) Date
                            FROM [stng].[Common_WorkDate]
                            WHERE Date >= TOQEndDate
                            AND IsWorkday = 1
                            ORDER BY Date ASC
                        ) AS SubQuery
                        ORDER BY Date DESC
                    )
                    ELSE NULL
                END
            WHERE UniqueID = @AwardedVendorID

            -- Push Dates in Cost Summary based on business days difference
            IF @BusinessDaysLate > 0
            BEGIN
                UPDATE [stng].TOQ_CostSummary
                SET 
                    [DateExtension_NewStartDate] = CASE 
                        WHEN DeliverableStartDate IS NOT NULL THEN (
                            SELECT TOP 1 Date
                            FROM (
                                SELECT TOP (@BusinessDaysLate + 1) Date
                                FROM [stng].[Common_WorkDate]
                                WHERE Date >= DeliverableStartDate
                                AND IsWorkday = 1
                                ORDER BY Date ASC
                            ) AS SubQuery
                            ORDER BY Date DESC
                        )
                        ELSE NULL
                    END,
                    [DateExtension_NewEndDate] = CASE 
                        WHEN DeliverableEndDate IS NOT NULL THEN (
                            SELECT TOP 1 Date
                            FROM (
                                SELECT TOP (@BusinessDaysLate + 1) Date
                                FROM [stng].[Common_WorkDate]
                                WHERE Date >= DeliverableEndDate
                                AND IsWorkday = 1
                                ORDER BY Date ASC
                            ) AS SubQuery
                            ORDER BY Date DESC
                        )
                        ELSE NULL
                    END,
                    NewTOQCommitmentDate = CASE 
                        WHEN NewTOQCommitmentDate IS NOT NULL THEN (
                            SELECT TOP 1 Date
                            FROM (
                                SELECT TOP (@BusinessDaysLate + 1) Date
                                FROM [stng].[Common_WorkDate]
                                WHERE Date >= NewTOQCommitmentDate
                                AND IsWorkday = 1
                                ORDER BY Date ASC
                            ) AS SubQuery
                            ORDER BY Date DESC
                        )
                        ELSE NULL
                    END,
                    UpdateDate = stng.GetDate(),
                    UpdatedBy = @EmployeeID
                WHERE VendorAssignedID = @AwardedVendorID

                -- Update the Static values so we have a trace on what the dates were originally calculated to
                UPDATE [stng].TOQ_CostSummary SET 
                    [DateExtension_NewStartDate_Static] = [DateExtension_NewStartDate],
                    [DateExtension_NewEndDate_Static] = [DateExtension_NewEndDate],
                    [DateExtension_NewCommitmentDate_Static] = [NewTOQCommitmentDate]
                WHERE VendorAssignedID = @AwardedVendorID
            END

            -- Assign deliverable locals
            EXEC stng.SP_TOQ_PopulateLocals @UniqueID = @TOQMainID, @ErrorDescription = @ErrorDescription OUTPUT
        END
    END

    RETURN @DateExtensionIsRun
END