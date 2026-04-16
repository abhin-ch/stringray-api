CREATE OR ALTER PROCEDURE stng.SP_Budgeting_StatusOptions(
	@CurrentStatus NVARCHAR(255),
	@EmployeeID NVARCHAR(255),
	@RecordType NVARCHAR(255),
	@RecordUID INT
)
AS
BEGIN
	DECLARE @Date1 DATE;

	IF(@RecordType = 'PBRF')
		BEGIN
			IF @CurrentStatus = 'ASMA'
				BEGIN

					IF EXISTS( select * FROM [stng].[VV_Budgeting_PBRFMain] where SM=DM and RecordTypeUniqueID=@RecordUID )
					begin
						SELECT 'DM' Status
					end
					else 
						print'' 
					end
			else IF @CurrentStatus ='ADMA'
				begin
					IF EXISTS( select * FROM [stng].[VV_Budgeting_PBRFMain] where SM=DivM and RecordTypeUniqueID=@RecordUID )
					begin
						SELECT 'DivM' Status
					end
					else 
						print'' 			
				end
					else print ''
		END
	ELSE IF(@RecordType = 'SDQ')
		BEGIN
			--If APGMA
			IF @CurrentStatus = 'APGMA'
				BEGIN
					-- Calculate date checks separately for each approval date (Automatic and Manual)
					DECLARE @PMAnticipatedApprovalDate DATE;
					DECLARE @AnticipatedProgMApprovalDate DATE;

					SELECT
						@PMAnticipatedApprovalDate = PMAnticipatedApprovalDate,
						@AnticipatedProgMApprovalDate = AnticipatedProgMApprovalDate
					FROM stng.VV_Budgeting_SDQMain
					WHERE RecordTypeUniqueID = @RecordUID;

					-- Check for AOERC
					-- Only proceed if we're not past either approval date
					-- If AnticipatedProgMApprovalDate is provided (Manual entry), then both dates must be in the future
					IF (stng.FN_General_WorkDateDelta(@PMAnticipatedApprovalDate, null) > 0) AND
					   (@AnticipatedProgMApprovalDate IS NULL OR stng.FN_General_WorkDateDelta(@AnticipatedProgMApprovalDate, null) > 0)
					AND EXISTS
					(
					  SELECT a.*
					  FROM stngetl.VV_Budgeting_SDQ_P6_DeliverablesSummary AS a
					  WHERE a.EndActualized = 0 AND a.SDQUID = @RecordUID and ScopeTrend <> 'Not required'
					)
					AND NOT EXISTS
					(
					  SELECT *
					  FROM stng.VV_Budgeting_SDQ_RevisedCommitment
					  WHERE SDQUID = @RecordUID
					)
					AND NOT EXISTS
					(
					  -- Check for APRE followed by APJMA in the status log
					  -- ( Do not do the AOERC process if additional partial )
					  SELECT 1
					  FROM [stng].[VV_Budgeting_SDQStatusLog] AS sl1
					  JOIN [stng].[VV_Budgeting_SDQStatusLog] AS sl2 
						ON sl1.SDQUID = sl2.SDQUID 
						AND sl1.CreatedDate < sl2.CreatedDate
					  WHERE sl1.SDQUID = @RecordUID
						AND sl1.StatusValue = 'APRE'
						AND sl2.StatusValue = 'APJMA'
					)
					SELECT 'AOERC' Status


					-- Check for AOEFR
					ELSE IF EXISTS
					(
						SELECT *
						FROM stng.VV_Budgeting_SDQ_CustomerApproval_2
						WHERE SDQUID = @RecordUID AND Active = 1 AND IsPartial = 1
					)
					SELECT 'AOEFR' Status

					-- Check for AOEFR
					ELSE IF EXISTS
					(
						SELECT *
						FROM stng.Budgeting_MinorChangeLog AS a
						WHERE a.SDQUID = @RecordUID
					)
					SELECT 'APCSC' Status
					ELSE
					SELECT 'AFRE' Status	

			END -- @CurrentStatus = 'APGMA'

			ELSE IF @CurrentStatus = 'AOERC'
				BEGIN
					IF EXISTS
					(
						SELECT *
						FROM stng.VV_Budgeting_SDQ_CustomerApproval_2
						WHERE SDQUID = @RecordUID AND Active = 1 AND IsPartial = 1
					)
					SELECT 'AOEFR' Status

					ELSE IF EXISTS
					(
						SELECT *
						FROM stng.Budgeting_MinorChangeLog AS a
						WHERE a.SDQUID = @RecordUID
					)
					SELECT 'APCSC' Status
					ELSE
					SELECT 'AFRE' Status
				END

			ELSE IF @CurrentStatus = 'AOEFR'
				BEGIN
					IF EXISTS
					(
						SELECT *
						FROM stng.Budgeting_MinorChangeLog AS a
						WHERE a.SDQUID = @RecordUID
					)
					SELECT 'APCSC' Status
					ELSE
					SELECT 'APRE' Status
				END

			ELSE IF @CurrentStatus = 'APCSC'
				BEGIN
					IF EXISTS
					(
						SELECT *
						FROM stng.VV_Budgeting_SDQ_CustomerApproval_2
						WHERE SDQUID = @RecordUID AND Active = 1 AND IsPartial = 1
					)
					SELECT 'APRE' Status
					ELSE
					SELECT 'AFRE' Status
				END
		
		END

	ELSE IF(@RecordType = 'DVN') PRINT ''








END