ALTER procedure [stng].[SP_Governtree_CRUD]
(
	@Operation int,
	@CurrentUser varchar(20) = null,

	@DocumentNo varchar(250) = null,
	@GTID varchar(200) = null,

	@IndustryStandard varchar(150) = null,
	@IndustryStandardTitle varchar(150) = null,
	@JobAidURL varchar(250) = null,
	@JobAidTitle varchar(250)=null,
	@PersonnelType varchar(10) = null,
	@IndustryStandardSectionID varchar(100) = null,
	@IndustryStandardSection varchar(100) = null,
	@IndustryStandardSectionTitle varchar(100) = null,
	@TCorTSC varchar(100)=null,
	@Org varchar(100)=null,
	@ProcessOwner varchar(100)=null,
	@JobAidID varchar(75) = null,
	@EmployeeId AS VARCHAR(100)=null,
	@Revision AS int=0,
	@JobAidNum AS int = null,
    @DocumentSubNo NVARCHAR(50)=null,
	@DocumentNoNum VARCHAR(250)=null,
	@IntID int = null,
	@UniqueID int = null,
	@actionname AS VARCHAR(100)=null,
	@orgtype AS VARCHAR(100)=null,
	@status AS VARCHAR(200)=null,
	@description AS VARCHAR(100)=null,
	@tcd AS datetime=null,
	@DocumentAttached AS bit=false,
	@actionTitle AS VARCHAR(100)=null,
	@actionOwner AS VARCHAR(100)=null,
	@ActionStatus AS VARCHAR(100)=null,
	@actionID bigint = null,
	@Value1 AS varchar(250) = null,
	@Governance AS varchar(350) = null,
	@Compliance AS varchar(350) = null,
	@Excellence AS varchar(350) = null,
	@Comment AS varchar(MAX) = null,
	@UUID uniqueIdentifier = null,

	@PHID AS bigint = null,
	@HealthSection AS varchar(50) = null,
	@Responsibility AS varchar(MAX) = null,
	@Action AS varchar(MAX) = null,
	@StatusID AS uniqueidentifier = null,
	@DueDate AS datetime = null
)

