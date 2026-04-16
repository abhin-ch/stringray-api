/*
Author: Habib Shakibanejad
Description: Validation process for changing status in Budgeting
CreatedDate: 30 Nov 2023
*/
ALTER   PROCEDURE [stng].[SP_Budgeting_ChangeStatusValidation]
(
	@NextStatus NVARCHAR(255) = NULL,
	@RecordType NVARCHAR(255) = NULL,
	@RecordUID INT = NULL,
	@EmployeeID NVARCHAR(255) = NULL
)
AS 
BEGIN TRY
	DECLARE @CurrentStatus NVARCHAR(255)
	SELECT @CurrentStatus = StatusValue FROM stng.VV_Budgeting_Main A WHERE A.Type = @RecordType AND A.RecordTypeUniqueID = @RecordUID
	
	IF(@CurrentStatus = 'INIT')
	BEGIN
		-- Check if P6 schedule is linked and the self-check is complete
		SELECT Active FROM [stng].[Budgeting_SDQP6Link] WHERE SDQUID = @RecordUID 

		SELECT QuestionCategory,QuestionOrder FROM stng.VV_Budgeting_SDQ_Checklist_Instance 
		WHERE SDQChecklistType = 'Self'
		AND (((Response = 'No' OR Response = 'N/A') AND Comment = '') OR Response is Null)
		AND SDQUID = @RecordUID
	END

	ELSE IF(@CurrentStatus = 'AOEA')
	BEGIN
		SELECT A.Category QuestionCategory,A.InternalID QuestionOrder FROM stng.VV_PCC_SDQ_ChecklistItem A
		INNER JOIN stng.PCC_SDQ_Checklist B ON B.UniqueID = A.ChecklistID
		WHERE  B.ChecklistTypeID = (SELECT T.ChecklistTypeID FROM stng.VV_PCC_ref_ChecklistType T WHERE T.ChecklistType = 'OE')
		AND A.SDQUID = @RecordUID AND B.[Current] = 1
		AND ((([No] = 1 OR NA = 1) AND (Comment = '' OR Comment IS NULL))
		OR (Yes = 0 AND [No] = 0 AND NA = 0 ))	
	END

	ELSE IF(@CurrentStatus = 'AVER')
	BEGIN
		DECLARE @ApprovalType NVARCHAR(50);

		-- Find approver type for this employee
		SELECT TOP 1 @ApprovalType = b.SDQApprovalType
		FROM stng.VV_Budgeting_SDQ_Approval b
		WHERE b.SDQUID = @RecordUID
		  AND b.SDQApprovalType IN ('Verifier','LeadPlanner')
		  AND b.Approver IN (SELECT EmployeeID 
							 FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID));

		-- Data1: Verifier checklist
		IF (@ApprovalType = 'Verifier')
		BEGIN
			SELECT QuestionCategory, QuestionOrder
			FROM stng.VV_Budgeting_SDQ_Checklist_Instance 
			WHERE SDQChecklistType = 'Verifier'
			  AND (((Response = 'No' OR Response = 'N/A') AND Comment = '') OR Response IS NULL)
			  AND SDQUID = @RecordUID;
		END
		ELSE
		BEGIN
			SELECT NULL AS QuestionCategory, NULL AS QuestionOrder;
		END

		-- Data2: Planner checklist
		IF (@ApprovalType = 'LeadPlanner')
		BEGIN
			SELECT QuestionCategory, QuestionOrder
			FROM stng.VV_Budgeting_SDQ_Checklist_Instance 
			WHERE SDQChecklistType = 'Planner'
			  AND (((Response = 'No' OR Response = 'N/A') AND Comment = '') OR Response IS NULL)
			  AND SDQUID = @RecordUID;
		END
		ELSE
		BEGIN
			SELECT NULL AS QuestionCategory, NULL AS QuestionOrder;
		END
	END
	
END TRY
BEGIN CATCH
	INSERT INTO stng.App_ErrorLog([Number],[Procedure],[Line],[Message]) VALUES (
        ERROR_NUMBER(),
        ERROR_PROCEDURE(),
        ERROR_LINE(),
        ERROR_MESSAGE()
    );
	THROW
END CATCH
