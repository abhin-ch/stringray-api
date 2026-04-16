/****** Object:  StoredProcedure [stng].[SP_ER_CRUD]    Script Date: 4/8/2026 11:08:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [stng].[SP_ER_CRUD]
(
	@Operation int,
	@SubOp int = null,
	@EmployeeID varchar(20) = null,
	@UniqueID varchar(40) = null,
	@ID varchar(50) = null,

	@isAdmin bit = 0,

	@Completed bit = 0,
	@InHouse bit = 0,
	@Primary bit = 0,
	@DED bit = 0,
	@ProjectRequired bit = 0,
	@ScheduleBuilt bit = null,
	@AtRisk bit = null,
	@ERID varchar(50) = null,
	@ERTCD date = null,
	@ERDueDate date = null,

	@SearchText varchar(100) = null,
	
	@DeliverableID varchar(50) = null,
	@VendorID varchar(50) = null,
	@Resource varchar(20) = null,
	@ResourceType varchar(50) = null,
	@EstimatedHours float = null,
	@Assessment varchar(200) = null,
	@Prerequisite varchar(200) = null,
	@SectionName varchar(5000) = null,
	@Comment varchar(max) = null,
	@ProjectID varchar(100) = null,

	@UniqueIDNum bigint = null,
	@Section bigint = null,
	@Department bigint = null,
	
	@StatusShort varchar(10) = null,
	@CurrentStatus varchar(10) = null,

	@Value1 varchar(max) = null,

	@ERDueDateOverride date = null,
	@OverrideERDueDateCheck bit = null,
	@AdminOptionText varchar(1000) = null,
	@Reason varchar(50) = null,
	
	@Value2 nvarchar(100) = null,
	@DateFrom date = null,
	@DateTo date = null,
	
	@KPI int = null,
	@Exception bit = 0
)
as
begin

	declare @WorkingStatus uniqueidentifier;

	--Main table query
	if @Operation = 1
		begin 

			if @Completed = 1
				begin

					select a.*
					,case when @isAdmin = 1 or b.SM is not null or c.[Resource] is not null then 1 else 0 end as IsSM
					from stng.VV_ER_Main as a
					left join (
						select Section, SM
						from stng.ER_SectionManager
						where SM = @EmployeeID and Deleted = 0
					) as b on a.Section = b.Section
					left join (
						SELECT ERID, [Resource]
						FROM [stng].[VV_ER_Resource]
						where resource = @EmployeeID and [ResourceTypeC] = 'Alternate Assessor'
					) as c on a.ERID = c.ERID
					order by ER asc;

				end

			else
				begin

					select a.*
					,case when @isAdmin = 1 or b.SM is not null or c.[Resource] is not null then 1 else 0 end as IsSM
					from stng.VV_ER_Main as a
					left join (
						select Section, SM
						from stng.ER_SectionManager
						where SM = @EmployeeID and Deleted = 0
					) as b on a.Section = b.Section
					left join (
						SELECT ERID, [Resource]
						FROM [stng].[VV_ER_Resource]
						where [Resource] = @EmployeeID and [ResourceTypeC] = 'Alternate Assessor'
					) as c on a.ERID = c.ERID
					where CurrentStatusShort not in ('COM', 'CAN')
					order by ER asc;

				end


		end

	--Status Log
	else if @Operation = 2
		begin

			select *
			from stng.VV_ER_StatusLog
			where ERID = @ERID
			order by StatusDate desc
			option(optimize for (@ERID unknown));

		end

	--Deliverables
	else if @Operation = 3
		begin

			select *
			from stng.VV_ER_Deliverable
			where ERID = @ERID
			order by DelName asc
			option(optimize for (@ERID unknown));

		end

	--Delete Deliverable
	else if @Operation = 4
		begin

			--if exists(select 1
			--	from stng.VV_ER_Main as a
			--	left join stng.ER_SectionManager as b on a.Section = b.Section
			--	where a.ERID = @UniqueID and SM = @EmployeeID and b.Deleted = 0
			--) or @isAdmin = 1
			--	begin
					update stng.ER_Deliverable
					set Deleted = 1,
					DeletedBy = @EmployeeID,
					DeletedOn = stng.GetBPTime(getdate())
					where UniqueID = @UniqueIDNum;

					select @UniqueID = ERID, @DeliverableID = DeliverableID, @VendorID = Vendor, @EstimatedHours = EstimatedHours
						,@InHouse = InHouse
					from stng.ER_Deliverable
					where UniqueID = @UniqueIDNum;


					-- Log the deliverable
						INSERT into [stng].[ER_DeliverableLog] (
							[ERID]
						  ,[DeliverableID]
						  ,[VendorID]
						  ,[Hours]
						  ,InHouse
						  ,[Status]
						  ,[RAD]
						  ,[RAB]
						)
						values
						(@UniqueID
						, @DeliverableID
						, @VendorID
						, @EstimatedHours
						,@InHouse
						,'Removed Deliverable'
						,  stng.GetBPTime(getdate())
						, @EmployeeID)
			--	end

			--else 
			--	begin
			--		select 'You must be the section manager for this ER to remove a deliverable' as ReturnMessage;
			--		return;
			--	end
			
			

		end

	--Get Comments
	else if @Operation = 5
		begin

			select *
			from stng.VV_ER_Comment
			where ERID = @ERID
			order by CommentDate desc
			option(optimize for (@ERID unknown));

		end

	--Get Risks
	else if @Operation = 6
		begin

			select *
			from stng.VV_ER_Risk
			where ERID = @ERID
			order by RiskDate desc
			option(optimize for (@ERID unknown));

		end

	--Get Supporting WO
	else if @Operation = 7
		begin

			select *
			from stng.VV_ER_WO
			where ERID = @ERID
			order by WONUM asc
			option(optimize for (@ERID unknown));

		end

	--Get prereqs
	else if @Operation = 8
		begin

			select *
			from stng.VV_ER_Prerequisite
			where ERID = @ERID
			order by Completed desc, Prerequisite asc
			option(optimize for (@ERID unknown));

		end

	--Get Field Change Log
	else if @Operation = 9
		begin

			select *
			from stng.VV_ER_FieldChangeLog 
			where ERID = @ERID
			order by ChangedOn desc
			option(optimize for (@ERID unknown));

		end

		--Linked P6 endpoint
	--else if @Operation = 10
	--	begin

	--		select *
	--		from stng.VV_ER_FieldChangeLog 
	--		where ERID = @ERID
	--		order by FieldName asc, ChangedOn desc
	--		option(optimize for (@ERID unknown));

	--	end

		--Add Comment
	else if @Operation = 11
		begin

			INSERT into [stng].[ER_Comment] (
				[ERID]
				,[Comment]
				,[RAB]
			)
			values 
			(@UniqueID, @Value1, @EmployeeID)

		end

		--Add Risk
	else if @Operation = 12
		begin

			INSERT into [stng].[ER_Risk] (
				[ERID]
				,[Risk]
				,[RAB]
			)
			values 
			(@UniqueID, @Value1, @EmployeeID)

		end

		--Remove Comment
	else if @Operation = 13
		begin
			if(exists(
				select 1
				from [stng].[ER_Comment]
				where UniqueID = @UniqueIDNum and RAB = @EmployeeID
			))
				begin
					UPDATE [stng].[ER_Comment] set
					[Deleted] = 1
					,[DeletedOn] = stng.GetBPTime(getdate())
					,[DeletedBy] = @EmployeeID
					where UniqueID = @UniqueIDNum
				end
			else
				begin
					select 'You cant remove another users comment' as ReturnMessage;
					return
				end
			

		end

		--Remove Risk
	else if @Operation = 14
		begin

			UPDATE [stng].[ER_Risk] set
			[Deleted] = 1
			,[DeletedOn] = stng.GetBPTime(getdate())
			,[DeletedBy] = @EmployeeID
			where UniqueID = @UniqueIDNum

		end
	--save data
	else if @Operation = 15
		begin
			declare @PrevSection varchar(20);
			declare @PrevTCD date;
			declare @PrevSecString varchar(200);
			declare @SecString varchar(200);
			declare @PrevDueDate date;

			declare @PrevReason varchar(40);
			declare @PrevReasonString varchar(500);
			declare @ReasonString varchar(500);
			
			declare @PrevScheduleBuilt bit;
			declare @PrevAtRisk bit;
			declare @PrevProject varchar(100);

			declare @PrevOverridecheck bit;

			select @PrevReason = Reason, @PrevSection = section, @PrevScheduleBuilt = ScheduleBuilt, @PrevAtRisk = AtRisk, @PrevProject = ProjectID, @PrevTCD = ERTCD
			, @PrevDueDate = ERDueDateActual, @PrevOverridecheck = [OverrideERDueDateCheck]
			from  [stng].VV_ER_Main
			where ERID = @UniqueID 

			if ( @Reason <> @PrevReason or (@PrevReason is null and @Reason is not null) or (@Reason is null and @PrevReason is not null))
				begin

					select @PrevReasonString = Reason 
					from [stng].[ER_Reason]
					where uniqueID = @PrevReason

					select @ReasonString = Reason 
					from [stng].[ER_Reason]
					where uniqueID = @Reason

					Insert into 
					[stng].[ER_FieldChangeLog]
					([ERID]
					  ,[FieldName]
					  ,[ChangedFromStr]
					  ,[ChangedToStr]
					  ,RAD
					  ,RAB)
					values
					(@UniqueID, 'Reason for ER', @PrevReasonString, @ReasonString, stng.GetBPTime(getdate()), @EmployeeID)

					
					UPDATE [stng].[ER_Main] set
					Reason = @Reason
					where UniqueID = @UniqueID
				end


			if ( @Section <> @PrevSection or (@PrevSection is null and @Section is not null) or (@PrevSection is not null and @Section is null))
				begin

					select @PrevSecString = Section 
					from [stng].ER_Section
					where uniqueID = @PrevSection

					select @SecString = Section 
					from [stng].ER_Section
					where uniqueID = @Section

					Insert into 
					[stng].[ER_FieldChangeLog]
					([ERID]
					  ,[FieldName]
					  ,[ChangedFromStr]
					  ,[ChangedToStr]
					  ,RAD
					  ,RAB)
					values
					(@UniqueID, 'Section', @PrevSecString, @SecString, stng.GetBPTime(getdate()), @EmployeeID)

					UPDATE [stng].[ER_Main] set
					Section = @Section
					where UniqueID = @UniqueID
				end

			if ( @ScheduleBuilt <> @PrevScheduleBuilt or (@PrevScheduleBuilt is null and @ScheduleBuilt is not null))
				begin

					Insert into 
					[stng].[ER_FieldChangeLog]
					([ERID]
					  ,[FieldName]
					  ,[ChangedFromStr]
					  ,[ChangedToStr]
					  ,RAD
					  ,RAB)
					values
					(@UniqueID, 'Schedule Built'
					,case 
						when @PrevScheduleBuilt = 1 then 'Yes'
						else 'No'
					end
					,case 
						when @ScheduleBuilt = 1 then 'Yes'
						else 'No'
					end
					, stng.GetBPTime(getdate())
					, @EmployeeID)

					UPDATE [stng].[ER_Main] set
					ScheduleBuilt = @ScheduleBuilt
					where UniqueID = @UniqueID
				end

			if ( @AtRisk <> @PrevAtRisk or (@PrevAtRisk is null and @AtRisk is not null))
				begin

					Insert into 
					[stng].[ER_FieldChangeLog]
					([ERID]
					  ,[FieldName]
					  ,[ChangedFromStr]
					  ,[ChangedToStr]
					  ,RAD
					  ,RAB)
					values
					(@UniqueID, 'At Risk'
					,case 
						when @PrevAtRisk = 1 then 'Yes'
						else 'No'
					end
					,case 
						when @AtRisk = 1 then 'Yes'
						else 'No'
					end
					, stng.GetBPTime(getdate())
					, @EmployeeID)

					UPDATE [stng].[ER_Main] set
					AtRisk = @AtRisk
					where UniqueID = @UniqueID
				end

			if ( @ProjectID <> @PrevProject or (@PrevProject is null and @ProjectID is not null) or (@ProjectID is null and @PrevProject is not null))
				begin

					Insert into 
					[stng].[ER_FieldChangeLog]
					([ERID]
					  ,[FieldName]
					  ,[ChangedFromStr]
					  ,[ChangedToStr]
					  ,RAD
					  ,RAB)
					values
					(@UniqueID, 'Project', @PrevProject, @ProjectID, stng.GetBPTime(getdate()), @EmployeeID)

					UPDATE [stng].[ER_Main] set
					ProjectID = @ProjectID
					where UniqueID = @UniqueID
				end

			if ( @ERTCD <> @PrevTCD or (@PrevTCD is null and @ERTCD is not null) or (@ERTCD is null and @PrevTCD is not null))
				begin

					--if exists(select 1
					--	from stng.VV_ER_Main as a
					--	left join stng.ER_SectionManager as b on a.Section = b.Section
					--	where a.ERID = @UniqueID and SM = @EmployeeID and b.Deleted = 0
					--) or @isAdmin = 1
					--	begin
							
							Insert into 
							[stng].[ER_FieldChangeLog]
							([ERID]
							  ,[FieldName]
							  ,[ChangedFromStr]
							  ,[ChangedToStr]
							  ,RAD
							  ,RAB)
							values
							(@UniqueID
							, 'ER TCD'
							, convert(varchar, @PrevTCD, 106) 
							, convert(varchar, @ERTCD, 106)
							, stng.GetBPTime(getdate())
							, @EmployeeID)

							UPDATE [stng].[ER_Main] set
							ERTCD = @ERTCD
							where UniqueID = @UniqueID
						--end

					
					--else 
					--	begin
					--		select 'You must be the section manager to change the ER TCD' as ReturnMessage;
					--		return;
					--	end

				end

			if ( @OverrideERDueDateCheck <> @PrevOverridecheck or (@PrevOverridecheck is null and @OverrideERDueDateCheck is not null))
				begin

					Insert into 
					[stng].[ER_FieldChangeLog]
					([ERID]
					  ,[FieldName]
					  ,[ChangedFromStr]
					  ,[ChangedToStr]
					  ,RAD
					  ,RAB)
					values
					(@UniqueID, 'ER Milestone Due Date Override'
					,case 
						when @PrevOverridecheck = 1 then 'Yes'
						else 'No'
					end
					,case 
						when @OverrideERDueDateCheck = 1 then 'Yes'
						else 'No'
					end
					, stng.GetBPTime(getdate())
					, @EmployeeID)

					UPDATE [stng].[ER_Main] set
					[OverrideERDueDateCheck] = @OverrideERDueDateCheck
					where UniqueID = @UniqueID
				end

			
				if ( @OverrideERDueDateCheck = 1 
						and (cast(@ERDueDateOverride as date) <> cast(@PrevDueDate as date) or (cast(@PrevDueDate as date) is null and cast(@ERDueDateOverride as date) is not null) or (cast(@ERDueDateOverride as date) is null and cast(@PrevDueDate as date) is not null))
				or ((@OverrideERDueDateCheck = 0 or @OverrideERDueDateCheck is null) and (cast(@ERDueDate as date) <> cast(@PrevDueDate as date) or (cast(@PrevDueDate as date) is null and cast(@ERDueDate as date) is not null) or (cast(@ERDueDateOverride as date) is null and cast(@PrevDueDate as date) is not null)))
				)
					begin

						if exists(select 1
							from stng.VV_ER_Main as a
							left join stng.ER_SectionManager as b on a.Section = b.Section
							where a.ERID = @UniqueID and SM = @EmployeeID and b.Deleted = 0
						) or @isAdmin = 1
							begin
							
								Insert into 
								[stng].[ER_FieldChangeLog]
								([ERID]
									,[FieldName]
									,[ChangedFromStr]
									,[ChangedToStr]
									,RAD
									,RAB)
								values
								(@UniqueID
								, 'ER Milestone Due Date'
								, convert(varchar, @PrevDueDate, 106) 
								, convert(varchar, case when @OverrideERDueDateCheck = 1 then @ERDueDateOverride else @ERDueDate end, 106)
								, stng.GetBPTime(getdate())
								, @EmployeeID)

								if @OverrideERDueDateCheck = 1
									begin
										UPDATE [stng].[ER_Main] set
										ERDueDateOverride = @ERDueDateOverride
										where UniqueID = @UniqueID
									end
							
							end

					
						else 
							begin
								select 'You must be the section manager to change the ER Milestone Due Date' as ReturnMessage;
								return;
							end

					end

		end

	else if @Operation = 16 --Update Assessment
			begin
				if @SubOp = 1 --Check Assessment
					begin
						SELECT DISTINCT Assessment
						FROM [stng].[ER_Assessment_Map]
						WHERE [ERID] = @UniqueID and [Assessment] = @Assessment
					end

				else if @SubOp = 2 --Add Assessment to record
					begin

						INSERT INTO [stng].[ER_Assessment_Map]
						([ERID], [Assessment], [RAB])
						values
						(@UniqueID, @Assessment, @EmployeeID)

					end 

				else if @SubOp = 3 --Delete Assessment to record
					begin

						DELETE FROM [stng].[ER_Assessment_Map]
						WHERE [ERID] = @UniqueID and [Assessment] = @Assessment

					end 

			end 

		else if @Operation = 17 --Get Assessment Admin
			begin

				SELECT UniqueID, Assessment
				FROM stng.ER_Assessment
				where Deleted = 0

			end 
		
		else if @Operation = 18 --Add Assessment Admin
			begin

				INSERT INTO stng.ER_Assessment
				([Assessment], RAB)
				values
				(@Assessment, @EmployeeID)

			end 

		else if @Operation = 19 --Remove Assessment Admin
			begin

				UPDATE stng.ER_Assessment 
				set
				Deleted = 1,
				DeletedBy = @EmployeeID,
				DeletedOn = stng.GetBPTime(getdate())
				WHERE UniqueID = @UniqueID

			end 

		else if @Operation = 20 --Get record Assessment
			begin

				SELECT a.*
				FROM [stng].[ER_Assessment_Map] as a
				inner join [stng].[ER_Assessment] as b on a.Assessment = b.UniqueID and b.Deleted = 0
				WHERE ERID = @UniqueID

			end 

		else if @Operation = 21 --Get Prereq Admin
			begin

				SELECT UniqueID, PrerequisiteType as [Prerequisite]
				FROM [stng].[ER_Prerequisite_Type]
				where Deleted = 0

			end 
		
		else if @Operation = 22 --Add Prereq Admin
			begin

				INSERT INTO [stng].[ER_Prerequisite_Type]
				([PrerequisiteType], [RAB])
				values
				(@Prerequisite, @EmployeeID)

			end 

		else if @Operation = 23 --Remove Prereq Admin
			begin

				UPDATE [stng].[ER_Prerequisite_Type]
				set
				Deleted = 1,
				DeletedBy = @EmployeeID,
				DeletedOn = stng.GetBPTime(getdate())
				WHERE UniqueID = @UniqueID

			end 

		else if @Operation = 24 --Get Prereq Assessment
			begin

				SELECT *
				FROM [stng].[ER_Prerequisite]
				WHERE ERID = @UniqueID

			end 

			--Add Deliverable
		else if @Operation = 25
			begin

				--if exists(select 1
				--		from stng.VV_ER_Main as a
				--		left join stng.ER_SectionManager as b on a.Section = b.Section
				--		where a.ERID = @UniqueID and SM = @EmployeeID and b.Deleted = 0
				--	) or @isAdmin = 1
				--		begin
							if @InHouse = 1
								begin
									set @VendorID = NULL
								end

							select @EstimatedHours = [StandardHours]
							from [stng].[VV_ER_StandardDeliverable]
							where [UniqueID] = @DeliverableID 
								and ActivityType = case when @InHouse = 1 then 'Internal' else 'External' end


							INSERT into [stng].[ER_Deliverable] (
								[ERID]
								,[DeliverableID]
								,[Vendor]
								,[RAB]
								,[EstimatedHours]
								,InHouse
								,[LUB]
							)
							values
							(  
							@UniqueID, @DeliverableID, @VendorID, @EmployeeID, @EstimatedHours, @InHouse, @EmployeeID)
				
				
							-- Log the deliverable
							INSERT into [stng].[ER_DeliverableLog] (
								[ERID]
							  ,[DeliverableID]
							  ,[VendorID]
							  ,[Hours]
							  ,InHouse
							  ,[Status]
							  ,[RAD]
							  ,[RAB]
							)
							values
							(@UniqueID
							, @DeliverableID
							, @VendorID
							, @EstimatedHours
							,@InHouse
							,'Added Deliverable'
							,  stng.GetBPTime(getdate())
							, @EmployeeID)

				--		end

				--else 
				--	begin
				--		select 'You must be the section manager to add a deliverable' as ReturnMessage;
				--		return;
				--	end

			end

		--Standard Deliverables
		else if @Operation = 26
			begin

				select Deliverable, UniqueID as DeliverableID, ActivityType
				from stng.VV_ER_StandardDeliverable
				where Active = 1
				order by Deliverable asc;

			end

		--Vendors
		else if @Operation = 27
			begin

				--select a.UniqueID, a.Attribute as VendorName
				--from stng.Admin_Attribute as a
				--inner join stng.Admin_AttributeType as b on a.AttributeType = b.UniqueID
				--where b.AttributeType = 'Vendor'
				--order by VendorName asc;

				select
				[Attribute] as VendorName
				, [AttributeID] as UniqueID
				from [stng].[VV_Admin_AllVendors]
				order by [Attribute] asc;

			end

			--Add Resource
		else if @Operation = 28
			begin

				--if exists(select 1
				--		from stng.VV_ER_Main as a
				--		left join stng.ER_SectionManager as b on a.Section = b.Section
				--		where a.ERID = @UniqueID and SM = @EmployeeID and b.Deleted = 0
				--	) or @isAdmin = 1
				--		begin

							if exists(
								SELECT 1 
								FROM [stng].[ER_Resource]
								where ERID = @UniqueID and ResourceType = @ResourceType and Deleted = 0
							)
								begin
									select 'A user for this resource type already exists' as ReturnMessage;
									return;
								end
							else
								begin
									INSERT into [stng].[ER_Resource] (
										[ERID]
										,[Resource]
										,[ResourceType]
										,[RAB]
									)
									values
									(@UniqueID, @Resource, @ResourceType, @EmployeeID)

									-- Log the resource
									INSERT into [stng].[ER_ResourceLog] (
										[ERID]
									  ,[ResourceID]
									  ,[ResourceType]
									  ,[Status]
									  ,[RAD]
									  ,[RAB]
									)
									values
									(@UniqueID, @Resource, @ResourceType, 'Added Resource', stng.GetBPTime(getdate()), @EmployeeID)

								end
							
					--	end
					--else
					--	begin
					--		select 'You must be the section manager to add a resource' as ReturnMessage;
					--		return;
					--	end

			end

		--Delete Resource
		else if @Operation = 29
			begin

				--if exists(select 1
				--		from stng.VV_ER_Main as a
				--		left join stng.ER_SectionManager as b on a.Section = b.Section
				--		where a.ERID = @UniqueID and SM = @EmployeeID and b.Deleted = 0
				--	) or @isAdmin = 1
				--		begin
			
							update [stng].[ER_Resource]
							set Deleted = 1,
							DeletedBy = @EmployeeID,
							DeletedOn = stng.GetBPTime(getdate())
							where UniqueID = @UniqueIDNum;

							Select @UniqueID = ERID, @Resource = [Resource], @ResourceType = ResourceType
							FROM [stng].[ER_Resource]
							where UniqueID = @UniqueIDNum;

							INSERT into [stng].[ER_ResourceLog] (
								[ERID]
							  ,[ResourceID]
							  ,[ResourceType]
							  ,[Status]
							  ,[RAD]
							  ,[RAB]
							)
							values
							(@UniqueID, @Resource, @ResourceType, 'Removed Resource', stng.GetBPTime(getdate()), @EmployeeID)
					--	end
					--else
					--	begin 
					--		select 'You must be the section manager to remove a resource' as ReturnMessage;
					--		return;
					--	end
			end

		--Resources in ER
		else if @Operation = 30
			begin

				select [UniqueID]
					  ,[ERID]
					  ,[Resource]
					  ,[ResourceC]
					  ,[ResourceType]
					  ,[ResourceTypeC]
					  ,[RAB]
					  ,[RAD]
				from [stng].[VV_ER_Resource]
				where ERID = @ERID 
				option(optimize for (@ERID unknown));

			end

		--Section Managers
		else if @Operation = 31
			begin

				SELECT distinct Section as PrimaryDiscipline, UniqueID, SMName, SMID, DED, ProjectRequired
				FROM [stng].[VV_ER_SectionManger]
				order by PrimaryDiscipline asc

			end

		--Workflow
		else if @Operation = 32
			begin

				if @StatusShort is null or @UniqueID is null
				begin

					select 'StatusShort and/or UniqueID is required' as ReturnMessage;
					return;

				end 

			--Get WorkingStatus
			select @WorkingStatus = UniqueID
			from stng.ER_Status
			where StatusShort = @StatusShort;

			if @WorkingStatus is null
				begin

					select concat(@StatusShort, ' is not a valid shortform status') as ReturnMessage;
					return;

				end

			declare @PriorStatus varchar(10) = null
			declare @StatusC varchar(50) = null

			select @PriorStatus = CurrentStatusShort, @Section = Section, @ERTCD = ERTCD, @ERID = ER
			from stng.VV_ER_Main
			where ERID = @UniqueID

			select @StatusC = [Status]
			from stng.ER_Status
			where StatusShort = @StatusShort

			if @StatusShort = 'AA' and @PriorStatus not in ('ASA', 'EXE')
				begin
							
					select concat('You cannot change the status to ', @StatusC, ' from the current status') as ReturnMessage;
					return
			
				end
			else if @StatusShort = 'ASA' and @PriorStatus not in ('AA', 'EXE', 'PREFI', 'PRESD', 'PRESP', 'PREOC', 'TDS')
				begin
							
					select concat('You cannot change the status to ', @StatusC, ' from the current status') as ReturnMessage;
					return
			
				end
			else if @StatusShort = 'TDS' and @PriorStatus not in ('ASA')
				begin
							
					select concat('You cannot change the status to ', @StatusC, ' from the current status') as ReturnMessage;
					return
			
				end
			else if @StatusShort = 'PREFI' and @PriorStatus not in ('ASA')
				begin
							
					select concat('You cannot change the status to ', @StatusC, ' from the current status') as ReturnMessage;
					return
			
				end
			else if @StatusShort = 'PRESD' and @PriorStatus not in ('ASA')
				begin
							
					select concat('You cannot change the status to ', @StatusC, ' from the current status') as ReturnMessage;
					return
			
				end
			else if @StatusShort = 'PRESP' and @PriorStatus not in ('ASA')
				begin
							
					select concat('You cannot change the status to ', @StatusC, ' from the current status') as ReturnMessage;
					return
			
				end
			else if @StatusShort = 'PREOC' and @PriorStatus not in ('ASA')
				begin
							
					select concat('You cannot change the status to ', @StatusC, ' from the current status') as ReturnMessage;
					return
			
				end
			else if @StatusShort = 'EXE' and @PriorStatus not in ('ASA')
				begin
							
					select concat('You cannot change the status to ', @StatusC, ' from the current status') as ReturnMessage;
					return
			
				end
				
			else --begin checks for relevant status'
				if @Section is null and @StatusShort not in ('AA')
					begin 
						select 'Section field required' as ReturnMessage;
						return
					end

				if @PriorStatus = 'AA' and @StatusShort in ('ASA')
					begin
						with outagedates as
								(
									select x.*,  DATEADD(month,-6,x.OutageStartDate) as PO06, DATEADD(month,-1,x.OutageStartDate) as PO01
									from
									(
										select BPOUTAGECODE as Outage, case when BPACTUALSTARTDATE is null then BPSTARTDATE else BPACTUALSTARTDATE end as OutageStartDate
										from stngetl.General_Outage
									) as x
								)

								insert into stng.ER_SMDueDate
								(ERID, SMDueDate, RAD, RAB)	
								select x.ERID,
								cast(DATEADD(d,x.SMDueDateDays, GETDATE()) as date) as SMDueDate,
								x.RAD, x.RAB
								from 
								(
									select a.ERID, 
									case when a.InventoryWO = 1 then 20 
									when a.EmergentBacklog = 'H' and a.WOPriority = 2 then 2
									when a.EmergentBacklog = 'H' and a.WOPriority not in (1,2) then 5
									when a.Outage is not null then 
										case when cast(getdate() as date) < c.MilestoneTCD then 14
											when cast(getdate() as date) >= c.MilestoneTCD and cast(getdate() as date) < d.PO06 then 14
											when cast(getdate() as date) >= d.PO06 and cast(getdate() as date) < d.PO01 then 7
											when cast(getdate() as date) >= d.PO01 and cast(getdate() as date) < d.OutageStartDate then 2
										end 
									when a.OnlineReporting = 1 then
										case when a.TweekCalc > 36 then 28
											when a.TweekCalc <= 36 and a.TweekCalc >= 18 then 14
											when a.TweekCalc <= 17 and a.TweekCalc >= 14 then 7
											when a.TweekCalc < 14 then 3
										end
									end as SMDueDateDays,
									stng.GETDATE() as RAD,
									'SYSTEM' as RAB
									from stng.VV_ER_Main as a
									left join stngetl.ER_OutageMilestones as c on a.Outage = c.outage and c.outagemilestone = '16'
									left join outagedates as d on a.Outage = d.Outage
									where a.ERID = @UniqueID
								) x 
								where x.SMDueDateDays is not null
					end

				if @PriorStatus = 'ASA' and @StatusShort in ('EXE', 'TDS')
					begin
						
						if @ERTCD is null
							begin 
								select 'ER TCD field required' as ReturnMessage;
								return
							end

						if (
								select count(uniqueid)
								from stng.VV_ER_Resource
								where ERID = @UniqueID 
							) = 0
							begin

								select 'At least one Resource is required to progress' as ReturnMessage;
								return

							end

						if (
								select count(uniqueid) as DelivCount
								from stng.VV_ER_Deliverable
								where ERID = @UniqueID
							) = 0

							begin

								select concat('At least one deliverable is required to progress to ', @StatusC) as ReturnMessage;
								return

							end

						if @StatusShort = 'EXE' and @PriorStatus = 'ASA'
							begin
								-- If moving to execution, and there are only in house deliverables then it can proceed, but if there
								-- are vendor deliverables then checks need to be done before status change. If there are vendor
								-- deliverables, before execution, they need to go through the tds process. A check needs to be done to
								-- see if all vendor deliverables have a related instance in the TOQLite module. If not, ER needs to 
								-- be submitted for TDS. In this case any outstanding vendor instances will be created in the TOQLite module
								-- A check also needs to be done to see if all vendor instances in the TOQLite module are either
								-- approved or canceled.
								if exists(
										select 1
										from stng.VV_ER_Deliverable
										where ERID = @UniqueID and InHouse = 0
									) 

									begin
										if exists(
													select 1
												from stng.ER_Main as a
												inner join stng.VV_ER_Deliverable as b on a.UniqueID = b.ERID and b.inhouse = 0
												left join stng.VV_TOQLite_Main as c on b.Vendor= c.VendorID and a.UniqueID = c.ERID
												where a.UniqueID = @UniqueID and c.Vendor is NULL
											) 
									
											begin
												select 'This ER has deliverables that need to be submitted to the TOQLite module for Vendor bids, please Create TDS for Vendor(s)' as ReturnMessage;
												return
											end
										else if exists (
												select 1
												from stng.[VV_TOQLite_Main]
												where ER = @ERID and currentstatusshort not in ('AA', 'C')
											) 

											begin
												select 'TDS instances for this ER have outstanding records that arent Approved and Awarded or Canceled in the TOQLite module' as ReturnMessage;
												return
											end

								
									end
							end

						-- Moving from Awaiting SM Assessment to TDS 
						if @StatusShort = 'TDS' and @PriorStatus = 'ASA'
							begin
								-- Need a vendor type deliverable (not in house) to proceed to TDS
								if (
										select count(uniqueid) as DelivCount
										from stng.VV_ER_Deliverable
										where ERID = @UniqueID and InHouse = 0 and Vendor is not null
									) = 0
									begin
										select 'Vendor deliverable required to create a TDS' as ReturnMessage;
										return
									end

								-- Need to check if the vendors that are assossiated with the deliverables already have a
								-- TDS records in the TOQLite module. There can be TDS records already created in the TOQLite module,
								-- there just needs to be a NEW vendor to proceed. To summarize, check to see if the same vendors 
								-- are in the ER module (deliverables) and the TOQLite module (main records), if not, throw error
								-- Edge case might be that if there is a need to add an additional deliverable for an already created vendor
								-- that has been approved in toqlite (update: going to be handled by the revision logic in the toqlite module)
								if (
									select count(b.Vendor)
									from stng.ER_Main as a
									inner join stng.VV_ER_Deliverable as b on a.UniqueID = b.ERID and b.inhouse = 0
									left join stng.VV_TOQLite_Main as c on b.Vendor = c.VendorID and c.ERID = b.ERID 
									where a.UniqueID = @UniqueID and c.Vendor is NULL
									) = 0
									begin
										select 'All Vendors have an instance created in the TOQLite module' as ReturnMessage;
										return
									end
							end

						if @PriorStatus = 'TDS' and @StatusShort in ('ASA')
							begin

								if exists (
									select 1
									from stng.[VV_TOQLite_Main]
									where ER = @ERID and currentstatusshort not in ('AA', 'C')
								) 

								begin
									select 'TDS instances for this ER have outstanding records that arent Approved and Awarded or Canceled in the TOQLite module' as ReturnMessage;
									return
								end
							
							end

					end

				
				update stng.ER_Main
				set CurrentStatus = @WorkingStatus,
				LUD = stng.GetBPTime(getdate()),
				LUB = @EmployeeID
				where UniqueID = @UniqueID;

				insert into stng.ER_StatusLog
				(ERID, StatusID, Comment, RAB)
				values
				(@UniqueID, @WorkingStatus,@Comment, @EmployeeID);

					
				select SCOPE_IDENTITY() as ReturnID, concat('Status changed to ',@StatusC) as SuccessMessage;

		end

			--Edit Deliverable
		else if @Operation = 33
			begin

				UPDATE [stng].[ER_Deliverable] 
				set
				[EstimatedHours] = @EstimatedHours
				,[InHouse] = @InHouse
				,[Vendor] = case when @InHouse = 1 then null else @VendorID end
				,[LUB] = @EmployeeID
				,[LUD] = stng.GetBPTime(getDate())
				where [UniqueID] = @UniqueIDNum

				select @UniqueID = ERID, @DeliverableID = DeliverableID
				FROM [stng].[ER_Deliverable] 
				where [UniqueID] = @UniqueIDNum

				-- Log the deliverable
				INSERT into [stng].[ER_DeliverableLog] (
					[ERID]
				  ,[DeliverableID]
				  ,[VendorID]
				  ,[Hours]
				  ,InHouse
				  ,[Status]
				  ,[RAD]
				  ,[RAB]
				)
				values
				(@UniqueID
				, @DeliverableID
				, case when @InHouse = 1 then null else @VendorID end
				, @EstimatedHours
				,@InHouse
				,'Updated Deliverable'
				,  stng.GetBPTime(getdate())
				, @EmployeeID)


			end

		else if @Operation = 34 --Create TOQLite
			begin
				if @SubOp = 1 --Get Vendors
					begin
						-- Only show vendors that havent been created in TOQLite yet
						select distinct b.Vendor
						from stng.ER_Main as a
						inner join stng.VV_ER_Deliverable as b on a.UniqueID = b.ERID and b.inhouse = 0
						left join stng.VV_TOQLite_Main as c on b.Vendor = c.VendorID and c.ERID = b.ERID 
						where a.UniqueID = @UniqueID and c.Vendor is NULL
					end

				-- There can only ever be one ER and Vendor relation in TOQLite 
				else if @SubOp = 2 --Create TOQLite
					begin

						declare @LatestRevision int;
						declare @Instance int;
						declare @TOQLiteID varchar(40);
						declare @Sec bigint;

						select @Instance = max(ERInstance)
						from stng.TOQLite_Main as a
						inner join stng.ER_Main as b on a.ERID = b.UniqueID and a.ERID = @ERID

						if @LatestRevision is null set @LatestRevision = 0;

						--Get I ID
						select @WorkingStatus = UniqueID
						from stng.TOQLite_Status
						where StatusShort = 'I';

						SELECT @Sec = UniqueID
						FROM [stng].[VV_ER_SectionManger] as a
						where Section is not null and a.UniqueID = (
							select section
							from stng.VV_ER_Main
							where ERID = @ERID
						) 

						SET @TOQLiteID = newid()

						--Insert new record
						insert into stng.TOQLite_Main
						([UniqueID], ERID, Revision, ERInstance, CurrentStatus, ProjectNo, Section, VendorID, RAB, LUB)
						select @TOQLiteID, ERID, @LatestRevision, case when @Instance is not null then @Instance + 1 else 0 end, @WorkingStatus, ProjectID, @Sec, @VendorID, 'SYSTEM', 'SYSTEM'
						from stng.VV_ER_Main
						where ERID = @ERID

						--Insert new status log record
						insert into stng.TOQLite_StatusLog
						(TOQLiteID, StatusID, Comment, RAB)
						values
						(@TOQLiteID, @WorkingStatus, N'Record Created', 'SYSTEM');

						--Insert Deliverables
						insert into stng.TOQLite_BPDeliverable
						(TOQLiteID, DeliverableID, DeliverableHours, RAB, LUB)
						select @TOQLiteID, b.DeliverableID, b.EstimatedHours, 'SYSTEM', 'SYSTEM'
						from stng.ER_Main as a
						inner join stng.VV_ER_Deliverable as b on a.UniqueID = b.ERID
						where b.Vendor = @VendorID and ERID = @ERID

					end 

			end 

		--Get resource types
		else if @Operation = 35
			begin

				select [UniqueID], [ResourceType]
				from [stng].[ER_Resource_Type]
				where Deleted = 0
				order by SortOrder asc

			end
		
		--Get Resource Log
		else if @Operation = 36
			begin

				select *
				from [stng].[VV_ER_ResourceLog] 
				where ERID = @ERID
				order by ChangedOn desc
				option(optimize for (@ERID unknown));

			end

		--Get Deliverable Log
		else if @Operation = 37
			begin

				Select *
				from [stng].[VV_ER_DeliverableLog]
				where ERID = @ERID
				order by ChangedOn desc
				option(optimize for (@ERID unknown));

			end

		--Get Online Report (Non-Merged)
		else if @Operation = 38
			begin

				Select *
				from stng.VV_ER_OnlineReport

			end

		--Section Logic
		else if @Operation = 39
			begin

				--Get Sections
				if @SubOp = 1
					begin

						SELECT distinct SECID, Section, DPID, Department, DED, ProjectRequired
						FROM [stng].[VV_ER_Section]
						order by Section

					end

				--Add Section
				else if @SubOp = 2
					begin

						INSERT INTO [stng].[ER_Section]
						(Section, DED, ProjectRequired, RAD, RAB)
						VALUES
						(@SectionName, @DED, @ProjectRequired, stng.GetBPTime(getdate()), @EmployeeID)
							

						INSERT INTO [stng].[ER_SectionToDepartment]
						(SECID, DPID, [RAD], [RAB])
						values
						(SCOPE_IDENTITY(), @Department, stng.GetBPTime(getdate()), @EmployeeID)
						

					end

				--Edit Section
				else if @SubOp = 3
					begin

						UPDATE [stng].[ER_Section]
						SET 
						Section = @SectionName,
						DED = @DED,
						ProjectRequired = @ProjectRequired
						WHERE UniqueID = @UniqueIDNum

						if exists(
							SELECT 1
							FROM [stng].[ER_SectionToDepartment]
							where SECID = @UniqueIDNum
						)
							begin
								UPDATE [stng].[ER_SectionToDepartment]
								set 
								DPID = @Department
								where SECID = @UniqueIDNum
							end
						else 
							begin
								INSERT INTO [stng].[ER_SectionToDepartment]
								(SECID, DPID, RAB, RAD)
								VALUES
								(@UniqueIDNum, @Department, @EmployeeID, stng.GetBPTime(getdate()))
							end

					end

				--Remove Section
				else if @SubOp = 4
					begin

						UPDATE [stng].[ER_Section]
						SET 
						Deleted = 1,
						DeletedOn = stng.GetBPTime(getdate()),
						DeletedBy = @EmployeeID
						WHERE UniqueID = @UniqueIDNum

					end

				--Get Departments
				else if @SubOp = 5
					begin

						SELECT distinct  DPID, Department
						FROM [stng].[VV_ER_Section]
						order by Department

					end
				--Get Section list for sm manager tool
				else if @SubOp = 6
					begin

						if @isAdmin = 1
							begin
								SELECT distinct SECID, Section, DPID, Department, DED, ProjectRequired
								FROM [stng].[VV_ER_Section]
								order by Section
							end

						else
							begin
								SELECT distinct SECID, Section, DPID, Department, DED, ProjectRequired
								FROM [stng].[VV_ER_Section]
								where SMEmployeeID = @EmployeeID and [Primary] = 1
								order by Section
							end
					end

			end

		--Section Manager logic
		else if @Operation = 40
			begin

				--Get Section Managers
				if @SubOp = 1
					begin

						Select UniqueID, SMEmployeeID, SM, [Primary]
						from stng.VV_ER_Section
						where SECID = @Section and UniqueID is not null
						order by [Primary] desc

					end
					
				--Add Section Manager
				else if @SubOp = 2
					begin

						if @Primary = 1 and exists(
							SELECT 1
							FROM [stng].[ER_SectionManager]
							WHERE Section = @Section and [Primary] = 1 and Deleted = 0
						)
							begin
								select 'A Primary Section Manager already exists for this Section. Remove Primary SM before assigning another.' as ReturnMessage;
								return;
							end

						if exists(
							SELECT *
							FROM [stng].[ER_SectionManager]
							WHERE Section = @Section and SM = @Resource
						)
							begin
								UPDATE [stng].[ER_SectionManager]
								SET
								[Primary] = @Primary,
								Deleted = 0,
								DeletedOn = NULL,
								DeletedBy = @EmployeeID
								WHERE Section = @Section and SM = @Resource
							end

						else	
							begin
								INSERT INTO [stng].[ER_SectionManager]
								(Section, SM, [Primary], RAD, RAB)
								VALUES
								(@Section, @Resource, @Primary, stng.GetBPTime(getdate()), @EmployeeID)
							end

					end

				--Remove Section Manager
				else if @SubOp = 3
					begin

						UPDATE [stng].[ER_SectionManager]
						SET
						Deleted = 1,
						DeletedOn = stng.GetBPTime(getdate()),
						DeletedBy = @EmployeeID
						WHERE Section = @Section and SM = @Resource
					end

			end

		--Edit Comment
		else if @Operation = 41
			begin
				if(exists(
					select 1
					from [stng].[ER_Comment]
					where UniqueID = @UniqueIDNum and RAB = @EmployeeID
				))
					begin
						UPDATE [stng].[ER_Comment] set
						Comment = @Value1
						where UniqueID = @UniqueIDNum
					end
				else
					begin
						select 'You cant edit another users comment' as ReturnMessage;
						return
					end
			end


		else if @Operation = 42 --Get All Project
			begin

				SELECT distinct PROJECTID as UniqueID, PROJECTID as Project
				FROM stng.MPL

			end 

		
		else if @Operation = 43 --Reason
			begin

				if @SubOp = 1 --Get All Reason
					begin

						SELECT UniqueID, [Reason]
						FROM stng.ER_Reason
						where Deleted = 0

					end 
		
				else if @SubOp = 2 --Add Reason Admin
					begin

						if exists(
							select UniqueID
							from stng.ER_Reason
							where [Reason] = @AdminOptionText and Deleted = 1
						)
							begin
								UPDATE stng.ER_Reason
								set 
								Deleted = 0,
								DeletedBy = null,
								DeletedOn = null
							end

						else 
							begin

								INSERT INTO stng.ER_Reason
								([Reason], RAB)
								values
								(@AdminOptionText, @EmployeeID)

							end

					end 

				else if @SubOp = 3 --Remove Reason Admin
					begin

						UPDATE stng.ER_Reason
						set
						Deleted = 1,
						DeletedBy = @EmployeeID,
						DeletedOn = stng.GetBPTime(getdate())
						WHERE UniqueID = @UniqueID

					end 

			end 

		else if @Operation = 44 --Email
			begin

				if @SubOp = 1 --Get To Emails
					begin

						SELECT distinct b.Email
						FROM stng.[VV_ER_Resource] as a
						inner join stng.[VV_Common_UserEmail] as b on a.[Resource] = b.[User] and EmailName = 'ResouceInExecution'
						where a.ERID = @Value2
						option(optimize for (@Value2 unknown));

					end 
		
				else if @SubOp = 2 --Get Data
					begin

						SELECT *
						from stng.[VV_ER_Main]
						where ERID = @Value2
						option(optimize for (@Value2 unknown));

					end 

				else if @SubOp = 3 --Get Email Template
					begin

						SELECT [Name], [Subject], Body
						FROM [stng].[Common_EmailTemplate]
						where [Name] = 'ResouceInExecution'

					end 

				else if @SubOp = 4 --Get Deliverables
					begin

						SELECT DelName, EstimatedHours, InHouse, VendorName
						from stng.[VV_ER_Deliverable]
						where ERID = @Value2
						option(optimize for (@Value2 unknown));

					end 

				if @SubOp = 5 --Get CC Emails
					begin

						SELECT distinct b.Email
						FROM stng.VV_ER_Main as a
						inner join stng.[VV_Common_UserEmail] as b on a.SMID = b.[User] and EmailName = 'SMInExecution'
						where a.ERID = @Value2
						option(optimize for (@Value2 unknown));

					end 
				
				if @SubOp = 6 --Get Resources
					begin

						select distinct 
						[ResourceC]
						,[ResourceTypeC]
						from [stng].[VV_ER_Resource]
						where ERID = @Value2 
						option(optimize for (@Value2 unknown));

					end 
			end 

		--P6 Report
		else if @Operation = 45
			begin
				with initialquery as
				(
					select distinct a.SiteID as Facility, a.ER as [ER No],
					cast(case when c.ERID is not null then 1 else 0 end as bit) as [New Work Initiated],
					cast(case when b.ERID is not null then 1 else 0 end as bit) as [ER TCD Changed],
					cast(case when d.ERID is not null then 1 else 0 end as bit) as [Assigned Individual Changed],
					a.ERType as [ER Type], a.ERTitle as [ER Desc.], a.Tweek, a.CurrentStatus as [Workflow Status],
					a.AssignedIndividual as [Assigned Individual], a.Verifier as Verifier, a.SMName as SM,
					case when a.inhouse = 'Yes' then 'Bruce Power'
					else a.Vendors 
					end 
					as Vendor, a.ProjectID,
					a.InHouse, a.minexecdate as [Min. Exec Date], a.maximotcd as [Maximo TCD], 
					a.ERTCD as [ER TCD], a.EstimatedHours as [Estimated Hours] 
					from stng.VV_ER_Main as a
					left join 
					(
						select ERID
						from [stng].[VV_ER_FieldChangeLog]
						where cast(ChangedOn as date) >= @DateFrom and
						cast(ChangedOn as date) <= @DateTo and FieldName = 'ER TCD'
					) as b on a.ERID = b.ERID
					left join 
					(
						select ERID
						from [stng].[VV_ER_FieldChangeLog]
						where cast(ChangedOn as date) >= @DateFrom and
						cast(ChangedOn as date) <= @DateTo and FieldName = 'Schedule Built'
					) as c on a.ERID = c.ERID
					left join 
					(
						select ERID
						from [stng].[VV_ER_ResourceLog]
						where cast(ChangedOn as date) >= @DateFrom and
						cast(ChangedOn as date) <= @DateTo and ResourceType = 'Assigned Individual'
					) as d on a.ERID = d.ERID
				)

				select *
				from initialquery
				where [New Work Initiated] = 1 or [ER TCD Changed] = 1 or [Assigned Individual Changed] = 1

			end

		-- Get Weekly Metric Snapshot
		else if @Operation = 46
			begin

				if @SubOp = 1 -- Get Snapdates and metric types
					begin

						Select distinct snap_dt
						from stngetl.[ER_MetricSnapshot]
						where snap_dt is not null
						order by snap_dt desc

						Select distinct b.KPI_ID, b.KPI_NAME, b.DisplayName
						from stngetl.[ER_MetricSnapshot] as a
						inner join stng.ER_MetricsKPI as b on a.KPI_ID = b.KPI_ID
						where b.DisplayName is not null
						order by KPI_ID

						select *
						from stng.ER_MetricReason
						where Deleted = 0

					end 
		
				else if @SubOp = 2 --Get snapshot week data
					begin

						SELECT *
						from stngetl.[ER_MetricSnapshot]
						where KPI_ID = @KPI and cast(snap_dt as date) = cast(@DateFrom as date)
						order by MilestoneOwner, WMCriteria desc, SectionName, ER, WONUM
						option(optimize for (@KPI unknown, @DateFrom unknown));

					end 

				else if @SubOp = 3 --Edit snapshot
					begin

						Update stngetl.[ER_MetricSnapshot]
						set 
						Exception = @Exception,
						Comment = @Comment,
						Metricreason = @Reason
						where UniqueID = @UniqueIDNum

					end 

				else if @SubOp = 4 --Delete snapshot
					begin

						Update stngetl.[ER_MetricSnapshot]
						set 
						Deleted = 1,
						DeletedOn = stng.GetBPTime(getdate()),
						DeletedBy = @EmployeeID
						where UniqueID = @UniqueIDNum

					end 
				
			end

		else if @Operation = 47 --ER Export
			begin
				if @SubOp = 1 --Active ERs
					begin
						SELECT *
						FROM stng.[VV_ER_Export] as a
						WHERE [Workflow Status] not in ('Complete', 'Canceled')
					end

				else if @SubOp = 2 --All ERs
					begin

						SELECT *
						FROM stng.[VV_ER_Export] 

					end 

				else if @SubOp = 3 --Active ERs with comments
					begin

						SELECT a.*, c.Comments
						FROM stng.[VV_ER_Export] as a
						left join stng.ER_Main as b on a.ER = b.ER
						left join 
						(
							select x.ERID, string_agg(concat(concat('(',FORMAT(x.CommentDate,'MMM dd yyyy'),') (',x.Commenter,')'),char(13),char(10),x.Comment), concat(char(13),char(10),'---------',char(13),char(10))) within group (order by x.CommentDate desc) as Comments
							from stng.VV_ER_Comment as x
							group by x.ERID 					
						) as c on b.UniqueID = c.ERID
						WHERE [Workflow Status] not in ('Complete', 'Canceled')

					end 

				else if @SubOp = 4 --All ERs with comments
					begin

						SELECT a.*, c.Comments
						FROM stng.[VV_ER_Export] as a
						left join stng.ER_Main as b on a.ER = b.ER
						left join 
						(
							select x.ERID, string_agg(concat(concat('(',FORMAT(x.CommentDate,'MMM dd yyyy'),') (',x.Commenter,')'),char(13),char(10),x.Comment), concat(char(13),char(10),'---------',char(13),char(10))) within group (order by x.CommentDate desc) as Comments
							from stng.VV_ER_Comment as x
							group by x.ERID 					
						) as c on b.UniqueID = c.ERID

					end 

			end 

end