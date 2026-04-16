/****** Object:  StoredProcedure [stng].[SP_MPL_CRUD]    Script Date: 2/27/2026 10:07:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
CreatedBy: John Baran
Created Date: 17 Feb 2023
Description: MPL CRUD

UpdatedBy: Neel Shah
Updated Date: 2 April 2024
Description: MPL CRUD
*/
Create or ALTER PROCEDURE [stng].[SP_MPL_CRUD](

									@Operation TINYINT
									,@EmployeeID VARCHAR(20) = NULL
									,@ProjectID NVARCHAR(40) = NULL
									,@FieldName NVARCHAR(40) = NULL
									,@ProjectUpdateID NVARCHAR(40) = NULL --Unique ID from ChangeRequest/MasterList Table
									,@ApprovalResp BIT = NULL 
									,@AcceptedID stng.TYPE_MPL_AcceptedID readonly
									,@OldUser VARCHAR(20) = NULL
                                    ,@NewUser VARCHAR(20) = NULL
									,@OverruledValue NVARCHAR(100) = NULL
									,@SubOp TINYINT = NULL
									,@field VARCHAR(10) = NULL
									,@OldValue NVARCHAR(255) = NULL
									,@NewValue NVARCHAR(255) = NULL
									,@CurrentUser varchar(50) = null
									,@Value1 NVARCHAR(MAX) = NULL
									,@Value2 NVARCHAR(255) = NULL
									,@Value3 NVARCHAR(255) = NULL
									,@Value4 NVARCHAR(255) = NULL
									,@Value5 NVARCHAR(255) = NULL
									,@ID1 INT = NULL
									,@ID2 INT = NULL
									,@ID3 INT = NULL
									,@Text NVARCHAR(1000) = NULL
									,@UpdateVal NVARCHAR(1000) = NULL
									,@IsTrue1 BIT = NULL
									,@Error INTEGER = NULL OUTPUT,
									 @ErrorDescription VARCHAR(8000) = NULL OUTPUT,
									 @NDQDate datetime=NULL,
									 @ResumeDate datetime=NULL,
									 @Department NVARCHAR(1000) = NULL,
									 @Comment NVARCHAR(1000) = NULL
									
) AS 
BEGIN
	/*
	Operations:
		
		1 - GET All Modules
		2 - Get PMC Data
		3 - Get SC Data
		4 - Get DED Data
		5 - Get User and Department based on @EmployeeID
		6 - Get distinct Status from ENG Projects
		7 - Get distinct Phase from ENG Projects
		8 - Change request process [Checks duplicates, inserts new change requests in Change Request table and Status Log]
		9 - Get all non-approved Change Requests
		10 - Get all non-approved change requests based on Project No
		11 - //Arvind
		12 - Approval and Denial [Changing Approve column in Change Request to 1 or 0] 
		13 - Get Status Log Table
		14 - Check duplicates before approving any Change Request
		15 - Patch overrule value in ChangeTo of Change Request Table
		16 - Get ONLY Change Requests to which the user has the PRIVILEGES for 
		17 - Get mapped list of DED privileges to its presence for signed in User [e.g. Piviledge X : true, Priviledge Y: false]
		18 - Get Approved Change Requests for Lead planner, planner & intern. Also EmailBody. 
		19 - Replace User and email tables & body.
		20 - Operation for MPL ETL to check if requested changes are made in P6 or not. If yes, were the changes made with or without error. 
		21 - get distinct Invoice for ENG Projects
		22 - Email for change request
		23 - Adding NDQdate 

	*/  
    BEGIN TRY

		-- GET All Module
        IF @Operation = 1
        BEGIN
			SELECT INTERNALID,ProjectID,ProjectName,Status,[Group],ProjectEngineer,ProjectManager,ProgramManager,SeniorProgramManager,ProjectPlanner,
			  CostAnalyst,Category,Portfolio,SubPortfolio,Phase,Program,CSProjectID,CSProjectName
			,CSStatus,CSBusinessDriver,CSPCS,CSProjectPlannerAlternate,CSBuyerAnalyst,CSMaterialBuyer,CSServiceBuyer,CSContractAdmin,
		   CSCSFLM,CSProjectManager,CSProgramManager,CSSeniorProgramManager
			,CHARGELIST,CHARGELISTDESC,BUDGETSTAT,ENGProjectID,ENGProjectName,ENGStatus,ENGPhase,ENGPCS,ENGOwnersEngineer,ENGSM,ENGDM,
			ENGProjectPlanner,ENGProgramManager,ENGProjectManager,ENGSeniorProgramManager,
			ENGDiscipline,ENGDepartment,ENGMultiDisc,ENGBusinessDriver,ENGFundingSource,ENGSubPortfolio
			FROM stng.VV_MPL_AllProjectData where ProjectID is not null
			order by case status when 'Active' then 1
					when 'On Hold' then 2 
					else 3 end
			, ProjectID asc
        END

		IF @Operation = 2
        BEGIN
			SELECT INTERNALID,ProjectID,ProjectName,Status,[Group],ProjectEngineer,ProjectManager,ProgramManager,SeniorProgramManager,
			ProjectPlanner,CostAnalyst,Category,Portfolio,SubPortfolio,Phase,Program,MultiDisc,Discipline,
			BusinessDriver,ContractType,FastTrack,Department
			FROM stng.VV_MPL_AllProjectData
			where [Group] like '%PMC%' and ProjectID is not null
			order by case status when 'Active' then 1
					when 'On Hold' then 2 
					else 3 end
			, ProjectID asc

        END
		IF @Operation = 3
        BEGIN
			SELECT INTERNALID,CSProjectID,CSProjectName,CSStatus,[Group],CSProjectType,CSPCS,CSProjectPlannerAlternate,CSMaterialBuyer,CSServiceBuyer,
			 CSContractAdmin,CSCSFLM,CSProjectManager,CSProgramManager,CommercialManager,ProjectID,CSPortfolio as Portfolio,CSSubPortfolio as SubPortfolio
			 FROM stng.VV_MPL_AllProjectData 
			where [Group] like '%SC%'  and ProjectID is not null--and ProjectPlannerAlternate like '%Joseph%'
			order by case CSStatus when 'Active' then 1
					when 'On Hold' then 2 
					else 3 end
			, CSProjectID asc
        END
		IF @Operation = 4
        BEGIN

			SELECT INTERNALID,ENGProjectID,ENGProjectName,ENGStatus,ENGPhase,
					[Group],ENGPCS,ENGOwnersEngineer,ENGSM,ENGDM,ENGProjectPlanner,
					ENGProgramManager,ENGProjectManager,ENGSeniorProgramManager,
					ENGCostAnalyst,ENGDiscipline,ENGDepartment,ENGMultiDisc,ENGFastTrack,
					ENGBusinessDriver,ENGFundingSource,ENGSubPortfolio,ENGInvoice,
					ENGProjectType,Released,actualtotalcost,AvailableBudget,ProjectID,
			      	ENGPCSLANID,   ENGOwnersEngineerLANID,  ENGSMLANID,
				    ENGProjectPlannerLANID,   ENGProjectManagerLANID, ENGProgramManagerLANID
			 FROM [stng].[VV_MPL_AllProjectData]
			where [Group] like '%DED%' and ProjectID is not null
			order by case engstatus when 'Active' then 1
					when 'On Hold' then 2 
					else 3 end
			, ProjectID asc

        END
		IF @Operation = 5
        BEGIN
		 with cte as (
			SELECT case when  b.[EmployeeID] is null then a.[EmployeeID] else b.[EmployeeID] end as [EmployeeID]
		   , case when b.[Department] is null then a.department else b.department end as Department
			 FROM [stng].[VV_MPL_UsersDepartments] as a
			 left join stng.MPL_UserDepartment as b on a.EmployeeID=b.EmployeeID)
			 select * from cte
			where EmployeeID = @EmployeeID
			OPTION(optimize FOR (@EmployeeID unknown));

        END
		IF @Operation = 6
		BEGIN
			SELECT DISTINCT Status
			FROM [stng].[VV_MPL_ENG]
		END
		IF @Operation = 7
		BEGIN
			SELECT DISTINCT Phase
			FROM [stng].[VV_MPL_ENG]

		END
		IF @Operation = 8
		BEGIN
		
			-- Declare variables
			DECLARE @FieldID uniqueidentifier;
			DECLARE @ChangeFromID varchar(20);
			DECLARE @ChangeToID varchar(20);
			DECLARE @isDuplicate bit;
		

			-- Retrieve UniqueID from stng.MPL_Field based on FieldShort value
			SELECT @FieldID = UniqueID
			FROM stng.MPL_Field
			WHERE FieldShort = @field;

			-- Retrieve EmployeeID from stng.Admin_User based on LANID (@OldValue)
			SELECT @ChangeFromID = EmployeeID
			FROM stng.Admin_User
			WHERE LANID = @OldValue;

			-- Retrieve EmployeeID from stng.Admin_User based on LANID (@NewValue)
			SELECT @ChangeToID = EmployeeID
			FROM stng.Admin_User
			WHERE LANID = @NewValue;
		
			--check for duplicates 
			SELECT @isDuplicate = CASE
				WHEN EXISTS (
					SELECT 1
					FROM stng.MPL_ChangeRequest
					WHERE FieldID = @FieldID
					AND  ((
						(@field IN ('Status', 'Phase', 'Invoice') AND ((ChangeFrom = @OldValue AND ChangeTo = @NewValue) 
						OR (@OldValue is NULL and ChangeFrom is NULL and ChangeTo = @NewValue)
						OR(ChangeFrom = @OldValue and @NewValue is NULL and ChangeTo is NULL) ))

						OR ((ChangeFrom = @ChangeFromID AND ChangeTo = @ChangeToID)	
						OR (@ChangeFromID is NULL and ChangeFrom is NULL and ChangeTo = @ChangeToID)
						OR(ChangeFrom = @ChangeFromID and @ChangeToID is NULL and ChangeTo is NULL) ))
					)
					AND ProjectNo = @ProjectID
					AND Approved is NULL
				) THEN 1
				ELSE 0
			END;
			IF @isDuplicate = 0
			BEGIN

					--Created a new UUID
					declare @WorkingUUID uniqueidentifier;
					set @WorkingUUID = NEWID();
					
					insert into temp.WorkingUUIDStorage(WorkingUUID) values(@WorkingUUID)

					-- Insert a new record into [stng].[MPL_ChangeRequest]
					INSERT INTO [stng].[MPL_ChangeRequest]
					(UniqueID, ProjectNo, FieldID, ChangeFrom, ChangeTo, RAB, RAD)
					VALUES
					(
						@WorkingUUID,
						@ProjectID,
						@FieldID,
						-- Use @OldValue as ChangeFrom if @field is 'Status' or 'Phase', else use @ChangeFromID
						CASE WHEN @field IN ('Status', 'Phase', 'Invoice') THEN @OldValue ELSE @ChangeFromID END,
						-- Use @NewValue as ChangeTo if @field is 'Status' or 'Phase', else use @ChangeToID
						CASE WHEN @field IN ('Status', 'Phase', 'Invoice') THEN @NewValue ELSE @ChangeToID END,
						@CurrentUser,
						stng.GetBPTime(GETDATE())
					);


					select @WorkingUUID as ReturnID, case when @field = 'Status' and @OldValue = 'Active' and @NewValue = 'On Hold' then 1 
					when @field = 'Status' and @OldValue = 'On Hold' and @NewValue = 'Active' then 1 else 0 end as IsStatusChanged;

				
				if(@field = 'Status' and @OldValue = 'On Hold' and @NewValue = 'Active')
					begin
								insert into stng.MPL_NDQDate (ProjectID,FK_unique,NDQ_Date,RAB)  
									values(@ProjectID , @WorkingUUID , cast(@NDQDate as date),@CurrentUser  )
					end
					if(@field = 'Status' and @OldValue = 'Active' and @NewValue = 'On Hold')
					begin
								insert into stng.MPL_ResumeDate (ProjectID,FK_unique,Resume_Date,RAB)  
									values(@ProjectID , @WorkingUUID , cast(@ResumeDate as date),@CurrentUser  )
					end

					INSERT INTO [stng].[MPL_StatusLog]
					(ProjectUpdateID, ActionStatus, RAD, RAB)
					VALUES (
					@WorkingUUID,
					CASE 
						WHEN (SELECT Approved from stng.MPL_ChangeRequest WHERE UniqueID = @ProjectUpdateID) = 1 THEN 'Approved'
						WHEN (SELECT Approved from stng.MPL_ChangeRequest WHERE UniqueID = @ProjectUpdateID) = 0 THEN 'Not Approved'
						ELSE 'Change Request'
					END,
					stng.GetBPTime(GETDATE()),
					@CurrentUser
					);
			END;
			SELECT @isDuplicate AS isDuplicate, @field as Field;
		END

		IF @Operation = 9
		BEGIN

		SELECT * 
		from [stng].[VV_MPL_ChangeRequest]
		where Approved is NULL or Approved=0
		order by RAD desc
		END 

		IF @Operation = 10
		BEGIN

		SELECT * 
		from [stng].[VV_MPL_ChangeRequest]
		where ProjectNo = @ProjectID and Approved is NULL
		order by RAD desc
		 OPTION(optimize FOR (@ProjectID unknown))
		

		END 

		IF @Operation = 11
		BEGIN

		IF @SubOp = 1
			BEGIN
				UPDATE stng.MPL_SCEditableFields SET CHARGELIST = @IsTrue1
				WHERE PROJECTID LIKE CONCAT('CS-',@ProjectID)

			END

			IF @SubOp = 2
			BEGIN
				UPDATE stng.MPL_SCEditableFields SET CHARGELISTDESC = @Value1
				WHERE PROJECTID LIKE CONCAT('CS-',@ProjectID)
			END

		
		

		END

		IF @Operation = 12
		BEGIN

		UPDATE stng.MPL_ChangeRequest
		SET Approved = @ApprovalResp
		WHERE UniqueID = @ProjectUpdateID

		INSERT INTO [stng].[MPL_StatusLog]
		(ProjectUpdateID, ActionStatus, RAB, RAD)
		VALUES(
		@ProjectUpdateID,
		CASE 
			WHEN (SELECT Approved from stng.MPL_ChangeRequest WHERE UniqueID = @ProjectUpdateID) = 1 THEN 'Approved'
			WHEN (SELECT Approved from stng.MPL_ChangeRequest WHERE UniqueID = @ProjectUpdateID) = 0 THEN 'Not Approved'
			ELSE 'Change Request'
		END,
		@CurrentUser,
		stng.GetBPTime(GETDATE())
		);
		if(@ApprovalResp=1)
		begin
		if ((select Field from stng.[VV_MPL_ChangeRequestwithEmails] WHERE UniqueID = @ProjectUpdateID)='Status' and 
		(select ChangeFrom from stng.[VV_MPL_ChangeRequestwithEmails] WHERE UniqueID = @ProjectUpdateID)='On Hold' and 
		(select ChangeTo from stng.[VV_MPL_ChangeRequestwithEmails] WHERE UniqueID = @ProjectUpdateID)='Active')
		begin
		SELECT [Content] as EmailBody  FROM [stng].[Common_EmailTemplate] where Name='MPLApproveNDQ'
		end
		else if ((select Field from stng.[VV_MPL_ChangeRequestwithEmails] WHERE UniqueID = @ProjectUpdateID)='Status' and 
		(select ChangeFrom from stng.[VV_MPL_ChangeRequestwithEmails] WHERE UniqueID = @ProjectUpdateID)='Active' and 
		(select ChangeTo from stng.[VV_MPL_ChangeRequestwithEmails] WHERE UniqueID = @ProjectUpdateID)='On Hold')
		begin
		SELECT [Content] as EmailBody  FROM [stng].[Common_EmailTemplate] where Name='MPLApproveResume'
		end
		else
		begin
		SELECT [Content] as EmailBody  FROM [stng].[Common_EmailTemplate] where Name='MPLAprrove'
		end
		
		select * from stng.[VV_MPL_ChangeRequestwithEmails] WHERE UniqueID = @ProjectUpdateID
		
		end
		else
		begin	
			if (@Comment is not null)
			begin
				INSERT INTO [stng].[Common_Comment] 
					([ParentID], [ParentTable], [Body], [CreatedBy]) 
				SELECT TOP 1 UniqueID AS ParentID, 'MPLComment' AS ParentTable,
					@Comment AS Body, @CurrentUser AS CreatedBy 
					FROM [stng].[MPL_StatusLog] WHERE ProjectUpdateID = @ProjectUpdateID ORDER BY RAD desc

				SELECT [Content] as EmailBody  FROM [stng].[Common_EmailTemplate] where Name='MPLRejectWithComment'
			end
			else 
			begin
				SELECT [Content] as EmailBody  FROM [stng].[Common_EmailTemplate] where Name='MPLReject'
			end
			
			select * from stng.[VV_MPL_ChangeRequestwithEmails] WHERE UniqueID = @ProjectUpdateID


		end

		select email as CurrentUserEmail from [stng].[Admin_User] where EmployeeID=@CurrentUser
		
		END

		IF @Operation = 13
		BEGIN
			Select * 
			from stng.VV_MPL_StatusLog as A
			where A.ProjectNo = @ProjectID
			order by A.RAD desc
			 OPTION(optimize FOR (@ProjectID unknown));
		END 

		IF @Operation = 14
		BEGIN
			select count(*) as DuplicateCount
			from stng.VV_MPL_ChangeRequest as A
			where A.ProjectNo = @ProjectID and A.Field = @FieldName and A.Approved is NULL
			 OPTION(optimize FOR (@ProjectID unknown));
		END

		IF @Operation = 15
		BEGIN
			UPDATE stng.MPL_ChangeRequest
			SET ChangeTo = @OverruledValue
			WHERE UniqueID = @ProjectUpdateID
		END

		IF @Operation = 16
		BEGIN

			SELECT *
			FROM stng.VV_MPL_ChangeRequest
			WHERE Approved IS NULL
			  AND (
				('DED-PCS' IN (SELECT  [Permission] as Name	FROM [stng].[VV_Admin_RolePermission] WHERE RoleID IN (SELECT RoleID FROM stng.VV_Admin_UserRole WHERE EmployeeID = @EmployeeID)) AND Field = 'Project Control Specialist')
				OR
				('DED-OE' IN (SELECT  [Permission] as Name	FROM [stng].[VV_Admin_RolePermission] WHERE RoleID IN (SELECT RoleID FROM stng.VV_Admin_UserRole WHERE EmployeeID = @EmployeeID)) AND Field = 'Owners Engineering Lead' AND ProjectSMEmployeeID = @EmployeeID)
				OR
				('DED-SM' IN (SELECT  [Permission] as Name	FROM [stng].[VV_Admin_RolePermission] WHERE RoleID IN (SELECT RoleID FROM stng.VV_Admin_UserRole WHERE EmployeeID = @EmployeeID)) AND Field = 'Section Manager' AND ChangeToRaw = @EmployeeID)
				OR
				('DED-Status' IN (SELECT  [Permission] as Name	FROM [stng].[VV_Admin_RolePermission] WHERE RoleID IN (SELECT RoleID FROM stng.VV_Admin_UserRole WHERE EmployeeID = @EmployeeID)) AND Field = 'Status')
				OR
				('DED-Phase' IN (SELECT  [Permission] as Name	FROM [stng].[VV_Admin_RolePermission] WHERE RoleID IN (SELECT RoleID FROM stng.VV_Admin_UserRole WHERE EmployeeID = @EmployeeID)) AND Field = 'Phase')
				OR
				('DED-Planner' IN (SELECT  [Permission] as Name	FROM [stng].[VV_Admin_RolePermission] WHERE RoleID IN (SELECT RoleID FROM stng.VV_Admin_UserRole WHERE EmployeeID = @EmployeeID)) AND Field = 'Planner')
				OR
				('DED-PM' IN (SELECT  [Permission] as Name	FROM [stng].[VV_Admin_RolePermission] WHERE RoleID IN (SELECT RoleID FROM stng.VV_Admin_UserRole WHERE EmployeeID = @EmployeeID)) AND Field = 'Project Manager')
				OR
				('DED-ProgM' IN (SELECT  [Permission] as Name	FROM [stng].[VV_Admin_RolePermission] WHERE RoleID IN (SELECT RoleID FROM stng.VV_Admin_UserRole WHERE EmployeeID = @EmployeeID)) AND Field = 'Program Manager')
				OR
				('DED-Invoice' IN (SELECT  [Permission] as Name	FROM [stng].[VV_Admin_RolePermission] WHERE RoleID IN (SELECT RoleID FROM stng.VV_Admin_UserRole WHERE EmployeeID = @EmployeeID)) AND Field = 'Invoice')
			  )

			 order by Field, RAD desc;

		END

		If @Operation = 17
		BEGIN
		SELECT
   			Privilege,
   			MAX(CASE WHEN a.Name IS NOT NULL THEN 'true' ELSE 'false' END) AS HasPrivilege
		FROM (
   			VALUES
   			('DED-PCS'),
   			('DED-OE'),
  			('DED-SM'),
  			('DED-Status'),
  			('DED-Phase'),
  			('DED-Planner'),
  			('DED-PM'),
  			('DED-ProgM'),
			('DED-Invoice'),
			('MasterList'),
			('ReplaceUser'),
			('ProjectUpdate'),
			('SendEmail')
   			-- Add more values for other privileges
		) AS PrivilegeList(Privilege)
		LEFT JOIN (
   			SELECT DISTINCT [Permission] as Name
   			FROM [stng].[VV_Admin_RolePermission]
   			WHERE RoleID IN (SELECT RoleID FROM stng.VV_Admin_UserRole WHERE EmployeeID = @EmployeeID)
		) AS a ON PrivilegeList.Privilege = a.Name
		GROUP BY Privilege
			OPTION(optimize FOR (@EmployeeID unknown));
 



		END

		--IF @Operation = 18
		--BEGIN

		---- Convert the string array to a table of uniqueidentifier values using OPENJSON
		---- Info for Lead PLanner
		--SELECT ProjectNo as 'Project No', ActionBy as 'Approved By', Field, ChangeFrom as 'Change From', ChangeTo as 'Change To' 
		--FROM stng.VV_MPL_StatusLog as A
		--INNER JOIN @AcceptedID as B on A.ProjectUpdateID = B.AcceptedID
		--WHERE A.Field in ('Project Control Specialist', 'Owners Engineering', 'Section Manager')
		--and A.ActionStatus = 'Approved'
		--order by A.ProjectNo, A.Field, A.RAD desc;

		---- Convert the string array to a table of uniqueidentifier values using OPENJSON
		---- Info For Planner
		--SELECT ProjectNo as 'Project No', ActionBy as 'Approved By', Field, ChangeFrom as 'Change From', ChangeTo as 'Change To' 
		--FROM stng.VV_MPL_StatusLog as A 
		--INNER JOIN @AcceptedID as B on A.ProjectUpdateID = B.AcceptedID
		--WHERE A.Field in ('Planner', 'Program Manager', 'Project Manager', 'Phase', 'Status')
		--and A.ActionStatus = 'Approved'
		--Order by A.ProjectNo, A.Field, A.RAD desc;

		---- Convert the string array to a table of uniqueidentifier values using OPENJSON
		---- Info For Intern
		--SELECT ProjectNo as 'Project No', ActionBy as 'Approved By', Field, ChangeFrom as 'Change From', ChangeTo as 'Change To' 
		--FROM stng.VV_MPL_StatusLog as A 
		--INNER JOIN @AcceptedID as B on A.ProjectUpdateID = B.AcceptedID
		--WHERE A.Field in ('Invoice')
		--and A.ActionStatus = 'Approved'
		--Order by A.ProjectNo, A.Field, A.RAD desc;

		--SELECT E.Content AS 'EmailBody', 'BNPDESDPROJECTBASELININGREQUEST@brucepower.com' AS 'SendTo' FROM stng.Common_EmailTemplate E WHERE E.[Name] = 'P6UpdateDED';

		--END

		--IF @Operation = 19
		--BEGIN
		--			DECLARE @WorkingInsert TABLE
		--	(
		--		ProjectNo VARCHAR(40),
		--		FieldID VARCHAR(50),
		--		ChangeFrom VARCHAR(100),
		--		ChangeTo VARCHAR(100),
		--		Approved BIT,
		--		RAD DATETIME,
		--		RAB VARCHAR(20)
		--	);

		--	-- Common Table Expressions (CTEs)
		--	WITH employeemapold AS
		--	(
		--		SELECT EmployeeID
		--		FROM stng.Admin_User
		--		WHERE LANID = @OldUser
		--	),
		--	employeemapnew AS
		--	(
		--		SELECT EmployeeID
		--		FROM stng.Admin_User
		--		WHERE LANID = @NewUser
		--	),
		--	allengprojects AS
		--	(
		--		SELECT *
		--		FROM stng.VV_MPL_AllProjectData
		--		WHERE [Group] LIKE '%DED%' AND ENGStatus IN ('ACTIVE', 'ON HOLD')
		--	),
		--	mappings AS
		--	(
		--		SELECT ProjectID, 'SM' AS FieldName
		--		FROM allengprojects
		--		WHERE ENGSMLANID = @OldUser
		--		UNION
		--		SELECT ProjectID, 'PCS' AS FieldName
		--		FROM allengprojects
		--		WHERE ENGPCSLANID = @OldUser
		--		UNION
		--		SELECT ProjectID, 'OE' AS FieldName
		--		FROM allengprojects
		--		WHERE ENGOwnersEngineerLANID = @OldUser
		--		UNION
		--		SELECT ProjectID, 'Planner' AS FieldName
		--		FROM allengprojects
		--		WHERE ENGProjectPlannerLANID = @OldUser
		--		-- Add other unions for different fields
		--	),
		--	mappingswithfld AS
		--	(
		--		SELECT a.*, b.UniqueID AS FieldID
		--		FROM mappings AS a
		--		INNER JOIN stng.MPL_Field AS b ON a.FieldName = b.FieldShort
		--	),
		--	forinsert AS
		--	(
		--		SELECT a.ProjectID AS ProjectNo, a.FieldID, b.EmployeeID AS ChangeFrom, c.EmployeeID AS ChangeTo, 1 AS Approved, stng.GetBPTime(GETDATE()) AS RAD, @EmployeeID AS RAB
		--		FROM mappingswithfld AS a, employeemapold AS b, employeemapnew AS c
		--	)

		--	-- Insert into @WorkingInsert
		--	INSERT INTO @WorkingInsert
		--		(ProjectNo, FieldID, ChangeFrom, ChangeTo, Approved, RAD, RAB)
		--	SELECT ProjectNo, FieldID, ChangeFrom, ChangeTo, Approved, RAD, RAB
		--	FROM forinsert;

		--	-- Insert any existing requests into Status Log before updating them
		--	INSERT INTO stng.MPL_StatusLog
		--		(ProjectUpdateID, ActionStatus, RAD, RAB)
		--	SELECT a.UniqueID, 'Approved upon user replacement', stng.GetBPTime(GETDATE()), @EmployeeID
		--	FROM stng.MPL_ChangeRequest AS a
		--	INNER JOIN @WorkingInsert AS b ON a.ProjectNo = b.ProjectNo AND a.FieldID = b.FieldID AND a.ChangeFrom = b.ChangeFrom AND a.ChangeTo = b.ChangeTo
		--	WHERE a.Approved IS NULL;

		--	-- Approve any existing requests and capture UniqueID
		--	DECLARE @UpdatedChangeRequests TABLE
		--	(
		--		UniqueID UNIQUEIDENTIFIER
		--	);

		--	UPDATE stng.MPL_ChangeRequest
		--	SET Approved = 1
		--	OUTPUT
		--		INSERTED.UniqueID INTO @UpdatedChangeRequests
		--	FROM stng.MPL_ChangeRequest AS a
		--	INNER JOIN @WorkingInsert AS b ON a.ProjectNo = b.ProjectNo AND a.FieldID = b.FieldID AND a.ChangeFrom = b.ChangeFrom AND a.ChangeTo = b.ChangeTo
		--	WHERE a.Approved IS NULL;

		--	-- Add Change Requests (And approve them) for all project/field combos that do not exist
		--	DECLARE @InsertedChangeRequests TABLE
		--	(
		--		UniqueID UNIQUEIDENTIFIER,
		--		ProjectNo VARCHAR(40),
		--		FieldID VARCHAR(50),
		--		ChangeFrom VARCHAR(100),
		--		ChangeTo VARCHAR(100),
		--		Approved BIT,
		--		RAD DATETIME,
		--		RAB VARCHAR(20)
		--	);

		--	INSERT INTO stng.MPL_ChangeRequest
		--		(ProjectNo, FieldID, ChangeFrom, ChangeTo, Approved, RAD, RAB)
		--	OUTPUT
		--		INSERTED.UniqueID, INSERTED.ProjectNo, INSERTED.FieldID, INSERTED.ChangeFrom, INSERTED.ChangeTo, INSERTED.Approved, INSERTED.RAD, INSERTED.RAB
		--	INTO @InsertedChangeRequests
		--	SELECT DISTINCT
		--		a.ProjectNo,
		--		a.FieldID,
		--		a.ChangeFrom,
		--		a.ChangeTo,
		--		a.Approved,
		--		a.RAD,
		--		a.RAB
		--	FROM
		--		@WorkingInsert AS a
		--	LEFT JOIN
		--		stng.MPL_ChangeRequest AS b ON a.ProjectNo = b.ProjectNo AND a.FieldID = b.FieldID AND a.ChangeFrom = b.ChangeFrom AND a.ChangeTo = b.ChangeTo
		--	WHERE
		--		b.UniqueID IS NULL;

		--	-- Insert into MPL_StatusLog
		--	INSERT INTO stng.MPL_StatusLog
		--		(ProjectUpdateID, ActionStatus, RAD, RAB)
		--	SELECT
		--		UniqueID,
		--		'Approved upon user replacement',
		--		stng.GetBPTime(GETDATE()),
		--		@EmployeeID
		--	FROM
		--		@InsertedChangeRequests;

		--	-- Combine ProjectUpdateIDs from both @InsertedChangeRequests and @UpdatedChangeRequests
		--	DECLARE @AllChangeRequests TABLE
		--	(
		--		ProjectUpdateID UNIQUEIDENTIFIER
		--	);

		--	INSERT INTO @AllChangeRequests
		--	SELECT UniqueID FROM @InsertedChangeRequests

		--	INSERT INTO @AllChangeRequests
		--	SELECT UniqueID FROM @UpdatedChangeRequests

		--	-- Retrieve data based on combined ProjectUpdateIDs for Lead Planner
		--	SELECT
		--		d.ProjectNo AS [Project No],
		--		d.ActionBy AS [Approved By],
		--		d.Field,
		--		d.ChangeFrom,
		--		d.ChangeTo
		--	FROM
		--		stng.VV_MPL_StatusLog AS d
		--	WHERE
		--		d.ProjectUpdateID IN (SELECT ProjectUpdateID FROM @AllChangeRequests) and d.Field in ('Project Control Specialist', 'Owners Engineering', 'Section Manager')
		--	ORDER BY
		--		d.ProjectNo, d.Field, d.RAD desc;

		--	-- Retrieve data based on combined ProjectUpdateIDs for Planner
		--	SELECT
		--		d.ProjectNo AS [Project No],
		--		d.ActionBy AS [Approved By],
		--		d.Field,
		--		d.ChangeFrom AS [Change From],
		--		d.ChangeTo AS [Change To]
		--	FROM
		--		stng.VV_MPL_StatusLog AS d
		--	WHERE
		--		d.ProjectUpdateID IN (SELECT ProjectUpdateID FROM @AllChangeRequests) and d.Field in ('Planner', 'Program Manager', 'Project Manager', 'Phase', 'Status')
		--	ORDER BY
		--		d.ProjectNo, d.Field, d.RAD desc;

		--	SELECT E.Content AS 'EmailBody' FROM stng.Common_EmailTemplate E WHERE E.[Name] = 'P6UpdateDED';
		--END

		--IF @Operation = 20
		--BEGIN
		
		--	DECLARE @compareForP6Update TABLE (
		--		UniqueID uniqueidentifier,
		--		ProjectNo INT,
		--		Field VARCHAR(255),
		--		ChangeFrom VARCHAR(255), 
		--		ChangeTo VARCHAR(255) 
		--	);

		--	INSERT INTO @compareForP6Update (UniqueID, ProjectNo, Field, ChangeFrom, ChangeTo)
		--	SELECT
		--		cr.UniqueID,
		--		cr.ProjectNo,

		--		CASE
		--			WHEN mf.FieldShort = 'PCS' THEN 'ENGPCSLANID'
		--			WHEN mf.FieldShort = 'PM' THEN 'ENGPMLANID'
		--			WHEN mf.FieldShort = 'Phase' THEN 'ENGPhase'
		--			WHEN mf.FieldShort = 'SM' THEN 'ENGSMLANID'
		--			WHEN mf.FieldShort = 'Planner' THEN 'ENGProjectPlannerLANID'
		--			WHEN mf.FieldShort = 'OE' THEN 'ENGOwnersEngineerLANID'
		--			WHEN mf.FieldShort = 'ProgM' THEN 'ENGPogMLANID'
		--			WHEN mf.FieldShort = 'Status' THEN 'ENGStatus'
		--			WHEN mf.FieldShort = 'Invoice' THEN 'ENGInvoice'
		--			-- Add other mappings for different fields as needed
		--			ELSE NULL
		--		END AS Field,
		--		CASE
		--			WHEN mf.FieldShort IN ('Status', 'Phase', 'Invoice') THEN cr.ChangeFrom
		--			ELSE vauF.LANID -- Map ChangeFrom to LANID from VV_Admin_UserView
		--		END AS ChangeFrom,
		--		  CASE
		--			WHEN mf.FieldShort IN ('Status', 'Phase', 'Invoice') THEN cr.ChangeTo
		--			ELSE vauT.LANID
		--		END AS ChangeTo
   
  
		--	FROM
		--		stng.MPL_ChangeRequest cr 
		--	JOIN
		--		stng.MPL_Field mf ON cr.FieldID = mf.UniqueID
		--	LEFT JOIN
		--	 	stng.VV_Admin_Users vauF ON cr.ChangeFrom = vauF.EmployeeID
		--	LEFT JOIN
		--		stng.VV_Admin_Users vauT ON cr.ChangeTo = vauT.EmployeeID
		--	where cr.isUpdatedinP6 = 0;



		--	-- Create a table to store the UniqueIDs of records updated in P6 - NO ERRORS 
		--	declare @updatedinP6NoErrors table (
		--		UniqueID uniqueidentifier
		--	);

		--	-- Create a table to store the UniqueIDs of records updated in P6 - WITH ERRORS
		--	declare @updatedinP6WithErrors table (
		--		UniqueID uniqueidentifier
		--	);

		--	-- Insert the UniqueIDs into updatedinP6 based on the comparison criteria
		--	INSERT INTO @updatedinP6NoErrors (UniqueID)
		--	SELECT cu.UniqueID
		--	FROM @compareForP6Update cu
		--	JOIN stng.VV_MPL_AllProjectData apd ON cu.ProjectNo = apd.ProjectID
		--	WHERE 
		--		(cu.Field = 'ENGPCSLANID' AND apd.ENGPCSLANID = cu.ChangeTo)
		--		OR
		--		(cu.Field = 'ENGPMLANID' AND apd.ENGProjectManagerLANID = cu.ChangeTo)
		--		 OR
		--		(cu.Field = 'ENGProjectPlannerLANID' AND apd.ENGProjectPlannerLANID = cu.ChangeTo)
		--		 OR
		--		(cu.Field = 'ENGProgMLANID' AND apd.ENGProjectManagerLANID = cu.ChangeTo)
		--		 OR
		--		(cu.Field = 'ENGOwnersEngineerLANID' AND apd.ENGOwnersEngineerLANID = cu.ChangeTo)
		--		 OR
		--		(cu.Field = 'ENGStatus' AND apd.ENGStatus = cu.ChangeTo)
		--		 OR
		--		(cu.Field = 'ENGPhase' AND apd.ENGPhase = cu.ChangeTo)
		--		 OR
		--		(cu.Field = 'ENGSMLANID' AND apd.ENGSMLANID = cu.ChangeTo)
		--		OR
		--		(cu.Field = 'ENGInvoice' AND apd.ENGInvoice = cu.ChangeTo);

			
		--	Insert into @updatedinP6WithErrors (UniqueID)
		--	select cu.UniqueID
		--	from @compareForP6Update cu
		--	join stng.VV_MPL_AllProjectData apd on cu.ProjectNo = apd.ProjectID
		--	where 
		--		(cu.Field = 'ENGPCSLANID' AND (apd.ENGPCSLANID <> cu.ChangeTo and apd.ENGPCSLANID <> cu.ChangeFrom) )
		--		 OR
		--		(cu.Field = 'ENGPMLANID' AND (apd.ENGProjectManagerLANID <> cu.ChangeTo and apd.ENGProjectManagerLANID <> cu.ChangeFrom))
		--		 OR
		--		(cu.Field = 'ENGProjectPlannerLANID' AND (apd.ENGProjectPlannerLANID <> cu.ChangeTo and apd.ENGProjectPlannerLANID <> cu.ChangeFrom))
		--		 OR
		--		(cu.Field = 'ENGProgMLANID' AND (apd.ENGProgramManagerLANID <> cu.ChangeTo and apd.ENGProgramManagerLANID <> cu.ChangeFrom))
		--		 OR
		--		(cu.Field = 'ENGOwnersEngineerLANID' AND (apd.ENGOwnersEngineerLANID <> cu.ChangeTo and apd.ENGOwnersEngineerLANID <> cu.ChangeFrom))
		--		 OR
		--		(cu.Field = 'ENGStatus' AND (apd.ENGStatus <> cu.ChangeTo and apd.ENGStatus <> cu.ChangeFrom))
		--		 OR
		--		(cu.Field = 'ENGPhase' AND (apd.ENGPhase <> cu.ChangeTo and apd.ENGPhase <> cu.ChangeFrom))
		--		 OR
		--		(cu.Field = 'ENGSMLANID' AND (apd.ENGSMLANID <> cu.ChangeTo and apd.ENGSMLANID <> cu.ChangeFrom))
		--		OR
		--		(cu.Field = 'ENGInvoice' AND (apd.ENGInvoice <> cu.ChangeTo and apd.ENGInvoice <> cu.ChangeFrom));

		--	-- Update isUpdatedinP6 boolean for records without errors
		--	UPDATE stng.MPL_ChangeRequest
		--	SET isUpdatedinP6 = 1
		--	WHERE UniqueID IN (SELECT UniqueID FROM @updatedinP6NoErrors);

		--	-- Insert into stng.MPL_StatusLog for records without errors
		--	INSERT INTO stng.MPL_StatusLog (ProjectUpdateID, ActionStatus, RAB, RAD)
		--	SELECT UniqueID, 'Updated in P6', 'SYSTEM', stng.GetBPTime(GETDATE())
		--	FROM @updatedinP6NoErrors;

		--	-- Insert into stng.MPL_StatusLog for records with errors
		--	INSERT INTO stng.MPL_StatusLog (ProjectUpdateID, ActionStatus, RAB, RAD)
		--	SELECT UniqueID, 'Updated in P6 with error', 'SYSTEM', stng.GetBPTime(GETDATE())
		--	FROM @updatedinP6WithErrors;

		--END

		IF(@Operation = 21)
		BEGIN
		select distinct ENGInvoice from stng.VV_MPL_ENG where ENGInvoice is not null
		END


		IF(@Operation=22)
		Begin
		-- Declare variables to store NDQ and Resume dates
