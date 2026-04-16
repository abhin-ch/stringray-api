/****** Object:  StoredProcedure [stng].[SP_CARLA_CRUD]    Script Date: 3/24/2026 9:42:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER   PROCEDURE [stng].[SP_CARLA_CRUD](
 @Operation TINYINT,
    @SubOp TINYINT = NULL,
    @EmployeeID INT = NULL,
    @Value1 NVARCHAR(255) = NULL,
    @Value2 NVARCHAR(255) = NULL,
    @Value3 NVARCHAR(255) = NULL,
    @Value4 NVARCHAR(255) = NULL,
    @Value5 NVARCHAR(255) = NULL,
    @Value6 NVARCHAR(max) = NULL,
    @DatesPastFuture BIT = NULL,
    @Num1 INT = NULL,
    @Num2 INT = NULL,
    @Num3 INT = NULL,
    @IsTrue1 BIT = NULL,
    @NR BIT = NULL,
    @Change BIT = NULL,
    @Saved BIT = NULL,
    @Sent_to_planner BIT = NULL,
    @IsTrue2 BIT = NULL,
    @ClearIcon BIT = NULL,
    @OriginalData BIT = NULL,
    @Icon BIT = NULL,
    @Actualized BIT = NULL,
    @NewValue NVARCHAR(255) = NULL,
    @temp BIT = NULL,
    @Date1 DATETIME = NULL,
    @CurrentUser VARCHAR(20) = NULL,
    @ActivityID VARCHAR(20) = NULL,
    @ActivityIDs VARCHAR(20) = NULL,
    @NextActivityID VARCHAR(150) = NULL,
    @MainActivity NVARCHAR(100) = NULL,
    @CreatedBy NVARCHAR(100) = NULL,
    @CreatedDate DATETIME = NULL,
    @SubActivity NVARCHAR(max) = NULL,
    @EmailName VARCHAR(35) = NULL,
    @P6UpdateRequired BIT = NULL,
    @status VARCHAR(20) = NULL,
	@oldStatus varchar(20)=NULL,
    @FieldName VARCHAR(20) = NULL,
    @Date2 DATETIME = NULL,	
	@Priority VARCHAR(20) = NULL,
	@CompletionDate DATETIME = NULL,
    @ScheduleUpdate [stng].CARLA_FADetails READONLY,
    @SubFragnetList [stng].CARLA_FADetails READONLY,
	@Search VARCHAR(30) = NULL,
	@Searchkind VARCHAR(20) = NULL,
	@ProjectID VARCHAR(20) = NULL,
	@Comment VARCHAR(max) = NULL,
	@CommentID VARCHAR(10) = NULL,
	@pendingChanges stng.PendingChangeType READONLY,
    @ScopeDetails stng.ScopeDetailType READONLY


) AS 
BEGIN


--CREATE TYPE [stng].PendingChangeType AS TABLE ( ID NVARCHAR(50), typ NVARCHAR(100), Names NVARCHAR(MAX), PreviousName NVARCHAR(MAX) );
	/*
	Operations:
		1 - UPDATE Reset Start/Finish Date
        2 - GET FragnetActivity & Fragnet
		3 - GET Internal Note
        4 - UPDATE Internal Note
		5 - UPDATE EmailSent
		6 - GET Child Activities
		7 - GET Commitment Review (Last Week)
		8 - Schedule Update
		9 - GET ChangeLog
		10 - GET All Commitment Review
		11 - UPDATE Category
		12 - Email => Schedule Update
		13 - Save BUtton
		14 - UPDATE Activity temporary changes
		15 - GET Remaining dates for Schedule Prompt
		17 - UPDATE Activity Detail
		18 - GET Activity Numbers
		19 - UPDATE - Update Required
		20 - DELETE Activity Status
		21 - DELETE Activity Detail Number
		22 - ADD Activity Detail Number
		24 - GET CSQ Summary
		25 - INSERT PlannerSubmission
		26 - Planner View
		27 - Get Child Activity for Planner
		28 - Activity sent to planner
		29 - Add Status in PLanner tab
		30 - Planner Status Values
		31 - Get Planner Status 
		32 - Planner Emails
		33 - Get temp child activity
		34 - Actualized or anticipated based on today date
		35 - NR Activity
		36 - Status and Category dropdown
		37 - Activity getting old data
		38 - schedule-change-temp-icon
	*/  
     BEGIN TRY
        DECLARE @StatusCount TINYINT;
        DECLARE @Category VARCHAR(20);
        DECLARE @PreviousValue NVARCHAR(255);
        DECLARE @CommitmentDate DATETIME;
        DECLARE @ChangeLogCount INT;
        DECLARE @TempPK NVARCHAR(255);
        DECLARE @NewDiff INT;
        DECLARE @PrevDate DATE;
        DECLARE @NewDate DATE;
        DECLARE @NewStartDate DATE;
        DECLARE @NewFinishDate DATE;
        DECLARE @FinishDate DATE;
        DECLARE @StartDate DATE;
        DECLARE @DateLimit DATE;
        DECLARE @Key NVARCHAR(20);
        DECLARE @Today DATE;
        DECLARE @FragnetID NVARCHAR(50);
        DECLARE @PK_ActivityID NVARCHAR(255);
        DECLARE @Next_ActivityID1 NVARCHAR(255);

        SET @TempPK = @Value1;
        SET @PK_ActivityID = (SELECT TOP 1 Item FROM stng.FN_0124_SplitString(@Value1, ','));
        SET @Next_ActivityID1 = (SELECT TOP 1 Item FROM stng.FN_0124_SplitString(@NextActivityID, ','));

		

		-- UPDATE Reset Start/Finish Date
        IF @Operation = 1
			UPDATE stng.CARLA_ChangeLog
				SET P6UpdateRequired = 0 
				WHERE stng.CARLA_ChangeLog.ActivityID IN (SELECT Item FROM stng.FN_0124_SplitString(@PK_ActivityID,',')) 
					AND FieldName = @Value2
					AND P6UpdateRequired = 1

		-- GET FragnetActivity & Fragnet
        IF (@Operation = 2)
		begin
		
			if @ActivityID IS NULL OR @ActivityID=''
				begin
					SELECT * FROM [stng].[VV_CARLA_CSQMain]  ORDER BY DateSort 
				end
				else  
					begin
						SELECT * FROM [stng].[VV_CARLA_CSQMain]  where ActivityID=@ActivityID ORDER BY DateSort
					end

				
			end
		/*GET Internal Note*/
        IF(@Operation = 3)
            BEGIN
				SELECT N.ActivityID
					,N.Content
					,N.CreatedDate
					,N.LastModified
					,N.ContentLength
				FROM stng.CARLA_InternalNote N
					WHERE N.CreatedBy = @EmployeeID 
						AND N.ActivityID = @PK_ActivityID
            END

		/*UPDATE Internal Note*/
        IF @Operation = 4
            BEGIN
				DECLARE @NoteCount TINYINT
				SET @NoteCount = (SELECT COUNT(*) FROM stng.CARLA_InternalNote N WHERE N.ActivityID=@PK_ActivityID AND N.CreatedBy=@EmployeeID)
				IF(@NoteCount > 0) UPDATE stng.CARLA_InternalNote SET Content=@Value2,LastModified=stng.GetBPTime(GETDATE()),ContentLength=@Num1 WHERE CreatedBy = @EmployeeID AND ActivityID = @PK_ActivityID 
				ELSE INSERT INTO stng.CARLA_InternalNote(ActivityID,Content,CreatedBy,ContentLength) VALUES (@PK_ActivityID,@Value2,@EmployeeID,@Num1)
            END

		/*UPDATE EmailSent*/
		IF @Operation = 5
            BEGIN		
				--Grab all Activities related to CSQ
				SELECT FA.ActivityID INTO #TempUpdate FROM stng.CARLA_FragnetActivity FA
				LEFT JOIN stng.CARLA_FragnetUpdate F ON F.ActivityID = FA.ActivityID
				WHERE FA.FragnetID IN (SELECT F.FragnetID FROM stng.CARLA_Fragnet F WHERE F.ParentID = (SELECT DISTINCT F.FragnetID FROM stng.CARLA_Fragnet F
						WHERE F.FragnetID 
						IN (SELECT P.ParentID FROM stng.CARLA_Fragnet P 
						WHERE P.FragnetID = (SELECT A.FragnetID FROM stng.CARLA_FragnetActivity A 
						WHERE A.ActivityID = @PK_ActivityID))))
				AND (FA.Actualized = 0 OR F.Actualized = 0)
				
				-- Set EmailSent to 1. This will enable all Revised Date fields for related activities. 
				UPDATE stng.CARLA_FragnetUpdate SET EmailSent = 1 
				WHERE ActivityID IN (SELECT F.ActivityID FROM #TempUpdate F) 
				AND EmailSent = 0 

				INSERT INTO stng.CARLA_FragnetUpdate(ActivityID,CreatedBy,CreatedDate,EmailSent)
				SELECT A.ActivityID,@EmployeeID,stng.GetBPTime(GETDATE()),1 FROM #TempUpdate A 
				WHERE A.ActivityID NOT IN (SELECT U.ActivityID FROM stng.CARLA_FragnetUpdate U)

				SELECT T.ActivityID FROM #TempUpdate T
            END
		
		/* GET Child Activities*/
		IF (@Operation = 6)
			begin
			EXEC stng.SP_CARLA_GetChildActivities @PK_ActivityID=@PK_ActivityID
				Update [stng].[CARLA_TempChangeLog] set change=0

				DECLARE curPred CURSOR FOR
					SELECT  [ActivityID],[FieldName]  ,[P6UpdateRequired]  ,[Saved]
					from  [stng].[CARLA_ChangeLog] where saved=1 and [P6UpdateRequired]=1
				OPEN curPred
				FETCH NEXT FROM curPred INTO @ActivityID,@FieldName,@P6UpdateRequired ,@Saved
				WHILE @@FETCH_STATUS = 0 
				BEGIN

				update [stng].[CARLA_TempChangeLog] set saved=@Saved where  ActivityID=@ActivityId and Fieldname=@FieldName and P6UpdateRequired=@P6UpdateRequired

				FETCH NEXT FROM curPred INTO @ActivityID,@FieldName,@P6UpdateRequired ,@Saved
			END
			CLOSE curPred
			DEALLOCATE curPred


				DECLARE curPred CURSOR FOR
					SELECT  [ActivityID],[FieldName]  ,[P6UpdateRequired]  ,Sent_to_planner
					from  [stng].[CARLA_ChangeLog] where Sent_to_planner=1 and [P6UpdateRequired]=1
				OPEN curPred
				FETCH NEXT FROM curPred INTO @ActivityID,@FieldName,@P6UpdateRequired ,@Saved
				WHILE @@FETCH_STATUS = 0 
				BEGIN

				update [stng].[CARLA_TempChangeLog] set Sent_to_planner=@Saved,saved=@Saved where  ActivityID=@ActivityId and Fieldname=@FieldName and P6UpdateRequired=@P6UpdateRequired

				FETCH NEXT FROM curPred INTO @ActivityID,@FieldName,@P6UpdateRequired ,@Saved
			END
			CLOSE curPred
			DEALLOCATE curPred
	
	
	
			DECLARE curPred CURSOR FOR
				 SELECT [ActivityID]     ,[FieldName]      ,[NewValue]      ,[PreviousValue]      ,[CreatedBy]      ,[CreatedDate]      ,[P6UpdateRequired],[Key],[Saved]  ,[Sent_to_planner]
				 FROM [stng].[CARLA_ChangeLog]
					where   P6UpdateRequired=1 and ActivityID in ( select value from string_split(@SubActivity,',') ) 
				
				OPEN curPred
				FETCH NEXT FROM curPred INTO @ActivityID,@FieldName,@NewValue,@PreviousValue,@CreatedBy,@CreatedDate,@P6updateRequired ,@Key, @Sent_to_planner,@Saved 
		
				WHILE @@FETCH_STATUS = 0 
				BEGIN

				update stng.CARLA_TempChangeLog 
					set NewValue=@NewValue,PreviousValue=@PreviousValue,CreatedBy=@CreatedBy,CreatedDate=@CreatedDate,@P6UpdateRequired=@P6UpdateRequired,[Key]=@Key, [Saved]=@Saved
					    ,[Sent_to_planner]=@Sent_to_planner
						  ,[NR]=0
						  where ActivityID=@ActivityID and FieldName=@FieldName
	
				FETCH NEXT FROM curPred INTO  @ActivityID,@FieldName,@NewValue,@PreviousValue,@CreatedBy,@CreatedDate,@P6updateRequired ,@Key, @Sent_to_planner,@Saved 		
			END
			CLOSE curPred
			DEALLOCATE curPred
			EXEC stng.SP_CARLA_GetChildActivities @PK_ActivityID=@PK_ActivityID

			end
		
		/*GET Commitment Review (Last Week)*/
		IF (@Operation = 7)
			SELECT * FROM stng.VV_CARLA_CommitmentReview V ORDER BY V.CommitmentDate ASC	

		/*UPDATE Status*/
		IF(@Operation = 8)
			BEGIN
			-- @oldStatus=status from stng.CARLA_FragnetUpdate where ActivityID = @PK_ActivityID 
				select @status= case when  @Value2 is null then null else [Label] end FROM [stng].[Common_ValueLabel] where moduleID=4 and [Group]= 'CSQ' and field='Status' AND [VALUE]=@VALUE2
				
				INSERT INTO stng.Common_ChangeLog(ParentID,NewValue,PreviousValue,AffectedField,AffectedTable,CreatedBy,PreviousDate,NewDate)
				SELECT F.ActivityID,@status,F.Status,'Status','FragnetUpdate',@EmployeeID,F.RevisedCommitmentDate,F.RevisedCommitmentDate 
				FROM stng.CARLA_FragnetUpdate F WHERE F.ActivityID = @PK_ActivityID
			
				if exists (select * from stng.CARLA_FragnetUpdate where ActivityID = @PK_ActivityID)
				begin
				UPDATE stng.CARLA_FragnetUpdate SET Status = @status	
					,ModifiedBy = @EmployeeID
					,LastModified = stng.GetBPTime(GETDATE())
					WHERE stng.CARLA_FragnetUpdate.ActivityID = @PK_ActivityID
				end
				else
				begin
				-- Create new Fragnet update if activity record does not exist
				INSERT INTO stng.CARLA_FragnetUpdate(ActivityID,[Status],CreatedBy,RevisedCommitmentDate) 
				SELECT A.Item,@status,@EmployeeID,@Value3 FROM stng.FN_0124_SplitString(@TempPK,',') A
				WHERE A.Item NOT IN (SELECT U.ActivityID FROM stng.CARLA_FragnetUpdate U)
				end
				
				

				-- A. Update all child activities to EmailSent
				DECLARE @tempTable TABLE (ActivityID VARCHAR(50))
				UPDATE stng.CARLA_FragnetUpdate SET EmailSent = 1 
				OUTPUT INSERTED.ActivityID INTO @TempTable
				WHERE stng.CARLA_FragnetUpdate.ActivityID IN (
					SELECT FA.ActivityID FROM stng.CARLA_FragnetActivity FA
					WHERE FA.FragnetID IN (SELECT F.FragnetID FROM stng.CARLA_Fragnet F WHERE F.ParentID IN 
					(SELECT CSQ.ParentID FROM stng.CARLA_Fragnet CSQ WHERE CSQ.FragnetID = 
					(SELECT A.FragnetID FROM stng.CARLA_FragnetActivity A WHERE A.ActivityID = @PK_ActivityID)))
					AND FA.Actualized = 0
				)

				-- B. Insert record into FragnetUpdate if child activity does not exist
				INSERT INTO stng.CARLA_FragnetUpdate(ActivityID,CreatedBy,EmailSent)
				SELECT FA.ActivityID,@EmployeeID,1 FROM stng.CARLA_FragnetActivity FA WHERE FA.ActivityID IN (
					SELECT FA.ActivityID FROM stng.CARLA_FragnetActivity FA
							WHERE FA.FragnetID IN (SELECT F.FragnetID FROM stng.CARLA_Fragnet F WHERE F.ParentID IN 
							(SELECT CSQ.ParentID FROM stng.CARLA_Fragnet CSQ WHERE CSQ.FragnetID = 
							(SELECT TOP 1 A.FragnetID FROM stng.CARLA_FragnetActivity A WHERE A.ActivityID = @PK_ActivityID)))
							AND FA.Actualized = 0)
				AND FA.ActivityID NOT IN (SELECT DISTINCT T.ActivityID FROM @tempTable T)




				SELECT LOWER(U.Email) Email FROM stng.VV_Admin_UserRole UR 
					INNER JOIN stng.Admin_User U ON U.EmployeeID = UR.EmployeeID
						WHERE UR.Role = 'Eng-Tech SPOC'

			SELECT T.Content AS [EmailBody] FROM stng.Common_EmailTemplate T WHERE T.[Name] = 'CARLA_At_Risk';
					
			select ActivityID,
				ProjectManager,b.Email as ProjectManagerEmail,
				CommitmentOwner,CommitmentOwnerEmail,
				CSFLM,c.Email as CSFLMEmail,
				ContractAdmin,d.Email as ContractAdminEmail,
				PCS,e.Email as PCSEmail
			from stng.VV_CARLA_CSQMain a
			left join   [stng].[Admin_User]  b on a.ProjectManager=b.Fullname
			left join   [stng].[Admin_User] c on a.CSFLM=c.Fullname
			left join   [stng].[Admin_User] d on a.ContractAdmin=d.Fullname
			left join   [stng].[Admin_User] e on a.PCS=e.Fullname
			where ActivityID=@PK_ActivityID

				select Username as CurrentUserEmail from stng.Admin_User where EmployeeID=@CurrentUser

				SELECT TOP 1   [Body] as Comment
				FROM [stng].[Common_Comment]
				WHERE ParentTable = 'FragnetActivity' 
				AND ParentID = @PK_ActivityID
				ORDER BY CreatedDate DESC;

			END

		/*GET ChangeLog*/
		IF(@Operation = 9)
			BEGIN
				select distinct * from stng.VV_CARLA_Changelog_2  where 
						not (newvalue is  null and PreviousValue is  null)
						AND  left(ParentID,charindex('_',ParentID+'_')-1) = @PK_ActivityID
				ORDER BY CreatedDate DESC


			END
		
		/*GET All Commitment Review*/
		IF(@Operation = 10)
			BEGIN
				-- 1. NCSQs
                SELECT 
					FA.[ProjShortName] AS 'ProjectID'
					,FA.[ActivityID]
					,FA.[ActivityName]
					,FA.[FragnetID]
					,FA.[NCSQ]
					,FORMAT(FA.[ActualStartDate],'dd-MMM-yyyy') AS 'StartDate'
					,FORMAT(FA.[EndDate],'dd-MMM-yyyy') AS 'CommitmentDate'
					,FORMAT(FA.[ActualEndDate],'dd-MMM-yyyy') AS 'FinishDate'
					,FA.[ActualStartDate]
					,FA.[EndDate]
					,FA.[Actualized]
					,FA.[Resource]
					,SubF.[FragnetName] AS 'SubfragnetName'
					,FF.FragnetName
					,M.ProjectName
					,M.[Portfolio]
					--,M.[CSPCS] AS 'PCS'
					--,M.[OE]
					,M.ProjectManager
					,M.ProjectPlanner
					,M.ProgramManager
					,M.MaterialBuyer
					,M.ContractAdmin
					,M.ServiceBuyer
					,M.BuyerAnalyst
					,M.CSFLM
					--,M.ContractSpecialist
					,M.FastTrack
					,M.ProjectCostAnalyst
					,IIF(FA.[ActualEndDate] <= FA.[EndDate], 'Actualized','Actualized Late') AS 'Status'
					,DATEDIFF(DAY,FA.ActualEndDate,FA.EndDate) AS 'Variance'
					,stng.FN_CARLA_GetSDSNumber(FF.FragnetName) AS 'SDS'
					,C.Name AS 'CommitmentOwner'
					,U.Category
				FROM stng.CARLA_FragnetActivity FA
				INNER JOIN stng.CARLA_Fragnet SubF ON SubF.FragnetID = FA.FragnetID
				LEFT JOIN stng.MPL M ON M.ProjectID = FA.ProjShortName
				LEFT JOIN stng.VV_CARLA_GetCommitmentOwner C ON C.ProjectID = FA.ProjShortName AND C.CommitmentOwner = FA.CommitmentOwner
				LEFT JOIN stng.CARLA_FragnetUpdate U ON U.ActivityID = FA.ActivityID
				CROSS APPLY (
					SELECT TOP 1 F.FragnetName FROM stng.CARLA_Fragnet F WHERE F.FragnetID = (SELECT TOP 1 ParentID FROM stng.CARLA_Fragnet S WHERE S.FragnetID = FA.FragnetID)
				) AS FF
				WHERE FA.Actualized = 1					
				AND (FA.[NCSQ] = 'CSQ' OR FA.[NCSQ] = 'NCSQ')
				AND M.Status = 'ACTIVE'
				UNION
				SELECT
					FA.[ProjShortName] AS 'ProjectID'
					,FA.[ActivityID]
					,FA.[ActivityName]
					,FA.[FragnetID]
					,FA.[NCSQ]
					,FORMAT(FA.[StartDate],'dd-MMM-yyyy') AS 'StartDate'
					,FORMAT(FA.[EndDate],'dd-MMM-yyyy') AS 'CommitmentDate'
					,FORMAT(FA.[ReendDate],'dd-MMM-yyyy') AS 'FinishDate'
					,FA.[ActualStartDate]
					,FA.[EndDate]
					,FA.[Actualized]
					,FA.[Resource]					
					,SubF.[FragnetName] AS 'SubfragnetName'
					,FF.FragnetName
					,M.ProjectName
					,M.[Portfolio]
					--,M.[CSPCS] AS 'PCS'
					--,M.[OE]
					,M.ProjectManager
					,M.ProjectPlanner
					,M.ProgramManager
					,M.MaterialBuyer
					,M.ContractAdmin
					,M.ServiceBuyer
					,M.BuyerAnalyst
					,M.CSFLM
					--,M.ContractSpecialist
					,M.FastTrack
					,M.ProjectCostAnalyst
					,IIF(FA.[EndDate] < CAST(GETDATE() AS DATE), 'Not Actualized',NULL) AS 'Status'
					,DATEDIFF(DAY,FA.ReendDate,FA.EndDate) AS 'Variance'
					,stng.FN_CARLA_GetSDSNumber(FF.FragnetName) AS 'SDS'
					,C.Name AS 'CommitmentOwner'
					,U.Category
				FROM stng.CARLA_FragnetActivity FA
				INNER JOIN stng.CARLA_Fragnet SubF ON SubF.FragnetID = FA.FragnetID
				LEFT JOIN stng.MPL M ON M.ProjectID = FA.ProjShortName
				LEFT JOIN stng.VV_CARLA_GetCommitmentOwner C ON C.ProjectID = FA.ProjShortName AND C.CommitmentOwner = FA.CommitmentOwner
				LEFT JOIN stng.CARLA_FragnetUpdate U ON U.ActivityID = FA.ActivityID
				CROSS APPLY (
					SELECT TOP 1 F.FragnetName FROM stng.CARLA_Fragnet F WHERE F.FragnetID = (SELECT TOP 1 ParentID FROM stng.CARLA_Fragnet S WHERE S.FragnetID = FA.FragnetID)
				) AS FF
				WHERE FA.Actualized = 0 
				AND FA.EndDate < CAST(GETDATE() AS DATE)
				AND (FA.[NCSQ] = 'CSQ' OR FA.[NCSQ] = 'NCSQ')
				AND M.Status = 'ACTIVE'
				ORDER BY FA.EndDate ASC
			END

		/*Update Category*/
		IF(@Operation = 11)
			BEGIN
				select 	 @category=   [Label]    FROM [stng].[Common_ValueLabel] where moduleID=4 and [Group]= 'CSQ' and field='Category' AND [vALUE]=@vALUE2

				INSERT INTO stng.Common_ChangeLog(ParentID,NewValue,PreviousValue,AffectedField,AffectedTable,CreatedBy,PreviousDate,NewDate)
				SELECT F.ActivityID,@category,F.Category,'Category','FragnetUpdate',@EmployeeID,F.RevisedCommitmentDate,F.RevisedCommitmentDate 
				FROM stng.CARLA_FragnetUpdate F WHERE F.ActivityID = @PK_ActivityID

				UPDATE stng.CARLA_FragnetUpdate SET Category = @category	
					,ModifiedBy = @EmployeeID
					,LastModified = stng.GetBPTime(GETDATE())
				WHERE stng.CARLA_FragnetUpdate.ActivityID = @PK_ActivityID
			END

		/*Email => Schedule Update*/
		IF(@Operation = 12)
			BEGIN
				DECLARE @NCSQ VARCHAR(5)
				--SELECT @ParentID = SF.ParentID FROM stng.CARLA_Fragnet SF WHERE SF.FragnetID = (SELECT FA.FragnetID FROM stng.CARLA_FragnetActivity FA WHERE FA.ActivityID = @PK_ActivityID)
				SELECT @NCSQ = FA.[NCSQ] FROM stng.CARLA_FragnetActivity FA WHERE FA.ActivityID = @PK_ActivityID
						
				-- GET Email Body
				IF(@NCSQ = 'NCSQ') 
				SELECT E.Content AS 'EmailBody' FROM stng.Common_EmailTemplate E WHERE E.[Name] = 'ScheduleUpdateNCSQ'
				ELSE
				SELECT E.Content AS 'EmailBody' FROM stng.Common_EmailTemplate E WHERE E.[Name] = 'ScheduleUpdate'

				/*Get ProjectInfo*/

			
			SELECT FA.ActivityID
					,FA.FragnetName
					,FA.RevisedDate
					,a.[Label] AS 'Reason'
					,(SELECT TOP 1 NewValue FROM stng.Common_ChangeLog CL WHERE CL.ParentID = @PK_ActivityID AND CL.AffectedField = 'Status' ORDER BY CL.CreatedDate DESC) AS 'Status'
					,FA.CommitmentOwner,
					FA.CommitmentOwnerEmail
					,CO.LANID AS 'CommitmentOwnerLANID'
					,M.[CSFLM] AS 'FLM'
					,M.CSFLMLANID FLMLANID
					,M.ProjectID AS 'ProjectID'
					,M.ProjectManager AS 'PM'
					,M.ProjectManagerLANID AS 'PMLANID',AU.Email AS 'PMEmail'
					,M.ProjectName AS 'ProjectName'
					,M.ContractAdmin 
					,M.ContractAdminLANID, AU2.Email AS 'ContractAdminEmail'
					,M.ProjectPlanner AS 'Planner'
					,M.ProjectPlannerLANID AS 'PlannerLANID',AU1.Email AS 'PlannerEmail'
					,P.Email PCSLeadEmail
					,P.Name PCSLeadName,C.Body as 'Comment'
				FROM stng.VV_CARLA_CSQMain FA
				left join (select *   FROM [stng].[Common_ValueLabel] where [group] ='csq' and Field='category') as a on Fa.Category=a.Value
				LEFT JOIN stng.VV_CARLA_GetCommitmentOwner CO ON CO.CommitmentOwner = FA.CommitmentOwner
				LEFT JOIN stng.VV_MPL_SC M ON M.ProjectID = FA.ProjectID
				left join   [stng].[Admin_User] AU on AU.LANID=M.ProjectManagerLANID
				left join   [stng].[Admin_User] AU1 on AU1.LANID=M.ProjectPlannerLANID
				left join   [stng].[Admin_User] AU2 on AU2.LANID=M.ContractAdminLANID
				left join (SELECT [Body],ParentID
						FROM [stng].[Common_Comment] as b
				 inner join (select Max(CreatedDate) as CreatedDate FROM [stng].[Common_Comment] group by ParentID) as a on b.CreatedDate=a.CreatedDate
					 where ParentID=@PK_ActivityID) c on FA.ActivityID=C.ParentID
				CROSS APPLY (	
					SELECT STRING_AGG(U.Email,';') Email,STRING_AGG(CONCAT(U.FirstName,' ',U.LastName),',') [Name] FROM stng.VV_Admin_UserRole UR
					INNER JOIN stng.Admin_User U ON U.EmployeeID = UR.EmployeeID WHERE UR.Role = 'PCS Lead'
				) P
				WHERE FA.ActivityID = @PK_ActivityID
						
				-- GET Pre-Reqs & Commitments
				--IF(@NCSQ = 'CSQ')
				SELECT FA.ActivityID 
					,FA.ActivityName AS 'Title'
					,FORMAT(FA.[EndDate],'dd-MMM-yyyy') AS 'CommitmentDate'
					,FA.Resource
					,IIF(A.NewValue IS NULL,A2.FinishDate,FORMAT(CAST(A.NewValue AS DATE),'dd-MMM-yyyy')) AS 'RevisedDate'
					,A2.FinishDate
					,FORMAT(FA.[EndDate],'yyyyMMdd') AS 'DateSort'
					,FA.[NCSQ]
				FROM stng.CARLA_FragnetActivity FA 
				LEFT JOIN stng.VV_MPL_SC M ON M.ProjectID = FA.ProjShortName
				LEFT JOIN stng.CARLA_FragnetUpdate FU ON FU.ActivityID = FA.ActivityID 
				LEFT JOIN stng.CARLA_Fragnet F ON F.FragnetID = FA.FragnetID
				LEFT JOIN (
					SELECT CL.NewValue,FA.ActivityID
					FROM stng.CARLA_ChangeLog CL 
					INNER JOIN stng.CARLA_FragnetActivity FA ON FA.ActivityID = CL.ActivityID
					WHERE CL.ActivityID = FA.ActivityID AND CL.FieldName = 'FinishDate' AND CL.P6UpdateRequired = 1
				) A ON A.ActivityID = FA.ActivityID
				CROSS APPLY (
					SELECT IIF(FA.[Actualized] = 0,FORMAT(FA.[ReendDate],'dd-MMM-yyyy'),FORMAT(FA.[ActualEndDate],'dd-MMM-yyyy')) FinishDate
					FROM stng.CARLA_FragnetActivity FA1 WHERE FA1.ActivityID = FA.ActivityID
				) A2
				WHERE FA.Actualized = 0
				AND M.Status = 'ACTIVE'
				AND ((FA.Resource IN ('Project Manager','Engineering') AND (F.FragnetName NOT LIKE '%Contract Admin%' AND F.FragnetName NOT LIKE '%PO Admin%')) OR (FA.[NCSQ] IS NULL AND @NCSQ ='NCSQ'))
				AND FA.FragnetID IN (SELECT A.DetailValue FROM @SubFragnetList A)
				UNION
				SELECT FA.ActivityID
					,FA.ActivityName AS 'Title'
					,FORMAT(FA.[EndDate],'dd-MMM-yyyy') AS 'CommitmentDate'
					,IIF(FA.[Resource] IS NULL, FA.[NCSQ], FA.[Resource]) AS 'Resource'      
					,IIF(FU.RevisedCommitmentDate IS NULL,A.FinishDate,FORMAT(FU.RevisedCommitmentDate,'dd-MMM-yyyy')) AS 'RevisedDate'
					,A.FinishDate
					,IIF(FA.Status = 'Active', FORMAT(FA.[ReendDate],'yyyyMMdd'),FORMAT(FA.[EndDate],'yyyyMMdd')) AS 'DateSort'
					,FA.[NCSQ]
				FROM stng.CARLA_FragnetActivity FA 
				LEFT JOIN stng.MPL M ON M.ProjectID = FA.ProjShortName
				LEFT JOIN stng.CARLA_FragnetUpdate FU ON FU.ActivityID = FA.ActivityID
				CROSS APPLY (
						SELECT IIF(FA.[Actualized] = 0,FORMAT(FA.[ReendDate],'dd-MMM-yyyy'),FORMAT(FA.[ActualEndDate],'dd-MMM-yyyy')) FinishDate 
						FROM stng.CARLA_FragnetUpdate U WHERE FA.ActivityID = U.ActivityID
				) A
				WHERE FA.Actualized = 0
				AND M.Status = 'ACTIVE'
				AND FA.[NCSQ] IN ('CSQ','NCSQ')
				AND FA.FragnetID IN (SELECT A.DetailValue FROM @SubFragnetList A)
				ORDER BY DateSort
						
				--Update EmailSent if Project Info found
				DECLARE @Count INT						
				SELECT @Count = COUNT(*) FROM stng.CARLA_FragnetActivity FA 
					LEFT JOIN stng.MPL M ON M.ProjectID = FA.ProjShortName
					WHERE FA.Actualized = 0
					AND M.Status = 'ACTIVE'
					--AND (FA.[NCSQ] = 'CSQ' OR FA.[NCSQ] IS NULL) 
					AND FA.FragnetID IN (SELECT A.DetailValue FROM @SubFragnetList A)

				IF(@Count > 0) UPDATE stng.CARLA_FragnetUpdate SET EmailSent = 2 WHERE stng.CARLA_FragnetUpdate.ActivityID = @PK_ActivityID
			END

		/*save Button*/
IF(@Operation = 13)
BEGIN 

	IF EXISTS (SELECT 1 FROM @pendingChanges)
	BEGIN
	
		 INSERT INTO stng.CARLA_ChangeLog (
		    ActivityID,  FieldName,   NewValue,  PreviousValue,   CreatedBy,  P6UpdateRequired,   Saved,   Sent_to_planner    )
		SELECT     case when CHARINDEX(',', ID) > 0 then LEFT(ID,ChARINDEX(',',ID)-1) else ID end ,    typ ,    Names,   PreviousName ,    @CurrentUser,    1,    1,    0
			FROM @pendingChanges 

		INSERT INTO stng.Common_ChangeLog (
			 ParentID,    AffectedField,    NewValue,    PreviousValue,    AffectedTable,    CreatedBy)
		SELECT   
		  case when CHARINDEX(',', ID) > 0 then	CONCAT(@MainActivity, '_',   LEFT(ID,ChARINDEX(',',ID)-1) ) 
		  else 	CONCAT(@MainActivity, '_', ID)  end
		,    typ,    Names,    PreviousName,    'FragnetActivity',    @CurrentUser
		FROM @pendingChanges 

	END
	 
		--INSERT INTO stng.CARLA_ChangeLog (
		--		 ActivityID, FieldName, NewValue, PreviousValue, CreatedBy, [Key], P6UpdateRequired, Saved, Sent_to_planner)
		--SELECT 	 ActivityID, FieldName, NewValue, PreviousValue, CreatedBy, [Key], P6UpdateRequired,
		--		CASE WHEN [Saved] = 1 THEN [Saved] ELSE [Change] END AS Saved, Sent_to_planner
		--		FROM stng.CARLA_TempChangeLog	WHERE ActivityID IN (SELECT value FROM string_split(@SubActivity, ','));
		INSERT INTO stng.CARLA_ChangeLog (
    ActivityID, FieldName, NewValue, PreviousValue, CreatedBy, [Key],
    P6UpdateRequired, Saved, Sent_to_planner
)
SELECT  
    t.ActivityID,
    t.FieldName,
    t.NewValue,
    t.PreviousValue,
    t.CreatedBy,
    t.[Key],
    t.P6UpdateRequired,
    CASE WHEN t.[Saved] = 1 THEN t.[Saved] ELSE t.[Change] END AS Saved,
    t.Sent_to_planner
FROM stng.CARLA_TempChangeLog t
WHERE t.ActivityID IN (SELECT value FROM string_split(@SubActivity, ','))
AND NOT EXISTS (
    SELECT 1
    FROM stng.CARLA_ChangeLog c
    WHERE c.ActivityID = t.ActivityID
      AND c.FieldName = t.FieldName
      AND c.NewValue = t.NewValue
      AND c.PreviousValue = t.PreviousValue
      AND c.CreatedBy = t.CreatedBy
      AND c.[Key] = t.[Key]
      AND c.P6UpdateRequired = t.P6UpdateRequired
      AND c.Sent_to_planner = t.Sent_to_planner
      AND c.Saved = CASE WHEN t.[Saved] = 1 THEN t.[Saved] ELSE t.[Change] END
);


		INSERT INTO stng.Common_ChangeLog (
			 ParentID, NewDate, PreviousDate, NewValue, PreviousValue, AffectedField, AffectedTable, CreatedBy)
		SELECT 
    CONCAT(@MainActivity, '_', T.ActivityID),
    T.NewValue, T.PreviousValue, T.[Key], C.[Key], T.FieldName, 'FragnetActivity', T.CreatedBy
FROM stng.CARLA_TempChangeLog T
JOIN stng.CARLA_ChangeLog C 
    ON C.ActivityID = T.ActivityID AND C.FieldName = T.FieldName AND C.P6UpdateRequired = 1
WHERE 
    T.ActivityID IN (SELECT value FROM string_split(@SubActivity, ','))
    AND (CASE WHEN T.[Saved] = 1 THEN T.[Saved] ELSE T.[Change] END) = 1;



	MERGE stng.CARLA_FragnetUpdate AS target
USING (
    SELECT DISTINCT ActivityID
    FROM stng.CARLA_TempChangeLog
    WHERE ActivityID IN (SELECT value FROM string_split(@SubActivity, ',')) AND NR = 1
) AS source
ON target.ActivityID = source.ActivityID
WHEN MATCHED THEN
    UPDATE SET 
        NR = 1,
        LastModified = stng.GetBPTime(GETDATE()),
        ModifiedBy = @CurrentUser
WHEN NOT MATCHED THEN
    INSERT (ActivityID, CreatedBy, CreatedDate, NR)
    VALUES (source.ActivityID, @CurrentUser, stng.GetBPTime(GETDATE()), 1);




	-- Mark Saved = 1 where Change = 1
				UPDATE T
				SET Saved = 1
				FROM stng.CARLA_TempChangeLog T
				WHERE 
			    ActivityID IN (SELECT value FROM string_split(@SubActivity, ','))
				   AND (CASE WHEN T.[Saved] = 1 THEN T.[Saved] ELSE T.[Change] END) = 1;

-- Mark NR = 1 where NR = 1
			UPDATE T
			SET NR = 1
			FROM stng.CARLA_TempChangeLog T
			WHERE 
		   ActivityID IN (SELECT value FROM string_split(@SubActivity, ','))
		  AND NR = 1;


		  UPDATE f
SET RevisedCommitmentDate = IIF(c.NewValue = '', NULL, c.NewValue),
    ModifiedBy = c.CreatedBy,
    LastModified = stng.GetBPTime(GETDATE())
FROM stng.CARLA_FragnetUpdate f
INNER JOIN string_split(@SubActivity, ',') s ON f.ActivityID = s.value
LEFT JOIN stng.CARLA_TempChangeLog c 
    ON f.ActivityID = c.ActivityID AND c.Fieldname = 'FinishDate'
WHERE EXISTS (
    SELECT 1 FROM stng.CARLA_TempChangeLog 
    WHERE ActivityID = f.ActivityID AND Fieldname = 'FinishDate'
);

-- Insert new records
INSERT INTO stng.CARLA_FragnetUpdate (ActivityID, CreatedDate, CreatedBy, RevisedCommitmentDate)
SELECT @MainActivity, stng.GetBPTime(GETDATE()), CreatedBy, 
       IIF(NewValue = '', NULL, NewValue)
FROM stng.CARLA_TempChangeLog
WHERE ActivityID = @MainActivity AND Fieldname = 'FinishDate'
AND NOT EXISTS (
    SELECT 1 FROM stng.CARLA_FragnetUpdate 
    WHERE ActivityID = @MainActivity
);



		SELECT V.RevisedDate,V.ActivityID FROM stng.VV_CARLA_CSQMain V WHERE V.ActivityID = @MainActivity
			--	DECLARE curPred CURSOR FOR
			--		SELECT [ActivityID],
			--		[FieldName] ,
			--		[NewValue]  ,
			--		[PreviousValue]  ,
			--		[CreatedBy]  ,
			--		[P6UpdateRequired]  ,
			--		[Key] ,
			--		case when [saved]=1 then [saved] else [Change] end as [Change],
			--	    Sent_to_planner,
			--		NR
			--		from  [stng].[CARLA_TempChangeLog] 
			--					where ActivityID in ( select value from string_split(@SubActivity,',') ) 
				
			--	OPEN curPred
			--	FETCH NEXT FROM curPred INTO @ActivityID,@FieldName,@NewValue ,@PreviousValue,@EmployeeID,@P6UpdateRequired ,@Key,@Change,@sent_to_planner,@NR
			--	WHILE @@FETCH_STATUS = 0 
			--	BEGIN

			--		INSERT INTO stng.CARLA_ChangeLog
			--		(ActivityID,FieldName,NewValue,PreviousValue,CreatedBy,[Key],[P6UpdateRequired],[Saved],[Sent_to_planner])
			--		values( @ActivityID,@FieldName,@NewValue,@PreviousValue,@EmployeeID,@Key,@P6UpdateRequired,@change,@sent_to_planner )

			--	if (@Change=1 )
			--	begin
			--		INSERT INTO stng.Common_ChangeLog(ParentID,NewDate,PreviousDate,NewValue,PreviousValue,AffectedField,AffectedTable,CreatedBy)		
			--		SELECT CONCAT(@MainActivity,'_',@ActivityID),@NewValue,@PreviousValue,@Key,B.[Key],@FieldName,'FragnetActivity',@EmployeeID from
			--		stng.CARLA_ChangeLog B where B.ActivityID = @ActivityID AND B.FieldName = @FieldName AND B.P6UpdateRequired = 1

				
			--		update  [stng].[CARLA_TempChangeLog] set Saved=1 where ActivityID =@ActivityID and [FieldName] =@fieldname
			--	 end

			--	 if(@NR=1)
			--	 begin
			--	 if exists(select 1 from [stng].[CARLA_FragnetUpdate] where ActivityID=ActivityID )
			--			begin
			--				Update [stng].[CARLA_FragnetUpdate] set NR=@NR, LastModified=stng.GetBPTime(GETDATE()),ModifiedBy=@CurrentUser
			--				where ActivityID=@ActivityID
			--			end
			--		else 
			--			begin
			--				insert into [stng].[CARLA_FragnetUpdate]
			--				(ActivityID,CreatedBy,CreatedDate,NR) 
			--				values(@ActivityID,@CurrentUser,stng.GetBPTime(GETDATE()),@NR)
			--		end

			--		update  [stng].[CARLA_TempChangeLog] set nr=1 where ActivityID =@ActivityID and [FieldName] =@fieldname

			--	 end
				
				
			--	FETCH NEXT FROM curPred INTO @ActivityID,@FieldName,@NewValue ,@PreviousValue,@EmployeeID,@P6UpdateRequired ,@Key ,@Change,@sent_to_planner,@NR
				
			
			
			--END
			
			
			--CLOSE curPred
			--DEALLOCATE curPred






		--		DECLARE curPred CURSOR FOR
		--			SELECT [ActivityID] from stng.CARLA_FragnetUpdate
		--			where ActivityID in ( select value from string_split(@SubActivity,',') ) 

	
		--		OPEN curPred
		--		FETCH NEXT FROM curPred INTO @ActivityID
		--		WHILE @@FETCH_STATUS = 0 
		--		BEGIN

		--		If exists(select * from stng.CARLA_FragnetUpdate where ActivityID=@ActivityID )
		--		begin
		--			UPDATE stng.CARLA_FragnetUpdate 
		--			SET RevisedCommitmentDate = IIF(( select [NewValue] from  [stng].[CARLA_TempChangeLog] 
		--										where ActivityID=@ActivityID and Fieldname='FinishDate') = '',NULL,
		--										( select [NewValue] from  [stng].[CARLA_TempChangeLog]
		--										where ActivityID=@ActivityID and Fieldname='FinishDate')),
		--			ModifiedBy = (select CreatedBy from  [stng].[CARLA_TempChangeLog] where ActivityID=@ActivityID and Fieldname='FinishDate'),
		--			LastModified = stng.GetBPTime(GETDATE())
		--			WHERE ActivityID =@ActivityID
					 
		--		end
		--else 
		--		begin
		--			INSERT INTO stng.CARLA_FragnetUpdate(ActivityID,CreatedDate,CreatedBy,RevisedCommitmentDate) 
		--			select @MainActivity,stng.GetBPTime(GETDATE()),CreatedBy,NewValue from  [stng].[CARLA_TempChangeLog] where ActivityID=@MainActivity and Fieldname='FinishDate'
		--		end

					
		--		FETCH NEXT FROM curPred INTO @ActivityID
			
		--	END

		--	CLOSE curPred
		--	DEALLOCATE curPred

						
			end
			
		/*Making temporary changes*/
		IF(@Operation = 14)
			begin

			IF(convert( date,@Value2)>convert(date, getdate())) 
			begin
				set @DatesPastFuture=1
			end
			else
			begin
			set @DatesPastFuture=0
			end
				IF(@Value3 = 'Start')
				begin
					SET @PrevDate = (SELECT top(1) IIF(FA.[Status] = 'NotStart',FA.[StartDate],FA.[ActualStartDate]) 
									FROM stng.CARLA_FragnetActivity FA WHERE FA.ActivityID = @PK_ActivityID)

					if exists (SELECT 1  FROM [stng].[CARLA_TempChangeLog] where saved=1 and  P6UpdateRequired=1 and ActivityID=@PK_ActivityID and FieldName='StartDate' )
							begin
								update [stng].[CARLA_TempChangeLog] set saved=0,change=0 where P6UpdateRequired=1 and ActivityID=@PK_ActivityID and FieldName='StartDate'
							end

				end

				IF(@Value3 = 'Finish')
				begin
					SET @PrevDate = (SELECT top(1) IIF(FA.[Actualized] = 0,FA.[ReendDate],FA.[ActualEndDate])
									FROM stng.CARLA_FragnetActivity FA WHERE FA.ActivityID = @PK_ActivityID)
					if exists (SELECT *  FROM [stng].[CARLA_TempChangeLog] where saved=1 and P6UpdateRequired=1 and ActivityID=@PK_ActivityID and FieldName='FinishDate' )
							begin
								update [stng].[CARLA_TempChangeLog] set saved=0,change=0 where P6UpdateRequired=1 and ActivityID=@PK_ActivityID and FieldName='FinishDate'
							end
				end
				SET @NewDiff = stng.FN_CARLA_GetDateDiff(@PrevDate,CAST(@Value2 AS DATE))

				DECLARE curPred CURSOR FOR
				SELECT A.ActivityID,
						A.NewStartDate,
						A.NewFinishDate,
						A.FinishDate,
						A.StartDate,
						A.DateLimit 
						FROM stng.FN_CARLA_GetNewDates
					(@PK_ActivityID,@NewDiff,@Value2,@ScheduleUpdate,@Value3) A 
				OPEN curPred
					FETCH NEXT FROM curPred INTO @ActivityID,@NewStartDate, @NewFinishDate,@FinishDate,@StartDate,@DateLimit
					WHILE @@FETCH_STATUS = 0 
						BEGIN
						if (@ClearIcon=1)
						begin
							
								
										/*Finish Date*/
										IF(CAST(@NewFinishDate AS DATE) > CAST(GETDATE() AS DATE))						
											EXEC stng.SP_CARLA_UpdateFinishDate @ActivityID=@ActivityID,@EmployeeID=@EmployeeID,@NewValue=@NewFinishDate,@Key='Anticipated'
										ELSE IF (CAST(@NewFinishDate AS DATE)<=CAST(GETDATE() AS DATE)) and @DatesPastFuture=1 
												EXEC stng.SP_CARLA_UpdateFinishDate @ActivityID=@ActivityID,@EmployeeID=@EmployeeID,@NewValue=@NewFinishDate,@Key='Anticipated'
										ELSE IF (CAST(@NewFinishDate AS DATE)<=CAST(GETDATE() AS DATE)) and @DatesPastFuture=0 and (CAST(@NewFinishDate AS DATE) > CAST(@Value2 AS DATE))
											EXEC stng.SP_CARLA_UpdateFinishDate @ActivityID=@ActivityID,@EmployeeID=@EmployeeID,@NewValue=@NewFinishDate,@Key='Anticipated'
									
										ELSE IF (CAST(@NewFinishDate AS DATE)<=CAST(GETDATE() AS DATE)) and @DatesPastFuture=0
											EXEC stng.SP_CARLA_UpdateFinishDate @ActivityID=@ActivityID,@EmployeeID=@EmployeeID,@NewValue=@NewFinishDate,@Key='Actual'
										
										ELSE IF(@Value2 IS NULL)
											EXEC stng.SP_CARLA_UpdateFinishDate @ActivityID=@ActivityID,@EmployeeID=@EmployeeID,@NewValue=NULL,@Key=NULL
								
								
									
										/*Start Date*/

										IF(CAST(@NewStartDate AS DATE) > CAST(GETDATE() AS DATE))						
											EXEC stng.SP_CARLA_UpdateStartDate @ActivityID=@ActivityID,@EmployeeID=@EmployeeID,@NewValue=@NewStartDate,@Key='Anticipated'
									
										ELSE IF(@Value2 IS NULL) 
											EXEC stng.SP_CARLA_UpdateStartDate @ActivityID=@ActivityID,@EmployeeID=@EmployeeID,@NewValue=NULL,@Key=NULL
									
										ELSE IF (CAST(@NewStartDate AS DATE)<=CAST(GETDATE() AS DATE)) and @DatesPastFuture=1
												EXEC stng.SP_CARLA_UpdateStartDate @ActivityID=@ActivityID,@EmployeeID=@EmployeeID,@NewValue=@NewStartDate,@Key='Anticipated'
										ELSE IF (CAST(@NewStartDate AS DATE)<=CAST(GETDATE() AS DATE)) and @DatesPastFuture=0 and (CAST(@NewStartDate AS DATE) > CAST(@Value2 AS DATE))
											EXEC stng.SP_CARLA_UpdateStartDate @ActivityID=@ActivityID,@EmployeeID=@EmployeeID,@NewValue=@NewStartDate,@Key='Anticipated'
							
										ELSE IF (CAST(@NewStartDate AS DATE)<=CAST(GETDATE() AS DATE)) and @DatesPastFuture=0
											EXEC stng.SP_CARLA_UpdateStartDate @ActivityID=@ActivityID,@EmployeeID=@EmployeeID,@NewValue=@NewStartDate,@Key='Actual'
						
						end
						else
						begin
													   
							if not exists (SELECT *  FROM [stng].[CARLA_TempChangeLog] where saved=1 and ActivityID=@ActivityID and FieldName='FinishDate'  )
						AND	
								
								 not exists (SELECT *  FROM [stng].[CARLA_TempChangeLog] where change=1  and @ActivityID=@PK_ActivityID and @Value3='Start' and FieldName='FinishDate' and ActivityID=@ActivityID )
							and
								
									 not exists(SELECT *  FROM [stng].[CARLA_TempChangeLog] where ActivityID=@ActivityID  and FieldName='FinishDate' and change=1 and
									ActivityID<>@PK_ActivityID )
									begin
										/*Finish Date*/
										IF(CAST(@NewFinishDate AS DATE) > CAST(GETDATE() AS DATE))						
											EXEC stng.SP_CARLA_UpdateFinishDate @ActivityID=@ActivityID,@EmployeeID=@EmployeeID,@NewValue=@NewFinishDate,@Key='Anticipated'
										ELSE IF (CAST(@NewFinishDate AS DATE)<=CAST(GETDATE() AS DATE)) and @DatesPastFuture=1
											EXEC stng.SP_CARLA_UpdateFinishDate @ActivityID=@ActivityID,@EmployeeID=@EmployeeID,@NewValue=@NewFinishDate,@Key='Anticipated'
										ELSE IF (CAST(@NewFinishDate AS DATE)<=CAST(GETDATE() AS DATE)) and @DatesPastFuture=0 and (CAST(@NewFinishDate AS DATE) > CAST(@Value2 AS DATE))
											EXEC stng.SP_CARLA_UpdateFinishDate @ActivityID=@ActivityID,@EmployeeID=@EmployeeID,@NewValue=@NewFinishDate,@Key='Anticipated'
										ELSE IF (CAST(@NewFinishDate AS DATE)<=CAST(GETDATE() AS DATE)) and @DatesPastFuture=0 
												EXEC stng.SP_CARLA_UpdateFinishDate @ActivityID=@ActivityID,@EmployeeID=@EmployeeID,@NewValue=@NewFinishDate,@Key='Actual'
										ELSE IF(@Value2 IS NULL)
											EXEC stng.SP_CARLA_UpdateFinishDate @ActivityID=@ActivityID,@EmployeeID=@EmployeeID,@NewValue=NULL,@Key=NULL
								
							end
							if not exists (SELECT *  FROM [stng].[CARLA_TempChangeLog] where  saved=1 and ActivityID=@ActivityID and FieldName='StartDate')
							AND
								 not exists (SELECT *  FROM [stng].[CARLA_TempChangeLog] where change=1  and @ActivityID=@PK_ActivityID and FieldName='StartDate'and @Value3='Finish' and ActivityID=@ActivityID )
								AND
									 not exists(SELECT *  FROM [stng].[CARLA_TempChangeLog] where ActivityID=@ActivityID  and  FieldName='StartDate' and change=1 
									and  ActivityID<>@PK_ActivityID)
									begin
										/*Start Date*/
										IF(CAST(@NewStartDate AS DATE) > CAST(GETDATE() AS DATE))						
											EXEC stng.SP_CARLA_UpdateStartDate @ActivityID=@ActivityID,@EmployeeID=@EmployeeID,@NewValue=@NewStartDate,@Key='Anticipated'
									
										ELSE IF(@Value2 IS NULL) 
											EXEC stng.SP_CARLA_UpdateStartDate @ActivityID=@ActivityID,@EmployeeID=@EmployeeID,@NewValue=NULL,@Key=NULL
									
										ELSE IF (CAST(@NewStartDate AS DATE)<=CAST(GETDATE() AS DATE)) and @DatesPastFuture=1									
											EXEC stng.SP_CARLA_UpdateStartDate @ActivityID=@ActivityID,@EmployeeID=@EmployeeID,@NewValue=@NewStartDate,@Key='Anticipated'
										
										ELSE IF (CAST(@NewStartDate AS DATE)<=CAST(GETDATE() AS DATE)) and @DatesPastFuture=0 and (CAST(@NewStartDate AS DATE) > CAST(@Value2 AS DATE))
											EXEC stng.SP_CARLA_UpdateStartDate @ActivityID=@ActivityID,@EmployeeID=@EmployeeID,@NewValue=@NewStartDate,@Key='Anticipated'

										ELSE IF (CAST(@NewStartDate AS DATE)<=CAST(GETDATE() AS DATE)) and @DatesPastFuture=0
											EXEC stng.SP_CARLA_UpdateStartDate @ActivityID=@ActivityID,@EmployeeID=@EmployeeID,@NewValue=@NewStartDate,@Key='Actual'

					
					      end
							
							
							end
							FETCH NEXT FROM curPred INTO @ActivityID,@NewStartDate,@NewFinishDate,@FinishDate,@StartDate,@DateLimit
						END
					CLOSE curPred
				DEALLOCATE curPred
				IF(@Value3 = 'Start')
				begin
					Update [stng].[CARLA_TempChangeLog] set change=1,saved=0,Sent_to_planner=0 where ActivityID=@PK_ActivityID and FieldName='StartDate'
				end
				IF(@Value3 = 'Finish')
				begin
					Update [stng].[CARLA_TempChangeLog] set change=1,saved=0,Sent_to_planner=0 where ActivityID=@PK_ActivityID and FieldName='FinishDate'
				end
			
			SELECT V.RevisedDate,V.ActivityID,V.Variance FROM stng.VV_CARLA_CSQMain V WHERE V.ActivityID = @Value6

			END

		/*GET Remaining dates for Schedule Prompt*/
		IF(@Operation = 15)
		BEGIN
			

			IF(@Value3 = 'Start')
				SET @PrevDate = (SELECT top(1) IIF(FA.[Status] = 'NotStart',FA.[StartDate],FA.[ActualStartDate]) 
								FROM stng.CARLA_FragnetActivity FA WHERE FA.ActivityID = @PK_ActivityID)
			IF(@Value3 = 'Finish')
				SET @PrevDate = (SELECT top(1) IIF(FA.[Actualized] = 0,FA.[ReendDate],FA.[ActualEndDate])
								FROM stng.CARLA_FragnetActivity FA WHERE FA.ActivityID = @PK_ActivityID)

			SET @NewDiff = stng.FN_CARLA_GetDateDiff(@PrevDate,CAST(@Value2 AS DATE))

			EXEC stng.SP_CARLA_GetRemainingDates @ActivityID=@PK_ActivityID,@NewDiff=@NewDiff;

			IF(@Value2 IS NULL)
			SELECT STRING_AGG(CONVERT(NVARCHAR(500),A.ActivityID), ',') WITHIN GROUP (ORDER BY A.ActivityID)  'ActivityID'
				,A.NewStartDate
				,A.NewFinishDate
				,A.StartDate
				,A.FinishDate
			FROM stng.FN_CARLA_GetNewDates(@PK_ActivityID,@NewDiff,@Value2,@SubFragnetList,@Value3) A
			LEFT JOIN (
				SELECT ActivityID,STRING_AGG(RelatedActivityID,',') ReleatedActivity,[Type] 
				FROM stng.CARLA_RelatedActivity
				GROUP BY [Type], ActivityID
				HAVING [Type] = 'Predecessor'
			) Pred ON Pred.ActivityID = A.ActivityID
			LEFT JOIN (
				SELECT ActivityID,STRING_AGG(RelatedActivityID,',') ReleatedActivity,[Type] 
				FROM stng.CARLA_RelatedActivity
				GROUP BY [Type], ActivityID
				HAVING [Type] = 'Successor'
			) Succ ON Succ.ActivityID = A.ActivityID
			GROUP BY A.FragnetID
				,Pred.ReleatedActivity
				,Succ.ReleatedActivity
				,A.NewStartDate
				,A.NewFinishDate
				,A.StartDate
				,A.FinishDate

			IF(@Value2 IS NOT NULL)
			SELECT STRING_AGG(CONVERT(NVARCHAR(500),A.ActivityID), ',') WITHIN GROUP (ORDER BY A.ActivityID)  'ActivityID'
				,A.NewStartDate
				,A.NewFinishDate
				,A.StartDate
				,A.FinishDate
			FROM stng.FN_CARLA_GetNewDates(@PK_ActivityID,@NewDiff,@Value2,@SubFragnetList,@Value3) A
			LEFT JOIN (
				SELECT ActivityID,STRING_AGG(RelatedActivityID,',') ReleatedActivity,[Type] 
				FROM stng.CARLA_RelatedActivity
				GROUP BY [Type], ActivityID
				HAVING [Type] = 'Predecessor'
			) Pred ON Pred.ActivityID = A.ActivityID
			LEFT JOIN (
				SELECT ActivityID,STRING_AGG(RelatedActivityID,',') ReleatedActivity,[Type] 
				FROM stng.CARLA_RelatedActivity
				GROUP BY [Type], ActivityID
				HAVING [Type] = 'Successor'
			) Succ ON Succ.ActivityID = A.ActivityID
			GROUP BY A.FragnetID
				,Pred.ReleatedActivity
				,Succ.ReleatedActivity
				,A.NewStartDate
				,A.NewFinishDate
				,A.StartDate
				,A.FinishDate
			HAVING (A.NewFinishDate > GETDATE() AND A.NewStartDate IS NULL) OR (A.NewStartDate > GETDATE())
		END
		
		/*Update Activity Detail*/
		IF(@Operation = 17)
			BEGIN 
				SET @PreviousValue = (SELECT TOP 1 CL.NewValue FROM stng.CARLA_ChangeLog CL WHERE CL.FKID = @Value3 ORDER BY CL.CreatedDate DESC)
				INSERT INTO stng.CARLA_ChangeLog(ActivityID,FieldName,NewValue,PreviousValue,CreatedBy,P6UpdateRequired,[Key],FKID) 
				VALUES (@PK_ActivityID,@Value4,@Value2,@PreviousValue,@EmployeeID,1,'Number',@Value3)
			END
		
		/*GET Activity Numbers*/
		IF(@Operation = 18)
			BEGIN 
			--	SELECT * FROM (
			--		SELECT DISTINCT AD.ActivityID
			--			,AD.DetailName AS 'Type'
			--			,AD.DetailValue AS 'Number'
			--			,CAST(AD.FADetailID AS VARCHAR) AS 'FADetailID'
			--			,ROW_NUMBER() OVER(PARTITION BY AD.DetailValue,AD.DetailName ORDER BY AD.ActivityID ASC) AS RN
			--		FROM stng.CARLA_FragnetActivityDetail AD
			--		INNER JOIN stng.CARLA_FragnetActivity FA ON FA.ActivityID = AD.ActivityID
			--		WHERE FA.FragnetID IN (SELECT F.FragnetID FROM stng.CARLA_Fragnet F WHERE F.ParentID = (SELECT SF.ParentID FROM stng.CARLA_Fragnet SF 
			--						WHERE SF.FragnetID = (SELECT FA.FragnetID FROM stng.CARLA_FragnetActivity FA WHERE FA.ActivityID = @PK_ActivityID ))) 
			--		AND AD.Type = 'Number'
			--		UNION
			--		SELECT CL.ActivityID
			--			,CL.FieldName
			--			,CL.NewValue
			--			,CL.FKID
			--			,ROW_NUMBER() OVER(PARTITION BY CL.FieldName,CL.FKID ORDER BY CL.ActivityID ASC) AS RN
			--		FROM stng.CARLA_ChangeLog CL
			--		WHERE CL.[Key] = 'Number' 
			--		AND CL.P6UpdateRequired = 1
			--		AND CL.ActivityID IN (SELECT A.ActivityID FROM stng.CARLA_FragnetActivity A 
			--			WHERE A.ActivityName NOT LIKE '%Amendment%'
			--			AND A.FragnetID IN (SELECT F.FragnetID FROM stng.CARLA_Fragnet F 
			--				WHERE F.ParentID = (SELECT SF.ParentID FROM stng.CARLA_Fragnet SF 
			--					WHERE SF.FragnetID = (SELECT FA.FragnetID FROM stng.CARLA_FragnetActivity FA WHERE FA.ActivityID = @PK_ActivityID )))) 
			--		UNION
			--		SELECT CL.ActivityID
			--			,CL.FieldName
			--			,CL.NewValue
			--			,CL.FKID
			--			,ROW_NUMBER() OVER(PARTITION BY CL.FieldName,CL.FKID ORDER BY CL.ActivityID ASC) AS RN
			--		FROM stng.CARLA_ChangeLog CL
			--		WHERE CL.[Key] = 'Number' 
			--		AND CL.P6UpdateRequired = 1
			--		AND CL.ActivityID = @PK_ActivityID
			--	) A
			--	WHERE A.RN = 1

			select ActivityID, ScopeType as [Type], 
			case when ScopeType='TDS' then TDS.SheetID
	--		when ScopeType  ='Item' then ITEMNUM
			when ScopeType  in ('PR','PO','RFQ') then cast (PO.PURCHASINGOBJECT as varchar)
			else
			cast (Reference_ID  as varchar) end as Number
			from  [stng].[CARLA_ScopeSelection] SD
		--	left join  stng.VV_CARLA_ItemWO as ItemWO on SD.Reference_ID = ITEMWO.uniqueID
			left join   [stng].[VV_ETDB_ScopingSheet] TDS on cast(SD.Reference_ID as varchar)= cast (TDS.SSID as varchar)
			left join 	[stngetl].[General_PurchasingObject] PO on cast( SD.Reference_ID as varchar)= cast(PO.UniqueID as varchar)
			where ActivityID = @ActivityID and 
					ScopeType <> 'Item' and  active is null
			END

		/*Update - Update Required*/
		IF(@Operation = 19)
		BEGIN
			SET @PreviousValue = (SELECT TOP 1 C.NewValue FROM stng.Common_ChangeLog C 
				WHERE ParentID = @PK_ActivityID AND C.AffectedField = 'Status' AND C.AffectedTable = 'FragnetUpdate' ORDER BY C.CreatedDate DESC)
			IF(@PreviousValue IS NULL OR @PreviousValue != @Value2)
				BEGIN

					INSERT INTO stng.Common_ChangeLog(ParentID,NewValue,PreviousValue,AffectedField,AffectedTable,CreatedBy)
					SELECT Item,@Value2,U.[Status],'Status','FragnetUpdate',@EmployeeID FROM stng.FN_0124_SplitString(@TempPK,',') A
					LEFT JOIN stng.CARLA_FragnetUpdate U ON U.ActivityID = A.Item
				END
			ELSE
				INSERT INTO stng.Common_ChangeLog(ParentID,NewValue,PreviousValue,AffectedField,AffectedTable,CreatedBy)
				SELECT Item,@Value2,U.[Status],'Status','FragnetUpdate',@EmployeeID FROM stng.FN_0124_SplitString(@TempPK,',') A
				LEFT JOIN stng.CARLA_FragnetUpdate U ON U.ActivityID = A.Item
	
			-- Update Fragnet update record on existing activity record
			UPDATE stng.CARLA_FragnetUpdate SET UpdateRequired = @IsTrue1,ModifiedBy=@EmployeeID,LastModified=stng.GetBPTime(GETDATE()),[Status]=@Value2
			WHERE stng.CARLA_FragnetUpdate.ActivityID IN (SELECT Item FROM stng.FN_0124_SplitString(@TempPK,','))			

			-- Create new Fragnet update if activity record does not exist
			INSERT INTO stng.CARLA_FragnetUpdate(ActivityID,CreatedBy,Status,UpdateRequired) 
			SELECT A.Item,@EmployeeID,@Value2,@IsTrue1 FROM stng.FN_0124_SplitString(@TempPK,',') A
			WHERE A.Item NOT IN (SELECT U.ActivityID FROM stng.CARLA_FragnetUpdate U)


			


		END

		/*DELETE Activity Status*/
		IF(@Operation = 20)
			BEGIN
				INSERT INTO stng.Common_ChangeLog(ParentID,NewValue,PreviousValue,AffectedField,AffectedTable,CreatedBy)
				SELECT U.ActivityID,NULL,U.[Status],'Status','FragnetUpdate',@EmployeeID FROM stng.CARLA_FragnetUpdate U WHERE U.ActivityID = @PK_ActivityID
				UPDATE stng.CARLA_FragnetUpdate SET Status = NULL,LastModified = stng.GetBPTime(GETDATE()),ModifiedBy = @EmployeeID WHERE ActivityID = @PK_ActivityID
			END
		
		/*DELETE Activity Detail Number*/
		IF(@Operation = 21)
			BEGIN
				UPDATE stng.CARLA_ChangeLog SET P6UpdateRequired = 0 WHERE stng.CARLA_ChangeLog.FKID = @Value2 AND P6UpdateRequired = 1

				SET @PreviousValue = (SELECT F.DetailName FROM stng.CARLA_FragnetActivityDetail F WHERE CAST(FADetailID AS VARCHAR) = @Value2)
				SET @Value3 = (SELECT F.DetailValue FROM stng.CARLA_FragnetActivityDetail F WHERE CAST(FADetailID AS VARCHAR) = @Value2)

				DELETE AD FROM stng.CARLA_FragnetActivityDetail AD
				INNER JOIN stng.CARLA_FragnetActivity FA ON FA.ActivityID = AD.ActivityID
					WHERE FA.FragnetID IN (SELECT F.FragnetID FROM stng.CARLA_Fragnet F 
					WHERE F.ParentID IN (SELECT CSQ.ParentID FROM stng.CARLA_Fragnet CSQ 
					WHERE CSQ.FragnetID IN (SELECT A.FragnetID FROM stng.CARLA_FragnetActivity A WHERE A.ActivityID = @PK_ActivityID)))
				AND AD.[Type] = 'Number'
				AND AD.DetailName = @PreviousValue
				AND AD.DetailValue = @Value3
			END

		/*ADD Activity Detail Number*/
		IF(@Operation = 22)
			BEGIN

				INSERT INTO stng.CARLA_ChangeLog(ActivityID,FieldName,NewValue,CreatedBy,[Key],FKID) 
				VALUES (@PK_ActivityID,@Value2,@Value3,@EmployeeID,'Number',CONCAT(@PK_ActivityID,@Value2,@Value3))

				SELECT * FROM (
					SELECT DISTINCT AD.ActivityID
						,AD.DetailName AS 'Type'
						,AD.DetailValue AS 'Number'
						,CAST(AD.FADetailID AS VARCHAR) AS 'FADetailID'
						,ROW_NUMBER() OVER(PARTITION BY AD.DetailValue,AD.DetailName ORDER BY AD.ActivityID ASC) AS RN
					FROM stng.CARLA_FragnetActivityDetail AD
					INNER JOIN stng.CARLA_FragnetActivity FA ON FA.ActivityID = AD.ActivityID
					WHERE FA.FragnetID IN (SELECT F.FragnetID FROM stng.CARLA_Fragnet F WHERE F.ParentID = (SELECT SF.ParentID FROM stng.CARLA_Fragnet SF 
									WHERE SF.FragnetID = (SELECT FA.FragnetID FROM stng.CARLA_FragnetActivity FA WHERE FA.ActivityID = @PK_ActivityID ))) 
					AND AD.Type = 'Number'
					UNION
					SELECT CL.ActivityID
						,CL.FieldName
						,CL.NewValue
						,CL.FKID
						,ROW_NUMBER() OVER(PARTITION BY CL.FieldName,CL.FKID ORDER BY CL.ActivityID ASC) AS RN
					FROM stng.CARLA_ChangeLog CL
					WHERE CL.[Key] = 'Number' 
					AND CL.P6UpdateRequired = 1
					AND CL.ActivityID IN (SELECT A.ActivityID FROM stng.CARLA_FragnetActivity A 
					WHERE A.FragnetID IN (SELECT F.FragnetID FROM stng.CARLA_Fragnet F 
					WHERE F.ParentID = (SELECT SF.ParentID FROM stng.CARLA_Fragnet SF 
					WHERE SF.FragnetID = (SELECT FA.FragnetID FROM stng.CARLA_FragnetActivity FA WHERE FA.ActivityID = @PK_ActivityID )))) 
				) A
				WHERE A.RN = 1
			END

		/*GET CSQ Summary*/
		IF(@Operation = 24) 
			BEGIN
				SELECT FN.ActivityID,FN.Total,FN.[Type] FROM stng.FN_CARLA_CSQSummary(@PK_ActivityID) FN
				SELECT F.ActivityID,F.ActivityName FROM stng.CARLA_FragnetActivity F 
				WHERE F.FragnetID IN (SELECT FragnetID FROM stng.CARLA_FragnetActivity WHERE ActivityID = @PK_ActivityID)
				AND F.NCSQ IN ('NCSQ','CSQ') ORDER BY F.EndDate 
			END

		/*INSERT PlannerSubmission*/
		IF (@Operation = 25) 
			INSERT INTO stng.CARLA_PlannerSubmission(ActivityID, PriorityType, DateOC, PCSComments) 
			VALUES(@PK_ActivityID,@Value2,@Date1,@Value6);

		/*Planner-View*/
		IF (@Operation = 26) 
		begin
			Update [stng].[CARLA_TempChangeLog] set change=0
			SELECT * FROM [stng].[VV_CARLA_CSQMain] C 
			INNER JOIN [stng].[CARLA_PlannerSubmission] D ON C.ActivityID = D.ActivityID
			ORDER BY C.DateSort;
		end

		/* GET Child Activities for Planner*/
		IF (@Operation = 27) 
		Begin
			if exists (select ActivityID from stng.CARLA_Planner where activityID=@ActivityID)
			begin
				EXEC stng.SP_CARLA_GetChildActivities @PK_ActivityID=@ActivityID
			end 
		end

		/*Activity sent to planner*/
		IF (@Operation = 28) 
		begin
			Insert into  [stng].[CARLA_Planner] (ActivityID,RAD,RAB,LUD,LUB,Status) values (@ActivityID,getdate(),@currentuser,getdate(),@currentuser,'Pending Update')

		        INSERT INTO stng.Common_ChangeLog(ParentID,NewValue,AffectedField,AffectedTable,CreatedBy) values(
				@ActivityID,
				'Added to Planner Tab with Priority :'+@Priority+' Completion Date :'+CONVERT(NVARCHAR(50), @CompletionDate, 106)
				,'SendToPlanner','FragnetUpdate',@CurrentUser)

				UPDATE [stng].[CARLA_ChangeLog]
				SET Sent_to_planner = 1
				WHERE Saved = 1 AND P6UpdateRequired = 1
				AND ActivityID IN (SELECT value FROM string_split(@SubActivity, ','));

				
				UPDATE [stng].[CARLA_ChangeLog]
				SET Sent_to_planner = 1
				WHERE Saved = 1 AND P6UpdateRequired = 1
				AND ActivityID IN (select distinct Cast (FragnetID as varchar) FROM [stng].[CARLA_FragnetActivity]
									where ActivityID in (SELECT value FROM string_split(@SubActivity, ',')));
					

				UPDATE [stng].[CARLA_TempChangeLog]
				SET Sent_to_planner = 1
				WHERE Saved = 1 AND P6UpdateRequired = 1
				AND ActivityID IN (SELECT value FROM string_split(@SubActivity, ','));

		end

		/*add-status-from-planner*/
			IF (@Operation = 29) 
			begin

				
				INSERT INTO stng.Common_ChangeLog(ParentID,NewValue,PreviousValue,AffectedField,AffectedTable,CreatedBy)
				SELECT F.ActivityID,@status,F.Status,'PlannerStatus','FragnetUpdate',@CurrentUser
				FROM stng.CARLA_Planner F WHERE F.ActivityID = @ActivityID

				if exists (select status from [stng].[CARLA_Planner] where ActivityID=@ActivityID and status is not null)
					begin
							Insert into  [stng].[CARLA_Planner] (ActivityID,[Status],RAD,RAB,LUD,LUB)  select distinct @ActivityID,@status,  RAD,RAB,getdate(),@CurrentUser from [stng].[CARLA_Planner] where ActivityID=@ActivityID 
					end
					else 
						update [stng].[CARLA_Planner] set Status=@status where ActivityID=@ActivityID
	if (@status='Complete')
	begin
				UPDATE [stng].[CARLA_ChangeLog]
				SET Sent_to_planner = 0,saved=0
				WHERE  P6UpdateRequired = 1
				AND ActivityID IN (SELECT value FROM string_split(@SubActivity, ','));

				UPDATE [stng].[CARLA_ChangeLog]
				SET P6UpdateRequired = 0
				WHERE  P6UpdateRequired = 1 and Fieldname in ('ActivityName')
				AND ActivityID IN (SELECT value FROM string_split(@SubActivity, ','));

				UPDATE [stng].[CARLA_ChangeLog]
				SET P6UpdateRequired = 0
				WHERE P6UpdateRequired = 1 
				AND ActivityID IN (select distinct FragnetID  FROM [stng].[CARLA_FragnetActivity]
									where ActivityID in (SELECT value FROM string_split(@SubActivity, ',')));


				UPDATE [stng].[CARLA_TempChangeLog]
				SET Sent_to_planner = 0,saved=0,Change=0
				WHERE  P6UpdateRequired = 1
				AND ActivityID IN (SELECT value FROM string_split(@SubActivity, ','));
				end	
			
				end

			/*Planner status values*/		
			IF (@Operation = 30) 
					   			
				select  distinct UniqueID,LUD ,[Status] as status,b.FullName as LUB 
					from  [stng].[CARLA_Planner] a
				inner join   [stng].[VV_Admin_Users] b 
					on a.LUB=b.EmployeeID 
					where ActivityID=@ActivityID and status is not null
					order by LUD desc
				
			/*get planner status*/
			IF (@Operation = 31) 		   			
				select Top(1)* from  [stng].[CARLA_Planner]  where ActivityID=@ActivityID order by LUD desc
			
			/*Planner emails*/
			if	(@operation=32)
				begin
			

					SELECT LOWER(U.Email) Email FROM stng.VV_Admin_UserRole UR 
					INNER JOIN stng.Admin_User U ON U.EmployeeID = UR.EmployeeID
						WHERE UR.Role = 'Eng-Tech SPOC'

					SELECT T.Content AS [EmailBody] FROM stng.Common_EmailTemplate T WHERE T.[Name] = @EmailName;
					
					SELECT [ActivityID],PCS as PCSFullName ,b.Username as PCSEmail, c.FirstName+' '+c.LastName as PlannerFullName,c.Username as PlannerEmail
						FROM [stng].[VV_CARLA_CSQMain] a left join [stng].[Admin_User] b on a.PCS=b.FullName
						left join [stng].[Admin_User] c 
						on a.SupplychainPlanner= c.FullName 
						where ActivityID=@ActivityID

					select Username as CurrentUserEmail from stng.Admin_User where EmployeeID=@CurrentUser

					SELECT  Email as SeniorPlannerEmail  FROM [stng].[VV_Admin_UserRole] a left join [stng].[VV_Admin_Users] b on a.EmployeeID=b.EmployeeID
					 where Role = 'CARLA Senior Planner'
					
					
						 SELECT a.ActivityID,RAD,RAB, c.email as InitiatorEmail
						  FROM [stng].[CARLA_Planner] a left join 
						  (SELECT ActivityID,Min(RAD) as min_rad
   						 FROM [stng].[CARLA_Planner] group by ActivityID ) b
						 on a.ActivityID=b.ActivityID and a.RAD =b.min_rad 
						  left join [stng].[Admin_User] c on a.RAB=c.EmployeeID  where a.ActivityID=@ActivityID

				end

			/* GET Temp Child Activities*/
			IF (@Operation = 33) 
				EXEC stng.SP_CARLA_GetChildActivitiesTemp @PK_ActivityID=@PK_ActivityID

			/*Actualize or anticiapated based on today date*/
			if	(@operation=34)
				begin
					if (@Actualized=1)
						Update [stng].[CARLA_TempChangeLog] set [key]='Actual' where ActivityID=@ActivityID and FieldName=@FieldName 
					else 
					    Update [stng].[CARLA_TempChangeLog] set [key]='Anticipated' where ActivityID=@ActivityID and FieldName=@FieldName 
					select * from [stng].[CARLA_TempChangeLog]  where ActivityID=@ActivityID and FieldName=@FieldName 
				end

			/*NR activities*/
			IF (@Operation = 35) 
				begin
				if  (@NR=0)
				begin
				
				 if exists(select * from [stng].[CARLA_FragnetUpdate] where ActivityID=ActivityID )
						begin
							Update [stng].[CARLA_FragnetUpdate] set NR=@NR, LastModified=stng.GetBPTime(GETDATE()),ModifiedBy=@CurrentUser
							where ActivityID=@PK_ActivityID
						end
					else 
						begin
							insert into [stng].[CARLA_FragnetUpdate]
							(ActivityID,CreatedBy,CreatedDate,NR) 
							values(@PK_ActivityID,@CurrentUser,stng.GetBPTime(GETDATE()),@NR)
					end
					Update [stng].[CARLA_TempChangeLog] set nr=@NR where ActivityID=@PK_ActivityID and FieldName='StartDate'
				end 
				else 
				begin
					Update [stng].[CARLA_TempChangeLog] set nr=1 where ActivityID=@PK_ActivityID and FieldName='StartDate'
				end

				end

			/*Status and Category dropdown*/
			 IF (@Operation = 36) 
				begin
					  select [Label] ,[Value]  FROM [stng].[Common_ValueLabel] where moduleID=4 and [Group]= 'CSQ' and field='Status'
					  select [Label],[Value]  FROM [stng].[Common_ValueLabel] where moduleID=4 and [Group]= 'CSQ' and field='Category'
			   end

			/*Activity getting old data*/
			 IF (@Operation = 37) 
				begin
					if(@OriginalData=1)
						begin
							DECLARE curPred CURSOR FOR SELECT [ActivityID],[FieldName] ,[NewValue]  from  [stng].[CARLA_ChangeLog] 
							where   P6UpdateRequired=1 and ActivityID in ( select value from string_split(@SubActivity,',') ) 
				
							OPEN curPred
							FETCH NEXT FROM curPred INTO @ActivityID,@FieldName,@NewValue
							WHILE @@FETCH_STATUS = 0 
							BEGIN
								if(@Fieldname='StartDate')
									begin
										if exists (select * from stng.CARLA_TempChangeLog where ActivityID=@ActivityID and fieldname=@FieldName)
										begin
										Update stng.CARLA_TempChangeLog set NewValue=(select Startdate FROM [stng].[CARLA_FragnetActivity] where ActivityID=@ActivityID),
											PreviousValue=(select NewValue FROM [stng].[CARLA_ChangeLog] where ActivityID=@ActivityID and FieldName=@FieldName and P6UpdateRequired=1),
											change=0,saved=0,Sent_to_planner=0
											where ActivityID=@ActivityID and FieldName=@FieldName
										end 
									else
										begin
											INSERT INTO stng.CARLA_TempChangeLog
											(ActivityID,FieldName,NewValue,PreviousValue,CreatedBy,[Key],[P6UpdateRequired],[Saved],[Sent_to_planner])
											 Select  @ActivityID,'StartDate',StartDate,@NewDate,@CurrentUser, case when Actualized=1 then 'Actual' else  'Anticipated' end 
											 ,1,0,0  FROM [stng].[CARLA_FragnetActivity] where ActivityID=@ActivityID
										end
							 end
								if(@Fieldname='FinishDate')
									begin
										if exists (select * from stng.CARLA_TempChangeLog where ActivityID=@ActivityID and fieldname=@FieldName)
											begin
												Update stng.CARLA_TempChangeLog set NewValue=(select ReendDate FROM [stng].[CARLA_FragnetActivity] where ActivityID=@ActivityID ),
												PreviousValue=(select NewValue FROM [stng].[CARLA_ChangeLog] where ActivityID=@ActivityID and FieldName=@FieldName and P6UpdateRequired=1)
												,change=0,saved=0,Sent_to_planner=0
												where ActivityID=@ActivityID and FieldName=@FieldName
											end 
										else
											begin
												INSERT INTO stng.CARLA_ChangeLog
												(ActivityID,FieldName,NewValue,PreviousValue,CreatedBy,[Key],[P6UpdateRequired],[Saved],[Sent_to_planner])
												 Select  @ActivityID,'FinishDate',ReendDate,@NewDate,@CurrentUser, case when Actualized=1 then 'Actual' else  'Anticipated' end ,
												 1,0,0  FROM [stng].[CARLA_FragnetActivity]
												 where ActivityID=@ActivityID
											end
									end
								FETCH NEXT FROM curPred INTO @ActivityID,@FieldName,@NewValue 
						END
						CLOSE curPred
						DEALLOCATE curPred

				  end
					else
						 begin
							    DECLARE curPred CURSOR FOR
								SELECT [ActivityID]     ,[FieldName]      ,[NewValue]      ,[PreviousValue]      ,[CreatedBy]      ,[CreatedDate]      ,[P6UpdateRequired],[Key],[Saved]  ,[Sent_to_planner]
								FROM [stng].[CARLA_ChangeLog]
								where  P6UpdateRequired=1 and ActivityID in ( select value from string_split(@SubActivity,',') ) 

								OPEN curPred
								FETCH NEXT FROM curPred INTO @ActivityID,@FieldName,@NewValue,@PreviousValue,@CreatedBy,@CreatedDate,@P6updateRequired ,@Key, @Sent_to_planner,@Saved 	
								WHILE @@FETCH_STATUS = 0 
									BEGIN
										update stng.CARLA_TempChangeLog 
										set NewValue=@NewValue,PreviousValue=@PreviousValue,CreatedBy=@CreatedBy,CreatedDate=@CreatedDate,@P6UpdateRequired=@P6UpdateRequired,[Key]=@Key, [Saved]=@Saved
										,[Sent_to_planner]=@Sent_to_planner,[NR]=0
										 where ActivityID=@ActivityID and FieldName=@FieldName
										FETCH NEXT FROM curPred INTO  @ActivityID,@FieldName,@NewValue,@PreviousValue,@CreatedBy,@CreatedDate,@P6updateRequired ,@Key, @Sent_to_planner,@Saved 				
									END
									CLOSE curPred
									DEALLOCATE curPred
								end
			    end

			/*schedule-change-temp-icon*/
			 IF (@Operation = 38) 
				begin
					select @icon
					if(@icon=1)
						begin
							DECLARE curPred CURSOR FOR
								SELECT [ActivityID] from  [stng].[CARLA_ChangeLog] 	where   P6UpdateRequired=1 and ActivityID in ( select value from string_split(@SubActivity,',') ) 
				
							OPEN curPred
							FETCH NEXT FROM curPred INTO @ActivityID
							WHILE @@FETCH_STATUS = 0 
								BEGIN
									update stng.CARLA_TempChangeLog set [Change]=0 ,[Saved]=0  ,[Sent_to_planner]=0 ,[NR]=0 where ActivityID=@ActivityID
									FETCH NEXT FROM curPred INTO @ActivityID
								END
							CLOSE curPred
							DEALLOCATE curPred
						end
					else 
						begin
							DECLARE curPred CURSOR FOR
								SELECT [ActivityID]   ,[FieldName]  ,[NewValue] ,[PreviousValue]  ,[CreatedBy]  ,[CreatedDate] ,[P6UpdateRequired],[Key],[Saved] ,[Sent_to_planner]
								FROM [stng].[CARLA_ChangeLog]
								where P6UpdateRequired=1 and ActivityID in ( select value from string_split(@SubActivity,',') ) 
							OPEN curPred
							FETCH NEXT FROM curPred INTO @ActivityID,@FieldName,@NewValue,@PreviousValue,@CreatedBy,@CreatedDate,@P6updateRequired ,@Key, @Sent_to_planner,@Saved 
							WHILE @@FETCH_STATUS = 0 
							BEGIN
								update stng.CARLA_TempChangeLog 
								set NewValue=@NewValue,PreviousValue=@PreviousValue,CreatedBy=@CreatedBy,CreatedDate=@CreatedDate,@P6UpdateRequired=@P6UpdateRequired,[Key]=@Key ,[Saved]=@Saved
								,[Sent_to_planner]=@Sent_to_planner  ,[NR]=0 
								where ActivityID=@ActivityID and FieldName=@FieldName
	
								FETCH NEXT FROM curPred INTO  @ActivityID,@FieldName,@NewValue,@PreviousValue,@CreatedBy,@CreatedDate,@P6updateRequired ,@Key, @Sent_to_planner,@Saved 		
							END
							CLOSE curPred
							DEALLOCATE curPred
						end
					end

					/*Get WO info*/
			 IF (@Operation = 39) 
			 begin
				
					SELECT  distinct   wo.[WONUM],  wo.[WOSTATUS],
						  wo.[PROJECTID],  wo.[WOTYPE],  wo.[WOPRIORITY],  wo.[WOSTATUSDATE], 
						 wo.[WODESCRIPTION],
						 case when sd.Reference_ID is not null then cast(1 as bit) else cast(0 as bit ) end as checked
					 FROM 
						  [stngetl].[General_WODemand] wo  left join 
						  (select * from  [stng].[CARLA_ScopeSelection] where ActivityID=@ActivityID and scopetype='wo' and active is null) SD on wo.wonum=sd.Reference_ID
					WHERE 
						   (
					      (@SearchKind = 'project' AND ((@Search IS NULL AND ProjectID IS NULL) OR (ProjectID = @Search)))
					      OR
					     (@SearchKind = 'wo' AND ((@Search IS NULL AND WONUM IS NULL) OR (WONUM = @Search)))
						 OR
					     (@SearchKind = 'item' AND ((@Search IS NULL AND Itemnum IS NULL) OR (Itemnum = @Search)))
						
						  )
						       

			end

			/*Get Item info*/
			 IF (@Operation = 40) 
			 begin
			
				select Itemwo.*, case when sd.Reference_ID is not null then cast(1 as bit) else cast(0 as bit ) end as checked
				from stng.VV_CARLA_ItemWO as ItemWO
				left join 
				(select * from  [stng].[CARLA_ScopeSelection] where ActivityID=@ActivityID and scopetype='item' and active is null) SD on ItemWO.uniqueid=sd.Reference_ID
				
					WHERE 
						   (
					      (@SearchKind = 'project' AND ProjectID = @Search)
					      OR
					     (@SearchKind = 'wo' AND WONUM = @Search)
						 OR
					     (@SearchKind = 'item' AND Item = @Search)
						
						  )
				
			end

			/*Get TDS info*/
			 IF (@Operation = 41) 
			 begin
				if (@SearchKind='project')
				begin
					SELECT tds.*, case when sd.Reference_ID is not null then cast(1 as bit) else cast(0 as bit ) end as checked  
					FROM [stng].[VV_ETDB_ScopingSheet] tds	
					left join 
				(select * from  [stng].[CARLA_ScopeSelection] where ActivityID=@ActivityID and scopetype='tds' and active is null) SD on tds.SSID=sd.Reference_ID
			
					
					
					where right(ProjectID,5)=@Search
				end
			end
				/*Get PO,PR info*/
			 IF (@Operation = 42) 
			 begin

			 if(@SearchKind in ('project','pr','rfq','po'))
			 begin
					with PO as(
					SELECT   [PURCHASINGOBJECTTYPE]      ,[PURCHASINGOBJECT]      ,[PURCHASINGOBJECTSTATUS]      ,[PURCHASINGOBJECTSTATUSDATE]
					,[PURCHASINGOBJECTBUYER]      ,max([UniqueID]) as [UniqueID]
					FROM [stngetl].[General_PurchasingObject]  group by  [PURCHASINGOBJECTTYPE],[PURCHASINGOBJECT] ,[PURCHASINGOBJECTSTATUS]
																 ,[PURCHASINGOBJECTSTATUSDATE] ,[PURCHASINGOBJECTBUYER] 
																
																 )
			
			        SELECT a.*, b.[PROJECTID]
					, case when sd.Reference_ID is not null then cast(1 as bit) else cast(0 as bit ) end as checked  
					FROM PO a
				   LEFT JOIN (SELECT distinct  [PURCHASINGOBJECTTYPE]      ,[PURCHASINGOBJECT] ,[PROJECTID]
					FROM [stngetl].[General_PurchasingObjectProject] 	) b 
					ON a.[PURCHASINGOBJECT] = b.[PURCHASINGOBJECT]
					left join 
				  (select * from  [stng].[CARLA_ScopeSelection] where ActivityID=@ActivityID and scopetype in ('pr','rfq','po') and active is null)
				  SD on a.UniqueID=sd.Reference_ID
			  WHERE (
						   (@SearchKind = 'project' AND b.Projectid = @Search)
						   OR (@SearchKind = 'pr' AND a.PURCHASINGOBJECTTYPE = 'PR' AND a.PURCHASINGOBJECT = @Search)
					    OR (@SearchKind = 'rfq' AND a.PURCHASINGOBJECTTYPE = 'RFQ' AND a.PURCHASINGOBJECT = @Search)
					    OR (@SearchKind = 'po' AND a.PURCHASINGOBJECTTYPE = 'PO' AND a.PURCHASINGOBJECT = @Search)
						)

				end

				if (@SearchKind='item')
				begin
					SELECT a.*, b.[PROJECTID] FROM [stngetl].[General_PurchasingObject] a
				    LEFT JOIN [stngetl].[General_PurchasingObjectProject] b 
				    ON a.[PURCHASINGOBJECT] = b.[PURCHASINGOBJECT] where a.itemnum=@Search
				end

			
			end

		

				/*Get TDS info*/
			 IF (@Operation = 43) 
			 begin
					SELECT a.*  FROM [stng].[VV_ETDB_ScopingSheet] a
					inner join (select * from  [stng].[CARLA_ScopeSelection] where ActivityID=@ActivityID and scopetype='tds' and active is null) b
					on a.SSID=b.Reference_ID
				
			end
				/*Get WO info*/
			 IF (@Operation = 44) 
			 begin
			
			      SELECT  distinct  [WONUM], [WOSTATUS],
						 [PROJECTID], [WOTYPE], [WOPRIORITY], [WOSTATUSDATE], 
						[WODESCRIPTION]	 FROM [stngetl].[General_WODemand]  a
				  inner join (select * from  [stng].[CARLA_ScopeSelection] where ActivityID=@ActivityID and scopetype='WO'and active is null) b
				  on a.WOnum=b.Reference_ID

				end

					/*Get Service info*/
			 IF (@Operation = 45) 
			 begin

			with cte as (
				 SELECT  a.*
					FROM [stngetl].[General_PurchasingObject] a 
					inner join (select * from  [stng].[CARLA_ScopeSelection] where 
					ActivityID=@ActivityID and
					scopetype  in ('PR','RFQ','PO')and active is null) b 
					on a.UniqueID=b.Reference_ID)

, PO as (
					select 
					 cte.[ITEMNUM]
					,cte.[PURCHASINGOBJECT] as PONUM
					,cte.[PURCHASINGOBJECTSTATUS] as POStatus
					,cte.[PURCHASINGOBJECTSTATUSDATE] as POStatusDate
					,cte.[PURCHASINGOBJECTBUYER] as POBuyer
					,[PRNUM]
					,c.[PURCHASINGOBJECTSTATUS] as PRStatus
					,c.[PURCHASINGOBJECTSTATUSDATE] as PRStatusDate
					,c.[PURCHASINGOBJECTBUYER] as PRBuyer
					,[RFQNUM]
					,d.[PURCHASINGOBJECTSTATUS] as RFQStatus
					,d.[PURCHASINGOBJECTSTATUSDATE] as RFQStatusDate
					,d.[PURCHASINGOBJECTBUYER] as RFQBuyer
					,[REFWO],
					e.[WOSTATUS]
				  ,e.[WOTYPE]
 		  		   ,e.[WOPRIORITY]
 		  		   ,e.[WOSTATUSDATE]
 					,e.[WORKTYPE]
				      ,e.[OUTAGE]
 				     ,e.[WODESCRIPTION]
 				     ,e.[WOSTARTDATE]
					
					 from cte 
					left join [stngetl].[CARLA_PR_RFQPO] b on cte.PURCHASINGOBJECT=b.PONUM
					left join [stngetl].[General_PurchasingObject] c on c.[PURCHASINGOBJECT] =b.PRNUM
					left join [stngetl].[General_PurchasingObject] d on d.[PURCHASINGOBJECT] =b.RFQNUM
					left join [stngetl].[General_WODemand] e on e.wonum=b.REFWO
					where cte.[PURCHASINGOBJECTTYPE]='PO'
					)

, PR as(

							select 
					 cte.[ITEMNUM]
					,cte.[PURCHASINGOBJECT] as PRNUM
					,cte.[PURCHASINGOBJECTSTATUS] as PRStatus
					,cte.[PURCHASINGOBJECTSTATUSDATE] as PRStatusDate
					,cte.[PURCHASINGOBJECTBUYER] as PRBuyer
					,[PONUM]
					,c.[PURCHASINGOBJECTSTATUS] as POStatus
					,c.[PURCHASINGOBJECTSTATUSDATE] as POStatusDate
					,c.[PURCHASINGOBJECTBUYER] as POBuyer
					,[RFQNUM]
					,d.[PURCHASINGOBJECTSTATUS] as RFQStatus
					,d.[PURCHASINGOBJECTSTATUSDATE] as RFQStatusDate
					,d.[PURCHASINGOBJECTBUYER] as RFQBuyer
					,[REFWO],
					e.[WOSTATUS]
				  ,e.[WOTYPE]
 		  		   ,e.[WOPRIORITY]
 		  		   ,e.[WOSTATUSDATE]
 					,e.[WORKTYPE]
				      ,e.[OUTAGE]
 				     ,e.[WODESCRIPTION]
 				     ,e.[WOSTARTDATE]
					
					 from cte 
					left join [stngetl].[CARLA_PR_RFQPO] b on cte.PURCHASINGOBJECT=b.prnum
					left join [stngetl].[General_PurchasingObject] c on c.[PURCHASINGOBJECT] =b.PONUM
					left join [stngetl].[General_PurchasingObject] d on d.[PURCHASINGOBJECT] =b.RFQNUM
					left join [stngetl].[General_WODemand] e on e.wonum=b.REFWO
					where cte.[PURCHASINGOBJECTTYPE]='PR')
, RFQ as (
							select 
					 cte.[ITEMNUM]
					,cte.[PURCHASINGOBJECT] as RFQNUM
					,cte.[PURCHASINGOBJECTSTATUS] as RFQStatus
					,cte.[PURCHASINGOBJECTSTATUSDATE] as RFQStatusDate
					,cte.[PURCHASINGOBJECTBUYER] as RFQBuyer,
				f.[PONUM]
					,c.[PURCHASINGOBJECTSTATUS] as POStatus
					,c.[PURCHASINGOBJECTSTATUSDATE] as POStatusDate
					,c.[PURCHASINGOBJECTBUYER] as POBuyer
					,PRNUM
					,d.[PURCHASINGOBJECTSTATUS] as PRStatus
					,d.[PURCHASINGOBJECTSTATUSDATE] as PRStatusDate
					,d.[PURCHASINGOBJECTBUYER] as PRBuyer
					,f.[REFWO],
					e.[WOSTATUS]
				  ,e.[WOTYPE]
 		  		   ,e.[WOPRIORITY]
 		  		   ,e.[WOSTATUSDATE]
 					,e.[WORKTYPE]
				      ,e.[OUTAGE]
 				     ,e.[WODESCRIPTION]
 				     ,e.[WOSTARTDATE]
					
					 from cte 
					 left join  [stngetl].[CARLA_RFQ_PO] f on cte.PURCHASINGOBJECT=f.RFQNUM
					left join [stngetl].[CARLA_PR_RFQPO] b on cte.PURCHASINGOBJECT=b.prnum
					left join [stngetl].[General_PurchasingObject] c on c.[PURCHASINGOBJECT] =b.PONUM
					left join [stngetl].[General_PurchasingObject] d on d.[PURCHASINGOBJECT] =b.RFQNUM
					left join [stngetl].[General_WODemand] e on e.wonum=b.REFWO
					where cte.[PURCHASINGOBJECTTYPE]='RFQ'

					)

					select * from PR
					union
					select * from PO 
					union
					select * from RFQ
					


			end
				/*Get Item info*/
			 IF (@Operation = 47) 
			 begin

			       select a.*,b.[WOSTATUS],b.[WOTYPE], b.[WOPRIORITY], b.[WOSTATUSDATE], 
				   b.[WODESCRIPTION] from stng.VV_CARLA_ItemWO a left join 	  [stngetl].[General_WODemand]  b
                    on a.wonum=b.wonum
					inner join (select * from  [stng].[CARLA_ScopeSelection] where ActivityID=@ActivityID and scopetype='item' and active is null) c
					on a.uniqueID=c.Reference_ID
					union
					select a.*,b.[WOSTATUS],b.[WOTYPE], b.[WOPRIORITY], b.[WOSTATUSDATE], 
				   b.[WODESCRIPTION] from stng.VV_CARLA_ItemWO a left join 	  [stngetl].[General_WODemand]  b
                    on a.wonum=b.wonum
					inner join (select * from  [stng].[CARLA_ScopeSelection] where ActivityID=@ActivityID and scopetype='WO' and active is null) c
					on a.WONUM=c.Reference_ID 
				
		
				
			end


	/*Insert Scope element*/
			 IF (@Operation = 46) 
			 begin

				 -- INSERT INTO [stng].[CARLA_ScopeSelection] (ActivityId, ScopeType, [Reference_ID],RAB)
				 --  SELECT ActivityId, ScopeType, Reference_Id,@CurrentUser
					--FROM @ScopeDetails;
				
				-- 1. Reactivate rows by setting Active = NULL if they exist but are inactive
UPDATE cs
SET cs.Active = NULL
FROM [stng].[CARLA_ScopeSelection] cs
JOIN @ScopeDetails sd
    ON cs.ActivityId = sd.ActivityId
    AND cs.ScopeType = sd.ScopeType
    AND cs.Reference_ID = sd.Reference_ID
WHERE cs.Active = 0;

-- 2. Insert new rows that don't already exist
INSERT INTO [stng].[CARLA_ScopeSelection] (ActivityId, ScopeType, [Reference_ID], RAB)
SELECT sd.ActivityId, sd.ScopeType, sd.Reference_ID, @CurrentUser
FROM @ScopeDetails sd
WHERE NOT EXISTS (
    SELECT 1
    FROM [stng].[CARLA_ScopeSelection] cs
    WHERE cs.ActivityId = sd.ActivityId 
      AND cs.ScopeType = sd.ScopeType 
      AND cs.Reference_ID = sd.Reference_ID
);

-- 3. Deactivate rows that exist in main table but not in scope detail
--UPDATE cs
--SET cs.Active = 0
--FROM [stng].[CARLA_ScopeSelection] cs
--WHERE cs.ActivityId IN (SELECT DISTINCT ActivityId FROM @ScopeDetails)
--AND NOT EXISTS (
--    SELECT 1
--    FROM @ScopeDetails sd
--    WHERE sd.ActivityId = cs.ActivityId 
--      AND sd.ScopeType = cs.ScopeType 
--      AND sd.Reference_ID = cs.Reference_ID
--);


	
			end


	/*Update latest comment info*/
	 IF (@Operation = 48) 
	begin
	
		 insert into [stng].[Common_Comment] 
		(ParentID,ParentTable,Body,CreatedBy,CreatedDate)
		values (@ActivityID,'FragnetActivity',@Comment,@CurrentUser,getdate())
	
	end
		
    END TRY
	BEGIN CATCH
        INSERT INTO stng.App_ErrorLog([Number],[Procedure],[Line],[Message],Operation) VALUES (
                     ERROR_NUMBER(),
                     ERROR_PROCEDURE(),
                     ERROR_LINE(),
                     CONCAT(ERROR_MESSAGE(),'PK_ActivityID: ',@PK_ActivityID),
					 @Operation
              );
			  THROW
	END CATCH
	
END
