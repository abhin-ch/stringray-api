-- Create Attribute
EXEC stng.SP_Admin_UserManagement @Operation=1,@Attribute='PCS',@AttributeType='BPRole',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=1,@Attribute='PCS Lead',@AttributeType='BPRole',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=1,@Attribute='EBS',@AttributeType='BPRole',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=1,@Attribute='OE',@AttributeType='BPRole',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=1,@Attribute='Planner',@AttributeType='BPRole',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=1,@Attribute='ProjectM',@AttributeType='BPRole',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=1,@Attribute='ProgramM',@AttributeType='BPRole',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=1,@Attribute='Supervisor',@AttributeType='BPRole',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=1,@Attribute='SM',@AttributeType='BPRole',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=1,@Attribute='DM',@AttributeType='BPRole',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=1,@Attribute='DM EP',@AttributeType='BPRole',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=1,@Attribute='DivM',@AttributeType='BPRole',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=1,@Attribute='VP',@AttributeType='BPRole',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=1,@Attribute='ExecVP',@AttributeType='BPRole',@EmployeeID = '619704'

--TOQ
EXEC stng.SP_Admin_UserManagement @Operation=5,@Permission='TOQViewAll',@Description='View all TOQ records regardless of Role',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=9,@Permission='TOQViewAll',@Attribute='TOQ',@AttributeType = 'Module',@EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation=5,@Permission='TOQDeleteOEQuestionAttachment',@Description='Allow the ability to delete attachments on OE Question records',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=9,@Permission='TOQDeleteOEQuestionAttachment',@Attribute='TOQ',@AttributeType = 'Module',@EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation=5,@Permission='TOQAddOECorrespondenceAnswer',@Description='Ability for OE to add an answer to a question',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=9,@Permission='TOQAddOECorrespondenceAnswer',@Attribute='TOQ',@AttributeType = 'Module',@EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation=5,@Permission='TOQAddVendorCorrespondenceAnswer',@Description='Ability for Vendor to add an answer to a question',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=9,@Permission='TOQAddVendorCorrespondenceAnswer',@Attribute='TOQ',@AttributeType = 'Module',@EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation=9,@Permission='TOQAddVendorCorrespondenceAnswer',@AttributeType = 'Vendor',@EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation=5,@Permission='TOQDeleteVCQuestionAttachment',@Description='Ability for Vendor to delete attachment from submitted question',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=9,@Permission='TOQDeleteVCQuestionAttachment',@Attribute='TOQ',@AttributeType = 'Module',@EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation=9,@Permission='TOQDeleteVCQuestionAttachment',@AttributeType = 'Vendor',@EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation=5,@Permission='TOQShowVCQuestionCreatedBy',@Description='Show the EmployeeID of the attachment on Vendor Correspondence Questions.',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=9,@Permission='TOQShowVCQuestionCreatedBy',@Attribute='TOQ',@AttributeType = 'Module',@EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation=5,@Permission='TOQDownloadTDSAttachment',@Description='Enable download button for TDS Attachment in TDS Header',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=9,@Permission='TOQDownloadTDSAttachment',@Attribute='TOQ',@AttributeType = 'Module',@EmployeeID = '619704';

