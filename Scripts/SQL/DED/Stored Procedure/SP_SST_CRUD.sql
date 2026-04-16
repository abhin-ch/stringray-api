CREATE OR ALTER PROCEDURE [stng].[SP_SST_CRUD]
(
	@Operation int,
	@EmployeeID varchar(20) =  null,
	@SubOp int =null,

	@SSTID varchar(50) = null,
	@CommentType varchar(50) = null,

	@StateType varchar(50) = null,
	@Comment varchar(max) = null,

	@SSTNo varchar(50) = null,
	
	@SSTCommentID bigint = null,

	@SSTIDExclude varchar(50) = null,
	@Clone bit = 0,

	@SSTCloneIDList stng.TYPE_SST_CloneList readonly,
	@SSTIDList stng.TYPE_SST_IDList readonly,

	@PredoseCost int = null,
	@Dose int = null,
	@DoseMREM int = null,
	@SingleExecutionCost int = null,

	@ImpairmentCount int = null,
	@ImpairmentUnit nvarchar(50) = null,
	@ImpairmentNA bit = null,
	@ChannelRejectionCount int = null,
	@ChannelRejectionUnit nvarchar(50) = null,
	@ChannelRejectionNA bit = null

)
AS
BEGIN
	/*
		Operations
		1 - Get Main Table
		2 - Get Comments
		3 - Add comment
		4 - Remove Comment
		5 - SST Historical Info
		6 - SST Historical Info Metrics
		7 - SST Locations
		8 - OSR Query
		10 - Get Docs
		11 - Clone Docs
		12 - Clone Comments
		13 - Get unique PMIDs
		14 - Patch SST Header Data
	*/

	--Main Table
	if @Operation = 1
		begin

			if @SSTIDExclude is not null and @Clone = 1
				begin

					select 0 as Checked, a.*
					from stng.VV_SST_Main as a
					where a.SSTID <> @SSTIDExclude
					order by a.PM asc
					option(optimize for (@SSTIDExclude unknown));

				end

			else
				begin

					select *
					from stng.VV_SST_Main
					order by PM asc;
				end

		end

	--Get comments
	else if @Operation = 2
		begin

			select *
			from stng.VV_SST_Comment
			where (CommentType = @CommentType or @CommentType is null) and SSTID = @SSTID
			order by CommentDate desc
			option(optimize for (@CommentType unknown, @SSTID unknown));

		end

	--Add comment
	else if @Operation = 3
		begin

			--Check for SSTID, StateType, and Comment
			if @SSTID is null or @CommentType is null or @Comment is null
				begin

					select 'SSTID, CommentType, and Comment are required' as ReturnMessage;
					return;

				end

			--Add new record
			insert into stng.SST_Comment
			(SSTID, CommentType, Comment, RAB)
			select @SSTID, UniqueID, @Comment, @EmployeeID
			from stng.SST_StateType
			where StateType = @CommentType;
		
		end

	--Remove comment
	else if @Operation = 4
		begin
	
			--Check for SSTID, StateType, and Comment or SSTCommentID
			if @SSTCommentID is null
				begin
						
					select 'SSTCommentID is required' as ReturnMessage;
					return;

				end

			--Perform delete
			update stng.SST_Comment
			set Deleted = 1,
			DeletedBy = @EmployeeID,
			DeletedOn = stng.GetBPTime(GETDATE())
			where UniqueID = @SSTCommentID;

		end

	--SST Historical info
	else if @Operation = 5
		begin
			
			select *
			from stng.SST_HistoricalInfo_Mapped
			where SSTID = @SSTID
			order by SSTDate desc
			option(optimize for (@SSTID unknown));

		end

	--SST Historical info metrics
	else if @Operation = 6
		begin
			
			select Passed as [5 Yr Passed],
			Aborted as [5 Yr Aborted],
			Failed as [5 Yr Failed],
			PassRate as [5 Yr Passed Rate]
			from stng.SST_Historical_5Yr
			where SSTID = @SSTID

		end 

	--SST locations
	else if @Operation = 7
		begin
			select distinct UniqueID, LOCATION, JPNUM, USI, SITEID, LocationDesc, CRIT_CAT, SPV
			from stng.VV_SST_Location
			where SSTID = @SSTID
			order by LOCATION asc, SITEID asc
			option(optimize for (@SSTID unknown));

		end

	--OSR query
	else if @Operation = 8
		begin

			select *
			from stng.VV_SST_OSR as a
			where a.SSTID = @SSTID
			order by a.name asc
			option(optimize for (@SSTID unknown));

		end

	--SOE references
	else if @Operation = 9
		begin

			select *
			from stng.VV_SST_SOEReference
			where SSTID = @SSTID
			order by UniqueID asc
			option(optimize for (@SSTID unknown));

		end

	--Get Docs
	else if @Operation = 10
		begin

			select 0 as Checked, a.FileMetaID, a.Name, a.UUID, concat(c.FirstName, ' ', c.LastName) as CreatedBy
			from stng.Common_FileMeta as a
			inner join stng.Admin_Module as b on a.ModuleID = b.UniqueID
			inner join stng.Admin_User as c on a.CreatedBy = c.EmployeeID
			where b.NameShort = 'SST' and a.Deleted = 0 and a.ParentID = @SSTID and a.GroupBy = @StateType
			order by a.CreatedDate desc
			option(optimize for (@SSTID unknown, @StateType unknown));

		end

	--Clone Comments
	else if @Operation = 12
		begin
		


			if(not exists (select 1 from @SSTCloneIDList))
				begin

					select 'SSTCloneIDList is required' as ReturnMessage;
					return;

				end

			else if (exists(
				select UUID from @SSTIDList
				except
				select UniqueID from
				stng.SST_Main m
			))
				begin
					select 'All SSTIDs must exist in stng.SST_Main' as ReturnMessage;
					return;
				end
			else
				begin


					insert into stng.SST_Comment(SSTID, CommentType, Comment, RAD, RAB)
					--one for each SSTID given (copy to)
					select s.UniqueID as SSTID, a.CommentType, a.Comment, stng.GetBPTime(GETDATE()), @EmployeeID
					FROM stng.SST_Comment a
					LEFT JOIN stng.SST_Main s on s.UniqueID in (select UUID from @SSTIDList)
					WHERE a.UniqueID in (select UUID from @SSTCloneIDList)


				end



		end
	--Get Related PMIDs
	else if @Operation = 13
	begin
		select distinct PM as PMID, pmunit as UNIT, @SSTNo as SSTNum, SITEID as Station from stng.VV_SST_Main where SST = @SSTNo
	end
	--update header tab data select * from stng.SST_HeaderCosts
	else if @Operation = 14
	begin
		if not exists (select top(1) * from stng.SST_HeaderCosts where SSTID = @SSTID)
		begin
			insert into stng.SST_HeaderCosts(SSTID, Dose, DoseMREM, PreDoseCost, SingleExecutionCost, LUB)
			select @SSTID, @Dose, @DoseMREM, @PredoseCost, @SingleExecutionCost, @EmployeeID
		end
		else
		begin
			update stng.SST_HeaderCosts
			set Dose = @Dose, 
			DoseMREM = @DoseMREM, 
			PreDoseCost = @PredoseCost, 
			SingleExecutionCost = @SingleExecutionCost
			where SSTID = @SSTID
		end

		if not exists (select top(1) * from stng.SST_HeaderTimes where SSTID = @SSTID)
		begin
			insert into stng.SST_HeaderTimes(SSTID, ImpairmentCount, ImpairmentUnit, ImpairmentNA, ChannelRejectionCount, ChannelRejectionUnit, ChannelRejectionNA, LUB)
			select @SSTID, @ImpairmentCount, @ImpairmentUnit, @ImpairmentNA, @ChannelRejectionCount, @ChannelRejectionUnit, @ChannelRejectionNA, @EmployeeID
		end
		else
		begin
			update stng.SST_HeaderTimes
			set ImpairmentCount = @ImpairmentCount, 
			ImpairmentUnit = @ImpairmentUnit, 
			ImpairmentNA = @ImpairmentNA,
			ChannelRejectionCount = @ChannelRejectionCount, 
			ChannelRejectionUnit = @ChannelRejectionUnit, 
			ChannelRejectionNA = @ChannelRejectionNA
			where SSTID = @SSTID
		end
		
	end
	--Get Header Tab data
	else if @Operation = 15
	begin
		select
		CASE WHEN PreDoseCost is null THEN 0 ELSE PreDoseCost END as PreDoseCost,
		CASE WHEN Dose is null THEN 0 ELSE Dose END as Dose,
		CASE WHEN DoseMREM is null THEN 0 ELSE DoseMREM END as DoseMREM,
		CASE WHEN SingleExecutionCost is null THEN 0 ELSE SingleExecutionCost END as SingleExecutionCost,
		CASE WHEN ImpairmentCount is null THEN 0 ELSE ImpairmentCount END as ImpairmentCount,
		ImpairmentUnit,
		CASE WHEN ImpairmentNA is null THEN 0 ELSE ImpairmentNA END as ImpairmentNA,
		CASE WHEN ChannelRejectionCount is null THEN 0 ELSE ChannelRejectionCount END as ChannelRejectionCount,
		ChannelRejectionUnit,
		CASE WHEN ChannelRejectionNA is null THEN 0 ELSE ChannelRejectionNA END as ChannelRejectionNA,
		i.LastCompletedWO as PreviousWONumber,
		i.lastwocompdate as LastCompletionDate,
		i.lastWOCompletionCode as CompletionCode,
		i.CurrentWOPMDueDate,
		i.EarliestNextDueDate,
		i.DOCNUM as OSRRef
		from stng.VV_SST_HeaderCosts c
		join stng.VV_SST_HeaderTimes t on c.SSTID = t.SSTID
		join stng.SST_Main m on c.SSTID = m.UniqueID
		left join stng.SST_SupportingInfo i on i.pmnum = m.PM
		WHERE c.SSTID = @SSTID
		
	end

	--Get All files associated with SST
	else if @Operation = 16
	begin
		SELECT F.FileMetaID, F.Name,F.ParentID,CONCAT(M.NameShort,'/',F.UUID) UUID,F.GroupBy,F.CreatedBy,U.FullName,F.CreatedDate,M.NameShort Module
		FROM stng.Common_FileMeta F
		INNER JOIN stng.Admin_Module M ON M.UniqueID = F.ModuleID
		INNER JOIN stng.Admin_User U ON U.EmployeeID = F.CreatedBy
		WHERE M.NameShort = 'SST' AND ParentID = @SSTID and Deleted = 0
	end

END
GO