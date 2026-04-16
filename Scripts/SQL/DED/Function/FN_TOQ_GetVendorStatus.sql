CREATE OR ALTER FUNCTION [stng].[FN_TOQ_GetVendorStatus]
(
    @StatusValue VARCHAR(10),
    @TypeValue VARCHAR(50),
    @UniqueID UNIQUEIDENTIFIER,
    @AwardedVendor VARCHAR(100),
    @EmployeeID VARCHAR(50)
)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @VendorStatus VARCHAR(50)

    SELECT @VendorStatus = 
        CASE
			WHEN @TypeValue = 'SVN'
				THEN (SELECT Label FROM [stng].[Common_ValueLabel] where [Group] = 'SVN' and Field = 'Status' and Value = @StatusValue)
			WHEN @TypeValue = 'REWORK'
				THEN (SELECT Label FROM [stng].[Common_ValueLabel] where [Group] = 'REWORK' and Field = 'Status' and Value = @StatusValue)
            -- Vendor submission status cases
            WHEN @StatusValue = 'AVS' THEN ( select SubmissionStatus from [stng].[VV_TOQ_VendorSubmission] where TOQMainID = @UniqueID AND Vendor = (
                    SELECT UA.Attribute
                    FROM [stng].[VV_Admin_UserAttribute] UA
                    WHERE UA.EmployeeID = @EmployeeID 
                    AND UA.AttributeType = 'Vendor'
                ))
			WHEN @StatusValue IN ('ALAMS','HSDQ', 'ASDQF') 
                THEN 'BP Processing'
			WHEN @StatusValue IN ('INIT','AEIA','ASMIA') 
                THEN 'BP Processing - Initiating'
			WHEN @StatusValue IN ('AOEVA','ALAMS','ADPR','ICORR','CORR') 
                THEN 'BP Processing with OE'
			WHEN @StatusValue IN ('ASAA','AVSA', 'ASMA') 
                THEN 'BP Processing with SM'
			WHEN @StatusValue IN ('AEBSP','ACOR','AESAA','AEFP','ASVPA','APCOR','ACANC', 'AEAP','CANCO', 'CANCS') 
                THEN 'BP Processing with EBS'
			WHEN @StatusValue IN ('ADIVA') 
                THEN 'BP Processing with DivM'
			WHEN @StatusValue IN ('ADMA','ADVMA') 
                THEN 'BP Processing with DM EP'
            -- Not Awarded cases
            WHEN @StatusValue IN ('ACC','ARIP','VDU','ODU') AND @AwardedVendor IS NOT NULL 
                AND NOT EXISTS (
                    SELECT 1 
                    FROM [stng].[VV_Admin_UserAttribute] UA
                    WHERE UA.EmployeeID = @EmployeeID 
                    AND UA.AttributeType = 'Vendor'
                    AND UA.Attribute = @AwardedVendor
                ) THEN 'Not Awarded'
			-- Late Start Processing
			WHEN @StatusValue IN ('ODU') 
                THEN 'Date Update - BP Processing'
			WHEN @StatusValue = 'VDU'
                THEN 'Vendor Date Update'
			-- Awarded
            WHEN @StatusValue IN ('ACC','ARIP') AND @AwardedVendor IS NOT NULL 
                AND EXISTS (
                    SELECT 1 
                    FROM [stng].[VV_Admin_UserAttribute] UA
                    WHERE UA.EmployeeID = @EmployeeID 
                    AND UA.AttributeType = 'Vendor'
                    AND UA.Attribute = @AwardedVendor
                ) THEN 'Awarded'
            -- Closed cases
            WHEN @StatusValue = 'CLOSE' AND @AwardedVendor IS NOT NULL 
                AND NOT EXISTS (
                    SELECT 1 
                    FROM [stng].[VV_Admin_UserAttribute] UA
                    WHERE UA.EmployeeID = @EmployeeID 
                    AND UA.AttributeType = 'Vendor'
                    AND UA.Attribute = @AwardedVendor
                ) THEN 'Not Awarded'
            WHEN @StatusValue = 'CLOSE' AND @AwardedVendor IS NOT NULL 
                AND EXISTS (
                    SELECT 1 
                    FROM [stng].[VV_Admin_UserAttribute] UA
                    WHERE UA.EmployeeID = @EmployeeID 
                    AND UA.AttributeType = 'Vendor'
                    AND UA.Attribute = @AwardedVendor
                ) THEN 'TOQ Closed'
            -- Other statuses
            WHEN @StatusValue = 'CANC' THEN 'TOQ Cancelled'
            WHEN @StatusValue = 'NOT' THEN 'TOQ Not Approved'
            WHEN @StatusValue = 'SUPER' AND @AwardedVendor IS NOT NULL 
                AND NOT EXISTS (
                    SELECT 1 
                    FROM [stng].[VV_Admin_UserAttribute] UA
                    WHERE UA.EmployeeID = @EmployeeID 
                    AND UA.AttributeType = 'Vendor'
                    AND UA.Attribute = @AwardedVendor
                ) THEN 'Not Awarded'
            WHEN @StatusValue = 'SUPER' AND @AwardedVendor IS NOT NULL 
                AND EXISTS (
                    SELECT 1 
                    FROM [stng].[VV_Admin_UserAttribute] UA
                    WHERE UA.EmployeeID = @EmployeeID 
                    AND UA.AttributeType = 'Vendor'
                    AND UA.Attribute = @AwardedVendor
                ) THEN 'TOQ Revised'
            WHEN @StatusValue = 'AVENA' THEN 'Awaiting Vendor Approval'
			WHEN @StatusValue = 'REP' THEN 'Replaced'
			WHEN @TypeValue = 'EMERG'
				THEN (SELECT Label FROM [stng].[Common_ValueLabel] where [Group] = 'EMERG' and Field = 'Status' and Value = @StatusValue)
            ELSE 'No Status Available'
        END

    RETURN @VendorStatus
END
