/*
Author: Habib Shakibanejad
Description: 
CreatedDate: 09 April 2022
*/
CREATE OR ALTER PROCEDURE [stng].[SP_Admin_ReleaseNoteCRUD](
    @Operation			TINYINT
	,@Username			NVARCHAR(50) /*The real Windows Login ID*/
	,@ReleaseNoteID		INT				= NULL
	,@Version			NVARCHAR(255)	= NULL
	,@Module			NVARCHAR(255)	= NULL
	,@Type				NVARCHAR(255)	= NULL
	,@Title				NVARCHAR(255)	= NULL
	,@Description		NVARCHAR(4000)	= NULL
	,@ReleaseDate		DATE			= NULL
	,@AffectedRole		NVARCHAR(255)	= NULL

	,@Error INTEGER = NULL OUTPUT
	,@ErrorDescription NVARCHAR(2000) = NULL OUTPUT
)
AS
BEGIN
    /*
        Operations:
        1 - CREATE Release Note
		2 - GET Release Notes
		3 - UPDATE Release Note
		4 - DELETE Release Note
    */
    BEGIN TRY
        IF @Operation = 1
			INSERT INTO stng.ReleaseNote([Version],[Module],[Type],[Title],[Description],[ReleaseDate],[AffectedRole])
			VALUES (@Version,@Module,@Type,@Title,@Description,@ReleaseDate,@AffectedRole)

		IF @Operation = 2
			SELECT [ReleaseNoteID]
				,[Version]
				,[Module]
				,[Type]
				,[Title]
				,[Description]
				,FORMAT([ReleaseDate], 'dd-MM-yyyy') AS 'ReleaseDate'
				,[AffectedRole]
			FROM [stng].[ReleaseNote]
		
		IF @Operation = 3
			UPDATE stng.ReleaseNote SET Version = @Version
				,Module = @Module
				,Type = @Type
				,Title = @Title
				,Description = @Description
				,ReleaseDate = @ReleaseDate
				,AffectedRole = @AffectedRole
			WHERE ReleaseNoteID = @ReleaseNoteID

		IF @Operation = 4
			DELETE FROM stng.ReleaseNote WHERE ReleaseNoteID = @ReleaseNoteID
    END TRY
    BEGIN CATCH
        INSERT INTO stng.ErrorLog([Number],[Procedure],[Line],[Message])
            VALUES
                (
                    ERROR_NUMBER(),
                    ERROR_PROCEDURE(),
                    ERROR_LINE(),
                    ERROR_MESSAGE()
                )
    END CATCH
END
GO