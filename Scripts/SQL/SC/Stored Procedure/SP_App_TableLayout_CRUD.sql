/*
Author: Raman Molla
Description: A procedure used for CRUD operations on the Save Layouts feature of MainTable.
CreatedDate: 7 March 2023
RevisedDate: 19 Dec 2023
RevisedBy: 
*/
ALTER   PROCEDURE [stng].[SP_App_TableLayout_CRUD](
     @Operation			TINYINT
	,@EmployeeID		varchar(20) = NULL
	,@ShareUserID		INT = NULL
	,@TableLayoutID		INT = NULL
	,@LayoutName		nvarchar(255) = NULL
	,@ModuleName	    nvarchar(255) = NULL
	,@JSONLiteral		nvarchar(MAX) = NULL
) AS 
BEGIN
	/*
	Operations:
		1 - GET TableLayout List
		2 - GET TableLayout JSON
        3 - ADD TableLayout
		4 - UPDATE TableLayout
        5 - DELETE TableLayout
		6 - Share TableLayout
		7 - Get List of Users you can share to
	*/  
    BEGIN TRY
		
		DECLARE @ModuleID INT;
		SELECT @ModuleID = ModuleID FROM stng.Admin_Module where Name = @ModuleName or NameShort = @ModuleName;

		DECLARE @UserID INT;
		SELECT @UserID = UserID FROM stng.Admin_User where EmployeeID = @EmployeeID;

		-- GET TableLayout List
        IF @Operation = 1
			BEGIN
				 SELECT DISTINCT a.[TableLayoutID]
				  ,a.[Name]
				  ,a.[CreationDate]
				  ,a.[ModifiedDate]
				  ,b.FirstName + ' ' + b.LastName as CreatedBy
				  ,b.Username
				  ,CASE WHEN c.UserID IS NULL THEN 'No' ELSE 'Yes' END AS IsSharedWithUser
					FROM [stng].[App_TableLayout] as a
					LEFT JOIN stng.Admin_User as b ON b.UserID = a.UserID
					LEFT JOIN [stng].[App_TableShare] as c ON c.TableLayoutID = a.TableLayoutID AND c.UserID = @UserID
					WHERE a.ModuleID = @ModuleID AND (a.UserID = @UserID OR c.UserID = @UserID) -- Check if the layout is made by the user or shared with user
			END

		-- GET TableLayout JSON
        IF @Operation = 2
			BEGIN
				SELECT [JSONLiteral]
					  FROM [stng].[App_TableLayout]
					  WHERE TableLayoutID = @TableLayoutID
		END

		-- ADD TableLayout
        IF @Operation = 3
			BEGIN
				INSERT INTO [stng].[App_TableLayout](ModuleID,[Name],JSONLiteral,UserID) 
				VALUES (@ModuleID,@LayoutName,@JSONLiteral,@UserID)
			END

		-- UPDATE TableLayout
        IF @Operation = 4
			BEGIN
				if @JSONLiteral = 'noupdate' 
					UPDATE [stng].[App_TableLayout] 
					SET 
						[Name] = @LayoutName ,
						[ModifiedDate] = GETDATE()
					WHERE TableLayoutID = @TableLayoutID
				else
					UPDATE [stng].[App_TableLayout] 
					SET 
						[Name] = @LayoutName, 
						JSONLiteral = @JSONLiteral,
						[ModifiedDate] = GETDATE()
					WHERE TableLayoutID = @TableLayoutID
			END

		-- DELETE TableLayout
        IF @Operation = 5
			BEGIN
				DELETE FROM [stng].[App_TableLayout] 
				WHERE TableLayoutID = @TableLayoutID
			END

	    -- SHARE TableLayout
        IF @Operation = 6
			BEGIN
				INSERT INTO [stng].[App_TableShare](TableLayoutID,UserID,SharedByUserID) 
				VALUES (@TableLayoutID,@ShareUserID,@UserID)
		END

		-- GET List of users that you can share to
		IF @Operation = 7
			BEGIN
			SELECT DISTINCT UserID, FullName FROM stng.FN_Admin_GetUsersForModule(@ModuleName)
			where UserID != @UserID
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
