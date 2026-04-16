CREATE OR ALTER   PROCEDURE [stng].[SP_Catalog_CRUD](
	@Operation TINYINT
	,@EmployeeID Varchar(50) = NULL
	,@Value1 NVARCHAR(255) = NULL
	,@Value2 NVARCHAR(255) = NULL
	,@Value3 NVARCHAR(255) = NULL
	,@Value4 NVARCHAR(255) = NULL
	,@Value5 NVARCHAR(255) = NULL
	,@Value6 NVARCHAR(max) = NULL
	,@ID1 INT = NULL
	,@ID2 INT = NULL
	,@ID3 INT = NULL
) AS 
BEGIN
	/*
	Operations:
		
		1 - GET All Modules
		2 - CREATE Module Request
		3 - GET Module Owners

	*/  
    BEGIN TRY
		-- GET All Module
        IF @Operation = 1
        BEGIN
			SELECT modules.*
			FROM stng.VV_Admin_Modules as modules
			where ShowInCatalog = 1
			ORDER BY Department asc, Name asc;
        END

		-- CREATE Module Request -- OUTDATED
		IF(@Operation = 2)
		BEGIN
			INSERT INTO [stng].[Admin_ModuleAccess](ModuleID,RequestorID,Reason,Archived,CreatedBy)
			VALUES (
				@ID1, 
				(SELECT UserID FROM stng.Admin_User WHERE EmployeeID = @EmployeeID),
				@Value6,
				0,
				@EmployeeID
			)
			SELECT *
			FROM [stng].[Admin_ModuleAccess]
		END

		-- GET Module Admins
        IF @Operation = 3
        BEGIN
			SELECT *
			FROM [stng].[VV_Admin_ModuleOwners]
        END

		
    END TRY
	BEGIN CATCH
        INSERT INTO stng.App_ErrorLog([Number],[Procedure],[Line],[Message],Operation) VALUES (
			ERROR_NUMBER(),
			ERROR_PROCEDURE(),
			ERROR_LINE(),
			ERROR_MESSAGE(),
			@Operation
		);
		THROW
	END CATCH

END
GO