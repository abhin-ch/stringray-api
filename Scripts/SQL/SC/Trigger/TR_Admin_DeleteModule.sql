/*
CreatedBy: Habib Shakibanejad
*/
CREATE OR ALTER TRIGGER [stng].[TR_Admin_DeleteModule]
   ON [stng].[Admin_Module] AFTER DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	UPDATE stng.Admin_Role SET ModuleID = NULL WHERE ModuleID IN (SELECT D.ModuleID FROM deleted D)

	DELETE FROM stng.Admin_UserAccess WHERE ASID IN (SELECT A.ASID FROM stng.Admin_AppSecurity A WHERE A.ModuleID IN (SELECT D.ModuleID FROM deleted D))
	DELETE FROM stng.Admin_AppSecurity WHERE ModuleID IN (SELECT D.ModuleID FROM deleted D)
END
GO


