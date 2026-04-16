CREATE OR ALTER PROCEDURE [stng].[SP_MCRE_DVN_CRUD](
	 @Operation INT
	,@DVNID nvarchar(255) = NULL
	,@DVNActivityDetailID NVARCHAR(255) = NULL
	,@DVNActivityMRoCWeightID NVARCHAR(255) = NULL
	,@SubOp		TINYINT = NULL
	,@Unit NVARCHAR(255) = NULL
    ,@ProjectName NVARCHAR(1000) = NULL
    ,@ProjectID NVARCHAR(100) = NULL
	,@SubProject NVARCHAR (500) = NULL
	,@DVNCause NVARCHAR(MAX) = NULL

	,@Comments NVARCHAR(MAX) = NULL

	,@ActivityID NVARCHAR(255) = NULL
    ,@PCS NVARCHAR(255) = NULL
	,@OE NVARCHAR(255) = NULL
	,@PM NVARCHAR(255) = NULL
	,@SM NVARCHAR(255) = NULL
	,@DM NVARCHAR(255) = NULL
	,@Planner NVARCHAR(255) = NULL

	,@IsApprover NVARCHAR(10) = NULL
	,@IsComplete NVARCHAR(10) = NULL
	,@Field NVARCHAR(10) = NULL

    ,@Description NVARCHAR(1000) = NULL
    ,@RevisedDate DATETIME = NULL
	,@CurrentDate DATETIME = NULL
	,@ActivityName NVARCHAR(MAX) = NULL
	,@ScopeTrend NVARCHAR(100) = NULL
	,@Reason NVARCHAR (1000) = NULL
	,@SCRNum NVARCHAR (50) = NULL
	,@CurrentMRoCWeight NVARCHAR (50) = NULL
	,@RevisedMRoCWeight NVARCHAR (50) = NULL
    ,@Status NVARCHAR(255) = NULL
	
	,@DVNUpdate NVARCHAR(4000) = NULL

	,@CurrentUser varchar(255) = NULL

    ,@UpdateCol NVARCHAR(255) = NULL
    ,@UpdateVal NVARCHAR(255) = NULL

) AS 
BEGIN
BEGIN TRY
	/*
	Operations:
	*/  
    
	IF @Operation = 2
		BEGIN 
			
			IF @IsApprover = 'true'
				BEGIN
				IF @IsComplete = 1
					BEGIN
						SELECT DVNID, 
								UNIT AS Unit, 
								ProjectID, 
								CASE 
									WHEN SubProject IS NULL OR SubProject = '' THEN ProjectName 
								ELSE
									CONCAT(ProjectName, ': ',SubProject) 
								END AS ProjectName,
								MCRProgram,
								DVNCause,
								B.EmpName as PCS,
								C.EmpName as OE,
								D.EmpName as PM,
								E.EmpName as SM,
								F.EmpName as PCM,
								Status,
								A.CreatedDate
								FROM [stng].[MCRE_DVNMain] A
								LEFT OUTER JOIN [stng].[VV_Admin_UserView] B ON A.PCS = B.EmployeeID
								LEFT OUTER JOIN [stng].[VV_Admin_UserView] C ON A.OE = C.EmployeeID
								LEFT OUTER JOIN [stng].[VV_Admin_UserView] D ON a.PM = D.EmployeeID
								LEFT OUTER JOIN [stng].[VV_Admin_UserView] E ON a.SM = E.EmployeeID
								LEFT OUTER JOIN [stng].[VV_Admin_UserView] F ON a.DM = F.EmployeeID
								WHERE Status in ('Complete','Cancelled')
								ORDER BY CreatedDate DESC
					END
				ELSE
					BEGIN
						WITH tempTable AS(SELECT * FROM [stng].[MCRE_DVNStatusLog] Where @CurrentUser = Approver AND Complete = 0)
							SELECT A.DVNID, 
								UNIT AS Unit, 
								ProjectID, 
								CASE 
									WHEN SubProject IS NULL OR SubProject = '' THEN ProjectName 
								ELSE
									CONCAT(ProjectName, ': ',SubProject) 
								END AS ProjectName,
								MCRProgram,
								DVNCause,
								B.EmpName as PCS,
								C.EmpName as OE,
								D.EmpName as PM,
								E.EmpName as SM,
								F.EmpName as PCM,
								OE as OEID,
								SM as SMID,
								DM as DMID,
								PM as PMID,
								A.Status,
								A.CreatedDate
								FROM [stng].[MCRE_DVNMain] A
								LEFT OUTER JOIN [stng].[VV_Admin_UserView] B ON A.PCS = B.EmployeeID
								LEFT OUTER JOIN [stng].[VV_Admin_UserView] C ON A.OE = C.EmployeeID
								LEFT OUTER JOIN [stng].[VV_Admin_UserView] D ON a.PM = D.EmployeeID
								LEFT OUTER JOIN [stng].[VV_Admin_UserView] E ON a.SM = E.EmployeeID
								LEFT OUTER JOIN [stng].[VV_Admin_UserView] F ON a.DM = F.EmployeeID
								JOIN tempTable G ON G.DVNID = A.DVNID AND A.Status = G.Status
								ORDER BY CreatedDate DESC						
					END
				END
			ELSE
				BEGIN
						SELECT DVNID, 
						UNIT AS Unit, 
						ProjectID, 
						CASE 
							WHEN SubProject IS NULL OR SubProject = '' THEN ProjectName 
						ELSE
							CONCAT(ProjectName, ': ',SubProject) 
						END AS ProjectName,
						MCRProgram,
						DVNCause,
						B.EmpName as PCS,
						C.EmpName as OE,
						D.EmpName as PM,
						E.EmpName as SM,
						F.EmpName as PCM,
						OE as OEID,
						SM as SMID,
						DM as DMID,
						PM as PMID,
						Status,
						A.CreatedDate
						FROM [stng].[MCRE_DVNMain] A
						LEFT OUTER JOIN [stng].[VV_Admin_UserView] B ON A.PCS = B.EmployeeID
						LEFT OUTER JOIN [stng].[VV_Admin_UserView] C ON A.OE = C.EmployeeID
						LEFT OUTER JOIN [stng].[VV_Admin_UserView] D ON a.PM = D.EmployeeID
						LEFT OUTER JOIN [stng].[VV_Admin_UserView] E ON a.SM = E.EmployeeID
						LEFT OUTER JOIN [stng].[VV_Admin_UserView] F ON a.DM = F.EmployeeID
						WHERE @CurrentUser = CreatedBy OR
						@CurrentUser = OE OR
						@CurrentUser = PM OR
						@CurrentUser = SM OR
						@CurrentUser = DM
						ORDER BY CreatedDate DESC

				END
		END	
	ELSE IF @Operation = 3
		BEGIN 
			SELECT * FROM [stng].[MCRE_DVNActivityDetails] WHERE DVNID = @DVNID 
		END	
	ELSE IF @Operation = 4
		BEGIN 
			--SELECT  [PROJECTIDNUM],[PROJECTNAME] FROM [stng].[MPL] WHERE PORTFOLIO like '%major%' AND PROJECTID LIKE 'ENG-%' ORDER BY PROJECTIDNUM

			with distinctList as (
				select distinct SUBSTRING(ProjectID,5,5) as num from stngetl.MCRE_DVN_DUMP)
			select CAST([Project ID] AS varchar) AS PROJECTIDNUM, 
			CONCAT([Project ID],': ',[Project Name]) AS PROJECTNAME
			from  temp.MCRProjectList A
			JOIN distinctList B ON A.[Project ID] = CAST(b.num AS INT)
			order by [Project ID]
		
		END	
	ELSE IF @Operation = 5
		BEGIN 			
			DECLARE @NewRev AS INT			
			DECLARE @inserted table(DVNID int);
			DECLARE @NewDVNID AS INT

			INSERT INTO [stng].[MCRE_DVNMain]
           ([Unit]
           ,[ProjectID]
           ,[ProjectName]
		   ,[SubProject]
           ,[MCRProgram]
           ,[PCS]
           ,[OE]
           ,[PM]
           ,[Status]
           ,[Rev]
           ,[CreatedBy])
			OUTPUT INSERTED.DVNID
			INTO @inserted
		   SELECT DISTINCT
			B.UNIT AS Unit,
			B.[Project ID] AS ProjectID,
			B.[Project Name] AS ProjectName,
			@SubProject as SubProject,
			MPL.SUBPORTFOLIO as MCRProgram,
			@PCS AS PCS,
			@OE as OE,
			@PM as PM,
			'Draft' AS Status,
			0 as Rev,
			@CurrentUser
			FROM temp.MCRProjectList B
			LEFT OUTER JOIN [stng].[MPL] MPL ON MPL.PROJECTIDNUM = @ProjectID
			WHERE B.[Project ID] = @ProjectID AND PROJECTIDNUM = @ProjectID 

			SELECT @NewRev = Rev + 1 from [stng].[MCRE_DVNMain] where ProjectName = CONCAT(@ProjectName, ': ',@SubProject);
			SELECT @NewDVNID = (SELECT TOP 1 DVNID FROM @inserted)

			UPDATE [stng].[MCRE_DVNMain]
			SET Rev = @NewRev
			WHERE DVNID = @NewDVNID

			INSERT INTO [stng].[MCRE_DVNStatusLog](DVNID, Status, Complete, Approver, ApproverRole,CreatedBy)
			VALUES
			(@NewDVNID,'Awaiting OE Approval', 0, @OE,'OE',@CurrentUser),
			(@NewDVNID,'Awaiting SM Approval', 0, '','SM',@CurrentUser),
			(@NewDVNID,'Awaiting PM Approval', 0, @PM,'PM',@CurrentUser),
			(@NewDVNID,'Awaiting DM Approval', 0, '','DM',@CurrentUser),
			(@NewDVNID,'Complete', 0, @Planner,'Planner',@CurrentUser);

		END	
	ELSE IF @Operation = 6
		BEGIN  
			DECLARE @subProject2 varchar(500) = (SELECT SubProject FROM [stng].[MCRE_DVNMain] WHERE DVNID = @DVNID)
			IF @subProject2 = ''
				BEGIN
					SELECT B.ActivityID, B.ActivityName, B.baselinefinish,
						CONCAT(B.ActivityID, ' - ',B.ActivityName) AS Activity 
					FROM [stng].[MCRE_DVNMain] A
					LEFT OUTER JOIN [stngetl].[MCRE_DVN_DUMP] B ON CONCAT('ENG-',A.ProjectID) = B.ProjectID
					WHERE A.DVNID = @DVNID AND ActualizedFinish = 0 --ProjectID = CONCAT('ENG-',@ProjectID)
				END
			ELSE
				BEGIN
					SELECT B.ActivityID, B.ActivityName, B.baselinefinish,
						CONCAT(B.ActivityID, ' - ',B.ActivityName) AS Activity 
					FROM [stng].[MCRE_DVNMain] A
					LEFT OUTER JOIN [stngetl].[MCRE_DVN_DUMP] B ON CONCAT('ENG-',A.ProjectID) = B.ProjectID AND A.SubProject = B.Lvl2WBS
					WHERE A.DVNID = @DVNID AND ActualizedFinish = 0 --ProjectID = CONCAT('ENG-',@ProjectID)
				END			
		END
	ELSE IF @Operation = 7
		BEGIN
			SELECT * FROM [stng].[MCRE_DVNActivityMRoCWeights] WHERE DVNID = @DVNID
		END
	ELSE IF @Operation = 8
		BEGIN
			--DECLARE @subProject3 varchar(500) = (SELECT SubProject FROM [stng].[MCRE_DVNMain] WHERE DVNID = @DVNID)
			--IF @subProject3 = ''
				BEGIN
					SELECT ProjectID,ActivityID,ActivityName,CONVERT(VARCHAR,baselinefinish,106) as baselinefinish, MRoCWeight,Lvl2WBS as SubProject 
					FROM [stngetl].[MCRE_DVN_DUMP] 
					WHERE ProjectID = CONCAT('ENG-',@ProjectID)
				END
			--ELSE
			--	BEGIN
			--		SELECT ProjectID,ActivityID,ActivityName,CAST(baselinefinish as date) as baselinefinish, MRoCWeight,Lvl2WBS as SubProject 
			--		FROM [stngetl].[MCRE_DVN_DUMP] 
			--		WHERE ProjectID = CONCAT('ENG-',@ProjectID) AND Lvl2WBS = @subProject3
			--	END
		END
	ELSE IF @Operation = 9
		BEGIN
			SELECT CONCAT(EmpName, ' - ',EmployeeID) AS EmpName, EmployeeID FROM [stng].[VV_Admin_UserView]					
		END
	ELSE IF @Operation = 10
		BEGIN
		
			DECLARE @ActivityExsists varchar(500) = NULL

			SELECT  @ActivityExsists = (CASE WHEN  DVNActivityDetailID IS NOT NULL 
				THEN  'Activity exsists in the list'
				END)
			FROM [stng].[MCRE_DVNActivityDetails]
			WHERE DVNID = @DVNID AND ActivityID = @ActivityID
			
			IF @ActivityExsists IS NULL 
			BEGIN
				INSERT INTO [stng].[MCRE_DVNActivityDetails]
			   ([DVNID]
			   ,[ActivityID]
			   ,[ActivityName]
			   ,[CurrentCommitmentDate]
			   ,[CreatedBy])
			   SELECT 
			   @DVNID,
			   ActivityID,
			   ActivityName,
			   baselinefinish,
			   @CurrentUser
			   FROM [stngetl].[MCRE_DVN_DUMP] WHERE ActivityID =  @ActivityID AND ProjectID = CONCAT('ENG-',@ProjectID)
		   END
		   ELSE
		   BEGIN
				SELECT @ActivityExsists
		   END
		END
	ELSE  IF @Operation = 11
		BEGIN
			IF @Status = 'Draft' OR @Status = 'Draft: Rejected' OR @Status = 'Draft: Withdrawn'
				BEGIN
					DECLARE @DVNCauseError varchar(500) = NULL,
						--@RevisedDateError varchar(500) = NULL,
						@ScopeTrendError varchar(500) = NULL,
						@ReasonError varchar(500) = NULL,
						@SCRNumError varchar(500) = NULL,
						@MRoCWeightError varchar(500) = NULL,
						@DVNUDocMissingError varchar(500) = NULL

					SELECT  @DVNCauseError = (CASE WHEN  DVNCause IS NULL OR DVNCause = ''
						THEN  'Missing dvn cause; '
					END)
					FROM [stng].[MCRE_DVNMain]
					WHERE DVNID = @DVNID;

					--#########################################################
					--WITH tempTable AS(
					--	SELECT TOP 1 
					--	CASE WHEN  RevisedCommitmentDate IS NULL OR RevisedCommitmentDate = ''
					--		THEN  'Missing revised commitment dates; '
					--	END AS DateMissing
					--	FROM [stng].[MCRE_DVNActivityDetails]
					--	WHERE DVNID = @DVNID
					--	ORDER BY DateMissing DESC)

					--SELECT @RevisedDateError = DateMissing FROM tempTable;

					--#########################################################
					WITH tempTable AS(
						SELECT TOP 1 
						CASE WHEN  ScopeTrend IS NULL OR ScopeTrend = ''
							THEN  'Missing Scope or Trend selection for activities; '
						END AS STMissing
						FROM [stng].[MCRE_DVNActivityDetails]
						WHERE DVNID = @DVNID ORDER BY STMissing DESC)

					SELECT @ScopeTrendError = STMissing FROM tempTable;

					--#########################################################
	
					WITH tempTable AS(
						SELECT TOP 1 
						CASE WHEN  Reason IS NULL OR Reason = ''
							THEN  'Missing reason for activities; '
						END AS ReasonMissing
						FROM [stng].[MCRE_DVNActivityDetails]
						WHERE DVNID = @DVNID 
						ORDER BY ReasonMissing DESC)

					SELECT @ReasonError = ReasonMissing FROM tempTable;

					--#########################################################
					WITH tempTable AS(
						SELECT TOP 1 
						CASE WHEN  SCRNum IS NULL OR SCRNum = ''
						THEN  'Missing SCR number for Trend activities; '
						END AS 'SCRMissing'
						FROM [stng].[MCRE_DVNActivityDetails]
						WHERE DVNID = @DVNID AND ScopeTrend = 'Trend' 
						ORDER BY SCRMissing DESC)

					SELECT @SCRNumError = SCRMissing FROM tempTable;

					--#########################################################

					WITH tempTable AS(
						SELECT TOP 1 
						CASE WHEN  RevisedMRoCWeight IS NULL OR RevisedMRoCWeight < 0
						THEN  'Missing MRoC weightage for activities; '
						END AS MROCMissing
						FROM [stng].[MCRE_DVNActivityMRoCWeights]
						WHERE DVNID = @DVNID	
						ORDER BY MROCMissing DESC)
					
					SELECT @MRoCWeightError = MROCMissing FROM tempTable;

					--#########################################################

					--WITH tempTable AS(
					--	SELECT TOP 1 
					--	CASE WHEN  ParentID IS NULL OR RevisedMRoCWeight < 0
					--	THEN  'Missing DVN MRoCs weightage list document, please upload;'
					--	END AS MROCMissing
					--	FROM [stng].[MCRE_DVNActivityMRoCWeights]
					--	WHERE DVNID = @DVNID	
					--	ORDER BY MROCMissing DESC)
					
					--SELECT @DVNUDocMissingError = MROCMissing FROM tempTable;

					--#########################################################
				
					IF @DVNCauseError IS NULL AND @ScopeTrendError IS NULL AND @ReasonError IS NULL AND @SCRNumError IS NULL AND @MRoCWeightError IS NULL
						BEGIN
							DECLARE @lastStatus varchar(100) = (SELECT TOP 1 Status FROM [MCRE_DVNStatusLog] where Complete = 0 AND DVNID = @DVNID ORDER by DVNStatusID)
							UPDATE [stng].[MCRE_DVNMain] SET DM=@DM, SM=@SM, Status = @lastStatus WHERE DVNID = @DVNID
							UPDATE [stng].[MCRE_DVNStatusLog] SET Approver=@SM WHERE DVNID = @DVNID AND ApproverRole = 'SM'
							UPDATE [stng].[MCRE_DVNStatusLog] SET Approver=@DM WHERE DVNID = @DVNID AND ApproverRole = 'DM'

							--Return DVN and other details
							IF @lastStatus = 'Awaiting OE Approval'
								BEGIN
									--Return DVN and other details
											SELECT
											emp.username AS CCEmail,
											oe.username AS ToEmail,
											oe.FirstName AS FirstName
											FROM [stng].MCRE_DVNMain B
											JOIN STNG.VV_Admin_UserView emp ON emp.EmployeeID = b.PCS
											JOIN STNG.VV_Admin_UserView Oe ON oe.EmployeeID = b.OE
											JOIN STNG.VV_Admin_UserView sm ON sm.EmployeeID = b.SM
											WHERE B.DVNID = @DVNID
											----Return email template

											SELECT * FROM [stng].[Common_EmailTemplate] WHERE name = 'DVNApproval'

											----Return Injected Items
											SELECT
											B.Unit,B.ProjectID AS 'Project ID', 
											CASE 
												WHEN SubProject IS NULL OR SubProject = '' THEN ProjectName 
											ELSE
												CONCAT(ProjectName, ': ',SubProject) 
											END AS 'Project Name',B.Status,emp.EmpName AS 'PCS'
 											FROM [stng].MCRE_DVNMain B
											JOIN STNG.VV_Admin_UserView emp ON emp.EmployeeID = b.PCS
											WHERE DVNID = @DVNID

								END
							IF @lastStatus = 'Awaiting SM Approval'
								BEGIN
									--Return DVN and other details
											SELECT
											emp.username+';'+oe.username AS CCEmail,
											sm.username AS ToEmail,
											sm.FirstName AS FirstName
											FROM [stng].MCRE_DVNMain B
											JOIN STNG.VV_Admin_UserView emp ON emp.EmployeeID = b.PCS
											JOIN STNG.VV_Admin_UserView Oe ON oe.EmployeeID = b.OE
											JOIN STNG.VV_Admin_UserView pm ON pm.EmployeeID = b.PM
											JOIN STNG.VV_Admin_UserView sm ON sm.EmployeeID = b.SM
											WHERE B.DVNID = @DVNID

											----Return email template

											SELECT * FROM [stng].[Common_EmailTemplate] WHERE name = 'DVNApproval'

											----Return Injected Items
											SELECT
											B.Unit,B.ProjectID AS 'Project ID', 
											CASE 
												WHEN SubProject IS NULL OR SubProject = '' THEN ProjectName 
											ELSE
												CONCAT(ProjectName, ': ',SubProject) 
											END AS 'Project Name',B.Status,emp.EmpName AS 'PCS'
 											FROM [stng].MCRE_DVNMain B
											JOIN STNG.VV_Admin_UserView emp ON emp.EmployeeID = b.PCS
											WHERE DVNID = @DVNID
								END
							IF @lastStatus = 'Awaiting PM Approval'
								BEGIN
									--Return DVN and other details
											SELECT
											emp.username+';'+oe.username+';'+sm.Username AS CCEmail,
											pm.username AS ToEmail,
											pm.FirstName AS FirstName
											FROM [stng].MCRE_DVNMain B
											JOIN STNG.VV_Admin_UserView emp ON emp.EmployeeID = b.PCS
											JOIN STNG.VV_Admin_UserView Oe ON oe.EmployeeID = b.OE
											JOIN STNG.VV_Admin_UserView pm ON pm.EmployeeID = b.PM
											JOIN STNG.VV_Admin_UserView sm ON sm.EmployeeID = b.SM
											JOIN STNG.VV_Admin_UserView dm ON dm.EmployeeID = b.DM
											WHERE B.DVNID = @DVNID
											
											----Return email template

											SELECT * FROM [stng].[Common_EmailTemplate] WHERE name = 'DVNApproval'

											----Return Injected Items
											SELECT
											B.Unit,B.ProjectID AS 'Project ID', 
											CASE 
												WHEN SubProject IS NULL OR SubProject = '' THEN ProjectName 
											ELSE
												CONCAT(ProjectName, ': ',SubProject) 
											END AS 'Project Name',B.Status,emp.EmpName AS 'PCS'
 											FROM [stng].MCRE_DVNMain B
											JOIN STNG.VV_Admin_UserView emp ON emp.EmployeeID = b.PCS
											WHERE DVNID = @DVNID

								END
							IF @lastStatus = 'Awaiting DM Approval'
								BEGIN
									--Return DVN and other details
											SELECT
											emp.username+';'+oe.username+';'+sm.Username+';'+pm.Username AS CCEmail,
											dm.username AS ToEmail,
											dm.FirstName AS FirstName
											FROM [stng].MCRE_DVNMain B
											JOIN STNG.VV_Admin_UserView emp ON emp.EmployeeID = b.PCS
											JOIN STNG.VV_Admin_UserView Oe ON oe.EmployeeID = b.OE
											JOIN STNG.VV_Admin_UserView pm ON pm.EmployeeID = b.PM
											JOIN STNG.VV_Admin_UserView sm ON sm.EmployeeID = b.SM
											JOIN STNG.VV_Admin_UserView dm ON dm.EmployeeID = b.DM
											WHERE B.DVNID = @DVNID
											
											----Return email template

											SELECT * FROM [stng].[Common_EmailTemplate] WHERE name = 'DVNApproval'

											----Return Injected Items
											SELECT
											B.Unit,B.ProjectID AS 'Project ID', 
											CASE 
												WHEN SubProject IS NULL OR SubProject = '' THEN ProjectName 
											ELSE
												CONCAT(ProjectName, ': ',SubProject) 
											END AS 'Project Name',B.Status,emp.EmpName AS 'PCS'
 											FROM [stng].MCRE_DVNMain B
											JOIN STNG.VV_Admin_UserView emp ON emp.EmployeeID = b.PCS
											WHERE DVNID = @DVNID
								END


						INSERT INTO [stng].[MCRE_DVNStatusLogItems](DVNID,Status,Approver,Comments) 
						SELECT @DVNID,
								CASE WHEN @Status = 'Draft' THEN 'Draft'
								ELSE 'Draft: Resubmission'
								END,
								@CurrentUser,
								@Comments
						END
					ELSE
						BEGIN
							 SELECT CONCAT(@DVNCauseError,@ScopeTrendError,@ReasonError,@SCRNumError,@MRoCWeightError) AS Result
							 SELECT 1 AS Result
						END
				END
			ELSE 
				BEGIN
					SELECT 0 AS Result
					SELECT @Status
				END
		END
	ELSE IF @Operation = 12
		BEGIN
			DECLARE @MROCActivityExsists varchar(500) = NULL

			SELECT  @MROCActivityExsists = (CASE WHEN  DVNActivityMRoCWeightID IS NOT NULL 
				THEN  'Activity exsists in the list'
				END)
			FROM [stng].[MCRE_DVNActivityMRoCWeights]
			WHERE DVNID = @DVNID AND ActivityID = @ActivityID
			
			IF @MROCActivityExsists IS NULL 
			BEGIN
				INSERT INTO [stng].[MCRE_DVNActivityMRoCWeights]
			   ([DVNID]
			   ,[ActivityID]
			   ,[ActivityName]
			   ,[CurrentMRoCWeight]
			   ,[CreatedBy])
			   SELECT
			   @DVNID,
			   ActivityID,
			   ActivityName,
			   MRocWeight,
			   @CurrentUser
			   FROM [stngetl].[MCRE_DVN_DUMP] WHERE ActivityID =  @ActivityID AND ProjectID = CONCAT('ENG-',@ProjectID)
		   END
		   ELSE
		   BEGIN
			SELECT @MROCActivityExsists
		   END
		END
	ELSE IF @Operation = 13
		BEGIN
			IF @ScopeTrend = 'All'
			BEGIN
				SELECT Reason, [Status] FROM stng.MCRE_DVNReasons
			END
			ELSE
			BEGIN
				SELECT Reason FROM stng.MCRE_DVNReasons WHERE Status = @ScopeTrend
			END
			
		END
	ELSE IF @Operation = 14
		BEGIN
			DECLARE @DVNRemove varchar(500) = NULL

			SELECT  @DVNRemove = (CASE WHEN  Status <> 'DRAFT'
				THEN  'DVN cannot be removed as its not in DRAFT status.'
			END)
			FROM [stng].[MCRE_DVNMain]
			WHERE DVNID = @DVNID;

			IF @DVNRemove IS NULL
				BEGIN
					DELETE FROM [stng].[MCRE_DVNMain] where DVNID = @DVNID AND Status = 'DRAFT'	
					SELECT '' AS Result
				END
			ELSE
				BEGIN
					SELECT @DVNRemove AS Result
					SELECT 1 AS Result
				END
		END
	ELSE IF @Operation = 15			
		BEGIN
			SELECT  CONVERT(VARCHAR,a.CreatedDate,106) AS 'Date',
					emp.FirstName + ' ' + emp.LastName AS 'Approver',
					a.Status,
					a.Comments
			FROM [stng].[MCRE_DVNStatusLogItems] a
			JOIN STNG.VV_Admin_UserView emp ON emp.EmployeeID = a.Approver
			WHERE DVNID = @DVNID
			ORDER BY a.CreatedDate DESC
		END
	ELSE IF @Operation = 16
		BEGIN
			SELECT CONCAT(EmpName, ' - ',EmployeeID) AS EmpName, EmployeeID FROM [stng].[VV_Admin_UserView]	
		END
	ELSE IF @Operation = 17
		BEGIN		
			UPDATE [stng].[MCRE_DVNMain] 
			SET OE =  @OE,
			PM = @PM,
			SM = @SM,
			DM = @DM
			where DVNID = @DVNID AND Status <> 'Complete'
			
			Update [stng].[MCRE_DVNStatusLog] SET Approver = @OE WHERE ApproverRole = 'OE' AND DVNID = @DVNID
			Update [stng].[MCRE_DVNStatusLog] SET Approver = @SM WHERE ApproverRole = 'SM' AND DVNID = @DVNID
			Update [stng].[MCRE_DVNStatusLog] SET Approver = @PM WHERE ApproverRole = 'PM' AND DVNID = @DVNID
			Update [stng].[MCRE_DVNStatusLog] SET Approver = @DM WHERE ApproverRole = 'DM' AND DVNID = @DVNID

			
		END	
	ELSE IF @Operation = 18
		BEGIN
			UPDATE [stng].[MCRE_DVNActivityMRoCWeights] SET RevisedMRoCWeight = CONVERT(decimal(18,4),@RevisedMRoCWeight) where DVNActivityMRoCWeightID = @DVNActivityMRoCWeightID
		END
	ELSE IF @Operation = 19
		BEGIN
			UPDATE [stng].[MCRE_DVNMain] SET DVNCause = @DVNCause where [DVNID] = @DVNID
		END
	ELSE IF @Operation = 20
		BEGIN
			--UPDATE [stng].[MCRE_DVNStatusLog] SET Complete = 0, AprrovedDate = NULL WHERE DVNID = @DVNID AND Status = 'Draft'
			UPDATE [stng].[MCRE_DVNMain] SET Status='Draft: Rejected' WHERE DVNID = @DVNID AND STATUS LIKE 'Awaiting %'

			--Return DVN and other details
							SELECT
							oe.username AS CCEmail,
							emp.username AS ToEmail,
							emp.FirstName AS FirstName
							FROM [stng].MCRE_DVNMain B
							JOIN STNG.VV_Admin_UserView emp ON emp.EmployeeID = b.PCS
							JOIN STNG.VV_Admin_UserView Oe ON oe.EmployeeID = @CurrentUser
							WHERE B.DVNID = @DVNID

							----Return email template
							SELECT * FROM [stng].[Common_EmailTemplate] WHERE name = 'DVNReject'

							----Return Injected Items
							SELECT
							B.Unit,B.ProjectID AS 'Project ID', 
							CASE 
								WHEN SubProject IS NULL OR SubProject = '' THEN ProjectName 
							ELSE
								CONCAT(ProjectName, ': ',SubProject) 
							END AS 'Project Name',
							'Draft: Rejected' AS Status,
							emp.EmpName AS 'PCS'
 							FROM [stng].MCRE_DVNMain B
							JOIN STNG.VV_Admin_UserView emp ON emp.EmployeeID = b.PCS
							WHERE DVNID = @DVNID

			INSERT INTO [stng].[MCRE_DVNStatusLogItems](DVNID,Status,Approver,Comments) VALUES(@DVNID,'Draft: Rejected',@CurrentUser,@Comments)
		END
	ELSE IF @Operation = 21
		BEGIN
			IF @Status = 'Awaiting OE Approval'
				BEGIN
					UPDATE [stng].[MCRE_DVNStatusLog] SET Complete = 1, AprrovedDate = GETDATE() WHERE DVNID = @DVNID AND Approver = @CurrentUser AND ApproverRole = 'OE'
					UPDATE [stng].[MCRE_DVNMain] SET Status='Awaiting SM Approval' WHERE DVNID = @DVNID
						--Return DVN and other details
							SELECT
							emp.username+';'+oe.username AS CCEmail,
							sm.username AS ToEmail,
							sm.FirstName AS FirstName
							FROM [stng].MCRE_DVNMain B
							JOIN STNG.VV_Admin_UserView emp ON emp.EmployeeID = b.PCS
							JOIN STNG.VV_Admin_UserView Oe ON oe.EmployeeID = b.OE
							JOIN STNG.VV_Admin_UserView sm ON sm.EmployeeID = b.SM
							WHERE B.DVNID = @DVNID

							----Return email template
							SELECT * FROM [stng].[Common_EmailTemplate] WHERE name = 'DVNApproval'

							----Return Injected Items
							SELECT
							B.Unit,B.ProjectID AS 'Project ID', 
							CASE 
								WHEN SubProject IS NULL OR SubProject = '' THEN ProjectName 
							ELSE
								CONCAT(ProjectName, ': ',SubProject) 
							END AS 'Project Name',B.Status,emp.EmpName AS 'PCS'
 							FROM [stng].MCRE_DVNMain B
							JOIN STNG.VV_Admin_UserView emp ON emp.EmployeeID = b.PCS
							WHERE DVNID = @DVNID

					INSERT INTO [stng].[MCRE_DVNStatusLogItems](DVNID,Status,Approver,Comments) VALUES(@DVNID,'Approved by OE',@CurrentUser,@Comments)
				END
			IF @Status = 'Awaiting SM Approval'
				BEGIN
					UPDATE [stng].[MCRE_DVNStatusLog] SET Complete = 1, AprrovedDate = GETDATE() WHERE DVNID = @DVNID AND Approver = @CurrentUser AND ApproverRole = 'SM'
					UPDATE [stng].[MCRE_DVNMain] SET Status='Awaiting PM Approval' WHERE DVNID = @DVNID
					--Return DVN and other details
							SELECT
							emp.username+';'+oe.username+';'+sm.Username AS CCEmail,
							pm.username AS ToEmail,
							pm.FirstName AS FirstName
							FROM [stng].MCRE_DVNMain B
							JOIN STNG.VV_Admin_UserView emp ON emp.EmployeeID = b.PCS
							JOIN STNG.VV_Admin_UserView Oe ON oe.EmployeeID = b.OE
							JOIN STNG.VV_Admin_UserView pm ON pm.EmployeeID = b.PM
							JOIN STNG.VV_Admin_UserView sm ON sm.EmployeeID = b.SM
							WHERE B.DVNID = @DVNID

							----Return email template
							SELECT * FROM [stng].[Common_EmailTemplate] WHERE name = 'DVNApproval'

							----Return Injected Items
							SELECT
							B.Unit,B.ProjectID AS 'Project ID', 
							CASE 
								WHEN SubProject IS NULL OR SubProject = '' THEN ProjectName 
							ELSE
								CONCAT(ProjectName, ': ',SubProject) 
							END AS 'Project Name',B.Status,emp.EmpName AS 'PCS'
 							FROM [stng].MCRE_DVNMain B
							JOIN STNG.VV_Admin_UserView emp ON emp.EmployeeID = b.PCS
							WHERE DVNID = @DVNID
				
					INSERT INTO [stng].[MCRE_DVNStatusLogItems](DVNID,Status,Approver,Comments) VALUES(@DVNID,'Approved by SM',@CurrentUser,@Comments)
				END
			IF @Status = 'Awaiting PM Approval'
				BEGIN
					UPDATE [stng].[MCRE_DVNStatusLog] SET Complete = 1, AprrovedDate = GETDATE() WHERE DVNID = @DVNID AND Approver = @CurrentUser AND ApproverRole = 'PM'
					UPDATE [stng].[MCRE_DVNMain] SET Status='Awaiting DM Approval' WHERE DVNID = @DVNID
							--Return DVN and other details
							SELECT
							emp.username+';'+oe.username+';'+sm.Username+';'+pm.Username AS CCEmail,
							dm.username AS ToEmail,
							dm.FirstName AS FirstName
							FROM [stng].MCRE_DVNMain B
							JOIN STNG.VV_Admin_UserView emp ON emp.EmployeeID = b.PCS
							JOIN STNG.VV_Admin_UserView Oe ON oe.EmployeeID = b.OE
							JOIN STNG.VV_Admin_UserView pm ON pm.EmployeeID = b.PM
							JOIN STNG.VV_Admin_UserView sm ON sm.EmployeeID = b.SM
							JOIN STNG.VV_Admin_UserView dm ON dm.EmployeeID = b.DM
							WHERE B.DVNID = @DVNID

							----Return email template
							SELECT * FROM [stng].[Common_EmailTemplate] WHERE name = 'DVNApproval'

							----Return Injected Items
							SELECT
							B.Unit,B.ProjectID AS 'Project ID', 
							CASE 
								WHEN SubProject IS NULL OR SubProject = '' THEN ProjectName 
							ELSE
								CONCAT(ProjectName, ': ',SubProject) 
							END AS 'Project Name',B.Status,emp.EmpName AS 'PCS'
 							FROM [stng].MCRE_DVNMain B
							JOIN STNG.VV_Admin_UserView emp ON emp.EmployeeID = b.PCS
							WHERE DVNID = @DVNID
				
					INSERT INTO [stng].[MCRE_DVNStatusLogItems](DVNID,Status,Approver,Comments) VALUES(@DVNID,'Approved by PM',@CurrentUser,@Comments)
				END
			IF @Status = 'Awaiting DM Approval'
				BEGIN
					UPDATE [stng].[MCRE_DVNStatusLog] SET Complete = 1, AprrovedDate = GETDATE() WHERE DVNID = @DVNID AND Approver = @CurrentUser AND ApproverRole = 'DM'
					UPDATE [stng].[MCRE_DVNMain] SET Status='Complete' WHERE DVNID = @DVNID

							SELECT
							emp.username+';'+oe.username+';'+sm.Username+';'+pm.Username+';'+dm.Username +';nima.moradi@brucepower.com;petri.hotari@brucepower.com;zubair.syed@brucepower.com' AS CCEmail,
							--emp.username+';'+oe.username+';'+sm.Username+';'+pm.Username+';'+dm.Username AS CCEmail,
							--'nima.moradi@brucepower.com' AS CCEmail,
							--'jaykumar.ahir@brucepower.com' AS ToEmail,
							--dm.username AS ToEmail,-->need to change to BNPD Global Email
							'BNPDESDPROJECTBASELININGREQUEST@brucepower.com' AS ToEmail,
							'Team' AS FirstName,
							emp.FirstName + ' ' + emp.LastName as PCSName,
							oe.FirstName + ' ' + oe.LastName as OEName,
							pm.FirstName + ' ' + pm.LastName as PMName
							FROM [stng].MCRE_DVNMain B
							JOIN STNG.VV_Admin_UserView emp ON emp.EmployeeID = b.PCS
							JOIN STNG.VV_Admin_UserView oe ON oe.EmployeeID = b.OE
							JOIN STNG.VV_Admin_UserView pm ON pm.EmployeeID = b.PM
							JOIN STNG.VV_Admin_UserView sm ON sm.EmployeeID = b.SM
							JOIN STNG.VV_Admin_UserView dm ON dm.EmployeeID = b.DM
							WHERE B.DVNID = @DVNID

							----Return email template
							SELECT * FROM [stng].[Common_EmailTemplate] WHERE name = 'DVNTemplate'

							----Return Main Item Items
							SELECT
							B.Unit,
							B.ProjectID AS 'Project ID', 
							CASE 
								WHEN SubProject IS NULL OR SubProject = '' THEN ProjectName 
							ELSE
								CONCAT(ProjectName, ': ',SubProject) 
							END AS 'Project Name',
							MCRProgram AS 'MCR Program',
							B.Status,
							b.DVNCause,
							emp.EmpName AS 'PCS'
 							FROM [stng].MCRE_DVNMain B
							JOIN STNG.VV_Admin_UserView emp ON emp.EmployeeID = b.PCS
							WHERE DVNID = @DVNID

							--DETAILS
							--SELECT * FROM stng.MCRE_DVNActivityDetails WHERE DVNID = @DVNID
							--SELECT * FROM stng.MCRE_DVNActivityMRoCWeights WHERE DVNID = @DVNID
							--SELECT * FROM stng.MCRE_DVNStatusLog WHERE DVNID = @DVNID
				
					INSERT INTO [stng].[MCRE_DVNStatusLogItems](DVNID,Status,Approver,Comments) VALUES(@DVNID,'Approved by PCM',@CurrentUser,@Comments)
				END
			IF @Status = 'Draft'
				BEGIN
					SELECT 'This is a Draft DVN. Please submit to put DVN in approval stage' AS Result
				END

		END
	ELSE IF @Operation = 22
		BEGIN
			DELETE FROM [stng].[MCRE_DVNActivityDetails] WHERE DVNActivityDetailID = @DVNActivityDetailID
		END
	ELSE IF @Operation = 23
		BEGIN
			DELETE FROM [stng].[MCRE_DVNActivityMRoCWeights] WHERE DVNActivityMRoCWeightID = @DVNActivityMRoCWeightID 
		END
	ELSE IF @Operation = 24
		BEGIN
			SELECT DVNID, 
			DVNStatusItemID,
			Comments,
			D.EmpName as Approver,
			Status,
			A.CreatedDate AS Date
			FROM [stng].[MCRE_DVNStatusLogItems] A
			JOIN [stng].[VV_Admin_UserView] D ON A.Approver = D.EmployeeID
			WHERE DVNID = @DVNID ORDER BY Date DESC 
		END
	ELSE IF @Operation = 25
		BEGIN
			SELECT ActivityID AS 'Activity ID',
				ActivityName AS 'Activity Name',
				CASE 
					WHEN CurrentCommitmentDate IS NULL THEN 'N/A'
					ELSE CONVERT(VARCHAR,CurrentCommitmentDate,106)
				END AS 'Current Commitment Date',
				CASE 
					WHEN RevisedCommitmentDate IS NULL OR RevisedCommitmentDate = '' THEN 'REMOVE'
					ELSE CONVERT(VARCHAR,RevisedCommitmentDate,106)
				END AS 'Revised Commitment Date',
				ScopeTrend AS 'Scope or Trend',
				Reason AS 'Reason',
				SCRNum as 'SCR #'
			FROM stng.MCRE_DVNActivityDetails 
			WHERE DVNID = @DVNID

			SELECT ActivityID AS 'Activity ID',
				ActivityName AS 'Activity Name',
				CAST(CurrentMRoCWeight AS decimal(18,2)) AS 'Current MRoC Weightage',
				CAST(RevisedMRoCWeight AS decimal(18,2)) AS 'Revised MRoC Weightage'
			FROM stng.MCRE_DVNActivityMRoCWeights WHERE DVNID = @DVNID

			SELECT TOP 1
			oe.FirstName + ' ' + oe.LastName +' - ' + CONVERT(VARCHAR,Oesign.AprrovedDate, 107) as OEsignature,
			pm.FirstName + ' ' + pm.LastName +' - ' + CONVERT(VARCHAR,PMSign.AprrovedDate, 107) as PMsignature,
			sm.FirstName + ' ' + sm.LastName +' - ' + CONVERT(VARCHAR,SMSign.AprrovedDate, 107) as SMsignature,
			dm.FirstName + ' ' + dm.LastName +' - ' + CONVERT(VARCHAR,DMSign.AprrovedDate, 107) as DMsignature
			FROM [stng].MCRE_DVNMain B
			JOIN STNG.VV_Admin_UserView oe ON oe.EmployeeID = b.OE
			JOIN STNG.VV_Admin_UserView pm ON pm.EmployeeID = b.PM
			JOIN STNG.VV_Admin_UserView sm ON sm.EmployeeID = b.SM
			JOIN STNG.VV_Admin_UserView dm ON dm.EmployeeID = b.DM
			JOIN STNG.MCRE_DVNStatusLog OESign ON B.OE = OESign.Approver AND OESign.DVNID = b.DVNID
			JOIN STNG.MCRE_DVNStatusLog PMSign ON B.PM = PMSign.Approver AND PMSign.DVNID = b.DVNID
			JOIN STNG.MCRE_DVNStatusLog SMSign ON B.SM = SMSign.Approver AND SMSign.DVNID = b.DVNID
			JOIN STNG.MCRE_DVNStatusLog DMSign ON B.DM = DMSign.Approver AND DMSign.DVNID = b.DVNID
			WHERE B.DVNID = @DVNID

			--SELECT ApproverRole AS Role, 
			--	emp.FirstName + ' ' + emp.LastName +'	'+ CONVERT(VARCHAR,AprrovedDate, 22) as 'Sign'
			--FROM stng.MCRE_DVNStatusLog A
			--JOIN STNG.VV_Admin_UserView emp ON emp.EmployeeID = A.Approver
			--WHERE DVNID = @DVNID
		END
	ELSE IF @Operation = 26
		BEGIN 
			SELECT DISTINCT Lvl2WBS AS SubProject FROM stngetl.MCRE_DVN_DUMP WHERE Lvl2WBS <> 'COMMON' AND ProjectID = CONCAT('ENG-',@ProjectID)--ORDER BY ProjectID
		END	
	ELSE IF @Operation = 27
		BEGIN 
			DECLARE @findStatus varchar(100) = (SELECT TOP 1 Status FROM STNG.MCRE_DVNMain A INNER JOIN STNG.MCRE_DVNActivityDetails B ON A.DVNID = B.DVNID WHERE B.DVNActivityDetailID = @DVNActivityDetailID)
			
			--Return DVN and other details
			IF @findStatus = 'Draft' OR @findStatus = 'Draft: Rejected' OR @findStatus = 'Draft: Withdrawn' OR (@IsApprover = 'true' AND @findStatus <> 'Complete')
				BEGIN
					UPDATE [stng].[MCRE_DVNActivityDetails] 
					SET RevisedCommitmentDate =  CONVERT(datetime,@RevisedDate),
					ScopeTrend = @ScopeTrend,
					Reason = @Reason,
					SCRNum = @SCRNum
					where DVNActivityDetailID = @DVNActivityDetailID
				END
			ELSE
				BEGIN
					SELECT 'DVN is not in "Draft" status.' AS Message
				END
		END	
	ELSE IF @Operation = 28
		BEGIN 
		DECLARE @findStatus2 varchar(100) = (SELECT TOP 1 Status FROM STNG.MCRE_DVNMain A INNER JOIN STNG.[MCRE_DVNActivityMRoCWeights] B ON A.DVNID = B.DVNID WHERE B.DVNActivityMRoCWeightID = @DVNActivityMRoCWeightID)

			--Return DVN and other details
			IF @findStatus2 = 'Draft' OR @findStatus2 = 'Draft: Rejected' OR @findStatus = 'Draft: Withdrawn' OR (@IsApprover = 'true' AND @findStatus2 <> 'Complete')
				BEGIN
					UPDATE [stng].[MCRE_DVNActivityMRoCWeights] 
					SET RevisedMRoCWeight = CONVERT(decimal(18,4),@RevisedMRoCWeight) 
					where DVNActivityMRoCWeightID = @DVNActivityMRoCWeightID
				END
			ELSE
				BEGIN
					SELECT 'DVN is not in "Draft" status.' AS Message
				END
		END	
	ELSE IF @Operation = 29
		BEGIN  
			DECLARE @subProject4 varchar(500) = (SELECT SubProject FROM [stng].[MCRE_DVNMain] WHERE DVNID = @DVNID)
			IF @subProject4 = ''
				BEGIN
					SELECT B.ActivityID, B.ActivityName, B.MRocWeight,
						CONCAT(B.ActivityID, ' - ',B.ActivityName) AS Activity 
					FROM [stng].[MCRE_DVNMain] A
					LEFT OUTER JOIN [stngetl].[MCRE_DVN_DUMP] B ON CONCAT('ENG-',A.ProjectID) = B.ProjectID
					WHERE A.DVNID = @DVNID--ProjectID = CONCAT('ENG-',@ProjectID)
				END
			ELSE
				BEGIN
					SELECT B.ActivityID, B.ActivityName,B.MRocWeight,
						CONCAT(B.ActivityID, ' - ',B.ActivityName) AS Activity 
					FROM [stng].[MCRE_DVNMain] A
					LEFT OUTER JOIN [stngetl].[MCRE_DVN_DUMP] B ON CONCAT('ENG-',A.ProjectID) = B.ProjectID AND A.SubProject = B.Lvl2WBS
					WHERE A.DVNID = @DVNID--ProjectID = CONCAT('ENG-',@ProjectID)
				END			
		END
	ELSE IF @Operation = 30
		BEGIN
		----Return Main Item Items
			SELECT
			B.Unit,
			B.ProjectID AS 'Project ID', 
			CASE 
				WHEN SubProject IS NULL OR SubProject = '' THEN ProjectName 
			ELSE
				CONCAT(ProjectName, ': ',SubProject) 
			END AS 'Project Name',
			MCRProgram AS 'MCR Program',
			B.Status,
			b.DVNCause,
			emp.EmpName AS 'PCS'
 			FROM [stng].MCRE_DVNMain B
			JOIN STNG.VV_Admin_UserView emp ON emp.EmployeeID = b.PCS
			WHERE DVNID = @DVNID
			
		END
    ELSE IF @Operation = 33
		BEGIN
			IF EXISTS (	SELECT DVNID FROM [stng].[MCRE_DVNMain] WHERE DVNID = @DVNID AND [Status] in ('Complete','Awaiting DM Approval')  )
			BEGIN
				SELECT 'Cannot cancel Complete or Awaiting DM Approval DVN' as ReturnMessage
				RETURN;
			END

			UPDATE [stng].[MCRE_DVNMain] SET [Status]='Cancelled' WHERE DVNID = @DVNID
			INSERT INTO [stng].[MCRE_DVNStatusLogItems](DVNID,Status,Approver,Comments) VALUES(@DVNID,'Cancelled',@CurrentUser,@Comments)
		END
	ELSE IF @Operation = 34
		BEGIN
			IF EXISTS (	SELECT DVNID FROM [stng].[MCRE_DVNMain] WHERE DVNID = @DVNID AND [Status] in ('Complete','Awaiting DM Approval','Draft: Rejected','Draft')  )
			BEGIN
				SELECT 'Cannot withdrawn Draft,Complete or Awaiting DM Approval DVN' as ReturnMessage
				RETURN;
			END

			UPDATE [stng].[MCRE_DVNMain] SET Status='Draft: Withdrawn' WHERE DVNID = @DVNID AND STATUS LIKE 'Awaiting %'
			UPDATE [stng].[MCRE_DVNStatusLog] SET Complete=0 WHERE DVNID = @DVNID
			INSERT INTO [stng].[MCRE_DVNStatusLogItems](DVNID,Status,Approver,Comments) VALUES(@DVNID,'Draft: Withdrawn',@CurrentUser,@Comments)
		END
	ELSE IF @Operation = 35
		BEGIN

			IF NOT EXISTS (	SELECT DVNID FROM [stng].[MCRE_DVNMain] WHERE DVNID = @DVNID AND [Status] in ('Draft: Rejected','Draft','Draft: Withdrawn')  )
			BEGIN
				SELECT 'Cannot modifiy activities that have been submitted for approval' as ReturnMessage
				RETURN;
			END

			INSERT INTO [stng].[MCRE_DVNActivityDetails]
			   ([DVNID]
			   ,[ActivityID]
			   ,[ActivityName]
			   ,[CurrentCommitmentDate]
			   ,RevisedCommitmentDate
			   ,ScopeTrend
			   ,Reason
			   ,SCRNum
			   ,[CreatedBy])
			VALUES
			(@DVNID, @ActivityID,@ActivityName, @CurrentDate ,@RevisedDate, @ScopeTrend, @Reason, @SCRNum, @CurrentUser)
			RETURN;
		END
	ELSE IF @Operation = 36
		BEGIN
		IF NOT EXISTS (	SELECT DVNID FROM [stng].[MCRE_DVNMain] WHERE DVNID = @DVNID AND [Status] in ('Draft: Rejected','Draft','Draft: Withdrawn')  )
		BEGIN
			SELECT 'Cannot modifiy activities that have been submitted for approval' as ReturnMessage
			RETURN;
		END
		DELETE FROM stng.MCRE_DVNActivityDetails WHERE DVNID = @DVNID
		END
	ELSE IF @Operation = 37
		BEGIN

			IF NOT EXISTS (	SELECT DVNID FROM [stng].[MCRE_DVNMain] WHERE DVNID = @DVNID AND [Status] in ('Draft: Rejected','Draft','Draft: Withdrawn')  )
			BEGIN
				SELECT 'Cannot modifiy activities that have been submitted for approval' as ReturnMessage
				RETURN;
			END

			INSERT INTO [stng].[MCRE_DVNActivityMRoCWeights]
				   ([DVNID]
				   ,[ActivityID]
				   ,[ActivityName]
				   ,[CurrentMRoCWeight]
				   ,[RevisedMRoCWeight]
				   ,[CreatedBy])
				   VALUES (
				   @DVNID,
				   @ActivityID,
				   @ActivityName,
				   @CurrentMRocWeight,
				   @RevisedMRoCWeight,
				   @CurrentUser )
				   RETURN;
		END
	ELSE IF @Operation = 38
		BEGIN
			IF NOT EXISTS (	SELECT DVNID FROM [stng].[MCRE_DVNMain] WHERE DVNID = @DVNID AND [Status] in ('Draft: Rejected','Draft','Draft: Withdrawn')  )
			BEGIN
				SELECT 'Cannot modifiy activities that have been submitted for approval' as ReturnMessage
				RETURN;
			END

			DELETE FROM stng.MCRE_DVNActivityMRoCWeights WHERE DVNID = @DVNID
		END
	ELSE IF @Operation = 98
		BEGIN
			SELECT CONCAT('MCREDVN/', A.UUID) AS UUID 
			FROM stng.Common_FileMeta A 
			INNER JOIN stng.Admin_Module B ON B.UniqueID = A.ModuleID 
			WHERE ParentID = @DVNID AND B.Name = 'MCREDVN' AND A.Deleted = 0
		END
	ELSE IF @Operation = 99
		BEGIN
			SELECT FirstName + ' ' + LastName AS Name FROM [stng].[VV_Admin_UserView] WHERE EmployeeID = @CurrentUser
		END
	ELSE IF @Operation = 97
		BEGIN
			IF @Field = 'PCM'
				SELECT @Field = 'DM';

			WITH tempTable AS(SELECT * FROM [stng].[MCRE_DVNStatusLog] Where Complete = 0 AND DVNID = @DVNID AND ApproverRole = @Field )
				SELECT A.DVNID,A.Status, b.EmpName
					FROM [stng].[MCRE_DVNMain] A
					LEFT OUTER JOIN [stng].[VV_Admin_UserView] B ON A.PCS = B.EmployeeID
					LEFT OUTER JOIN [stng].[VV_Admin_UserView] C ON A.OE = C.EmployeeID
					LEFT OUTER JOIN [stng].[VV_Admin_UserView] D ON a.PM = D.EmployeeID
					LEFT OUTER JOIN [stng].[VV_Admin_UserView] E ON a.SM = E.EmployeeID
					LEFT OUTER JOIN [stng].[VV_Admin_UserView] F ON a.DM = F.EmployeeID
					JOIN tempTable G ON G.DVNID = A.DVNID AND A.Status = G.Status
		END
	ELSE IF @Operation = 96
		BEGIN
			SELECT
			emp.username AS CCEmail,
			CASE 
				WHEN @Field = 'OE' THEN oe.username
				WHEN @Field = 'PM' THEN pm.username
				WHEN @Field = 'SM' THEN sm.username
				ELSE dm.username
			END AS ToEmail,
			CASE 
				WHEN @Field = 'OE' THEN oe.FirstName
				WHEN @Field = 'PM' THEN pm.FirstName
				WHEN @Field = 'SM' THEN sm.FirstName
				ELSE dm.FirstName
			END AS FirstName
			FROM [stng].MCRE_DVNMain B
			JOIN STNG.VV_Admin_UserView emp ON emp.EmployeeID = b.PCS
			JOIN STNG.VV_Admin_UserView Oe ON oe.EmployeeID = b.OE
			JOIN STNG.VV_Admin_UserView pm ON pm.EmployeeID = b.PM
			JOIN STNG.VV_Admin_UserView sm ON sm.EmployeeID = b.SM
			JOIN STNG.VV_Admin_UserView dm ON dm.EmployeeID = b.DM
			WHERE B.DVNID = @DVNID
			----Return email template

			SELECT * FROM [stng].[Common_EmailTemplate] WHERE name = 'DVNApproval'

			----Return Injected Items
			SELECT
			B.Unit,B.ProjectID AS 'Project ID', 
			CASE 
				WHEN SubProject IS NULL OR SubProject = '' THEN ProjectName 
			ELSE
				CONCAT(ProjectName, ': ',SubProject) 
			END AS 'Project Name',B.Status,emp.EmpName AS 'PCS'
 			FROM [stng].MCRE_DVNMain B
			JOIN STNG.VV_Admin_UserView emp ON emp.EmployeeID = b.PCS
			WHERE DVNID = @DVNID
		END
	END TRY
	BEGIN CATCH
		INSERT INTO stng.App_ErrorLog([Number],[Procedure],[Line],[Message],SubOp) VALUES (
                     ERROR_NUMBER(),
                     ERROR_PROCEDURE(),
                     ERROR_LINE(),
                     ERROR_MESSAGE(),
					 @SubOp
              );
			  THROW
	END CATCH
	
END