DECLARE @NDQ_DATE DATE, @Resume_DATE DATE;

-- Retrieve NDQ_DATE and Resume_DATE from the relevant records
SELECT 
    @NDQ_DATE = MAX(CAST(NDQ_DATE AS DATE)),
    @Resume_DATE = MAX(CAST(Resume_DATE AS DATE))
FROM [stng].[VV_MPL_ChangeRequestwithEmails] c
INNER JOIN temp.WorkingUUIDStorage w ON c.UniqueID = w.workingUUID;

-- Determine which email template to use based on date values
IF @NDQ_DATE IS NULL AND @Resume_DATE IS NULL
BEGIN
    SELECT T.Content AS [EmailBody]
    FROM stng.Common_EmailTemplate T
    WHERE T.[Name] = 'MPLChangeRequestnoNDQ';
END
ELSE IF @Resume_DATE IS NOT NULL
BEGIN
    SELECT T.Content AS [EmailBody]
    FROM stng.Common_EmailTemplate T
    WHERE T.[Name] = 'MPLChangeRequestResumeDate';
END
ELSE
BEGIN
    SELECT T.Content AS [EmailBody]
    FROM stng.Common_EmailTemplate T
    WHERE T.[Name] = 'MPLChangeRequest';
END

-- Return change request details
SELECT DISTINCT 
    Field,
    ChangeFrom,
    ChangeTo,
    CAST(NDQ_DATE AS DATE) AS NDQ_DATE,
    CAST(Resume_DATE AS DATE) AS Resume_Date
