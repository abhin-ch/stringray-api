/*
Author: Caleb Depatie
Description: A procedure used for CRUD operations on ETDB in QA. This will execute complete work flows.
CreatedDate: 1 June 2021 
RevisedDate: 01 Jan 2023
RevisedBy: Habib Shakibanejad
*/
CREATE OR ALTER PROCEDURE [stng].[SP_ETDB_CRUD](
	 @Operation TINYINT
	,@SubOp		TINYINT = NULL
	,@EmployeeID INT = NULL
	,@Detail			[stng].ETDB_ScopeDetail READONLY -- cant make null
	,@Value1 NVARCHAR(255) = NULL
	,@Value2 NVARCHAR(255) = NULL
	,@Value3 NVARCHAR(255) = NULL
	,@Value4 NVARCHAR(255) = NULL
	,@Value5 NVARCHAR(255) = NULL
	,@Value6 NVARCHAR(255) = NULL
	,@Value7 NVARCHAR(255) = NULL
	,@Value8 NVARCHAR(max) = NULL
	,@Num1 INT = NULL
	,@Num2 INT = NULL
	,@Num3 INT = NULL
	,@Istrue1 BIT = NULL
	,@Istrue2 BIT = NULL
	,@Date1 DATETIME = NULL
	,@Date2 DATETIME = NULL
	,@PressureBoundaryReview BIT=NULL
	,@Hours decimal(23,9) = null
) AS 
BEGIN
	/*
	Operations:
		1 - Create Scope Sheet + Details
		2 - GET All Active
		3 - UPDATE Sheet or Details
		4 - DELETE Sheet or Details
		5 - INSERT detail
		6 - GET StatusLog
		7 - GET scope detail (for global search)
		8 - GET scope details
		9 - GET ScopingSheet + Details & MPL
		10 - UPDATE ScopingDetail [Flagged] and Update ScopingSheet [Issues] 
		11 - GET EmailBody tempate for Completion/Cancelled Emails 
		12 - GET EmailBody tempate for Tempus Emails 
		13 - UPDATE Whole TDS issues
		14 - UPDATE Whole TDS assignments
		15 - UPDATE TDS
		16 - GET Commitments
	*/  
	BEGIN TRY
		DECLARE @Endpoints stng.[App_Endpoint] -- not required, using for CommonCRUD to remove error 
		DECLARE @PreviousValue NVARCHAR(500)
		DECLARE @ProjectID NVARCHAR(255), @JsonOld NVARCHAR(4000), @JsonNew NVARCHAR(4000)

		/*Create Scope Sheet + Details*/
		IF @Operation = 1
			BEGIN
				DECLARE @TDS         NVARCHAR(255)
				DECLARE @SheetID     NVARCHAR(255)
				DECLARE @Status		 NVARCHAR(255)
				DECLARE @PID         NVARCHAR(255)

				-- retrieve presently largest TDS, possibly overcomplicated
				SET @TDS = (SELECT MAX(CAST(SUBSTRING(SheetID, charindex('-',SheetID)+1, LEN(SheetID)) AS INTEGER)) AS TDS
							FROM [stng].[ETDB_ScopingSheet] WITH (UPDLOCK)
							WHERE ProjectID LIKE CONCAT('CS-',@Value1))

				-- create TDS number
				IF ISNUMERIC(@TDS) = 1 
					SET @TDS = @TDS + 1
				ELSE
					SET @TDS = 1001

				-- create initial status
				IF(@IsTrue1 = 1)
					SELECT @Status = V.Value FROM stng.Common_ValueLabel V 
					INNER JOIN stng.Admin_Module M ON M.ModuleID = V.ModuleID AND M.[Name] = 'ETDB'
					WHERE V.[Group] = 'TDS' AND V.Field = 'Status' AND V.Label = 'Pending TOQ from Vendor'
				ELSE IF(@IsTrue1 = 0 AND @IsTrue2 = 1)
					SELECT @Status = V.Value FROM stng.Common_ValueLabel V 
					INNER JOIN stng.Admin_Module M ON M.ModuleID = V.ModuleID AND M.[Name] = 'ETDB'
					WHERE V.[Group] = 'TDS' AND V.Field = 'Status' AND V.Label = 'New'
				ELSE IF(@IsTrue1 = 0 AND @IsTrue2 = 0)
					SELECT @Status = V.Value FROM stng.Common_ValueLabel V 
					INNER JOIN stng.Admin_Module M ON M.ModuleID = V.ModuleID AND M.[Name] = 'ETDB'
					WHERE V.[Group] = 'TDS' AND V.Field = 'Status' AND V.Label = 'New'

				SET @SheetID = CONCAT(@Value1,'-', @TDS)

				INSERT INTO [stng].[ETDB_ScopingSheet] (SheetID, Title, [Description], ProjectID,[StatusID], 
							NeedDate, [Type], CommitmentID, [External], [Emergent], [Group], [Initiator], CreatedBy,SheetNum,PressureBoundaryReview)
					VALUES (@SheetID, @Value2, @Value8, CONCAT('CS-',@Value1), @Status, @Date1, @Value3,
							@Value5, @IsTrue1, @IsTrue2, @Value4, @Value6,@EmployeeID,@TDS,@PressureBoundaryReview)
		   
				INSERT INTO [stng].[ETDB_ScopeDetail] (Type, Number, Description, SheetID, EstimatedHours,CreatedBy)
					SELECT D.[Type], D.[Number], D.[Description], @SheetID, @Num1, @EmployeeID FROM @Detail D

				INSERT INTO [stng].Common_ChangeLog (ParentID, NewValue, CreatedBy,PreviousValue, AffectedField, AffectedTable)
						SELECT SheetID, 1, @EmployeeID,null,'StatusID', 'ScopingSheet' FROM stng.ETDB_ScopingSheet S WHERE [SheetID] =@SheetID;	
				

				SET @JsonNew = (SELECT * FROM stng.ETDB_ScopingSheet A WHERE A.SheetID = @SheetID FOR JSON AUTO)
				INSERT INTO stng.Common_ChangeLog(NewValue,CreatedBy,AffectedField,AffectedTable,ParentID)
				VALUES (@JsonNew,@EmployeeID,'TDS','ScopingSheet',@SheetID)

				-- return new TDS number
				SELECT * from   [stng].[VV_ETDB_ScopingSheet] where SheetID=@SheetID
			END

		/* Fetch All Active or Archived */
		IF @Operation = 2
			BEGIN
				IF(@IsTrue1 = 0)
				BEGIN
					SELECT * FROM stng.VV_ETDB_ScopingSheet S WHERE S.[Status] != 'Complete' AND S.Status != 'Cancelled' ORDER BY S.CreatedDate Desc

					--Total records : requires tempVariable to make the query as simple to change as possibe]
					--SELECT COUNT(*) FROM stng.VV_0045_ScopingSheet S WHERE S.Status != 'Complete' AND S.Status != 'Cancelled'
				END

				IF(@IsTrue1 = 1)
				BEGIN
					SELECT * FROM stng.VV_ETDB_ScopingSheet S WHERE S.Status = 'Complete' OR  S.Status = 'Cancelled' ORDER BY S.CreatedDate Desc

					--Total records : requires tempVariable to make the query as simple to change as possibe]
					--SELECT COUNT(*) FROM stng.VV_0045_ScopingSheet S WHERE S.Status = 'Complete' OR  S.Status = 'Cancelled'
				END

				-- ScopingSheet Status (Used for Options)
				EXEC [stng].[SP_Common_CRUD] @Operation=1,@Value1='ETDB',@Value2='TDS',@Value3='Status',@Endpoints=@Endpoints

				-- ScopeDetail State (Used for Options)
				EXEC [stng].[SP_Common_CRUD] @Operation=1,@Value1='ETDB',@Value2='Item',@Value3='State',@Endpoints=@Endpoints

				-- Possible assignments
				SELECT U.FullName AS [Name],U.UserID
				FROM [stng].[Admin_User] AS U
				LEFT JOIN stng.VV_Admin_UserRole UR ON UR.EmployeeID = U.EmployeeID
				WHERE UR.Role = 'Engineering Technologist'
				UNION
				SELECT CONCAT('KI-',U.FullName),U.UserID
				FROM [stng].[Admin_User] AS U
				LEFT JOIN stng.VV_Admin_UserRole UR ON UR.EmployeeID = U.EmployeeID
				WHERE UR.Role = 'Eng-Tech External'
				UNION
				SELECT 'Kinectrics',0
				ORDER BY FullName

			END

		--3 - Update Sheet or Details
		IF @Operation = 3
			BEGIN
				/*Scoping Sheet*/
				IF(@SubOp = 1)
	
					BEGIN
						INSERT INTO [stng].Common_ChangeLog (ParentID, NewValue, CreatedBy,PreviousValue, AffectedField, AffectedTable)
						SELECT SheetID, cast(@Num1 as varchar(10)), @EmployeeID,S.[Hours],'Hours', 'ScopingSheet' FROM stng.ETDB_ScopingSheet S WHERE [SheetID] = @Value1;	
						UPDATE stng.ETDB_ScopingSheet SET [Hours] = @Num1 WHERE SheetID = @Value1
					END

				IF(@SubOp = 2)
					BEGIN
						INSERT INTO [stng].Common_ChangeLog (ParentID, NewValue, CreatedBy,PreviousValue, AffectedField, AffectedTable)
						SELECT SheetID, @Num1, @EmployeeID,S.StatusID,'StatusID', 'ScopingSheet' FROM stng.ETDB_ScopingSheet S WHERE [SheetID] = @Value1;	
						UPDATE stng.ETDB_ScopingSheet SET StatusID = @Num1 WHERE SheetID = @Value1
					END

				IF(@SubOp = 3)
					BEGIN
						INSERT INTO [stng].Common_ChangeLog (ParentID, NewDate, CreatedBy,PreviousDate, AffectedField, AffectedTable)
						SELECT SheetID, @Value2, @EmployeeID,S.NeedDate,'NeedDate', 'ScopingSheet' FROM stng.ETDB_ScopingSheet S WHERE [SheetID] = @Value1;	
						UPDATE stng.ETDB_ScopingSheet SET NeedDate = @Value2 WHERE SheetID = @Value1
					END

				/*Scope Detail*/
				IF(@SubOp = 4)
					BEGIN
						INSERT INTO [stng].Common_ChangeLog (ParentID, NewValue,PreviousValue, AffectedField, AffectedTable,CreatedBy)
						SELECT SheetID,@Value1,S.StateID,'State', 'ScopeDetail',@EmployeeID FROM stng.ETDB_ScopeDetail S WHERE S.SDID = @Num1;	
						UPDATE stng.ETDB_ScopeDetail SET StateID = @Value1 WHERE SDID = @Num1;	
					END

				IF(@SubOp = 5)
					BEGIN
						INSERT INTO [stng].Common_ChangeLog (ParentID, NewValue,PreviousValue, AffectedField, AffectedTable,CreatedBy)
						SELECT S.SDID,@Num2,S.EstimatedHours,'EstimatedHours', 'ScopeDetail',@EmployeeID FROM stng.ETDB_ScopeDetail S WHERE S.SDID = @Num1;	
						UPDATE stng.ETDB_ScopeDetail SET EstimatedHours = @Num2 WHERE SDID = @Num1;	
					END
				
				IF(@SubOp = 6)
					BEGIN
						INSERT INTO [stng].Common_ChangeLog (ParentID, NewValue,PreviousValue, AffectedField, AffectedTable,CreatedBy)
						SELECT SDID,@Num2,S.[Hours],'Hours', 'ScopeDetail',@EmployeeID FROM stng.ETDB_ScopeDetail S WHERE S.SDID = @Num1;	
						UPDATE stng.ETDB_ScopeDetail SET [Hours] = @Num2 WHERE SDID = @Num1;	
					END

				IF(@SubOp = 7)
					BEGIN
						INSERT INTO [stng].Common_ChangeLog (ParentID, NewValue,PreviousValue, AffectedField, AffectedTable,CreatedBy)
						SELECT SDID,@Value1,S.AssignedUserID,'AssignedUserID', 'ScopeDetail',@EmployeeID FROM stng.ETDB_ScopeDetail S WHERE S.SDID = @Num1;	
						UPDATE stng.ETDB_ScopeDetail SET AssignedUserID = @Value1 WHERE SDID = @Num1;	
					END
				IF(@SubOp = 8)
					BEGIN
						INSERT INTO [stng].Common_ChangeLog (ParentID, NewValue,PreviousValue, AffectedField, AffectedTable,CreatedBy)
						SELECT SDID,@Value1,S.Number,'Number', 'ScopeDetail',@EmployeeID FROM stng.ETDB_ScopeDetail S WHERE S.SDID = @Num1;	
						UPDATE stng.ETDB_ScopeDetail SET [Number] = @Value1 WHERE SDID = @Num1;	
					END
				IF(@SubOp = 9)
					BEGIN
						INSERT INTO [stng].Common_ChangeLog (ParentID, NewValue,PreviousValue, AffectedField, AffectedTable,CreatedBy)
						SELECT SDID,@Value1,S.Description,'Description', 'ScopeDetail',@EmployeeID FROM stng.ETDB_ScopeDetail S WHERE S.SDID = @Num1;	
						UPDATE stng.ETDB_ScopeDetail SET [Description] = @Value1 WHERE SDID = @Num1;	
					END
				
				IF(@SubOp = 10)
					BEGIN
						INSERT INTO [stng].Common_ChangeLog (ParentID, NewValue, CreatedBy,PreviousValue, AffectedField, AffectedTable)
						SELECT SheetID, @Value2, @EmployeeID,S.CommitmentID,'CommitmentID', 'ScopingSheet' FROM stng.ETDB_ScopingSheet S WHERE [SheetID] = @Value1;	
						UPDATE stng.ETDB_ScopingSheet SET CommitmentID = @Value2,
						[Type] = CASE WHEN @Value2 IS NULL THEN 'Unscheduled' ELSE 'Scheduled' END WHERE SheetID = @Value1
					END
			END

		/*Delete Sheet or Detail*/
		IF @Operation = 4
			BEGIN
				-- Sheet : Note that deleting a sheet also deletes ALL child details
				IF @Value1 IS NOT NULL
					BEGIN
						DELETE FROM stng.ETDB_ScopeDetail WHERE SheetID = @Value1
						DELETE FROM stng.ETDB_ScopingSheet WHERE SheetID = @Value1
						-- delete from changelog
						-- delete from comments
					END
				ELSE -- details : only deletes a single record
					BEGIN	
						DELETE FROM stng.ETDB_ScopeDetail WHERE SDID = @Num1
					END
			END

		/*INSERT detail*/
		IF @Operation = 5 
		BEGIN
			INSERT INTO stng.ETDB_ScopeDetail(SheetID,Description,Type,Number,CreatedBy) 
			SELECT @Value1,D.Description,D.Type,D.Number,@EmployeeID FROM @Detail D;
			SELECT S.SheetID,S.Description,S.Type,S.Number,S.SDID FROM stng.ETDB_ScopeDetail S WHERE S.SheetID = @Value1;
		END

		/*GET Status log*/
		IF @Operation = 6 
			SELECT U.FullName,FORMAT(C.CreatedDate, 'yyyy-MM-dd hh:mm') CreatedDate,NewValue StatusID,V.Label FROM stng.Common_ChangeLog C 
			LEFT JOIN stng.[Admin_User] U ON U.EmployeeID = C.CreatedBy 
			LEFT JOIN stng.Common_ValueLabel V ON V.Value = C.NewValue AND V.[Group] = 'TDS' AND V.Field = 'Status'
			WHERE C.AffectedTable = 'ScopingSheet' AND C.AffectedField = 'StatusID'-- AND C.ParentID = @Value1
			ORDER BY C.CreatedDate DESC
		
		/*GET ScopeDetails for global search*/
		IF @Operation = 7
		BEGIN
			IF(@IsTrue1 = 0)
			BEGIN
				SELECT * FROM stng.VV_ETDB_ScopeDetails A WHERE A.SheetID IN (
				SELECT S.SheetID FROM stng.VV_ETDB_ScopingSheet S WHERE S.[Status] != 'Complete' AND S.Status != 'Cancelled')
			END

			IF(@IsTrue1 = 1)
			BEGIN
				SELECT * FROM stng.VV_ETDB_ScopeDetails A WHERE A.SheetID NOT IN (
				SELECT S.SheetID FROM stng.VV_ETDB_ScopingSheet S WHERE S.[Status] != 'Complete' AND S.Status != 'Cancelled')
			END
		END

		/* GET scope details */
		IF @Operation = 8
			BEGIN                
				-- 1. ScopeDetails
				WITH Comments AS (
					SELECT C.ParentID,C.RelatedID,C.Body, ROW_NUMBER() OVER 
						(PARTITION BY C.RelatedID,C.ParentID ORDER BY C.Pinned DESC, C.CreatedDate DESC) AS RN
					FROM stng.Common_Comment AS C WHERE C.ParentTable = 'ScopeDetail' AND C.RelatedID = @Value1
				)
				SELECT SD.SDID
					,SD.Type
					,SD.Number
					,SD.Description
					,SD.SheetID
					,SD.Comment
					,V.Label AS 'State'
					,SD.Position
					,SD.Hours
					,SD.EstimatedHours
					,SD.AssignedUserID
					,SD.Issues
					,C.Body AS LatestComment
					,SD.StateID
				FROM [stng].[ETDB_ScopeDetail] AS SD
				LEFT JOIN Comments AS C ON C.ParentID = CAST(SD.Number AS NVARCHAR)
				LEFT JOIN stng.Common_ValueLabel V ON V.Value = SD.StateID AND V.[Group] = 'Item' AND Field = 'State' 
				WHERE SD.SheetID = @Value1
				AND (C.RN = 1 OR C.RN IS NULL)
			END

		/*GET ScopingSheet + Details & MPL*/
		IF @Operation = 9
			BEGIN 

				SELECT * FROM stng.VV_ETDB_ScopingSheet S WHERE S.SheetID = @Value1

				SELECT SD.SDID
					,SD.Type
					,SD.Number
					,SD.Description
					,SD.SheetID
					,SD.Comment
					,V.Label AS 'State'
					,SD.Position
					,SD.Hours
					,SD.EstimatedHours
					,SD.AssignedUserID
					,SD.Issues
				FROM [stng].[ETDB_ScopeDetail] AS SD
				LEFT JOIN stng.Common_ValueLabel V ON V.Value = SD.StateID AND V.Field = 'State' AND V.[Group] = 'Item'
				LEFT JOIN stng.Admin_Module MD ON MD.ModuleID = V.ModuleID AND MD.Name = 'ETDB'
				WHERE SD.SheetID = @Value1 

				SELECT [SQID]
					,[SheetID]
					,[Price]
					,[Notes]
					,[FiftyDate]
					,[FinalDate]
					,[CreatedBy]
					,[CreatedDate]
				FROM [stng].[ETDB_ScopeQuote]
				WHERE SheetID = @Value1
			END

		/*Update ScopingDetail [Issues] and Update ScopingSheet [Issues]*/ 
		IF (@Operation = 10)
		BEGIN
			--Update ScopeDetails first 
			UPDATE stng.ETDB_ScopeDetail SET Issues = @IsTrue1 WHERE SDID = @Num1;

			-- Grap Issues count based on previous Flagged to then update ScopingSheets
			SET @IsTrue2 = (SELECT IIF(COUNT(*)>0,1,0) AS [Issues] FROM stng.ETDB_ScopeDetail D 
														WHERE D.Issues = 1 
														AND D.SheetID = @Value1);

			INSERT INTO [stng].Common_ChangeLog (ParentID, NewValue, CreatedBy, AffectedField, AffectedTable,PreviousValue)
			SELECT @Value1, @IsTrue2, @EmployeeID, 'Issues', 'ScopingSheet',Issues FROM stng.ETDB_ScopingSheet WHERE SheetID = @Value1
			UPDATE stng.ETDB_ScopingSheet SET Issues = @IsTrue2 WHERE SheetID = @Value1;

			-- Use this operation to grab TDS details (used to fill email template)
			EXEC stng.SP_ETDB_CRUD @Operation = 9,
				@EmployeeID = @EmployeeID, 
				@Detail = @Detail,
				@Value1 = @Value1
		END

		-- Grab EmailBody tempate for Completion/Cancelled Emails 
		IF (@Operation = 11)
		BEGIN
			SELECT LOWER(U.Email) Email FROM stng.VV_Admin_UserRole UR 
			INNER JOIN stng.Admin_User U ON U.EmployeeID = UR.EmployeeID
			WHERE UR.Role = 'Eng-Tech SPOC'
			
			SELECT T.Content AS [EmailBody] FROM stng.Common_EmailTemplate T WHERE T.[Name] = @Value2;
			SELECT S.SheetID,S.CommitmentID,S.Title,S.[Description],S.LatestComment,S.Emergent,
		    SC.PCS,SC.PCSLANID,C.Email as PCSEmail ,
			SC.BuyerAnalystLANID, G.Email AS BuyerAnalystEmail,
			S.[Initiator],
			SC.MaterialBuyerLANID,D.Email as MaterialBuyerEmail,
			SC.ProjectManager, SC.ProjectManagerLANID,F.Email as ProjectManagerEmail,
			SC.CSFLM,SC.CSFLMLANID,E.Email as CSFLMEmail,s.Assigned
			FROM stng.VV_ETDB_ScopingSheet S 
			LEFT JOIN stng.VV_MPL_SC SC ON SC.ProjectID = S.ProjectID
			LEFT JOIN stng.Admin_User F ON F.LANID = SC.ProjectManagerLANID
			LEFT JOIN stng.Admin_User C ON C.LANID = SC.PCSLANID 
			LEFT JOIN stng.Admin_User D ON D.LANID = SC.MaterialBuyerLANID
			LEFT JOIN stng.Admin_User G ON G.LANID = SC.BuyerAnalystLANID
			LEFT JOIN stng.Admin_User E ON E.LANID = SC.CSFLMLANID 
				CROSS APPLY ( 
				SELECT STRING_AGG(LOWER(U.Email),',') AS AssignedEmail FROM stng.Admin_User U
				INNER JOIN string_split(S.AssignedUserID,',') A ON A.value = U.UserID
			) A
			WHERE S.SheetID = @Value1
		END 

		-- Grab EmailBody tempate for Tempus Pick Emails 
		IF (@Operation = 12)
		BEGIN
			SET @PID = RIGHT(@Value1,5)
			-- Grab email names to send email
			SELECT LOWER(U.Email) Email FROM stng.VV_Admin_UserRole UR 
			INNER JOIN stng.Admin_User U ON U.EmployeeID = UR.EmployeeID
			WHERE UR.Role = 'Eng-Tech SPOC'
		
		SELECT T.Content AS [EmailBody] FROM stng.Common_EmailTemplate T WHERE T.[Name] = 'ETDBTempusPick';

		SELECT (select value from string_split(CostAnalyst,',') ORDER BY value OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY) CostAnalyst,
		CostAnalystLANID,g.Email as CostAnalystEmail,ProjectManager, ProjectManagerLANID, e.Email as ProjectManagerEmail
			FROM stng.VV_MPL_AllProjectData
			Left JOIN stng.Admin_User G ON G.LANID = CostAnalystLANID
			Left JOIN stng.Admin_User E ON E.LANID = ProjectManagerLANID
		 WHERE  [ProjectID] = @PID;
		
		SELECT U.FirstName FullName,LOWER(U.Email) Email FROM stng.VV_Admin_UserRole UR 
			INNER JOIN stng.Admin_User U ON U.EmployeeID = UR.EmployeeID
			WHERE UR.Role = 'Tempus-Pick SPOC'
		END

		-- Update whole TDS issues
		IF (@Operation = 13)
		BEGIN
			INSERT INTO stng.Common_ChangeLog (ParentID, NewValue, CreatedBy,PreviousValue, AffectedField, AffectedTable)
			SELECT SheetID, @IsTrue1, @EmployeeID,[Issues],'Issues', 'ScopingSheet' FROM stng.ETDB_ScopingSheet S WHERE [SheetID] = @Value1;
			UPDATE [stng].[ETDB_ScopingSheet] SET [Issues] = @IsTrue1 WHERE [SheetID] = @Value1;
			
			INSERT INTO stng.Common_ChangeLog (ParentID, NewValue, CreatedBy, AffectedField, AffectedTable,PreviousValue)
			SELECT SDID, @IsTrue1, @EmployeeID, 'Issues', 'ScopeDetail',Issues FROM [stng].[ETDB_ScopeDetail] WHERE SheetID = @Value1
			UPDATE [stng].[ETDB_ScopeDetail] SET Issues = @IsTrue1 WHERE [SheetID] = @Value1

			SELECT E.Content AS Template FROM stng.Common_EmailTemplate E
			INNER JOIN stng.Admin_Module M ON M.ModuleID = E.ModuleID
			WHERE M.Name = 'ETDB' AND E.Name = 'ETDBIssues'

			SELECT S.ProjectID,S.LatestComment,S.Title,S.CommitmentID,FORMAT(S.CreatedDate, 'dd-MMM-yyyy') AS CreatedDate,CONCAT(U.FirstName,' ',U.LastName) AS 'CreatedBy',
			FORMAT(S.NeedDate, 'dd-MMM-yyyy') AS 'NeedDate',S.[Status],CONCAT(U2.FirstName,' ',U2.LastName) AS 'FlaggedBy',M.BuyerAnalystLANID,
			(select value from string_split(M.ProjectManager,',') ORDER BY value OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY) ProjectManager,
						M.ProjectManagerLANID,F.Email as ProjectManagerEmail,
			M.OwnersEngineerLANID,B.Email as OwnersEngineeremail,
			M.PCSLANID,C.Email as PCSEmail,
			M.MaterialBuyerLANID,D.Email as MaterialBuyerEmail,
			M.CSFLMLANID,E.Email as CSFLMemail,
			U2.Email AS 'FlaggedByEmail',
			S.[Initiator],A.AssignedEmail FROM stng.VV_ETDB_ScopingSheet S	
		    INNER JOIN stng.VV_MPL_SC M ON M.ProjectID = S.ProjectID
			Left JOIN stng.Admin_User U ON U.EmployeeID = S.CreatedBy 
			Left JOIN stng.Admin_User F ON F.LANID = M.ProjectManagerLANID
			Left JOIN stng.Admin_User B ON B.LANID = M.OwnersEngineerLANID
			Left JOIN stng.Admin_User C ON C.LANID = M.PCSLANID 
			Left JOIN stng.Admin_User D ON D.LANID = M.MaterialBuyerLANID
			Left JOIN stng.Admin_User G ON G.LANID = M.BuyerAnalystLANID
			Left JOIN stng.Admin_User E ON E.LANID = M.CSFLMLANID 
			LEFT JOIN stng.Admin_User U2 ON U2.EmployeeID = cast(@EmployeeID as varchar)
			CROSS APPLY ( 
				SELECT STRING_AGG(U.Email,',') AS AssignedEmail FROM stng.Admin_User U
				INNER JOIN string_split(S.AssignedUserID,',') A ON A.value = U.UserID
			) A
			WHERE [SheetID] = @Value1
		
			SELECT U.Email as Email FROM stng.VV_Admin_UserRole UR 
			INNER JOIN stng.Admin_User U ON U.EmployeeID = UR.EmployeeID
			WHERE UR.Role = 'Eng-Tech Special Person of Contact'
		END

		-- Update an entire TDSs assignments : Left seperately to change logic after confirming desired functionality
		IF (@Operation = 14)
		BEGIN 
			INSERT INTO stng.Common_ChangeLog (ParentID, NewValue, CreatedBy,PreviousValue, AffectedField, AffectedTable)
			SELECT SheetID, @Value2, @EmployeeID,AssignedUserID,'AssignedUserID', 'ScopingSheet' FROM stng.ETDB_ScopingSheet S WHERE [SheetID] = @Value1;	
			UPDATE [stng].[ETDB_ScopingSheet] SET AssignedUserID = @Value2 WHERE [SheetID] = @Value1;

			INSERT INTO stng.Common_ChangeLog (ParentID, NewValue, CreatedBy, AffectedField, AffectedTable,PreviousValue)
			SELECT SDID, @Value2, @EmployeeID, 'AssignedUserID', 'ScopeDetail',AssignedUserID FROM [stng].[ETDB_ScopeDetail] WHERE SheetID = @Value1
			UPDATE [stng].[ETDB_ScopeDetail] SET AssignedUserID = @Value2 WHERE [SheetID] = @Value1			
		END
		
		/*UPDATE tds*/
		IF (@Operation = 15)
			IF(@SubOp = 1)
			BEGIN
				
				SET @ProjectID = (SELECT ProjectID FROM stng.ETDB_ScopingSheet WHERE SSID = @Value2)
				SET @JsonOld = (SELECT * FROM stng.ETDB_ScopingSheet A WHERE A.SSID = @Value2 FOR JSON AUTO)

				UPDATE stng.ETDB_ScopingSheet SET Title=@Value1
					,[Description]=@Value8
					,[Type]=@Value3
					,[Group]=@Value4
					,CommitmentID=@Value5
					,[Initiator]=@Value6
					,NeedDate=@Date1
					,Emergent=@IsTrue1
					,[External]=@IsTrue2
					,PressureBoundaryReview=@PressureBoundaryReview
				WHERE SSID = @Value2

				--Update ProjectID on all scoping sheets with the new value
				UPDATE stng.ETDB_ScopingSheet SET ProjectID=@Value7, SheetID = CONCAT(SUBSTRING(@Value7,4,LEN(@Value7)),'-',SheetNum)
				WHERE ProjectID = @ProjectID

				SET @JsonNew = (SELECT * FROM stng.ETDB_ScopingSheet A WHERE A.SSID = @Value2 FOR JSON AUTO)

				INSERT INTO stng.Common_ChangeLog(PreviousValue,NewValue,CreatedBy,AffectedField,AffectedTable,ParentID)
				VALUES (@JsonOld,@JsonNew,@EmployeeID,'TDS','ScopingSheet',
				(SELECT TOP 1 SheetID FROM stng.ETDB_ScopingSheet A WHERE A.SSID = @Value2))
				
				INSERT INTO [stng].[ETDB_ScopeDetail] (Type, Number, Description, SheetID, EstimatedHours,CreatedBy)
					SELECT D.[Type], D.[Number], D.[Description], (SELECT TOP 1 SheetID FROM stng.ETDB_ScopingSheet A WHERE A.SSID = @Value2),
					@Num1, @EmployeeID FROM @Detail D
					
			END

		/*GET Commitments*/
		IF(@Operation = 16)
		begin
			SELECT DISTINCT F.ActivityID, F.ActivityName                    
			FROM stng.CARLA_FragnetActivity AS F	               
			WHERE F.ProjShortName = @Value1                    
			AND F.Actualized = 0                    
			AND F.[NCSQ] = 'CSQ'
			union select 'To Be Confirmed','To Be Confirmed'
			union select 'Turbine Controls','Turbine Controls'
			 
			 end

		/*POST MPL information*/
		IF(@Operation = 17)
		begin
	--	 select @SheetID
			 SELECT INTERNALID,CSProjectID,CSProjectName,CSStatus,[Group],CSProjectType,CSPCS,CSProjectPlannerAlternate,CSMaterialBuyer,CSServiceBuyer,
			 CSContractAdmin,CSCSFLM,CSProjectManager,CSProgramManager,CommercialManager,a.ProjectID,CSPortfolio as Portfolio,CSSubPortfolio as SubPortfolio
			 FROM stng.VV_MPL_AllProjectData  a inner join (select ProjectId from stng.VV_ETDB_ScopingSheet where Sheetid=@Value1) b on
			 a.CSProjectID=b.ProjectID
			where [Group] like '%SC%'  
			order by case CSStatus when 'Active' then 1
					when 'On Hold' then 2 
					else 3 end
			, CSProjectID asc
		end




	END TRY
	BEGIN CATCH
		INSERT INTO stng.App_ErrorLog([Number],[Procedure],[Line],[Message],[Operation]) 
		VALUES (ERROR_NUMBER(),
				ERROR_PROCEDURE(),
				ERROR_LINE(),
				ERROR_MESSAGE(),
				@Operation
				);
		THROW
	END CATCH
END




