/****** Object:  StoredProcedure [stng].[SP_TOQLite_CRUD]    Script Date: 11/19/2025 9:26:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [stng].[SP_TOQLite_CRUD]
(
	@Operation int,
	@SubOp int = null,
	@CurrentUser varchar(20) = null,

	@ProjectSearch varchar(20) = null,

	@SingleRow bit = 0,

	@TOQLiteID varchar(40) = null,
	@VendorDeliverableID bigint = null,
	@VendorDeliverableActivityID bigint = null,

	@Section varchar(50) = null,
	@ProjectNo varchar(20) = null,
	@VendorTOQID varchar(100) = null,
	@VendorTOQRevision int = null,

	@PCT50Date date = null,
	@PCT90Date date = null,
	@ERLevelDates bit = null,

	@FromERModule bit = null,

	@VendorResponseDate date = null,

	@ER varchar(30) = null,

	@BPDeliverableID bigint = null,
	@DeliverableHours float = null,
	@DeliverableCost float = null,

	@Vendor varchar(200) = null,
	@VendorID varchar(50) = null,
	@Deliverable varchar(150) = null,
	@Comment varchar(max) = null,

	@Activity varchar(500) = null,
	@ActivityHours float = null,
	@ActivityStart date = null,
	@ActivityFinish date = null,
	@ActivityID varchar(50) = null,
	@ActivityType varchar(50) = null,
	 
	@BlendedRate float = null,

	@StatusShort varchar(10) = null,
	@CurrentStatus varchar(10) = null,

	@DeliverableName varchar(150) = null,

	@SortOrder stng.TYPE_TOQLite_SortOrder readonly,
	@SortUpdate bit = 0,

	@Outage varchar(20) = null,

	@Department varchar(50) = null,

	@TemplateName varchar(255) = null,

	@SeeAll bit = null,
	@Qualification varchar(200) = null,
	@Scope varchar(max) = null,

	@ReturnTOQLiteID varchar(40) = null output,
	@ReturnOperationSuccess bit = 1 output,
	@ReturnOperationMessage varchar(1000) = null output
)
as 
begin 

	--Proc working variables
	declare @TOQID uniqueidentifier;
	declare @LatestRevision int;
	declare @Instance int;
	declare @WorkingStatus uniqueidentifier;
	declare @WorkingSortOrder int;
	declare @WorkingBPTOQID int;
	declare @WorkingVendorDeliverableID bigint;
	declare @hasSection bit;
	declare @hasVendor bit;

	--Main query
	if @Operation = 1
		begin

			select hasSection, hasVendor
			into #TempAttributes
			from (select case when exists (
				select 1
				from stng.ER_SectionManager
				where SM = @CurrentUser and Deleted = 0
			) then 1 else 0 end as hasSection,
			case when exists (
				select 1 from stng.VV_Admin_UserAttribute
				where EmployeeID = @CurrentUser and attributetype = 'Vendor'
			) then 1 else 0 end as hasVendor) as hasVendor;

			select @hasSection = hasSection, @hasVendor = hasVendor 
			from #TempAttributes

			if @SeeAll = 1
				begin
					select *
					from stng.VV_TOQLite_Main
					order by RAD desc;
				end

			else if @hasVendor = 1
				begin

					select distinct a.*
					from stng.VV_TOQLite_Main as a
					inner join stng.VV_Admin_UserAttribute as b on a.VendorID = b.AttributeID and b.EmployeeID = @CurrentUser	
					where a.CurrentStatusShort in ('AV','AA') 


				end

			else if @hasSection = 1
				begin

					select a.*
					from stng.VV_TOQLite_Main as a
					inner join stng.ER_SectionManager as b on a.Section = b.Section and b.SM = @CurrentUser and b.Deleted = 0
					where a.CurrentStatusShort in (
						SELECT StatusShort
						FROM [stng].[TOQLite_Status]
					);

				end

			--EDIT, revert to TOQLiteID
			else if @SingleRow = 1 and @ER is not null
				begin

					select *
					from stng.VV_TOQLite_Main
					where ER = @ER
					order by RAD desc;

				end

		end

	--SMs
	else if @Operation = 2
		begin

			select *
			from stng.VV_General_Organization_Section;

		end

	--Project Suggestions
	else if @Operation = 3
		begin

			select SharedProjectID
			from stng.VV_MPL_ENG
			where SharedProjectID like @ProjectSearch + '%'
			option(optimize for (@ProjectSearch unknown));

		end

	--BP Deliverables
	else if @Operation = 4
		begin

			select *
			from stng.VV_TOQLite_BPDeliverable
			where TOQLiteID = @TOQLiteID
			option(optimize for (@TOQLiteID unknown));

		end

	--Vendors
	else if @Operation = 5
		begin

				--select AttributeID, Attribute as VendorName, VendorShort
				--from stng.VV_Admin_AllAttribute as a
				--inner join stng.General_Vendor as b on a.Attribute = b.VendorName
				--where AttributeType = 'Vendor'
				--order by VendorName asc;

				select Attribute as VendorName, AttributeID as VendorShort
				from  stng.[VV_Admin_AllVendors]
				order by VendorName asc;

		end

	--TOQs (TODO: replace this with actual TOQ mapping when available)
	else if @Operation = 6
		begin

			select *
			from stng.VV_TOQLite_TOQ
			where VendorID = @VendorID
			option(optimize for (@VendorID unknown));

		end

	--Vendor Deliverables
	else if @Operation = 7
		begin

			select *
			from stng.VV_TOQLite_VendorDeliverable
			where TOQLiteID = @TOQLiteID
			option(optimize for (@TOQLiteID unknown));

		end

	--Vendor Deliverable Activities
	else if @Operation = 8
		begin

			select *
			from stng.VV_TOQLite_VendorDeliverable_Activity
			where VendorDeliverableID = @VendorDeliverableID and ActivityType = @ActivityType
			order by SortOrder asc
			option(optimize for (@VendorDeliverableID unknown));

		end

	--Save event; 1-to-1
	else if @Operation = 9
		begin

			if @TOQLiteID is null 
				begin

					select 'TOQLiteID was not provided' as ReturnMessage;
					return;

				end

			--Update direct values
			update stng.TOQLite_Main
			set ERLevelDates = @ERLevelDates,
			PCT50Date = @PCT50Date,
			PCT90Date = @PCT90Date,
			ProjectNo = @ProjectNo,
			VendorResponseDate = @VendorResponseDate,
			LUB = @CurrentUser,
			LUD = stng.GetBPTime(getdate()),
			VendorNotes = @Comment,
			Scope = @Scope
			where UniqueID = @TOQLiteID;

			--Update VendorID
			if @VendorID is not null
				begin

					update stng.TOQLite_Main
					set VendorID = @VendorID
					where UniqueID = @TOQLiteID;

					if @VendorTOQID is not null
						begin

							select @TOQID = UniqueID
							from stng.VV_TOQLite_TOQ
							where VendorID = @VendorID and VendorTOQID = @VendorTOQID;

							--Update TOQID 
							if @TOQID is not null
								begin

									update stng.TOQLite_Main
									set TOQID = @TOQID
									where UniqueID = @TOQLiteID;

								end
						end
					else 
						begin 
							update stng.TOQLite_Main
							set TOQID = null
							where UniqueID = @TOQLiteID;
						end
				end

		end

	--BP deliverable add
	else if @Operation = 10
		begin

			--Take from ER Module
			if @FromERModule = 1
				begin

					insert into stng.TOQLite_BPDeliverable
					(TOQLiteID, DeliverableID, DeliverableHours, RAB, LUB)
					select @TOQLiteID, b.DeliverableID, b.[EstimatedHours], @CurrentUser, @CurrentUser
					from stng.ER_Main as a
					inner join stng.ER_Deliverable as b on a.UniqueID = b.ERID
					where a.ER = @ER;

				end

			--Take from parameters
			else
				begin

					insert into stng.TOQLite_BPDeliverable
					(TOQLiteID, DeliverableID, DeliverableHours, RAB, LUB)
					select @TOQLiteID, @Deliverable, sum(b.StandardHours) as DeliverableHours, @CurrentUser, @CurrentUser
					from stng.ER_StandardDeliverable as a
					inner join stng.ER_StandardDeliverableActivity as b on a.UniqueID = b.DeliverableID and b.ActivityType = 'External'
					where a.UniqueID = @Deliverable and a.Active = 1 
					group by a.UniqueID;

					select SCOPE_IDENTITY() as BPDeliverable;

				end

		end

	--Add TOQ Lite
	else if @Operation = 11
		begin

			--Next, check if ER param is null
			if @ER is null
				begin

					select 'ER is blank. Please provide an ER' as ReturnMessage;
					return;

				end

			--Next, check if ER exists
			if not exists(
				select ER
				from stng.ER_Main
				where ER = @ER
				)
				begin

					select CONCAT('ER ',@ER, ' does not exist') as ReturnMessage;

					return;

				end
			
			if exists(
			select a.ER
			from stng.ER_Main as a 
			inner join stng.ER_Status as b 
			on a.CurrentStatus = b.UniqueID and b.StatusShort not in ('TDS')
			where a.ER = @ER
			
			)
			begin
				select CONCAT('ER ',@ER, ' needs to be in the Pre Execution ESP cycle status. TOQ Lite cannot be created') as ReturnMessage;
				return;
			end

			--Check instance of the ER record, can have multiple records on same ER
			select @Instance = max(ERInstance)
			from stng.TOQLite_Main as a
			inner join stng.ER_Main as b on a.ERID = b.UniqueID and b.ER = @ER


			--If not, check for latest revision
			--select @LatestRevision = max(Revision)
			--from stng.TOQLite_Main as a
			--inner join stng.ER_Main as b on a.ERID = b.UniqueID and b.ER = @ER
			--inner join stng.TOQLite_Status as c on a.CurrentStatus = c.UniqueID
			--where c.StatusShort not in ('C','AA');

			if @LatestRevision is null set @LatestRevision = 0;

			--Get I ID
			select @WorkingStatus = UniqueID
			from stng.TOQLite_Status
			where StatusShort = 'I';

			SET @TOQLiteID = newid()

			--Insert new record

			--Need to figure out the logic if adding a TDS from the TOQLite module

			--insert into stng.TOQLite_Main
			--(UniqueID, ERID, Revision, ERInstance, CurrentStatus, ProjectNo, Section, VendorID, RAB, LUB)
			--select @TOQLiteID, UniqueID, @LatestRevision, case when @Instance is not null then @Instance + 1 else 0 end, @WorkingStatus, ProjectID, Section, Vendor, @CurrentUser, @CurrentUser
			--from stng.ER_Main
			--where ER = @ER;

			--Get TOQLiteID
			--select @TOQLiteID = a.UniqueID
			--from stng.TOQLite_Main as a
			--inner join stng.ER_Main as b on a.ERID = b.UniqueID
			--where a.Revision = @LatestRevision and b.ER = @ER;

			--Insert new status log record
			insert into stng.TOQLite_StatusLog
			(TOQLiteID, StatusID, Comment, RAB)
			values
			(@TOQLiteID, @WorkingStatus, N'Record Created', @CurrentUser);

			select @TOQLiteID as TOQLiteID;

		end

	--Remove BP deliverable
	else if @Operation = 12
		begin

			update stng.TOQLite_BPDeliverable
			set Deleted = 1,
			DeletedBy = @CurrentUser,
			DeletedOn = stng.GetBPTime(getdate()),
			LUD = stng.GetBPTime(getdate()),
			LUB = @CurrentUser
			where UniqueID = @BPDeliverableID;

		end

	--Edit BP deliverable values
	else if @Operation = 13
		begin

			update stng.TOQLite_BPDeliverable
			set DeliverableHours =  @DeliverableHours,
			Deliverable50PCT = @PCT50Date,
			Deliverable90PCT = @PCT90Date,
			LUD = stng.GetBPTime(getdate()),
			LUB = @CurrentUser
			where UniqueID = @BPDeliverableID;

		end
		
	--Copy BP deliverables to Vendor Deliverables
	else if @Operation = 14
		begin

			--First, check if there is already non-Deleted deliverables for the given TOQLiteID
			if exists(
				select UniqueID
				from stng.TOQLite_VendorDeliverable
				where TOQLiteID = @TOQLiteID and Deleted = 0
			)
				begin

					select CONCAT('There are already Vendor Deliverables for TOQ Lite ID ',@TOQLiteID) as ReturnMessage;
					return;

				end

			--Add deliverables
			select TOQLiteID, DeliverableID, UniqueID as ParentBPDeliverableID, DeliverableHours
			into #NewDeliverables
			from stng.VV_TOQLite_BPDeliverable
			where TOQLiteID = @TOQLiteID;

			insert into stng.TOQLite_VendorDeliverable
			(TOQLiteID, DeliverableID, ParentBPDeliverableID, RAB, LUB)
			select TOQLiteID, DeliverableID, ParentBPDeliverableID, @CurrentUser, @CurrentUser
			from #NewDeliverables;

			--Add activities. Apply standard spread to deliverable hours
			insert into TOQLite_VendorDeliverable_Activity
			(VendorDeliverableID, Activity, ActivityType, SortOrder, RAB, LUB)
			select distinct a.UniqueID, c.Activity, c.ActivityType, c.SortOrder, @CurrentUser, @CurrentUser
			from stng.TOQLite_VendorDeliverable as a
			inner join #NewDeliverables as b on a.TOQLiteID = b.TOQLiteID and a.DeliverableID = b.DeliverableID
			inner join stng.VV_ER_StandardDeliverableActivity as c on b.DeliverableID = c.DeliverableID and c.ActivityType = 'External';

		end

	--Edit Vendor Deliverable fields
	else if @Operation = 15
		begin

			update stng.TOQLite_VendorDeliverable
			set DeliverableCost = @DeliverableCost,
			LUD = stng.GetBPTime(getdate()),
			LUB = @CurrentUser
			where UniqueID = @VendorDeliverableID;

		end

	--Add new Vendor deliverable
	else if @Operation = 16
		begin

			insert into stng.TOQLite_VendorDeliverable
			(TOQLiteID, DeliverableID, Comment, RAB, LUB)
			select @TOQLiteID, a.UniqueID, @Comment, @CurrentUser, @CurrentUser
			from stng.VV_ER_StandardDeliverable as a
			where a.UniqueID = @Deliverable and a.ActivityType = 'External';

			select @WorkingVendorDeliverableID = SCOPE_IDENTITY();

			insert into stng.TOQLite_VendorDeliverable_Activity
			(VendorDeliverableID, Activity, ActivityType, SortOrder, RAB, LUB)
			select @WorkingVendorDeliverableID, a.Activity, a.ActivityType, a.SortOrder, @CurrentUser, @CurrentUser
			from stng.ER_StandardDeliverableActivity as a
			where DeliverableID = @Deliverable and Active = 1 and a.ActivityType = 'External';

		end

	--Verify ER
	else if @Operation = 17
		begin

			select ER
			from stng.ER_Main as a
			left join stng.ER_Status as b on a.CurrentStatus = b.UniqueID
			where ER like @ER + '%' and b.StatusShort = 'TDS'
			option(optimize for (@ER unknown));

		end

	--ER Suggestions
	else if @Operation = 18
		begin

			select distinct top 20 ER as [label], ER as [value]
			from stng.ER_Main as a
			left join stng.ER_Status as b on a.CurrentStatus = b.UniqueID
			where ER like @ER + '%' and b.StatusShort = 'TDS'
			option(optimize for (@ER unknown));

		end

	--Standard Deliverables
	else if @Operation = 19
		begin

			select Deliverable, UniqueID as DeliverableID
			from stng.VV_ER_StandardDeliverable
			where (ActivityType = 'External' or ActivityType is null) and Active = 1
			order by Deliverable asc;

		end

	--Add Activity
	else if @Operation = 20
		begin

			--Get working Sort Order
			select @WorkingSortOrder = isNULL(max(SortOrder) + 1, 1)
			from stng.TOQLite_VendorDeliverable_Activity
			where VendorDeliverableID = @VendorDeliverableID and Deleted = 0;

			insert into stng.TOQLite_VendorDeliverable_Activity
			(VendorDeliverableID, Activity, ActivityType, ActivityHours, SortOrder, RAB, LUB)
			values
			(@VendorDeliverableID, @Activity, 'External', @ActivityHours, @WorkingSortOrder, @CurrentUser, @CurrentUser);

		end

	--Remove Activity
	else if @Operation = 21
		begin

			if not exists
			(
				select * from stng.TOQLite_VendorDeliverable_Activity
				where UniqueID = @VendorDeliverableActivityID and Deleted = 0
			)
				begin

					select concat('Vendor Deliverable Activity ID ',@VendorDeliverableActivityID, ' does not exist or has already been deleted') as ReturnMessage;
					return;

				end

			update stng.TOQLite_VendorDeliverable_Activity
			set Deleted = 1,
			DeletedOn = stng.GetBPTime(getdate()),
			DeletedBy = @CurrentUser
			where UniqueID = @VendorDeliverableActivityID;

		end

	--Update Activity
	else if @Operation = 22
		begin

			if not exists
			(
				select * 
				from stng.TOQLite_VendorDeliverable_Activity
				where UniqueID = @VendorDeliverableActivityID and Deleted = 0
			)
				begin

					select concat('Vendor Deliverable Activity ID ',@VendorDeliverableActivityID, ' does not exist') as ReturnMessage;
					return;

				end

			update stng.TOQLite_VendorDeliverable_Activity
			set Activity = @Activity,
			ActivityHours = @ActivityHours,
			ActivityStart = @ActivityStart,
			ActivityFinish = @ActivityFinish,
			LUD = stng.GetBPTime(getdate()),
			LUB = @CurrentUser
			where UniqueID = @VendorDeliverableActivityID;

			select @VendorDeliverableID = VendorDeliverableID
			from stng.TOQLite_VendorDeliverable_Activity
			where UniqueID = @VendorDeliverableActivityID

			select @VendorDeliverableID as DeliverableID

			if @VendorDeliverableID is not null
				begin 
					select concat('Activity ',@VendorDeliverableActivityID, ' successfully updated') as ReturnMessage;
					return;
				end

		end

	--Update workflow status
	else if @Operation = 23
		begin

			if @StatusShort is null or @TOQLiteID is null
				begin

					select 'StatusShort and/or TOQLiteID is required' as ReturnMessage;
					return;

				end 

			--Get WorkingStatus
			select @WorkingStatus = UniqueID
			from stng.TOQLite_Status
			where StatusShort = case when @StatusShort = 'RC' then 'AA' else @StatusShort end;

			if @WorkingStatus is null
				begin

					select concat(@StatusShort, ' is not a valid shortform status') as ReturnMessage;
					return;

				end

			declare @PriorStatus varchar(10) = null
			declare @StatusC varchar(50) = null
			declare @ERID varchar(40) = null
			declare @Revision int = null

			select @PriorStatus = CurrentStatusShort, @ERID = ERID, @Revision = TDSRevision
			from stng.VV_TOQLite_Main
			where UniqueID = @TOQLiteID

			select @StatusC = [Status]
			from stng.TOQLite_Status
			where StatusShort = @StatusShort

			if (@StatusShort = 'AV' and @PriorStatus not in ('I', 'AB')) or
				(@StatusShort = 'AB' and @PriorStatus not in ('AV')) or
				(@StatusShort = 'AA' and @PriorStatus not in ('AB', 'RB')) or 
				(@StatusShort = 'NB' and @PriorStatus not in ('AV')) or 
				(@StatusShort = 'I' and @PriorStatus not in ('NB', 'AB', 'C')) or 
				(@StatusShort = 'C' and @PriorStatus not in ('I', 'NB', 'AB')) or 
				(@StatusShort = 'RI' and @PriorStatus not in ('AA')) or 
				(@StatusShort = 'RV' and @PriorStatus not in ('RI')) or 
				(@StatusShort = 'RB' and @PriorStatus not in ('RV')) or 
				(@StatusShort = 'RC' and @PriorStatus not in ('RI', 'RV', 'RB'))
				begin
							
					select concat('You cannot change the status to ', @StatusC, ' from the current status') as ReturnMessage;
					return
			
				end
			else if @StatusShort = 'RI' and exists(
					select 1
					from stng.VV_ER_Main as a
					inner join stng.VV_TOQLite_Main as b on a.ER = b.ER
					where b.UniqueID = @TOQLiteID and a.CurrentStatusShort not in ('ASA')
				) 
									
				begin
					select 'The ER associated with this TDS needs to be in Awaiting SM Assessment to revise the TDS.' as ReturnMessage;
					return
				end
			else
				begin
					update stng.TOQLite_Main
					set CurrentStatus = @WorkingStatus,
					LUD = stng.GetBPTime(getdate()),
					LUB = @CurrentUser
					from stng.TOQLite_Main
					where UniqueID = @TOQLiteID;

					if @StatusShort = 'RC'
						begin
							Set @Comment = concat('Canceled Revision. Reset to last approved state.', CHAR(13) + CHAR(10), @Comment)
						end

					insert into stng.TOQLite_StatusLog
					(TOQLiteID, StatusID, Comment, RAB)
					values
					(@TOQLiteID, @WorkingStatus, @Comment, @CurrentUser);

					if @StatusShort = 'I'
						begin

							update [stng].[TOQLite_VendorDeliverable]
							set
							Deleted = 1,
							DeletedBy = @CurrentUser,
							DeletedOn = stng.GetBPTime(getdate())
							where TOQLiteID = @TOQLiteID

							update [stng].[TOQLite_VendorDeliverable_Activity]
							set
							Deleted = 1,
							DeletedBy = @CurrentUser,
							DeletedOn = stng.GetBPTime(getdate())
							where VendorDeliverableID in (
								select UniqueID
								from [stng].[TOQLite_VendorDeliverable]
								where TOQLiteID = @TOQLiteID
							)
				
						end
					if @StatusShort = 'AA' or @StatusShort = 'C'
						begin
							if (
									select count(UniqueID) as ERCount
									from stng.[VV_TOQLite_Main]
									where [ERID] = @ERID and CurrentStatusShort not in ('AA', 'C')
								) = 0
								begin 

									declare @ERStatus varchar(40) = null

									select @ERStatus = [UniqueID]
									from stng.ER_Status
									where StatusShort = 'ASA'
									
									update stng.ER_Main
									set [CurrentStatus] = @ERStatus,
									LUD = stng.GetBPTime(getdate()),
									LUB = 'SYSTEM'
									where [UniqueID] = @ERID;

									--Add, remove, and update deliverables in the ER module 

									----only add delete and update toqlites that are approved and not canceled

									----delete function - any deliverables that arent in vendor deliverables need to be removed from er deliverables

								
									update stng.ER_Deliverable
									set
									deleted = 1,
									deletedby = 'SYSTEM',
									deletedOn = stng.GetBPTime(getdate())
									from stng.VV_ER_Deliverable as a
									left join stng.VV_TOQLite_VendorDeliverable as b on a.DeliverableID = b.DeliverableID and a.Vendor = b.VendorID
									left join stng.VV_TOQLite_Main as d on b.TOQLiteID = d.UniqueID and d.CurrentStatusC = 'AA'
									where stng.ER_Deliverable.ERID = @ERID and stng.ER_Deliverable.InHouse = 0 and b.UniqueID is NULL

									
									-- Update Deliverable thats already in ER module 
									
									update stng.ER_Deliverable
									set
									EstimatedHours = a.DeliverableHours
									from stng.VV_TOQLite_VendorDeliverable as a
									inner join [stng].[VV_ER_Deliverable] as b on a.DeliverableID = b.DeliverableID
									inner join stng.VV_TOQLite_Main as c on a.TOQLiteID= c.UniqueID and b.Vendor = c.VendorID and c.CurrentStatusC = 'AA'  
									where stng.ER_Deliverable.ERID = @ERID and stng.ER_Deliverable.inhouse = 0 and stng.ER_Deliverable.Deleted = 0


									------deliverables that are in vendordev and not in er

									INSERT into [stng].[ER_Deliverable] (
														[ERID]
														,[DeliverableID]
														,[Vendor]
														,[RAB]
														,[EstimatedHours]
														,InHouse
														,[LUB]
													)
									select a.ERID, a.DeliverableID, a.VendorID, 'SYSTEM', a.DeliverableHours, 0, 'SYSTEM'
									from stng.VV_TOQLite_VendorDeliverable as a 
									left join [stng].[VV_ER_Deliverable] as b on a.ERID = b.ERID and a.DeliverableID= b.DeliverableID and a.VendorID = b.Vendor and b.InHouse = 0 
									inner join stng.VV_TOQLite_Main as c on a.TOQLiteID= c.UniqueID and a.VendorID = c.VendorID and c.CurrentStatusShort = 'AA'  
									where a.ERID =  @ERID and b.UniqueID is NULL

									-- Update Deliverables in ER module, display old ones in the Logs tab

									insert into stng.ER_StatusLog
									([ERID], [StatusID], Comment, RAB)
									values
									(@ERID, @ERStatus,'All TDS Approved and Awarded or Canceled, moving status back to Awaiting SM Approval for final verification', 'SYSTEM');

								end
						end

					if @StatusShort = 'RI'
						begin

							update stng.TOQLite_Main
							set Revision = @Revision + 1
							from stng.TOQLite_Main
							where UniqueID = @TOQLiteID;
						
							-- Take snapshot of the state of the TDS in AA

							Insert into stng.TOQLite_Revision_Main
							([UniqueID],[VendorResponseDate],[PCT50Date],[PCT90Date],[ERLevelDates],[RAD],[RAB],[TOQID],[VendorNotes],[Scope])
							Select 
							[UniqueID],[VendorResponseDate],[PCT50Date],[PCT90Date],[ERLevelDates],[RAD],[RAB],[TOQID],[VendorNotes],[Scope]
							from stng.TOQLite_Main
							where UniqueID = @TOQLiteID

							Insert into stng.TOQLite_Revision_BPDeliverable
							(MappedID, [TOQLiteID],[DeliverableID],[DeliverableHours],[Deliverable50PCT],[Deliverable90PCT],[RAD],[RAB],[LUD],[LUB],[Deleted],[DeletedOn],[DeletedBy]) 
							Select 
							UniqueID, [TOQLiteID],[DeliverableID],[DeliverableHours],[Deliverable50PCT],[Deliverable90PCT],[RAD],[RAB],[LUD],[LUB],[Deleted],[DeletedOn],[DeletedBy]
							from stng.TOQLite_BPDeliverable
							where TOQLiteID = @TOQLiteID and Deleted = 0
							
							Insert into stng.TOQLite_Revision_VendorDeliverable
							(MappedID,[TOQLiteID],[DeliverableID],[ParentBPDeliverableID],[DeliverableCost],[RAD],[RAB],[LUD],[LUB],[Deleted],[DeletedOn],[DeletedBy],[Comment])
							Select 
							UniqueID,[TOQLiteID],[DeliverableID],[ParentBPDeliverableID],[DeliverableCost],a.[RAD],[RAB],[LUD],[LUB],[Deleted],[DeletedOn],[DeletedBy],[Comment]
							from stng.TOQLite_VendorDeliverable as a 
							where [TOQLiteID] = @TOQLiteID and Deleted = 0
							
							Insert into stng.TOQLite_Revision_VendorDeliverable_Activity
							(MappedID,[VendorDeliverableID],[Activity],[ActivityType],[ActivityHours],[ActivityStart],
							[ActivityFinish],[RAD],[RAB],[LUD],[LUB],[Deleted],[DeletedOn],[DeletedBy],[SortOrder])
							select
							b.UniqueID, b.[VendorDeliverableID],b.[Activity],b.[ActivityType],b.[ActivityHours],b.[ActivityStart],
							b.[ActivityFinish],b.[RAD],b.[RAB],b.[LUD],b.[LUB],b.[Deleted],b.[DeletedOn],b.[DeletedBy],b.[SortOrder]
							from stng.TOQLite_VendorDeliverable as a 
							inner join stng.TOQLite_VendorDeliverable_Activity as b on a.UniqueID = b.VendorDeliverableID and b.Deleted = 0
							where a.[TOQLiteID] = @TOQLiteID and a.Deleted = 0
						
						end

					if @StatusShort = 'RC'
						begin
							-- reset the state of the tds to what it was in AA
							-- 1. Mark existing activities as deleted if linked to a not-deleted deliverable
							UPDATE a
							SET a.Deleted   = 1,
								a.DeletedOn = stng.GetBPTime(GETDATE()),
								a.DeletedBy = @CurrentUser
							FROM stng.TOQLite_VendorDeliverable_Activity AS a
							LEFT JOIN stng.TOQLite_VendorDeliverable AS b
								ON a.VendorDeliverableID = b.UniqueID
							   AND b.Deleted = 0
							WHERE b.[TOQLiteID] = @TOQLiteID
							  AND a.Deleted = 0;

							-- 2. Mark deliverables as deleted
							UPDATE stng.TOQLite_VendorDeliverable
							SET Deleted   = 1,
								DeletedOn = stng.GetBPTime(GETDATE()),
								DeletedBy = @CurrentUser
							WHERE [TOQLiteID] = @TOQLiteID
							  AND Deleted = 0;

							UPDATE stng.TOQLite_BPDeliverable
							SET Deleted   = 1,
								DeletedOn = stng.GetBPTime(GETDATE()),
								DeletedBy = @CurrentUser
							WHERE [TOQLiteID] = @TOQLiteID
							  AND Deleted = 0;

							-- 3. Update main table from revision main
							UPDATE b
							SET b.VendorResponseDate = a.VendorResponseDate,
								b.PCT50Date          = a.PCT50Date,
								b.PCT90Date          = a.PCT90Date,
								b.ERLevelDates       = a.ERLevelDates,
								b.TOQID              = a.TOQID,
								b.VendorNotes        = a.VendorNotes,
								b.Scope              = a.Scope
							FROM stng.TOQLite_Revision_Main AS a
							INNER JOIN stng.TOQLite_Main AS b
								ON a.UniqueID = b.UniqueID
							WHERE a.UniqueID = @TOQLiteID
							  AND a.Deleted = 0;

							Update a
							set
							[Deliverable50PCT] = b.[Deliverable50PCT]
							,[Deliverable90PCT] = b.[Deliverable90PCT]
							,[LUD] = b.[LUD]
							,[LUB] = b.[LUB]
							,[Deleted] = 0
							,[DeletedOn] = null
							,[DeletedBy] = null
							from stng.TOQLite_BPDeliverable as a
							inner join stng.TOQLite_Revision_BPDeliverable as b on a.UniqueID = b.MappedID
							where b.TOQLiteID = @TOQLiteID and b.Deleted = 0

							
							Update a
							set
							[DeliverableCost] = b.[DeliverableCost]
							,[LUD] = b.[LUD]
							,[LUB] = b.[LUB]
							,[Deleted] = 0
							,[DeletedOn] = null
							,[DeletedBy] = null
							from stng.[TOQLite_VendorDeliverable] as a
							inner join stng.[TOQLite_Revision_VendorDeliverable] as b on a.UniqueID = b.MappedID
							where b.TOQLiteID = @TOQLiteID and b.Deleted = 0
							
							
							Update a
							set
							[Activity] = b.[Activity]
							,[ActivityHours] = b.[ActivityHours]
							,[ActivityStart] = b.[ActivityStart]
							,[ActivityFinish] = b.[ActivityFinish]
							,[LUD] = b.[LUD]
							,[LUB] = b.[LUB]
							,[Deleted] = 0
							,[DeletedOn] = null
							,[DeletedBy] = null
							from stng.[TOQLite_VendorDeliverable_Activity] as a
							inner join stng.[TOQLite_Revision_VendorDeliverable_Activity] as b on a.UniqueID = b.MappedID
							inner join stng.[TOQLite_Revision_VendorDeliverable] as c on b.VendorDeliverableID = c.MappedID
							where c.TOQLiteID = @TOQLiteID and b.Deleted = 0

						end

					if @StatusShort = 'AA' or @StatusShort = 'RC'
						begin
							if @StatusShort = 'RC'
								begin

									update stng.TOQLite_Main
									set Revision = @Revision - 1
									from stng.TOQLite_Main
									where UniqueID = @TOQLiteID;

								end
							
							--Removed any Revision entries for this TDS

							Update stng.TOQLite_Revision_BPDeliverable
							set
							Deleted = 1,
							DeletedOn = stng.GetBPTime(getdate()),
							DeletedBy = @CurrentUser
							where [TOQLiteID] = @TOQLiteID and Deleted = 0

							Update a
							set
							Deleted = 1,
							DeletedOn = stng.GetBPTime(getdate()),
							DeletedBy = @CurrentUser
							from stng.TOQLite_Revision_VendorDeliverable_Activity as a
							left join stng.TOQLite_Revision_VendorDeliverable as b on a.VendorDeliverableID = b.MappedID and b.deleted = 0
							where b.[TOQLiteID] = @TOQLiteID and a.Deleted = 0

							Update stng.TOQLite_Revision_VendorDeliverable
							set
							Deleted = 1,
							DeletedOn = stng.GetBPTime(getdate()),
							DeletedBy = @CurrentUser
							where [TOQLiteID] = @TOQLiteID and Deleted = 0

							Update stng.TOQLite_Revision_Main
							set
							Deleted = 1,
							DeletedOn = stng.GetBPTime(getdate()),
							DeletedBy = @CurrentUser
							where [UniqueID] = @TOQLiteID and Deleted = 0

						end

					select SCOPE_IDENTITY() as ReturnID, 
						case 
							when @StatusShort = 'RC' 
								then 'Canceling Revision. Resetting to last approved state.' 
							else concat( 'Status changed to ',@StatusC) 
						end as SuccessMessage;
				end
		end

	--Get workflow statuses
	else if @Operation = 24
		begin

			--Null check
			if @TOQLiteID is null 
				begin

					select 'TOQLiteID is required' as ReturnMessage;
					return;

				end

			select *
			from stng.VV_TOQLite_Status
			where TOQLiteID = @TOQLiteID
			order by RAD desc
			option(optimize for (@TOQLiteID unknown));

		end

	--Get standard deliverable activities
	else if @Operation = 25
		begin

			select *
			from stng.VV_ER_StandardDeliverableActivity
			where DeliverableID = @Deliverable and ActivityType = @ActivityType
			order by SortOrder asc
			option(optimize for (@Deliverable unknown));

		end

	--Delete Standard Deliverable
	else if @Operation = 26
		begin

			update stng.ER_StandardDeliverable
			set Active = 0,
			LUD = stng.GetBPTime(getdate()),
			LUB = @CurrentUser
			where UniqueID = @Deliverable;

		end

	--Edit Standard Deliverable Activity
	else if @Operation = 27
		begin

			if @SortUpdate = 1
				begin

					update stng.ER_StandardDeliverableActivity
					set SortOrder = b.SortOrder,
					LUD = stng.GetBPTime(getdate()),
					LUB = @CurrentUser
					from stng.ER_StandardDeliverableActivity as a
					inner join @SortOrder as b on a.UniqueID = b.UUID;

				end


			else
				begin

					update stng.ER_StandardDeliverableActivity
					set Activity = @Activity,
					StandardHours = @ActivityHours,
					LUD = stng.GetBPTime(getdate()),
					LUB = @CurrentUser
					where UniqueID = @ActivityID;

				end

		end

	--Get Blended Rate
	else if @Operation = 28
		begin

			select top 1 UniqueID, ConstantNum as BlendedRate
			from stng.ER_Constant
			where ConstantName = 'BlendedRate' and ConstantType = 'NUM';

		end

	--Edit Blended Rate
	else if @Operation = 29
		begin

			update stng.ER_Constant
			set ConstantNum = @BlendedRate,
			LUD = stng.GetBPTime(getdate()),
			LUB = @CurrentUser
			where ConstantName = 'BlendedRate' and ConstantType = 'NUM';

		end

	--Get All Outages
	else if @Operation = 30
		begin

			select x.*
			from
			(
				select *,
				case when year(BPSTARTDATE) = year(stng.getbptime(getdate())) then 1 else 0 end as [Rank]
				from stngetl.General_Outage
				where bpoutagecode like '[A-B]%'
			) as x
			order by x.[Rank] desc, x.BPSTARTDATE desc;

		end

	-- Get all activities for a particular TOQ Lite request and check for errors
	else if @Operation = 31
		begin
			
			select case when x.badactcount > 0 then 1 else 0 end as HasErrors
			from
			(
				select count(ActivityUniqueID) as badactcount
				from stng.VV_TOQLite_VendorDeliverable_Activity
				where TOQLiteID = @TOQLiteID and (ActivityStart is null or ActivityFinish is null)
			) as x
			option(optimize for (@TOQLiteID unknown));

			select case when x.badactcount > 0 then 1 else 0 end as HasErrors
			from
			(
				select count(ActivityUniqueID) as badactcount
				from stng.VV_TOQLite_VendorDeliverable_Activity
				where TOQLiteID = @TOQLiteID and (ActivityHours is null or ActivityHours = 0)
			) as x
			option(optimize for (@TOQLiteID unknown));

			select case when x.baddeliverablecount > 0 then 1 else 0 end as HasErrors
			from
			(
				select count(UniqueID) as baddeliverablecount
				from stng.VV_TOQLite_VendorDeliverable
				where TOQLiteID = @TOQLiteID and (DeliverableCost is null or DeliverableCost = 0)
			) as x
			option(optimize for (@TOQLiteID unknown));

		end

	--Add new standard deliverable
	else if @Operation = 32
		begin

			--Check if DeliverableName is null
			if @DeliverableName is null
				begin

					select 'DeliverableName is required' as ReturnMessage;
					return;
				end

			--Check if Deliverable already exists
			if exists
			(
				select *
				from stng.ER_StandardDeliverable
				where Active = 1 and Deliverable = @DeliverableName
			)
				begin

					select concat('Deliverable ',@DeliverableName, ' already exists') as ReturnMessage;
					return;

				end

			--If Deliverable's inactive, revive
			if exists
			(
				select *
				from stng.ER_StandardDeliverable
				where Active = 0 and Deliverable = @DeliverableName
			)
				begin

					update stng.ER_StandardDeliverable
					set Active = 1,
					RAD = stng.GetBPTime(getdate()),
					RAB = @CurrentUser, 
					LUD = stng.GetBPTime(getdate()),
					LUB = @CurrentUser
					where Deliverable = @DeliverableName;

				end

			--Otherwise, insert new record
			else
				begin

					insert into stng.ER_StandardDeliverable
					(Deliverable, RAB, LUB)
					values
					(@DeliverableName, @CurrentUser, @CurrentUser);

				end

		end

	--Add new standard deliverable activity
	else if @Operation = 33
		begin

			--Check if Deliverable and Activity have been provided
			if @Deliverable is null or @Activity is null
				begin

					select 'Deliverable and Activity are required' as ReturnMessage;
					return;
				end

			--Check if Activity already exists
			if exists
			(
				select *
				from stng.ER_StandardDeliverableActivity
				where DeliverableID = @Deliverable and Activity = @Activity and Active = 1 and ActivityType = @ActivityType
			)
				begin
					
					select concat('Activity ', @Activity, ' already exists on Deliverable ', @Deliverable) as ReturnMessage;
					return;

				end 

			--Set WorkingSortOrder
			select @WorkingSortOrder = case when max(SortOrder) is null then 0 else max(SortOrder) end + 1
			from stng.ER_StandardDeliverableActivity
			where DeliverableID = @Deliverable and Active = 1 and ActivityType = @ActivityType;

			--If Activity's inactive, revive
			if exists
			(
				select *
				from stng.ER_StandardDeliverableActivity
				where DeliverableID = @Deliverable and Activity = @Activity and Active = 0 and ActivityType = @ActivityType
			)
				begin

					update stng.ER_StandardDeliverableActivity
					set Active = 1,
					SortOrder = @WorkingSortOrder,
					RAD = stng.GetBPTime(getdate()),
					RAB = @CurrentUser, 
					LUD = stng.GetBPTime(getdate()),
					LUB = @CurrentUser
					where DeliverableID = @Deliverable and Activity = @Activity and Active = 0 and ActivityType = @ActivityType;

				end

			--Else, insert new record
			else
				begin

					insert into stng.ER_StandardDeliverableActivity
					(DeliverableID, Activity, ActivityType, StandardHours, SortOrder, RAB, LUB)
					values
					(@Deliverable, @Activity, @ActivityType, 0, @WorkingSortOrder, @CurrentUser, @CurrentUser);

				end

		end

	--Delete standard deliverable activity
	else if @Operation = 34
		begin

			update stng.ER_StandardDeliverableActivity
			set Active = 0,
			LUD = stng.GetBPTime(getdate()),
			LUB = @CurrentUser
			where UniqueID = @ActivityID;

		end

	--Add new Vendor TOQ
	else if @Operation = 35
		begin

			--Check if VendorShort and VendorTOQID have been provided
			if @VendorID is null or @VendorTOQID is null
				begin

					select 'VendorShort and VendorTOQID required' as ReturnMessage;
					return;

				end

			--Check if VendorTOQID already exists for given vendor
			if exists
			(
				select *
				from stng.VV_TOQLite_TOQ
				where VendorTOQID = @VendorTOQID and VendorID = @VendorID
			)
				begin

					select concat('Vendor TOQ ID ',@VendorTOQID, ' already exists on this Vendor') as ReturnMessage;
					return;

				end

			--Get WorkingBPTOQID
			select @WorkingBPTOQID = case when max(BPTOQID) is null then 0 else max(BPTOQID) end + 1
			from stng.TOQLite_TOQ_Temp;

			--Insert main record
			insert into stng.TOQLite_TOQ_Temp
			(BPTOQID, Revision, VendorTOQID, RAB, TOQTitle)
			values
			(@WorkingBPTOQID, 0, @VendorTOQID, @CurrentUser, @VendorTOQID);

			--Insert vendor mapping record
			select @TOQID = UniqueID
			from stng.TOQLite_TOQ_Temp
			where VendorTOQID = @VendorTOQID;

			--select @VendorID = UniqueID
			--from stng.General_Vendor
			--where VendorShort = @VendorShort and UseForER = 1;

			insert into stng.TOQLite_TOQVendorMapping_Temp
			(TOQID, VendorID, RAB)
			values
			(@TOQID, @VendorID, @CurrentUser);

		end

	--Delete vendor TOQ
	else if @Operation = 36
		begin

			--Check if VendorTOQID and VendorShort were provided
			if @VendorID is null or @VendorTOQID is null
				begin
					select 'VendorShort and VendorTOQID required' as ReturnMessage;
					return;
				end

			--Delete mapping record
			delete a
			from stng.TOQLite_TOQVendorMapping_Temp as a
			inner join stng.TOQLite_TOQ_Temp as b on a.TOQID = b.UniqueID and b.VendorTOQID = @VendorTOQID
			inner join stng.[VV_Admin_AllVendors] as c on a.VendorID = c.AttributeID 

			--Delete main record
			delete a
			from stng.TOQLite_TOQ_Temp as a
			where a.VendorTOQID = @VendorTOQID;

		end

	--Get projects on Outage
	else if @Operation = 37
		begin

			select a.UniqueID, a.ProjectID, b.PROJECTNAME
			from stng.TOQLite_OutageMapping as a 
			left join stng.MPL as b on a.ProjectID = b.PROJECTID
			where Outage = @Outage
			order by ProjectID asc
			option(optimize for (@Outage unknown));

		end

	--Add project to Outage
	else if @Operation = 38
		begin

			--Check if Outage and ProjectNo were provided
			if @Outage is null and @ProjectNo is null
				begin

					select 'Outage and ProjectNo are required' as ReturnMessage;
					return;

				end 

			--Check if Outage exists
			if not exists
			(
				select *
				from stngetl.General_Outage
				where BPOUTAGECODE = @Outage
			)
				begin

					select concat('Outage ',@Outage, ' does not exist') as ReturnMessage;
					return;

				end

			--Check if ProjectNo exists
			if not exists
			(
				select *
				from stng.MPL
				where PROJECTID = @ProjectNo
			)
				begin

					select concat('Project ',@ProjectNo, ' does not exist') as ReturnMessage;
					return;

				end 

			--Check if Project already on Outage
			if exists
			(
				select *
				from stng.TOQLite_OutageMapping
				where Outage = @Outage and ProjectID = @ProjectNo
			)
				begin

					select concat('Project ',@ProjectNo, ' is already mapped to Outage ', @Outage) as ReturnMessage;
					return;

				end

			--Otherwise, do row insert
			insert into stng.TOQLite_OutageMapping
			(Outage, ProjectID, RAB)
			values
			(@Outage, @ProjectNo, @CurrentUser);

		end

	--Delete project from Outage
	else if @Operation = 39
		begin

			delete
			from stng.TOQLite_OutageMapping
			where ProjectID = @ProjectNo and Outage= @Outage;

		end

	--Budgeting Report by Department
	else if @Operation = 40
		begin

			select *
			from stng.VV_TOQLite_BudgetReport
			where Department = @Department or @Department is null
			option(optimize for (@Department unknown));

		end

	--Delete vendor deliverable
	else if @Operation = 41
		begin

			update stng.TOQLite_VendorDeliverable
			set Deleted = 1,
			DeletedBy = @CurrentUser,
			DeletedOn = stng.GetBPTime(getdate()),
			LUD = stng.GetBPTime(getdate()),
			LUB = @CurrentUser
			where UniqueID = @VendorDeliverableID;

		end

	--Get email data
	else if @Operation = 42
		begin

			select @VendorID = VendorID, @Section = Section
			from stng.VV_TOQLite_Main
			where UniqueID = @TOQLiteID

			SELECT @TemplateName = d.Name
			FROM [stng].[TOQLite_EmailMapping] as a
			left join [stng].[TOQLite_Status] as FromStatus on a.StatusFrom = FromStatus.UniqueID
			left join [stng].[TOQLite_Status] as ToStatus on a.StatusTo = ToStatus.UniqueID
			left join [stng].[Common_EmailTemplate] as d on a.Template = d.UniqueID
			where FromStatus.StatusShort = @CurrentStatus and ToStatus.StatusShort = @StatusShort

			select users.Email
			from (	
				select EmployeeID
				from stng.Admin_UserAttribute as a
				inner join stng.[Admin_Attribute] as b on a.AttributeID = b.UniqueID
				where b.UniqueID = @VendorID
			) as empIDs
			inner join stng.VV_Admin_UserView as users on empIDs.EmployeeID = users.EmployeeID

			select users.Email
			from (	
				select EmployeeID
				from stng.Admin_UserAttribute as a
				inner join stng.[Admin_Attribute] as b on a.AttributeID = b.UniqueID
				inner join stng.General_Organization as c on b.Attribute = c.[Description]
				where c.PersonGroup = @Section
			) as empIDs
			inner join stng.VV_Admin_UserView as users on empIDs.EmployeeID = users.EmployeeID

			select ER, VendorResponseDate, Vendor
			from stng.VV_TOQLite_Main
			where UniqueID = @TOQLiteID

			Select [Subject], [Body]
			from [stng].[Common_EmailTemplate]
			where [Name] = @TemplateName

		end
			
		else if @Operation = 43 --Get Qualification Admin
			begin

				SELECT *
				FROM stng.TOQLite_Qualification

			end 
		
		else if @Operation = 44 --Add Qualification Admin
			begin

				INSERT INTO stng.TOQLite_Qualification
				([Qualification], RAB)
				values
				(@Qualification, @CurrentUser)

			end 

		else if @Operation = 45 --Remove Qualification Admin
			begin

				DELETE FROM stng.TOQLite_Qualification
				WHERE UniqueID = @Qualification

			end 

		else if @Operation = 46 --Get record Qualification
			begin

				SELECT *
				FROM [stng].[TOQLite_Qualification_Map]
				WHERE TOQLiteID = @TOQLiteID

			end 

		else if @Operation = 47 --Update Qualification
			begin
				if @SubOp = 1 --Check Qualification
					begin
						SELECT DISTINCT Qualification
						FROM [stng].[TOQLite_Qualification_Map]
						WHERE [TOQLiteID] = @TOQLiteID and [Qualification] = @Qualification
					end

				else if @SubOp = 2 --Add Qualification to record
					begin

						INSERT INTO [stng].[TOQLite_Qualification_Map]
						([TOQLiteID], [Qualification], [RAB])
						values
						(@TOQLiteID, @Qualification, @CurrentUser)

					end 

				else if @SubOp = 3 --Delete Qualification to record
					begin

						DELETE FROM [stng].[TOQLite_Qualification_Map]
						WHERE [TOQLiteID] = @TOQLiteID and [Qualification] = @Qualification

					end 

			end 

		else if @Operation = 48 --Check ER
			begin

				select count(a.UniqueID) as ERCount
				from stng.TOQLite_Main as a
				inner join stng.ER_Main as b on a.ERID = b.UniqueID and b.ER = @ER
				inner join stng.TOQLite_Status as c on a.CurrentStatus = c.UniqueID
				where c.StatusShort not in ('C')

			end 

		--ER Suggestions
		else if @Operation = 49
			begin

				select distinct ER as [label], ER as [value]
				from stng.ER_Main as a
				left join stng.ER_Status as b on a.CurrentStatus = b.UniqueID
				where ER = @ER and b.StatusShort = 'ASA'
				option(optimize for (@ER unknown));

			end

end