FROM [stng].[VV_MPL_ChangeRequestwithEmails] c
INNER JOIN temp.WorkingUUIDStorage w ON c.UniqueID = w.workingUUID;

-- Return project-related contact information
SELECT DISTINCT 
    ProjectNo,
    ENGSMEmail,
    ActionBy,
    ENGSM,
    ProjectName,
    ProjectManagerEmail,
    ProjectPlannerEmail,
    PCSEmail,
    OEEmail,
    DMEmail,
    actionbyemail,
    'nima.moradi@brucepower.com' AS leadplanner,
    'leon.cramer@brucepower.com' AS DMEP,
    'angela.pawley@brucepower.com' AS pcsmanager
FROM [stng].[VV_MPL_ChangeRequestwithEmails] c
INNER JOIN temp.WorkingUUIDStorage w ON c.UniqueID = w.workingUUID;

-- Clean up temporary storage
DELETE FROM temp.WorkingUUIDStorage;

		END

	
		IF(@Operation = 23)
		BEGIN
			INSERT INTO [stng].[MPL_UserDepartment]  (
							  [Department]
							 ,[EmployeeID] )
					VALUES (@Department ,@EmployeeID)

		 End

		 IF(@Operation = 24)
		 BEGIN
			if (@Comment is not null)
			begin
				INSERT INTO [stng].[Common_Comment] 
					([ParentID], [ParentTable], [Body], [CreatedBy]) 
				SELECT TOP 1 UniqueID, 'MPLComment',
					@Comment, @EmployeeID
					FROM [stng].[MPL_StatusLog] WHERE ProjectUpdateID = 
									(select top 1 uniqueid  from stng.MPL_ChangeRequest where ProjectNo=@ProjectID order by RAD desc)   
					ORDER BY RAD desc

			End
		 End
	

		
	    END TRY
	    BEGIN CATCH
        INSERT INTO stng.App_ErrorLog([Number],[Procedure],[Line],[Message]) VALUES (
                     ERROR_NUMBER(),
                     ERROR_PROCEDURE(),
                     ERROR_LINE(),
                     ERROR_MESSAGE()
              )

        SET @Error = ERROR_NUMBER()
		SET @ErrorDescription = ERROR_MESSAGE()
	END CATCH

END