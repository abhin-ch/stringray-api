EXEC stng.SP_Admin_CreateAppSecurity @Module='Budgeting',@Name='ViewAll',@Type='Data',@CreatedBy='619704',@Description='View all budgeting records, with no filters.';
EXEC stng.SP_Admin_CreateAppSecurity @Module='Budgeting',@Name='VerificationChecklistOverride',@Type='Data',@CreatedBy='619704',@Description='Enable verification checklist if you are NOT the PCS Lead';
EXEC stng.SP_Admin_CreateAppSecurity @Module='Budgeting',@Name='SMApprovalOverride',@Type='Button',@CreatedBy='619704',@Description='Enable button to Approve or Send for Correction if you are NOT the Section Manager.';
EXEC stng.SP_Admin_CreateAppSecurity @Module='Budgeting',@Name='SDQWriteAll',@Type='Access',@CreatedBy='619704',@Description='Enabled all SDQ controls for edit';
EXEC stng.SP_Admin_CreateAppSecurity @Module='Budgeting',@Name='PlannerChecklistOverride',@Type='Data',@CreatedBy='619704',@Description='Enable planner checklist if you are NOT the Planner';







