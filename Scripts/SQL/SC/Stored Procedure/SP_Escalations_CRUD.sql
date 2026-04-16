CREATE OR ALTER PROCEDURE [stng].[SP_Escalations_CRUD](
	 @Operation TINYINT
	,@EmployeeID INT = NULL
	,@SubOp		TINYINT = NULL
	,@PK_ID NVARCHAR(255) = NULL
    ,@Title NVARCHAR(255) = NULL
    ,@ProjectID NVARCHAR(255) = NULL
    ,@Type NVARCHAR(255) = NULL
    ,@ActionWith NVARCHAR(255) = NULL
    ,@ActionDue NVARCHAR(255) = NULL
    ,@Scheduled NVARCHAR(255) = NULL	
	,@CommentBody NVARCHAR(4000) = NULL
	,@ParentID BIGINT = NULL

	,@MPL BIT = NULL
	,@Archive BIT = NULL

    ,@UpdateCol NVARCHAR(255) = NULL
    ,@UpdateVal NVARCHAR(255) = NULL
) AS 
BEGIN
	/*
	Operations:
		1 - Create Escalation
		2 - Read Escalation
		3 - Update Escalation
		4 - Fetch Status Log
	*/  
	BEGIN TRY

	DECLARE @Endpoints stng.[App_Endpoint] -- not required, using for CommonCRUD to remove error 
	/*Create Escalation*/
    IF @Operation = 1
        BEGIN
			DECLARE @Status INT
	
			SET @Status = 1
			SET @PK_ID = NEWID()

            INSERT INTO stng.[Escalation](EscalationID,CreatedBy,ProjectID,StatusID,Title,Type,Scheduled,SCApproval,PMCApproval) 
				VALUES (@PK_ID,@EmployeeID,@ProjectID,@Status,@Title,@Type,@Scheduled,NULL,NULL)

			INSERT INTO stng.[Common_ChangeLog](ParentID,NewValue,CreatedBy,AffectedField,AffectedTable)
				VALUES (@PK_ID,@Status,@EmployeeID,'Status','Escalation')
				
			IF (@CommentBody IS NOT NULL) 
				INSERT INTO stng.[Common_Comment](ParentID,Body,CreatedBy,ParentTable) 
					VALUES(@PK_ID,@CommentBody,@EmployeeID,'Escalation')
        END

	/*Read Escalation*/
    IF @Operation = 2
		BEGIN 
			IF(@Archive = 1) SELECT E.* FROM stng.VV_Escalations_Main E WHERE E.[StatusID] = 3 OR E.[StatusID] = 4 /* = Complete or Removed*/
			IF(@Archive = 0) SELECT E.* FROM stng.VV_Escalations_Main E WHERE E.[StatusID] != 3 AND E.[StatusID] != 4 /* ! = Complete or Removed*/

			-- ScopingSheet Status (Used for Options)
			EXEC [stng].[SP_Common_CRUD] @Operation=1,@Value1='Escalations',@Value2='Main',@Value3='Status'
				
			SELECT * FROM stng.Common_Comment WHERE ParentTable = 'Escalation' ORDER BY CreatedDate DESC
			SELECT C.ParentID,C.CreatedDate,C.CreatedBy,C.NewValue FROM stng.Common_ChangeLog C 
			WHERE AffectedField = 'Status' AND AffectedTable = 'Escalation' ORDER BY CreatedDate DESC
				
		END

	/*Update Escalation*/
    IF(@Operation = 3)
        BEGIN
			IF @SubOp = 1
			BEGIN
				UPDATE stng.Escalation SET stng.Escalation.StatusID = @UpdateVal
				WHERE EscalationID = @PK_ID

				INSERT INTO stng.[Common_ChangeLog](ParentID,NewValue,CreatedBy,AffectedField,AffectedTable,PreviousValue)
				SELECT TOP 1 @PK_ID,@UpdateVal,@EmployeeID,'StatusID','Escalation',E.StatusID FROM stng.Escalation E WHERE E.EscalationID = @PK_ID ORDER BY CreatedDate DESC
			END

			IF @SubOp = 2
			BEGIN
				UPDATE stng.Escalation SET stng.Escalation.Scheduled = @UpdateVal
				WHERE EscalationID = @PK_ID
			END

			IF @SubOp = 3
			BEGIN
				UPDATE stng.Escalation 
				SET stng.Escalation.ActionWith = @UpdateVal
				WHERE EscalationID = @PK_ID
			END

			IF @SubOp = 4
			BEGIN
				Update stng.Escalation 
				SET stng.Escalation.ActionDue = @UpdateVal
				WHERE EscalationID = @PK_ID
			END

			IF @SubOp = 5
			BEGIN
				UPDATE stng.Escalation 
				SET stng.Escalation.Title = @UpdateVal
				WHERE EscalationID = @PK_ID
			END

			IF @SubOp = 6
			BEGIN
				IF @UpdateVal = 'NULL'
					UPDATE stng.Escalation 
					SET stng.Escalation.SCApproval = NULL
					WHERE EscalationID = @PK_ID
				ELSE
					UPDATE stng.Escalation 
					SET stng.Escalation.SCApproval = @UpdateVal
					WHERE EscalationID = @PK_ID
			END

			IF @SubOp = 7 
			BEGIN
				IF @UpdateVal = 'NULL'
					UPDATE stng.Escalation 
					SET stng.Escalation.PMCApproval = NULL
					WHERE EscalationID = @PK_ID
				ELSE
					UPDATE stng.Escalation 
					SET stng.Escalation.PMCApproval = @UpdateVal
					WHERE EscalationID = @PK_ID
			END

			IF @SubOp = 8
			BEGIN
				UPDATE stng.Escalation 
				SET stng.Escalation.Type = @UpdateVal
				WHERE EscalationID = @PK_ID
			END
		END

	/*GET Status Log*/
	IF @Operation = 4
	BEGIN 	
		SELECT U.FullName
			,C.NewValue
			,V.Label AS [Status]
			,C.CreatedDate
			,'Status' AS 'Field'
		FROM stng.Common_ChangeLog C
		INNER JOIN stng.Admin_User U ON U.EmployeeID = C.CreatedBy
		LEFT JOIN stng.Common_ValueLabel V ON V.[Value] = C.NewValue AND V.Field = 'Status' AND V.[Group] = 'Main'
		LEFT JOIN stng.Admin_Module MD ON MD.ModuleID = V.ModuleID AND MD.Name = 'Escalations'
		WHERE C.AffectedTable = 'Escalation' AND C.AffectedField = 'StatusID'
		AND C.ParentID = @PK_ID
	END
				
        
	END TRY
	BEGIN CATCH
		INSERT INTO stng.App_ErrorLog([Number],[Procedure],[Line],[Message],[Operation]) VALUES (
			ERROR_NUMBER(),
			ERROR_PROCEDURE(),
			ERROR_LINE(),
			ERROR_MESSAGE(),
			@Operation
		)
	END CATCH
	
END