as 
begin
	DECLARE @MaxJobAid int=null;
	declare @UID uniqueidentifier = null;
	DECLARE @NextPHID bigint;

	--Proc working variables

	--Main query
	if @Operation = 1
		begin
			select * 
			from stng.VV_GovernTree_Main
			order by RAD;
		end

	--Add new main Document
	else if @Operation = 2
		begin
			--Verify that document input is actually a Controlled Doc
			if not exists
			(
				select * from stngetl.General_ControlledDoc
				where [NAME] = @DocumentNo
			)
				begin
					select concat(@DocumentNo, ' is not a valid Controlled Document') as ReturnMessage;
					return;
				end

			--First, check if document's already in GovernTree_Main
			if exists
			(
				select *
				from stng.GovernTree_Main
				where DocumentNo = @DocumentNo and Deleted = 0
			)
				begin
					select concat(@DocumentNo, ' already exists in GovernTree. Please input a different Controlled Document') as ReturnMessage;
					return;
				end

			--Revert Deleted
			else if exists
			(
				select *
				from stng.GovernTree_Main
				where DocumentNo = @DocumentNo and Deleted = 1
			)
				begin
					update stng.GovernTree_Main
					set Deleted = 0,
					DeletedBy = null,
					DeletedOn = null
					where DocumentNo = @DocumentNo;					
				end
			
			--Insert new record
			else
				begin

					insert into stng.GovernTree_Main
					(DocumentNo, RAB, Deleted, ReferenceCount, FormCount, StandardCount, JobAidCount, DCRCount)
					values
					(@DocumentNo,@CurrentUser,0,0,0,0,0,0);
				end
		end

	--Remove main document
	else if @Operation = 3
		begin
			if exists  
			( 
				select * 
				from stng.GovernTree_Main
				where UniqueID = @GTID
			)
				begin
					select @DocumentNoNum = DocumentNo
					from stng.GovernTree_Main
					where UniqueID = @GTID;

					update stng.GovernTree_Main
					set Deleted = 1,
					DeletedBy = @CurrentUser,
					DeletedOn = stng.GetBPTime(getdate())
					where DocumentNo = @DocumentNoNum;
				end
			
			else if exists
			(
				select *
				from stng.VV_GovernTree_JobAid
				where JobAidID = @GTID
			)
				begin
					select @DocumentNoNum = DocumentNo, @JobAidNum = JobAidNum
					from stng.VV_GovernTree_JobAid
					where JobAidID = @GTID;

					update stng.GovernTree_JobAid
					set Deleted = 1,
					DeletedBy = @CurrentUser,
					DeletedOn = stng.GetBPTime(getdate())
					where DocumentNoNum = @DocumentNoNum AND JobAidNum = @JobAidNum;
				end
		end

	--Get References
	else if @Operation = 4
		begin
			select *
			from stng.VV_GovernTree_Reference
			where GTID = @GTID;
		end

	--Add reference
	else if @Operation = 5
		begin
			--Do uniqueness check
			if exists
			(
				select *
				from stng.VV_GovernTree_Reference
				where GTID = @GTID and DocumentNo = @DocumentNo
			)
				begin

					select concat('Reference relationship already exists between ',@DocumentNo, ' and the selected document') as ReturnMessage;
					return;

				end

			insert into stng.GovernTree_Reference
			(GTID, DocumentNo, RAB,RAD)
			values
			(@GTID, @DocumentNo, @CurrentUser,stng.GetBPTime(getdate()));
			
			-- update Reference count value
			if exists
			(
				SELECT *
				FROM [stng].[GovernTree_Main]
				where UniqueID = @GTID
			)
				BEGIN
					UPDATE m
					SET m.ReferenceCount = (
						SELECT COUNT(*)
						FROM [stng].[GovernTree_Reference] r
						WHERE (r.[GTID]) = m.[UniqueID]
					)
					FROM [stng].[GovernTree_Main] m;
				END
			else if exists
			(
				SELECT *
				FROM [stng].[GovernTree_JobAid]
				where UniqueID = @GTID
			)
			BEGIN
				UPDATE m
				SET m.ReferenceCount = (
					SELECT COUNT(*)
					FROM [stng].[GovernTree_Reference] r
					WHERE (r.[GTID]) = m.[UniqueID]
				)
				FROM [stng].[GovernTree_JobAid] m;
			END
		end

	--Remove reference
	else if @Operation = 6
		begin
			delete from stng.GovernTree_Reference where UniqueID = Cast(@UniqueID as Int);
			
			-- update Reference count value
			UPDATE m
			SET m.ReferenceCount = (
				SELECT COUNT(*)
				FROM [stng].[GovernTree_Reference] r
				WHERE (r.[GTID]) = m.[UniqueID]
			)
			FROM [stng].[GovernTree_Main] m;

			UPDATE m
			SET m.ReferenceCount = (
				SELECT COUNT(*)
				FROM [stng].[GovernTree_Reference] r
				WHERE (r.[GTID]) = m.[UniqueID]
			)
			FROM [stng].[GovernTree_JobAid] m;
		end

	--Get forms
	else if @Operation = 7
		begin
			select *
			from stng.VV_GovernTree_Form
			where GTID = @GTID;
		end

	--Add form
	else if @Operation = 8
		begin
			--Do uniqueness check
			if exists
			(
				select *
				from stng.VV_GovernTree_Form
				where GTID = @GTID and FormNo = @DocumentNo
			)
				begin

					select concat('Form relationship already exists between ',@DocumentNo, ' and the selected document') as ReturnMessage;
					return;
				end

			insert into stng.GovernTree_Form
			(GTID, FormNo, RAB)
			values
			(@GTID, @DocumentNo, @CurrentUser);
			
			-- update Form count value for GovernTree_Main table
			if exists
			(
				SELECT *
				FROM [stng].[GovernTree_Main]
				where UniqueID = @GTID
			)
				BEGIN
					UPDATE m
					SET m.FormCount = (
						SELECT COUNT(*)
						FROM [stng].[GovernTree_Form] r
						WHERE r.[GTID] = m.[UniqueID]
					)
					FROM [stng].[GovernTree_Main] m;
				END
			-- update Form count value for GovernTree_JobAid table
			else if exists
			(
				SELECT *
				FROM [stng].[GovernTree_JobAid]
				where UniqueID = @GTID
			)
				BEGIN
					UPDATE m
					SET m.FormCount = (
						SELECT COUNT(*)
						FROM [stng].[GovernTree_Form] r
						WHERE r.[GTID] = m.[UniqueID]
					)
					FROM [stng].[GovernTree_JobAid] m;
				END
		end

	--Remove form
	else if @Operation = 9
		begin
			delete from stng.GovernTree_Form where UniqueID = @UniqueID;
			
			-- update Form count value
			UPDATE m
			SET m.FormCount = (
				SELECT COUNT(*)
				FROM [stng].[GovernTree_Form] r
				WHERE (r.[GTID]) = m.[UniqueID]
			)
			FROM [stng].[GovernTree_Main] m;

			-- update Form count value for GovernTree_JobAid table
			UPDATE m
			SET m.FormCount = (
				SELECT COUNT(*)
				FROM [stng].[GovernTree_Form] r
				WHERE r.[GTID] = m.[UniqueID]
			)
			FROM [stng].[GovernTree_JobAid] m;
		end

	--Get Industry Standard Links
	else if @Operation = 10
		begin		
			select *
			from stng.VV_GovernTree_IndustryStandardLink
			where GTID = @GTID;
		end

	--Add Industry Standard Link
	else if @Operation = 11
		begin
			--Do uniqueness check
			if exists
			(
				select *
				from stng.VV_GovernTree_IndustryStandardLink
				where GTID = @GTID and IndustryStandard = @IndustryStandard 
			)
				begin

					select concat('Industry Standard relationship already exists between ',@GTID, ' and the selected document') as ReturnMessage;
					return;

				end
		--	select Concat('Industry Standard relationship already exists between ',@IndustryStandard, ' and the selected document',@IndustryStandard) as ReturnMessage;
				
			insert into stng.GovernTree_IndustryStandardLink
			(GTID, IndustryStandard, RAB,RAD)
			select @GTID, UniqueID, @CurrentUser,stng.GetBPTime(getdate())
			from stng.GovernTree_IndustryStandard 
			where IndustryStandard = @IndustryStandard;
			
			-- update Industry Standard count value for GovernTree_Main
			if exists
			(
				SELECT *
				FROM [stng].[GovernTree_Main]
				where UniqueID = @GTID
			)
				BEGIN
					UPDATE m
					SET m.StandardCount = (
						SELECT COUNT(*)
						FROM [stng].[GovernTree_IndustryStandardLink] r
						WHERE (r.[GTID]) = m.[UniqueID]
					)
					FROM [stng].[GovernTree_Main] m;
				END
			-- update Industry Standard count value for GovernTree_JobAid
			else if exists
			(
				SELECT *
				FROM [stng].[GovernTree_JobAid]
				where UniqueID = @GTID
			)
				BEGIN
					UPDATE m
					SET m.StandardCount = (
						SELECT COUNT(*)
						FROM [stng].[GovernTree_IndustryStandardLink] r
						WHERE (r.[GTID]) = m.[UniqueID]
					)
					FROM [stng].[GovernTree_JobAid] m;
				END
		end

	--Remove Industry Standard Link
	else if @Operation = 12
		begin

			delete from stng.GovernTree_IndustryStandardLink where UniqueID = @UniqueID;
			
			-- update Industry Standard count value
			UPDATE m
			SET m.StandardCount = (
				SELECT COUNT(*)
				FROM [stng].[GovernTree_IndustryStandardLink] r
				WHERE (r.[GTID]) = m.[UniqueID]
			)
			FROM [stng].[GovernTree_Main] m;

			-- update Industry Standard count value for GovernTree_JobAid
			UPDATE m
			SET m.StandardCount = (
				SELECT COUNT(*)
				FROM [stng].[GovernTree_IndustryStandardLink] r
				WHERE (r.[GTID]) = m.[UniqueID]
			)
			FROM [stng].[GovernTree_JobAid] m;

		end

	--Get Job Aid Links
	else if @Operation = 13
		begin

			select *
			from stng.VV_GovernTree_JobAidLink
			where GTID = @GTID;
		end 

	else if @Operation = 14
		begin
			--Ensure either JobAidURL or JobAidID were provided
			if @JobAidID is null and @JobAidURL is null
				begin					
					select 'Please provide either a JobAidID or JobAidURL' as ReturnMessage;
					return;
				end			

			--Do uniqueness check
			if exists
			(
				select *
				from stng.VV_GovernTree_JobAidLink
				where GTID = @GTID and JobAidURL = @JobAidURL and JobAidURL != ''
			)
				begin
					select concat('Job Aid relationship already exists between ',@JobAidURL, ' and the selected document') as ReturnMessage;
					return;
				end

			else if exists
			(
				select *
				from stng.VV_GovernTree_JobAidLink
				where GTID = @GTID and JobAidID = @JobAidID
			)	
				begin
					select concat('Job Aid relationship already exists between Stingray Job Aid',@JobAidID, ' and the selected document') as ReturnMessage;
					return;
				end

			if @JobAidURL is null
				set @JobAidURL = '';
			if @JobAidID is null
				set @JobAidID = '';

			insert into stng.GovernTree_JobAidLink
			(GTID, JobAidURL, JobAidID, RAB)
			values
			(@GTID,@JobAidURL,@JobAidID,@CurrentUser);
			
			-- update Job Aid Link count value
			if exists
			(
				SELECT *
				FROM [stng].[GovernTree_Main]
				where UniqueID = @GTID
			)
				BEGIN
				UPDATE m
				SET m.JobAidCount = (
					SELECT COUNT(*)
					FROM [stng].[GovernTree_JobAidLink] r
					WHERE (r.[GTID]) = m.[UniqueID]
				)
				FROM [stng].[GovernTree_Main] m;
			END
			-- update Job Aid Link count value for GovernTree_JobAid
			else if exists
			(
				SELECT *
				FROM [stng].[GovernTree_JobAid]
				where UniqueID = @GTID
			)
				BEGIN
					UPDATE m
					SET m.JobAidCount = (
						SELECT COUNT(*)
						FROM [stng].[GovernTree_JobAidLink] r
						WHERE (r.[GTID]) = m.[UniqueID]
					)
					FROM [stng].[GovernTree_JobAid] m;
				END
		end

	--Remove Job Aid Link
	else if @Operation = 15
		begin
			delete from stng.GovernTree_JobAidLink where UniqueID = @UniqueID;
			
			-- update Job Aid Link count value
			UPDATE m
			SET m.JobAidCount = (
				SELECT COUNT(*)
				FROM [stng].[GovernTree_JobAidLink] r
				WHERE (r.[GTID]) = m.[UniqueID]
			)
			FROM [stng].[GovernTree_Main] m;

			-- update Job Aid Link count value for GovernTree_JobAid
			UPDATE m
			SET m.JobAidCount = (
				SELECT COUNT(*)
				FROM [stng].[GovernTree_JobAidLink] r
				WHERE (r.[GTID]) = m.[UniqueID]
			)
			FROM [stng].[GovernTree_JobAid] m;
		end

	--Get DCR
	else if @Operation = 16
		begin
			select *
			from stng.VV_GovernTree_DCR
			where GTID = @GTID
			option(optimize for (@GTID unknown));
			
			-- update DCR count value
			UPDATE m
			SET m.DCRCount = ISNULL((
				SELECT COUNT(*)
				FROM [stng].[VV_GovernTree_DCR] r
				WHERE r.DocumentNo = m.DocumentNo
				AND r.DCRStatus IN ('ACTIVE', 'WAPPR', 'IN PROG')
			), 0)
			FROM [stng].[GovernTree_Main] m;

			-- update DCR count value
			UPDATE m
			SET m.DCRCount = ISNULL((
				SELECT COUNT(*)
				FROM [stng].[VV_GovernTree_DCR] r
				WHERE r.[GTID] = m.[UniqueID]
				AND r.DCRStatus IN ('ACTIVE', 'WAPPR', 'IN PROG')
			), 0)
			FROM [stng].[GovernTree_JobAid] m;
		end

	--Get PUCCs
	else if @Operation = 17
		begin
			select *
			from stng.VV_GovernTree_PUCC
			where GTID = @GTID
			option(optimize for (@GTID unknown));
		end

	--Get Industry Standards
	else if @Operation = 18
		begin
			select *
			from stng.VV_GovernTree_IndustryStandard
			order by OrgShort asc, IndustryStandard asc
		end

	--Get Industry Standard Sections
	else if @Operation = 19
		begin
			select distinct *
			from stng.VV_GovernTree_IndustryStandardFull
			--where Deleted = 0
		end

	--Get Industry Standard Section Personnel
	else if @Operation = 20
		begin
			select *
			from stng.[VV_GovernTree_IndustryStandardSectionPersonnel]
			where 
			IndustryStandardSectionID =@IndustryStandardSectionID
		end

	--Get All Doc name to add to main table
	else if @Operation = 21
		begin
			
		select Name from stngetl.General_ControlledDoc
		end

	--get Indystry standard name to add 
	else if @Operation = 22
		begin
			select distinct [IndustryStandard] from [stng].[VV_GovernTree_IndustryStandard]
		end

	--get job aid document name to add 
	else if @Operation = 23
		begin
			SELECT distinct [FullDocumentNoName] FROM [stng].[VV_GovernTree_JobAid]
		end

	--add TC and TCS
	else if @Operation = 24
		begin	
			if not exists 
			(
				select * 
				from [stng].[GovernTree_IndustryStandardSectionPersonnel] 
				where IndustryStandardSection=@IndustryStandardSectionID 
						and Personnel=@TCorTSC)	
				begin
					insert into [stng].[GovernTree_IndustryStandardSectionPersonnel](Personnel,PersonnelType,
					IndustryStandardSection,RAB,RAD,Deleted) 

					select @TCorTSC,UniqueID,@IndustryStandardSectionID,@CurrentUser,stng.GetBPTime(getdate()),0
					from stng.GovernTree_IndustryStandardPersonnel_Type
					where PersonnelType=@PersonnelType
				end
		 end

	--add Industry Standard
	else if @Operation = 25
		begin
			if not exists 
			(
				select uniqueid 
				from  [stng].[GovernTree_IndustryStandard] 
				where IndustryStandard=@IndustryStandard
			)

			begin
				insert into [stng].[GovernTree_IndustryStandard](OrgID,IndustryStandard,IndustryStandardTitle,RAD,RAB,LUD,LUB,Active)

				select  distinct UniqueID ,@IndustryStandard,
							@IndustryStandardTitle
							,stng.GetBPTime(getdate())
							,@CurrentUser
							,stng.GetBPTime(getdate())
							,@currentUser
							,1 
				from  stng.General_IndustryStandardOrg 
				where Org=@Org
			end

			if not exists 
			(
				select uniqueid 
				from [stng].[GovernTree_IndustryStandardSection] 
				where IndustryStandardsection=@IndustryStandardSection
			)
				
			begin
				insert into [stng].[GovernTree_IndustryStandardSection](IndustryStandardID,IndustryStandardSection,IndustryStandardSectionTitle,RAD,RAB,LUD,LUB,Active) 
				
				select UniqueID,@IndustryStandardSection,@IndustryStandardSectionTitle,stng.GetBPTime(getdate()),@CurrentUser,stng.GetBPTime(getdate()),@CurrentUser,1
				from [stng].[GovernTree_IndustryStandard] 
				where IndustryStandard=@IndustryStandard
			end
	end

	--check if Job Aid exists
	else if @Operation = 26
	  begin
	  declare @TempJobAid as varchar(100);
	  declare @JobAidPrefix as varchar(100) = 'CM-JA-';
		SET @TempJobAid = (CONCAT(@JobAidPrefix, SUBSTRING(@JobAidID,4, 2),SUBSTRING(@JobAidID,9, 5)));		 
		if  exists (
			select [DocumentNoNum], [JobAidNum] 
			FROM [stng].[GovernTree_JobAid] 
			where [DocumentNoNum]=@TempJobAid )
			begin
				select @TempJobAid as JobAidID
					,Concat('-',replicate('0',3 - len(Max([JobAidNum])+1)),Max([JobAidNum])+1) as JobAidNum 
				FROM [stng].[GovernTree_JobAid]
				where [DocumentNoNum]=@TempJobAid 
				group by DocumentNoNum
			end
			if not exists (
				select [DocumentNoNum]
				FROM [stng].[GovernTree_JobAid] 
				where [DocumentNoNum]=@TempJobAid )
				begin    
					Select @TempJobAid as JobAidID
						,'-001' as JobAidNum 
				end
		end
	
	--add job aid
	else if @Operation = 27
		begin
			SELECT @MaxJobAid = MAX(JobAidNum) 
			FROM [stng].[GovernTree_JobAid]
			WHERE DocumentNoNum = @JobAidID
			
			-- set MaxJobAid to 0 for initial Job Aid Doc Nums
			if @MaxJobAid IS NULL
			begin
				SET @MaxJobAid = 0
			end

			set @UID = newID()

			insert into [stng].[GovernTree_JobAid](UniqueID,DocumentNoNum,DocumentTitle,Revision,RAB,RAD,deleted, JobAidNum, ReferenceCount, FormCount, StandardCount, JobAidCount, DCRCount) 
			Values(@UID, @JobAidID,@JobAidTitle,@Revision,@CurrentUser,stng.GetBPTime(getdate()),0, @MaxJobAid + 1,0,0,0,0,0)

			select @UID as uniqueid
			
		 end

	-- get process owner
	else if @Operation = 28
		begin
			SELECT  [UniqueID] ,[GTID],[ProcessOwner]FROM [stng].[VV_GovernTree_ProcessOwner] where GTID=@DocumentNo
		end 

	--add Process owner
	else if @Operation = 29
		begin
			SET @EmployeeId = (
				select EmployeeID 
				from [stng].[VV_Admin_UserView] 
				where concat(EmpName, ' (', EmployeeID, ')')
				=@ProcessOwner)
			--Do uniqueness check
			if exists
			(
				select *
				from [stng].[VV_GovernTree_ProcessOwner]
				where GTID = @GTID and ProcessOwner = @EmployeeId
			)
				begin
					select concat('Process Owner relationship already exists between ',@ProcessOwner, ' and the selected document') as ReturnMessage;
					return;
				end

			insert into [stng].[GovernTree_ProcessOwner](GTID, ProcessOwner, RAB,RAD)
			values (@GTID, @EmployeeId, @CurrentUser,stng.GetBPTime(getdate()));
		end

	--Remove process owner
	else if @Operation = 30
		begin
			delete from [stng].[GovernTree_ProcessOwner] 
			where UniqueID = @UniqueID;
		end

	--get action
	else if @Operation = 31
		begin
			SELECT  [UniqueID]
				,[ActionTitle]
				,[IndustryStandardSectionID]
				,[ActionOwner]
				,ActionStatus 
				,TCD
				,ActionStatusC
				,IntID
			FROM stng.VV_GovernTree_IndustryStandardAction 
			where IndustryStandardSectionID=@IndustryStandardSectionID
		end 

	--add action
	else if @Operation = 32
		begin
			insert into  [stng].[GovernTree_IndustryStandardAction] ([ActionTitle],[IndustryStandardSectionID],ActionOwner,TCD,RAD,RAB,LUD,LUB,ACtive,actionstatus)
			values (@actiontitle,@IndustryStandardSectionID,@actionname,@tcd,stng.GetBPTime(getdate()), @CurrentUser,stng.GetBPTime(getdate()),@CurrentUser,1,@status);
		end 

	--Remove action
	else if @Operation = 33
		begin
			delete from stng.GovernTree_IndustryStandardAction where  IntID = @IntID;
		end


	--search Docno. from JobAid
	else if @Operation = 34
		begin
			select Name 
			from stngetl.General_ControlledDoc
			where Name like 'BP-S%' or Name like 'BP-P%';
		end
		
	--get Job Aid
	else if @Operation = 35
		begin
			SELECT  [JobAidID],[DocumentNo],[Revision] ,[DocumentTitle] ,[jobaidstatus],[DocumentAttached],[FullDocumentNoName], [JobAidNum], [StandardCount], [FormCount], [ReferenceCount], [JobAidCount],[DCRCount]
			FROM [stng].[VV_GovernTree_JobAid] 
			where FullDocumentNoName=(
				select FullDocumentNoName 
				from [stng].[VV_GovernTree_JobAid] 
				where JobAidID=@GTID)
			order by Revision desc
		end			
			
	--add Job Aid Revision
	else if @Operation = 36
		begin
			set @Revision=(Select MAX(Revision) 
			from  [stng].[VV_GovernTree_JobAid] 
			where FullDocumentNoName = (
				select FullDocumentNoName 
				from  [stng].[VV_GovernTree_JobAid] 
				where  JobAidID=@JobAidID))

			select @JobAidNum = JobAidNum 
			from  [stng].[VV_GovernTree_JobAid] 
			where JobAidID=@JobAidID
		
			insert into [stng].[GovernTree_JobAid](DocumentNonum,DocumentTitle,Revision,RAB,RAD,deleted, JobAidNum, StandardCount, FormCount, ReferenceCount, JobAidCount,DCRCount)
			SELECT  DocumentNo,[DocumentTitle],@Revision+1,@CurrentUser,stng.GetBPTime(getdate()),0,@JobAidNum,StandardCount, FormCount, ReferenceCount, JobAidCount,DCRCount
			FROM [stng].[VV_GovernTree_JobAid] 
			where JobAidID=@JobAidID

			select uniqueID
			from [stng].[GovernTree_JobAid]
			where Revision = @Revision + 1 and JobAidNum = @JobAidNum
			
			select *
			from stng.VV_GovernTree_Main
			where UniqueID = @GTID

		end
		
	--get Resource type
	else if @Operation = 37
		begin
			SELECT distinct PersonnelType,UniqueID,deleted 
			FROM [stng].[GovernTree_IndustryStandardPersonnel_Type] 
			where deleted=0
		end

	--add resource type
	else if @Operation = 38
		begin
			INSERT INTO [stng].[GovernTree_IndustryStandardPersonnel_Type]
			([PersonnelType]
			,[RAD]
			,[RAB]
			,[Deleted]
			)
			VALUES
			(@personneltype,stng.GetBPTime(getdate()),@currentuser,0)
		end

	--delete resource type
	else if @Operation = 39
		begin
			update [stng].[GovernTree_IndustryStandardPersonnel_Type] 
			set deleted=1,DeletedOn=stng.GetBPTime(getdate()),DeletedBy=@CurrentUser 
			where UniqueID=@PersonnelType
		end

	--get org type
	else if @Operation = 40
		begin
			select distinct orgtype,UniqueID 
			from [stng].[GovernTree_IndustryStandardOrg_Type] 
			where deleted=0
		end

	--add org type
	else if @Operation = 41
		begin
			select @Orgtype as returnmessage
				INSERT INTO [stng].[GovernTree_IndustryStandardOrg_Type] (
			   [OrgType]
			   ,[RAD]
			   ,[RAB]
			   ,[Deleted]
			   )
			VALUES
			   (@orgtype,stng.GetBPTime(getdate()),@currentuser,0)
		end

	-- update job aid status
	else if @Operation = 42
		begin
			update [stng].[GovernTree_IndustryStandardOrg_Type] 
			set deleted=1,DeletedOn=stng.GetBPTime(getdate()),DeletedBy=@CurrentUser 
			where UniqueID=@OrgType
		end
		
	--update job aid status
	else if @Operation = 43
	  begin
		Update [stng].[GovernTree_JobAid] 
		set [JobAidStatus]=@status,UpdateDate=stng.GetBPTime(getdate()) 
		where UniqueID=@JobAidID
	  end

	--update industry standard description
	else if @Operation = 44
		begin
			if (@description IS NOT NULL or  @description = '')
			begin
				if exists (
					select * 
					from [stng].[GovernTree_IndustryStandardDescription] 
					where [IndustryStandardSection] = @IndustryStandardSectionID)
					begin
						update [stng].[GovernTree_IndustryStandardDescription]
						set [Description] = @description, RAB = @CurrentUser
						where [IndustryStandardSection] = @IndustryStandardSectionID
					end
				else 
					begin
						insert into [stng].[GovernTree_IndustryStandardDescription] ([Description], [RAB], [Deleted], [IndustryStandardSection])
						values (@description, @CurrentUser, 0, @IndustryStandardSectionID)
					end
			end
		end

	--Get industry standard status and description
	else if @Operation = 45
		begin
			SELECT a.[Status] ,a.[IndustryStandardSection],b.Description,b.IndustryStandardSection as IndustryStandard
			FROM [stng].[GovernTree_IndustryStandardStatus]  a full join 
				[stng].[GovernTree_IndustryStandardDescription] as b on a.IndustryStandardSection=b.IndustryStandardSection 
			WHERE (a.IndustryStandardSection=@IndustryStandardSectionID or b.IndustryStandardSection=@IndustryStandardSectionID)
		end

	--Get Industry Status
	else if @Operation = 46 
		begin
			SELECT *
			FROM stng.GovernTree_IndustryStatus
			where Deleted = 0
		end 

	--Get Job Aid Status
	else if @Operation = 47
		begin
			SELECT *
			FROM stng.GovernTree_JobAidStatus
			where Deleted = 0
		end 

	--Remove industry ledger resource / tc and tsc
	else if @Operation = 48
		begin
			delete from stng.GovernTree_IndustryStandardSectionPersonnel 
			where IntID = @IntID;
		end

	--Remove industry ledger
	else if @Operation = 49
		begin
			update [stng].[GovernTree_IndustryStandardSection]
			set Deleted = 1,
				DeletedBy = @CurrentUser,
				DeletedOn = stng.GetBPTime(getdate())
			where UniqueID = @GTID;
		end

	--Edit Industry standard action
	else if @Operation = 50 
		begin
			update [stng].[VV_GovernTree_IndustryStandardAction]
			set [ActionTitle] = @ActionTitle
				,[ActionOwner] = @ActionOwner
				,[TCD] = @TCD
				,[ActionStatus] = @ActionStatus
				,[LUD] = [stng].[GetBPTime](getdate())
				,[LUB] = @CurrentUser
			where IntID = @ActionID;
		end 
		
	-- get list of all documents
	else if @Operation = 51
		SELECT top 25 Name label, Name value 
		from stngetl.General_ControlledDoc
		WHERE Name like  @Value1 + '%'
		ORDER BY Name
		option(optimize for (@Value1 unknown));

	-- update industry standard status
	else if @Operation = 52
	begin
		if (@status IS NOT NULL or @status = '')
		begin
			if exists (select * from [stng].[GovernTree_IndustryStandardStatus] where [IndustryStandardSection] = @IndustryStandardSectionID)
			begin
				update [stng].[GovernTree_IndustryStandardStatus]
				set [Status] = @status, RAB = @CurrentUser
				where [IndustryStandardSection] = @IndustryStandardSectionID
			end
			else 
			begin
				insert into [stng].[GovernTree_IndustryStandardStatus] ([Status], [RAB], [Deleted], [IndustryStandardSection])
				values (@status, @CurrentUser, 0, @IndustryStandardSectionID)
			end
		end
	end

	-- get most recent process health entry
	else if @Operation = 53
		begin
			SELECT  TOP 1 [UniqueID],[GTID],[Governance],[GovernanceColour],[Compliance],[ComplianceColour],[Excellence],[ExcellenceColour],[Comment],[Quarter],[RAD],[RAB] 
			FROM [stng].[VV_GovernTree_ProcessHealth] 
			where GTID=@DocumentNo and Deleted = 0
			order by RAD desc
		end 

	-- add process health
	else if @Operation = 54
		begin
			DECLARE @RAD datetime = stng.GetBPTime(getdate());

			insert into [stng].[GovernTree_ProcessHealth](GTID, Governance, Compliance, Excellence, Comment, RAB, RAD, [Quarter], Deleted)
			values (
				@GTID,
				@Governance,
				@Compliance,
				@Excellence,
				@Comment,
				@CurrentUser,
				stng.GetBPTime(getdate()),
				CASE 
					WHEN MONTH(@RAD) BETWEEN 1 AND 3 THEN 'Q1 ' + CAST(YEAR(@RAD) AS varchar(4))
					WHEN MONTH(@RAD) BETWEEN 4 AND 6 THEN 'Q2 ' + CAST(YEAR(@RAD) AS varchar(4))
					WHEN MONTH(@RAD) BETWEEN 7 AND 9 THEN 'Q3 ' + CAST(YEAR(@RAD) AS varchar(4))
					WHEN MONTH(@RAD) BETWEEN 10 AND 12 THEN 'Q4 ' + CAST(YEAR(@RAD) AS varchar(4))
				END,
				0
			);
						
			SET @NextPHID = SCOPE_IDENTITY();

			UPDATE a
			set 
			PHID = @NextPHID
			from stng.GovernTree_Actions as a
			left join stng.GovernTree_ProcessHealth as c on a.PHID = c.UniqueID
			left join stng.GovernTree_ActionStatus as b on a.StatusID = b.UniqueID
			where c.GTID = @GTID and b.ActionStatus = 'In Progress'
		end


	-- Remove process health
	else if @Operation = 55
		begin

			SELECT @GTID = GTID
			FROM stng.VV_GovernTree_ProcessHealth
			WHERE UniqueID = @UniqueID

			UPDATE [stng].[GovernTree_ProcessHealth] 
			set
			Deleted = 1
			,DeletedOn = stng.GetBPTime(getdate())
			,DeletedBy = @CurrentUser 
			where UniqueID = @UniqueID


			SELECT TOP 1 
			@PHID = [UniqueID]
			FROM [stng].[VV_GovernTree_ProcessHealth] 
			where GTID = @GTID and Deleted = 0
			order by RAD desc

			UPDATE a
			set 
			PHID = @PHID
			from stng.GovernTree_Actions as a
			where a.PHID = @UniqueID

		end

	-- verfiyRequest for doc no
	else if @Operation = 56
		begin
			SELECT 
			Name label, Name value 
			FROM stngetl.General_ControlledDoc
			WHERE Name = @Value1 
			ORDER BY Name
			option(optimize for (@Value1 unknown));
		end

	-- export Process Health
	else if @Operation = 57
		BEGIN
			SELECT *
			FROM [stng].[VV_GovernTree_ProcessHealthExport] 
			order by AddDate DESC, DocumentNumber
		END

	-- get process health matrix
	else if @Operation = 58
		begin
			SELECT [UniqueID]
				  ,[Section]
				  ,[Description]
				  ,[StatusColour]
				  ,[RAD]
				  ,[RAB]
				  ,[Deleted]
				  ,[DeletedOn]
				  ,[DeletedBy]
			FROM [stng].[GovernTree_ProcessHealth_Matrix]
			where Deleted = 0
		end

	-- get version history / all process health
	else if @Operation = 59
		begin
			SELECT [UniqueID],[GTID],[Governance],[Compliance],[Excellence],[Comment],[Quarter],[RAD],[RAB] 
			FROM [stng].[VV_GovernTree_ProcessHealth] 
			where GTID=@DocumentNo and Deleted = 0
			order by RAD desc
		end 

		-- Get action status'
	else if @Operation = 60
		begin
			SELECT *
			FROM stng.GovernTree_ActionStatus
			WHERE Deleted = 0
		end 
		-- Get actions on process health
	else if @Operation = 61
		begin
			SELECT *
			FROM stng.VV_GovernTree_Actions
			WHERE PHID = @PHID
			ORDER BY RAD desc
		end 
		-- Add action to process health
	else if @Operation = 62
		begin
			INSERT INTO stng.GovernTree_Actions
			([PHID], [Action], [Responsibility], [DueDate], [StatusID], [ProcessHealthSection], [RAD], [RAB])
			VALUES
			(@PHID, @Action, @Responsibility, @DueDate, @StatusID, @HealthSection, stng.GetBPTime(getdate()), @CurrentUser)
		end 
		-- Edit action on process health
	else if @Operation = 63
		begin
			UPDATE stng.GovernTree_Actions
			set
			[Action] = @Action,
			[Responsibility] = @Responsibility, 
			[DueDate] = @DueDate,
			[StatusID] = @StatusID, 
			[ProcessHealthSection] = @HealthSection
			where UniqueID = @ActionID

		end 
		-- Remove action from process health
	else if @Operation = 64
		begin
			UPDATE stng.GovernTree_Actions
			set
			[Deleted] = 1,
			[DeletedBy] = @CurrentUser, 
			[DeletedOn] = stng.GetBPTime(getdate())
			where UniqueID = @ActionID
		end 
		
		
end 