EXEC stng.SP_Admin_UserManagement @Operation=5,@Permission='TOQDeleteTDSAttachment',@Description='Allow to delete attachment from Attachment Component',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=5,@Permission='AttachmentListFiles',@Description='View files that have been uploaded in the Attachment Component',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=5,@Permission='AttachmentUploadFile',@Description='Enable ability to upload files in the Attachment Component',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=5,@Permission='AttachmentDownloadFile',@Description='Enable ability to download files in the Attachment Component',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=5,@Permission='AttachmentDeleteFile',@Description='Enable ability to delete files in the Attachment Component',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=5,@Permission='BudgetingCreatePBRF',@Description='Show button to Create and Revise PBRF',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=9,@Permission='BudgetingCreatePBRF',@Attribute='Budgeting',@AttributeType = 'Module',@EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation=5,@Permission='BudgetingCreateSDQ',@Description='Show button to Create SDQ',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=9,@Permission='BudgetingCreateSDQ',@Attribute='Budgeting',@AttributeType = 'Module',@EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation=5,@Permission='BudgetingSDQP6Tab',@Description='View the P6 Tab',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=9,@Permission='BudgetingSDQP6Tab',@Attribute='Budgeting',@AttributeType = 'Module',@EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation=5,@Permission='BudgetingSDQWriteCustomerApprovalTab',@Description='Enable Cusotmer Approval controls regardless of SDQ status',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=9,@Permission='BudgetingSDQWriteCustomerApprovalTab',@Attribute='Budgeting',@AttributeType = 'Module',@EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation=5,@Permission='BudgetingWritePlannerChecklist',@Description='Enable Planner Checklist regardless of status and user',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=9,@Permission='BudgetingWritePlannerChecklist',@Attribute='Budgeting',@AttributeType = 'Module',@EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation=5,@Permission='BudgetingSDQWriteRelatedTOQ',@Description='Enable Related TOQ fields regardless of status and user',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=9,@Permission='BudgetingSDQWriteRelatedTOQ',@Attribute='Budgeting',@AttributeType = 'Module',@EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation=5,@Permission='BudgetingSDQWriteHeader',@Description='Enable SDQ Header fields regardless of status and user',@EmployeeID = '619704'
EXEC stng.SP_Admin_UserManagement @Operation=9,@Permission='BudgetingSDQWriteHeader',@Attribute='Budgeting',@AttributeType = 'Module',@EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation = 38, @Endpoint = 'toq/ebs-band', @HTTPVerb = 'POST', @EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation = 42, @Endpoint = 'toq/ebs-band', @HTTPVerb = 'POST', @Attribute = 'AuthenticationOnly', @AttributeType = 'Authentication', @EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation = 42, @Endpoint = 'toq/ebs-band', @HTTPVerb = 'POST',@Attribute = 'TOQ', @AttributeType = 'Module', @EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation = 38, @Endpoint = 'toq/ebs-band-rate', @HTTPVerb = 'POST', @EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation = 42, @Endpoint = 'toq/ebs-band-rate', @HTTPVerb = 'POST', @Attribute = 'AuthenticationOnly', @AttributeType = 'Authentication', @EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation = 42, @Endpoint = 'toq/ebs-band-rate', @HTTPVerb = 'POST',@Attribute = 'TOQ', @AttributeType = 'Module', @EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation = 38, @Endpoint = 'toq/vendor-award/options', @HTTPVerb = 'POST', @EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation = 42, @Endpoint = 'toq/vendor-award/options', @HTTPVerb = 'POST', @Attribute = 'AuthenticationOnly', @AttributeType = 'Authentication', @EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation = 42, @Endpoint = 'toq/vendor-award/options', @HTTPVerb = 'POST',@Attribute = 'TOQ', @AttributeType = 'Module', @EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation = 38, @Endpoint = 'toq/vendor-award', @HTTPVerb = 'POST', @EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation = 42, @Endpoint = 'toq/vendor-award', @HTTPVerb = 'POST', @Attribute = 'AuthenticationOnly', @AttributeType = 'Authentication', @EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation = 42, @Endpoint = 'toq/vendor-award', @HTTPVerb = 'POST',@Attribute = 'TOQ', @AttributeType = 'Module', @EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation = 38, @Endpoint = 'toq/vs/status-log', @HTTPVerb = 'POST', @EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation = 42, @Endpoint = 'toq/vs/status-log', @HTTPVerb = 'POST', @Attribute = 'AuthenticationOnly', @AttributeType = 'Authentication', @EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation = 42, @Endpoint = 'toq/vs/status-log', @HTTPVerb = 'POST',@Attribute = 'TOQ', @AttributeType = 'Module', @EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation = 38, @Endpoint = 'toq/vendor-submission/status', @HTTPVerb = 'POST', @EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation = 42, @Endpoint = 'toq/vendor-submission/status', @HTTPVerb = 'POST', @Attribute = 'AuthenticationOnly', @AttributeType = 'Authentication', @EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation = 42, @Endpoint = 'toq/vendor-submission/status', @HTTPVerb = 'POST',@Attribute = 'TOQ', @AttributeType = 'Module', @EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation = 38, @Endpoint = 'toq/vendor-submission/validate', @HTTPVerb = 'GET', @EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation = 42, @Endpoint = 'toq/vendor-submission/validate', @HTTPVerb = 'GET', @Attribute = 'AuthenticationOnly', @AttributeType = 'Authentication', @EmployeeID = '619704';
EXEC stng.SP_Admin_UserManagement @Operation = 42, @Endpoint = 'toq/vendor-submission/validate', @HTTPVerb = 'GET',@Attribute = 'TOQ', @AttributeType = 'Module', @EmployeeID = '619704';


/**
--ADD ENDPOINTS
DECLARE @Endpoint NVARCHAR(255)
DECLARE @Method NVARCHAR(255)
DECLARE cursorName CURSOR FOR SELECT Name,Description FROM [stng].[Admin_AppSecurity] WHERE Type = 'Endpoint' AND Name LIKE 'toq/%'

OPEN cursorName

FETCH NEXT FROM cursorName INTO @Endpoint,@Method

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC stng.SP_Admin_UserManagement @Operation = 38, @Endpoint = @Endpoint, @HTTPVerb = @Method, @EmployeeID = '619704';
	EXEC stng.SP_Admin_UserManagement @Operation = 42, @Endpoint = @Endpoint, @HTTPVerb = @Method, @Attribute = 'AuthenticationOnly', @AttributeType = 'Authentication', @EmployeeID = '619704';
	EXEC stng.SP_Admin_UserManagement @Operation = 42, @Endpoint = @Endpoint, @HTTPVerb = @Method,@Attribute = 'TOQ', @AttributeType = 'Module', @EmployeeID = '619704';

	FETCH NEXT FROM cursorName INTO @Endpoint,@Method
END

CLOSE cursorName
DEALLOCATE cursorName
**/