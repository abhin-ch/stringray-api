CREATE OR ALTER PROCEDURE [stng].[SP_ALR_CRUD](

									@Operation TINYINT,
									@UserID INT = NULL,

									@ADID BIGINT = 2,
									@WMID BIGINT = 2,
									@SourceName NVARCHAR(4) = NULL,
									@ParentID BIGINT = NULL,
									@Deliverable VARCHAR(5) = NULL,
									@AStatus VARCHAR(5) = NULL,
									@Hour INT = NULL,
									@Comment VARCHAR(255) = NULL,
									@WeekStart DATETIME = NULL,
									@UserIDAssigned INT = NULL,									

									@SMSStatus VARCHAR(5) = NULL,

									@AUSIDReturn BIGINT = NULL OUTPUT,
									@Error INTEGER = NULL OUTPUT,
									@ErrorDescription VARCHAR(8000) = NULL OUTPUT
) AS 
BEGIN
	/*
	Operations:
		
		1 - GET ALR MAIN
		2 - GET ALR UserAssignments
		3 - GET ALR Comments
		4 - GET ALR WorkOrders
		5 - GET ALR Related Item
		6 - GET ALR UserAssignment
		7 - GET TAB Row Counts
		8 - CREATE UserAssignment
		9 - UPDATE UserAssignment
		10 - DELETE UserAssignment
		11 - PATCH Status
		12 - GET PossibleAssignments

	*/  
    BEGIN TRY
		-- GET ALR MAIN
        IF @Operation = 1
            BEGIN
               SELECT TOP 1000 * FROM stng.VV_ALR_Main AS V
            END
		-- GET ALR UserAssignments
		ELSE IF @Operation = 2
            BEGIN
                SELECT V.*, V.UserID as AssignedUser, T.FirstName + ' ' + T.LastName as FullName
				FROM stng.VV_ALR_UserAssignment AS V
				LEFT JOIN stng.Admin_User AS T ON T.UserID = V.UserID
				WHERE V.ParentID = @ParentID AND V.WMID = @SourceName AND DeleteRecord is null
            END
		-- GET ALR Comments
		ELSE IF @Operation = 3
            BEGIN
               SELECT * FROM stng.ALR_Comments AS V WHERE V.ParentID = @ParentID and DeletedRecord IS NULL
			END
		-- GET ALR WorkOrders
		ELSE IF @Operation = 4
            BEGIN
				IF @SourceName = 'ISS'
					BEGIN
							SELECT *, 'ISS' as Source FROM [stng].[ALR_ISSWOSupportInfo] WHERE ISSID = @ParentID
					END
				ELSE IF @SourceName = 'CRSS'
					BEGIN 
							SELECT *, 'CRSS' as Source FROM [stng].[ALR_CRSSWOSupportInfo] WHERE CRID = @ParentID
					END
        END
		-- GET ALR Related Item
		ELSE IF @Operation = 5
            BEGIN
				IF @SourceName = 'ISS'
					BEGIN
							SELECT A.ISSID AS ID,A.*,B.ItemNum,B.Description,B.MaximoStatus,B.MaximoStatusDate,B.PUS 
                                    FROM stng.ALR_ItemAndCRLink AS A
                                    INNER JOIN stng.VV_ALR_ISSMain AS B ON B.ISSID = A.ISSID 
                                    WHERE A.CRID = @ParentID
					END
				ELSE IF @SourceName = 'CRSS'
					BEGIN 
							SELECT A.CRID AS ID,A.*,B.CRType,B.CRNum,B.Description,B.MaximoStatus,B.MaximoStatusDate,B.Activity,B.ActivityType 
                                    FROM stng.ALR_ItemAndCRLink AS A 
                                    INNER JOIN stng.VV_ALR_CRSSMain AS B ON B.CRID = A.CRID 
                                    WHERE A.ISSID = @ParentID
				END
		END
		-- GET ALR Activities
		ELSE IF @Operation = 6
				BEGIN
					SELECT A.Wonum, A.Description, A.Status, A.Lead, A.Ownergroup, A.Targcompdate
                    FROM [stng].[ALR_CRSSATSupportInfo] AS A 
                    WHERE CRID = @ParentID
		END	
		-- GET TabRowCounts
		ELSE IF @Operation = 7
				BEGIN
					SELECT
						(SELECT COUNT(*) FROM stng.VV_ALR_UserAssignment WHERE ParentID = @ParentID  AND WMID = @SourceName AND DeleteRecord is null) AS UserAssignments,
						(SELECT COUNT(*) FROM stng.ALR_Comments WHERE ParentID = @ParentID AND DeletedRecord IS NULL) AS Comments,
						(CASE @SourceName
								WHEN 'ISS' THEN (SELECT COUNT(*) FROM [stng].[ALR_ISSWOSupportInfo] WHERE ISSID = @ParentID)
								WHEN 'CRSS' THEN (SELECT COUNT(*) FROM [stng].[ALR_CRSSWOSupportInfo] WHERE CRID = @ParentID)
						ELSE 0 END) AS WorkOrders,
						(CASE @SourceName
								WHEN 'ISS' THEN (SELECT COUNT(*)  FROM stng.ALR_ItemAndCRLink AS A
                                    INNER JOIN stng.VV_ALR_ISSMain AS B ON B.ISSID = A.ISSID 
                                    WHERE A.CRID = @ParentID)
								WHEN 'CRSS' THEN (SELECT COUNT(*) FROM stng.ALR_ItemAndCRLink AS A 
                                    INNER JOIN stng.VV_ALR_CRSSMain AS B ON B.CRID = A.CRID 
                                    WHERE A.ISSID = @ParentID)
						ELSE 0 END) AS RelatedItems,
						(SELECT COUNT(*) FROM [stng].[ALR_CRSSATSupportInfo] AS A WHERE CRID = @ParentID) AS Activities
				END
		-- CREATE UserAssignment
		ELSE IF @Operation = 8
				BEGIN
					INSERT INTO stng.ALR_DAssignment(WMID,ParentID,Deliverable,AStatus,Hour,UserID,Comment,WeekStart,CreatedDate,DateModified,ModifiedBy)
													VALUES(@SourceName,@ParentID,@Deliverable,@AStatus,@Hour,@UserIDAssigned,@Comment,@WeekStart,GETUTCDATE(),GETUTCDATE(),@UserID)
					SELECT @ADID = SCOPE_IDENTITY()
				END
		-- UPDATE UserAssignment*/
		ELSE IF @Operation = 9
			BEGIN
				UPDATE stng.ALR_DAssignment
					SET Deliverable = @Deliverable,
						AStatus = @AStatus,
						Hour = @Hour,
						UserID = @UserID,
						Comment = @Comment,
						WeekStart = @WeekStart,
						DateModified = GETUTCDATE(),
						ModifiedBy = @UserID
						WHERE ADID = @ADID
			END
		-- DELETE UserAssignment*/
		ELSE IF @Operation = 10
			BEGIN
				UPDATE stng.ALR_DAssignment
					SET DeleteRecord = 1,
						DeleteDate = GETUTCDATE(),
						DeleteBy = @UserID
						WHERE ADID = @ADID
			END

		-- PATCH Status */
		ELSE IF @Operation = 11
			BEGIN
				IF @SourceName = 'ISS'
					BEGIN
						UPDATE stng.ALR_ISSMain
							SET IStatus = @SMSStatus,
								LUD = GETUTCDATE(),
								LUB = @UserID
							WHERE ISSID = @ParentID
					END
				ELSE IF @SourceName = 'CRSS'
					BEGIN
						UPDATE stng.ALR_CRSSMain
							SET CRStatus = @SMSStatus,
								LUD = GETUTCDATE(),
								LUB = @UserID
								WHERE CRID = @ParentID
					END
				ELSE IF @SourceName = 8 /*PM*/
					/*BEGIN
						UPDATE stng.TT_0092_PMMain
							SET PStatus = @SMSStatus,
								LUD = GETUTCDATE(),
								LUB = @CurrentUser
								WHERE PMID = @ParentID
					END*/
				/*Update status log*/
				INSERT INTO sms.TT_0030_StatusLog (WMID, ParentID, ModuleStatus, Comment, RAD, RAB)
													VALUES(@SourceName, @ParentID, @SMSStatus, @Comment, GETUTCDATE(), @UserID)
			END

		-- GET PossibleAssignments*/		
		ELSE IF @Operation = 12
			BEGIN
				SELECT U.FullName AS label,U.UserID as value
				FROM [stng].[Admin_User] AS U
				/*LEFT JOIN stng.VV_Admin_UserRole UR ON UR.EmployeeID = U.EmployeeID
				WHERE UR.NameShort = 'Eng-Tech'*/
				ORDER BY FullName
			END

			


		
    END TRY
	BEGIN CATCH
        INSERT INTO stng.App_ErrorLog([Number],[Procedure],[Line],[Message],[Operation], [CreatedDate]) VALUES (
                     ERROR_NUMBER(),
                     ERROR_PROCEDURE(),
                     ERROR_LINE(),
                     ERROR_MESSAGE(),
					 @Operation,
                     FORMAT(GETDATE(),'yyyy-MM-ddTHH:mm:ss.fffZ')
              )
        SET @Error = ERROR_NUMBER()
		SET @ErrorDescription = ERROR_MESSAGE()
	END CATCH

END
GO