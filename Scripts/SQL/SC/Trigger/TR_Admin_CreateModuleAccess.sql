/*
CreatedBy: Habib Shakibanejad
*/
CREATE OR ALTER TRIGGER [stng].[TR_Admin_CreateModuleAccess]
   ON [stng].[Admin_Module] AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO stng.Admin_AppSecurity(ModuleID,Name,Description,Type,CreatedBy)
	SELECT M.ModuleID,M.NameShort,CONCAT('Access to ',M.NameShort,' Module'),'Module',M.CreatedBy FROM inserted M
END
GO

