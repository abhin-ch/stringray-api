/*
Author: Habib Shakibanejad
Description: Use this procedure to store user feedback
CreatedDate: 12 July 2021
RevisedDate:
RevisedBy: 
*/
CREATE OR ALTER PROCEDURE [stng].[SP_Admin_UserFeedback](
	@Operation INT
	,@Username NVARCHAR(255) = NULL
	,@Comment NVARCHAR(2000) = NULL
	,@Type NVARCHAR(255) = NULL
	,@Module NVARCHAR(255) = NULL
	,@Status NVARCHAR(1000) = NULL
	,@AddressedBy NVARCHAR(20) = NULL
	,@Version NVARCHAR(20) = NULL
	,@Resource [stng].[Resource] READONLY
	
	,@FeedbackID INT = NULL
) AS 
BEGIN
/*
	Operation 1: Create new Feedback record
	Operation 2: Update feedback to Addressed
	Operation 3: Retrieve all feedback
	Operation 4: Update Status
	Operation 5: Update AddressedBy
	Operation 6: Retrive Feedback Images
*/
	BEGIN TRY

		--Create new Feedback record
		IF(@Operation = 1)
		BEGIN
			BEGIN
				DECLARE @TempID TABLE (FeedbackID INT)
				INSERT INTO [stng].[UserFeedback](Username,Module,Type,Comment,Version) OUTPUT INSERTED.FeedbackID INTO @TempID VALUES 
				(@Username,@Module,@Type,@Comment,@Version)
				
				SET @FeedbackID = (SELECT TOP 1 T.FeedbackID FROM @TempID T)
				
				INSERT INTO stng.ImageStore(RelatedTable,FKID,ImageContent,FileType)
				SELECT 'UserFeedback',@FeedbackID,A.ImageContent,A.FileType FROM (
					SELECT R.ImageContent,R.FileType FROM @Resource R
				) A

				--Used for email information
				SELECT U.PK_Username AS 'Username',U.Email FROM stng.Users U
				INNER JOIN stng.Role R ON R.RoleId = U.RoleId
				WHERE R.Name = 'Admin' AND U.Active = 1 AND U.EmailFeedback = 1
			END
		END
		
		-- Update feedback to Addressed
		IF(@Operation = 2)
		BEGIN
			UPDATE [stng].[UserFeedback] SET Addressed = 1,
				AddressedOn = GETDATE()
			WHERE FeedbackID = @FeedbackID
		END

		-- Get all feedback
		IF(@Operation = 3)
		BEGIN
			SELECT UPPER(U.PK_Username) AS PK_Username FROM stng.Users U
			INNER JOIN stng.Role R ON R.RoleId = U.RoleId
			WHERE R.Name = 'Admin'
		END

		-- Update Status
		IF(@Operation = 4)
		BEGIN
			UPDATE [stng].[UserFeedback] SET Status = @Status
			WHERE FeedbackID = @FeedbackID			
		END

		-- Update AddressedBy
		IF(@Operation = 5)
		BEGIN
			UPDATE [stng].[UserFeedback] SET AddressedBy = @AddressedBy
			WHERE FeedbackID = @FeedbackID			
		END

		-- Retrieve Feedback Images
		IF(@Operation = 6)
		BEGIN
			SELECT I.ImageContent,I.Name,REPLACE(I.FileType,'image/','') AS 'FileType' FROM stng.ImageStore I WHERE I.FKID = @FeedbackID AND I.RelatedTable = 'UserFeedback'
		END

		SELECT F.FeedbackID
			,F.Username
			,F.Module
			,CASE WHEN F.Type = 'ChangeRequest' THEN 'Change'
				WHEN F.Type = 'NewFeatureRequest' THEN 'New Feature'
				ELSE F.Type
				END AS 'Type'
			,F.Comment
			,FORMAT(F.CreatedDate, 'dd-MMM-yyyy') AS CreatedDate
			,F.Addressed
			,FORMAT(F.AddressedOn, 'dd-MMM-yyyy') AS AddressedOn
			,F.AddressedBy
			,F.Status
			,F.Version
		FROM stng.UserFeedback F 
		ORDER BY F.CreatedDate DESC
	END TRY
	BEGIN CATCH
		INSERT INTO stng.ErrorLog([Number],[Procedure],[Line],[Message]) VALUES (
						 ERROR_NUMBER(),
						 ERROR_PROCEDURE(),
						 ERROR_LINE(),
						 ERROR_MESSAGE()
				  )
	END CATCH
END
GO

/*
CREATE TYPE stng.[Resource] AS TABLE(
	ImageContent VARBINARY(MAX),
	FileType NVARCHAR(5)
)
*/