/*
CreatedBy: Habib Shakibanejad
Description: Designed to create security privileges. 
Date: 12 Jan 2023
*/
CREATE OR ALTER PROCEDURE [stng].[SP_Admin_CreateAppSecurity](
	@Module NVARCHAR(255)
	,@Name NVARCHAR(255)
	,@Type NVARCHAR(255)
	,@Description NVARCHAR(1000)
	,@CreatedBy NVARCHAR(255)
	,@Location NVARCHAR(255) = NULL
)
AS
BEGIN
	INSERT INTO stng.Admin_AppSecurity(ModuleID,Name,Type,CreatedBy,Description,Location) 
	SELECT ModuleID,@Name,@Type,@CreatedBy,@Description,@Location FROM stng.Admin_Module M WHERE M.NameShort = @Module
END
GO
