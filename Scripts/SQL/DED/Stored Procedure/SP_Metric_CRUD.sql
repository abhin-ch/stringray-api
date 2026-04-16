/****** Object:  StoredProcedure [stng].[SP_Metric_CRUD]    Script Date: 3/20/2026 2:35:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER procedure [stng].[SP_Metric_CRUD]
(
	@Operation int,
	@SubOp int = null,
	@CurrentUser varchar(20) = null,

	@UniqueID varchar(50) = null,
	@UUID uniqueIdentifier = null,
	@MetricIntID bigint = null,

	@MeasureCategory uniqueidentifier = null,
	@MeasureName AS varchar(300) = null,
	@Department AS varchar(300) = null,
	@Section AS varchar(100) = null,
	@Unit uniqueidentifier = null,
	@MonthlyTarget AS varchar(100) = null,
	@YTDTarget AS varchar(100) = null,
	@MonthlyVariance AS varchar(max) = null,
	@Frequency uniqueidentifier = null,
	@MeasureType uniqueidentifier = null,
	@KPICategorization uniqueidentifier = null,
	@ParentMeasure uniqueidentifier = null,
	@Period uniqueidentifier = null,
	@ActionStatus AS varchar(20) = null,
	@Deleted AS bit = null,
	@DeletedBy AS varchar(20) = null,
	@DeletedOn AS datetime = null,
	@Action AS varchar(MAX) = null,
	@Responsibility AS varchar(MAX) = null,
	@DueDate AS datetime = null,	
	@StatusID AS uniqueidentifier = null,
	@Objective AS varchar(MAX) = null,
	@Definition AS varchar(MAX) = null,
	@Driver AS varchar(20) = null,
	@RedCriteria AS varchar(20) = null,
	@WhiteCriteria AS varchar(20) = null,
	@GreenCriteria AS varchar(20) = null,
	@YellowCriteria AS varchar(20) = null,
	@DataSource AS varchar(20) = null,
	@RedRecoveryDate AS datetime = null,	
	@Type AS varchar(20) = null,
	@OwnershipType AS uniqueidentifier = null,
	@MetricOwner AS varchar(20) = null,
	@DataOwner  AS varchar(20) = null,
	@MetricID uniqueidentifier = null,
	@Operator1 AS uniqueidentifier = null,
	@Value1 AS varchar(100) = null,
	@Operator2 AS uniqueidentifier = null,
	@Value2 AS varchar(100) = null,
	@Criteria AS varchar(50) = null,
	@ReportingYear varchar(40) = null,
	@Decimal1 decimal(18,2) = null,
	@Decimal2 decimal(18,2) = null,
	@ActiveStatus uniqueidentifier = null,
	@Num1 AS int = null,
	@Date1 as DateTime = null,

	
	@Month AS int = null,
	@Year as int = null,
	@MonthYear as varchar(50) = null,
	
	@ActionsReviewID uniqueidentifier = null,
	@AdminOptionText varchar(1000) = null,
	@TargetVal decimal(10,2) = null,
	
	@StatusShort varchar(10) = null,
	@MyView bit = 1,

	@MultiSelectList stng.TYPE_MultiSelectList READONLY
)
as 
begin
	Declare @SQL NVARCHAR(MAX);
	Declare @OwnershipTypeC AS varchar(30) = null;
	Declare @UnitC AS varchar(30) = null;
	Declare @CurrentYear int;
	Declare @CurrentMonth int;
	Declare @hasViewAllPerm bit = 0;

	--Main query
	IF @Operation = 1
	BEGIN

		if exists(
			SELECT 1
		  FROM [stng].[VV_Admin_AllUserPermission]
		  where permission = 'MetricViewAll' and employeeid = @CurrentUser
		)
		begin
			set @hasViewAllPerm = 1
		end
		
		-- Extract Month and Year from @MonthYear
		set @Year = Left(@monthYear, CHARINDEX('-', @monthYear) - 1)
		set @Month = SUBSTRING(@monthYear, CHARINDEX('-', @monthYear) + 1, LEN(@monthYear))

		if exists(
			SELECT 1
		  FROM [stng].[VV_Admin_AllUserPermission]
		  where permission = 'MetricAdmin' and employeeid = @CurrentUser
		) and @MyView = 0
			begin
				SELECT *
				FROM stng.FN_Metric_Main_ReportingMonth(@Year, @Month, @CurrentUser)
				order by MeasureName
			end
		else if @hasViewAllPerm = 1 and @MyView = 0
			begin
				SELECT *
				FROM stng.FN_Metric_Main_ReportingMonth(@Year, @Month, @CurrentUser)
				where ActiveStatusC = 'New' or ActiveStatusC = 'Active'
				order by MeasureName
			end
		else
			begin
				SELECT *
				FROM stng.FN_Metric_Main_ReportingMonth(@Year, @Month, @CurrentUser)
				where (ActiveStatusC = 'New' or ActiveStatusC = 'Active')
				and (IsDataOwner = 1 or IsMetricOwner = 1)
				order by MeasureName
			end
		
	END
		
		else if @Operation = 2 --Add measure
			begin

				--Admin should only add measures
				declare @WorkingUUID uniqueidentifier = newid();

				set @Year = Year(getdate())
				set @Month = Month(getdate())

				if @Month - 1 = 0
					begin
						set @Month = 12
						set @Year = @Year - 1
					end
				else 
					begin
						set @Month = @Month - 1
					end

				select @StatusID = UniqueID
				from stng.Metric_Status
				where StatusShort = 'AI'

				INSERT INTO stng.Metric_Main
				(UniqueID, MeasureName, Unit, RAB, RAD, Deleted)
				values
				(@WorkingUUID, @MeasureName, @Unit, @CurrentUser, stng.GetBPTime(getdate()), 0);

				INSERT into stng.Metric_StatusLog
				(MetricID, [Year], [Month], [Status], RAB, RAD)
				values
				(@WorkingUUID,  @Year, @Month, @StatusID, @CurrentUser, stng.GetBPTime(getdate()))
				

				INSERT INTO stng.Metric_Criteria
						([MetricID]
						, [Criteria]
						, [LUD]
						, [LUB]
						, [RAD]
						, [RAB]
						, [Deleted])
				values
				(@WorkingUUID,'Red',stng.GetBPTime(getdate()),@CurrentUser,stng.GetBPTime(getdate()),@CurrentUser,0);

				INSERT INTO stng.Metric_Criteria
						([MetricID]
						, [Criteria]
						, [LUD]
						, [LUB]
						, [RAD]
						, [RAB]
						, [Deleted])
				values
				(@WorkingUUID,'White',stng.GetBPTime(getdate()),@CurrentUser,stng.GetBPTime(getdate()),@CurrentUser,0);

				INSERT INTO stng.Metric_Criteria
						([MetricID]
						, [Criteria]
						, [LUD]
						, [LUB]
						, [RAD]
						, [RAB]
						, [Deleted])
				values
				(@WorkingUUID,'Green',stng.GetBPTime(getdate()),@CurrentUser,stng.GetBPTime(getdate()),@CurrentUser,0);

				INSERT INTO stng.Metric_Criteria
						([MetricID]
						, [Criteria]
						, [LUD]
						, [LUB]
						, [RAD]
						, [RAB]
						, [Deleted])
				values
				(@WorkingUUID,'Yellow',stng.GetBPTime(getdate()),@CurrentUser,stng.GetBPTime(getdate()),@CurrentUser,0);

				INSERT INTO [stng].[Metric_Targets]
				([MetricID], [Year], [Month], RAD, RAB)
				SELECT @WorkingUUID, year(stng.GetBPTime(getdate())), [Month], stng.GetBPTime(getdate()), @CurrentUser
				FROM [stng].[Metric_Month]

				INSERT INTO [stng].[Metric_Actuals]
				([MetricID], [Year], [Month], RAD, RAB)
				SELECT @WorkingUUID,  year(stng.GetBPTime(getdate())), [Month], stng.GetBPTime(getdate()), @CurrentUser
				FROM [stng].[Metric_Month]

				SELECT @WorkingUUID as UniqueID
			end

		else if @Operation = 3 --Edit measure
			begin
			--admin should only edit measures
				UPDATE stng.Metric_Main SET
				[MeasureCategory] = @MeasureCategory,
				[MeasureName] = @MeasureName,
				[Department] = @Department,
				[Section] = @Section,
				[Unit] = @Unit,
				[MonthlyTarget] = @MonthlyTarget,
				[YTDTarget] = @YTDTarget,
				[Frequency] = @Frequency,
				[MeasureType] = @MeasureType,
				[KPICategorization] = @KPICategorization,
				ParentMeasure = @ParentMeasure,
				[Period] = @Period,
				[Objective] = @Objective,
				[Definition] = @Definition,
				[Driver] = @Driver,
				[DataSource] = @DataSource,
				[ActiveStatus] = @ActiveStatus
				WHERE [UniqueID] = @UniqueID
			end	


		else if @Operation = 4 --Remove Measure
			begin
				--only admin can do this
				update stng.Metric_Main
					set Deleted = 1,
					DeletedBy = @CurrentUser,
					DeletedOn = stng.GetBPTime(getdate())
					where [UniqueID] = @UniqueID

			end 

		
			-- MeasureCategory
		else if @Operation = 5 --Get All MeasureCategory
			begin

				SELECT UniqueID, MeasureCategory, Deleted
				FROM stng.Metric_MeasureCategory
				--where Deleted = 0

			end 
		
		else if @Operation = 6 --Add MeasureCategory Admin
			begin

				if exists(
					select UniqueID
					from stng.Metric_MeasureCategory
					where MeasureCategory = @AdminOptionText and Deleted = 1
				)
					begin
						UPDATE stng.Metric_MeasureCategory
						set 
						Deleted = 0,
						DeletedBy = null,
						DeletedOn = null
					end

				else 
					begin

						INSERT INTO stng.Metric_MeasureCategory
						(MeasureCategory, RAB)
						values
						(@AdminOptionText, @CurrentUser)

					end

			end 

		else if @Operation = 7 --Remove MeasureCategory Admin
			begin

				UPDATE stng.Metric_MeasureCategory
				set
				Deleted = 1,
				DeletedBy = @CurrentUser,
				DeletedOn = stng.GetBPTime(getdate())
				WHERE UniqueID = @UniqueID

			end 


			-- Frequency
		else if @Operation = 8 --Get All Frequency
			begin

				SELECT UniqueID, Frequency, Deleted
				FROM stng.Metric_Frequency
				--where Deleted = 0

			end 
		
		else if @Operation = 9 --Add Frequency Admin
			begin

				if exists(
					select UniqueID
					from stng.Metric_Frequency
					where Frequency = @AdminOptionText and Deleted = 1
				)
					begin
						UPDATE stng.Metric_Frequency
						set 
						Deleted = 0,
						DeletedBy = null,
						DeletedOn = null
					end

				else 
					begin

						INSERT INTO stng.Metric_Frequency
						(Frequency, RAB)
						values
						(@AdminOptionText, @CurrentUser)

					end

			end 

		else if @Operation = 10 --Remove Frequency Admin
			begin

				UPDATE stng.Metric_Frequency
				set
				Deleted = 1,
				DeletedBy = @CurrentUser,
				DeletedOn = stng.GetBPTime(getdate())
				WHERE UniqueID = @UniqueID

			end 

			-- MeasureType
		else if @Operation = 11 --Get All Measure Type
			begin

				SELECT UniqueID, MeasureType, Deleted
				FROM stng.Metric_MeasureType
				--where Deleted = 0

			end 
		
		else if @Operation = 12 --Add MeasureType Admin
			begin

				if exists(
					select UniqueID
					from stng.Metric_MeasureType
					where MeasureType = @AdminOptionText and Deleted = 1
				)
					begin
						UPDATE stng.Metric_MeasureType
						set 
						Deleted = 0,
						DeletedBy = null,
						DeletedOn = null
					end

				else 
					begin

						INSERT INTO stng.Metric_MeasureType
						(MeasureType, RAB)
						values
						(@AdminOptionText, @CurrentUser)

					end

			end 

		else if @Operation = 13 --Remove MeasureType Admin
			begin

				UPDATE stng.Metric_MeasureType
				set
				Deleted = 1,
				DeletedBy = @CurrentUser,
				DeletedOn = stng.GetBPTime(getdate())
				WHERE UniqueID = @UniqueID

			end 

				-- [KPICategorization]
		else if @Operation = 14 --Get All [KPICategorization]
			begin

				SELECT UniqueID, [KPICategorization] as MeasureLevel, Deleted
				FROM stng.[Metric_KPICategorization]
				--where Deleted = 0

			end 
		
		else if @Operation = 15 --Add Outcome Admin
			begin

				if exists(
					select UniqueID
					from stng.[Metric_KPICategorization]
					where [KPICategorization] = @AdminOptionText and Deleted = 1
				)
					begin
						UPDATE stng.[Metric_KPICategorization]
						set 
						Deleted = 0,
						DeletedBy = null,
						DeletedOn = null
					end

				else 
					begin

						INSERT INTO stng.[Metric_KPICategorization]
						([KPICategorization], RAB)
						values
						(@AdminOptionText, @CurrentUser)

					end

			end 

		else if @Operation = 16 --Remove Outcome Admin
			begin

				UPDATE stng.[Metric_KPICategorization]
				set
				Deleted = 1,
				DeletedBy = @CurrentUser,
				DeletedOn = stng.GetBPTime(getdate())
				WHERE UniqueID = @UniqueID

			end 

		else if @Operation = 17 --Get Unit Admin
			begin

				SELECT [UniqueID]
					  ,[Unit]
					  ,[Deleted]
				FROM [stng].[Metric_Unit]
				--where deleted = 0
				ORDER BY Unit ASC

			end 

			-- ActionStatus
		else if @Operation = 23 --Get All ActionStatus
			begin

				SELECT UniqueID, [ActionStatus]
				FROM stng.[Metric_ActionStatus]
				where Deleted = 0

			end 
		
		else if @Operation = 24 --Add ActionStatus Admin
			begin

				if exists(
					select UniqueID
					from stng.[Metric_ActionStatus]
					where [ActionStatus] = @AdminOptionText and Deleted = 1
				)
					begin
						UPDATE stng.[Metric_ActionStatus]
						set 
						Deleted = 0,
						DeletedBy = null,
						DeletedOn = null
					end

				else 
					begin

						INSERT INTO stng.[Metric_ActionStatus]
						([ActionStatus], RAB)
						values
						(@AdminOptionText, @CurrentUser)

					end

			end 

		else if @Operation = 25 --Remove ActionStatus Admin
			begin

				UPDATE stng.[Metric_ActionStatus]
				set
				Deleted = 1,
				DeletedBy = @CurrentUser,
				DeletedOn = stng.GetBPTime(getdate())
				WHERE UniqueID = @UniqueID

			end 

		--Get Actions Review
		else if @Operation = 26
			begin

				-- Extract Month and Year from @MonthYear
				--set @Year = Left(@monthYear, CHARINDEX('-', @monthYear) - 1)
				--set @Month = SUBSTRING(@monthYear, CHARINDEX('-', @monthYear) + 1, LEN(@monthYear))

				--select a.*, b.MeasureName 
				--from stng.VV_Metric_ActionsReview as a
				--left join stng.VV_Metric_Main as b on a.MetricID = b.UniqueID
				--left join stng.VV_Metric_Main as c on a.ParentMeasure = c.UniqueID
				--where (a.[MetricID] = @MetricID and Year(a.ReportingYearC) = @Year)
				--or (b.Department = c.Department and c.Section is null and (a.ParentMeasure = @MetricID and Year(a.ReportingYearC) = @Year) )
				--order by case 
				--			when a.ActionStatusC = 'In Progress' then 1
				--			when a.ActionStatusC = 'Complete' then 2
				--			when a.ActionStatusC = 'Cancelled' then 3
				--			else 4
				--		end, RAD desc

				Select a.*, b.MeasureName 
				FROM stng.VV_Metric_ActionsReview as a
				left join stng.VV_Metric_Main as b on a.MetricID = b.UniqueID
				left join stng.VV_Metric_Main as c on a.ParentMeasure = c.UniqueID
				where (
					a.[MetricID] = @MetricID 
					or
					(b.Department = c.Department and c.Section is null and a.ParentMeasure = @MetricID )
				)
				and 
				(
					(FORMAT(DueDate, 'MMMM yyyy') >= CONVERT(DATETIME, concat(@MonthYear,'-1')) AND ActionStatusC in ('In Progress', 'Overdue'))
					OR (FORMAT(DueDate, 'MMMM yyyy') < CONVERT(DATETIME, concat(@MonthYear,'-1')) AND ActionStatusC in ('In Progress', 'Overdue'))
					OR (FORMAT(DueDate, 'MMMM yyyy') = FORMAT(CONVERT(DATETIME, concat(@MonthYear,'-1')), 'MMMM yyyy') AND ActionStatusC in ('Complete','Cancelled'))
					OR (FORMAT(DATEADD(Month,-1,a.RAD), 'MMMM yyyy') = FORMAT(CONVERT(DATETIME, concat(@MonthYear,'-1')), 'MMMM yyyy') AND ActionStatusC in ('Complete','Cancelled'))
				)
				
				ORDER BY DueDate DESC
				
			end

		--Add Actions Review
		else if @Operation = 27
			begin

				insert into stng.Metric_ActionsReview
				([MetricID], [Action], Responsibility, DueDate, [StatusID], [ReportingYear], RAD, RAB, Deleted)
				values
				(@MetricID,@Action,@Responsibility,@DueDate,@StatusID, @ReportingYear, stng.GetBPTime(getdate()),@CurrentUser,0);

			end

		--Remove Actions Review
		else if @Operation = 28
			begin

				update [stng].[Metric_ActionsReview]
						set Deleted = 1,
						DeletedBy = @CurrentUser,
						DeletedOn = stng.GetBPTime(getdate())
						where UniqueID = @MetricIntID		
						
			end

		--Get Measure Information
		else if @Operation = 29
			begin

				select [UniqueID]
				  ,[MeasureName]
				  ,[Department]
				  ,[Section]
				  ,[Objective]
				  ,[Definition]
				  ,[RedCriteria]
				  ,[WhiteCriteria]
				  ,[GreenCriteria]
				  ,[YellowCriteria]
				  ,[Driver]
				  ,[DataSource]
				  ,[RedRecoveryDate]
				  ,[RAD]
				  ,[RAB]
				  ,[FrequencyC]
				  ,[MeasureTypeC]
				  ,[KPICategorizationC]
				  ,[UnitC]
				  ,[PeriodC]
				  ,[MeasureCategoryC]
				from stng.VV_Metric_Main
				where UniqueID = @UniqueID
				
			end

		else if @Operation = 30 --Edit measure information
			begin
				UPDATE stng.Metric_Main SET
				[MeasureCategory] = @MeasureCategory,
				[MeasureName] = @MeasureName,
				[Department] = @Department,
				[Section] = @Section,
				[Objective] = @Objective,
				[Definition] = @Definition,
				[Driver] = @Driver,
				[RedCriteria] = @RedCriteria,
				[WhiteCriteria] = @WhiteCriteria,
				[GreenCriteria] = @GreenCriteria,
				[YellowCriteria] = @YellowCriteria,
				[DataSource] = @DataSource,
				[Frequency] = @Frequency,
				[RedRecoveryDate] = @RedRecoveryDate,
				[MeasureType] = @MeasureType,
				[KPICategorization] = @KPICategorization,
				[Unit] = @Unit
				
				WHERE [UniqueID] = @UniqueID
			end	

			-- OwnershipType
		else if @Operation = 31 --Get All OwnershipType
			begin

				SELECT UniqueID, OwnershipType
				FROM stng.Metric_OwnershipType
				where Deleted = 0

			end 
		
		else if @Operation = 32 --Add OwnershipType Admin
			begin

				if exists(
					select UniqueID
					from stng.Metric_OwnershipType
					where OwnershipType = @AdminOptionText and Deleted = 1
				)
					begin
						UPDATE stng.Metric_OwnershipType
						set 
						Deleted = 0,
						DeletedBy = null,
						DeletedOn = null
					end

				else 
					begin

						INSERT INTO stng.Metric_OwnershipType
						(OwnershipType, RAB)
						values
						(@AdminOptionText, @CurrentUser)

					end

			end 

		else if @Operation = 33 --Remove Outcome Admin
			begin

				UPDATE stng.Metric_OwnershipType
				set
				Deleted = 1,
				DeletedBy = @CurrentUser,
				DeletedOn = stng.GetBPTime(getdate())
				WHERE UniqueID = @UniqueID

			end 

		else if @Operation = 34 --Get Metric Owner
			begin

				SELECT [MeasureInfoID]
					  ,[MetricID]
					  ,[MetricOwner]
					  ,[MetricOwnerC]
					  ,[OwnershipTypeC]
					  ,[AssignedByC]
					  ,[RAD]
					  ,[Deleted]
				FROM stng.VV_Metric_MetricOwner
				where deleted = 0 and [MetricID] = @MetricID
				ORDER BY RAD ASC

			end 
		
		else if @Operation = 35 --Add Metric Owner
			begin

				if not exists(
					select 1
					from [stng].VV_Metric_MetricOwner
					where MetricID = @MetricID and OwnershipTypeC = 'Primary' and MetricOwner = @CurrentUser 
				) and 
				not exists(
					SELECT 1
					FROM [stng].[VV_Admin_AllUserPermission]
					where permission = 'MetricAdmin' and employeeid = @CurrentUser
				)
					begin
						select 'You are not a Primary Metric owner, cannot edit Metric owner' as ReturnMessage;
						return;
					end


				select @OwnershipTypeC = OwnershipType
				from stng.Metric_OwnershipType
				where UniqueID = @OwnershipType

				-- check if there's already a primary owner
				if @OwnershipTypeC = 'Primary' 
					and  exists
					(
						select 1
						from [stng].[Metric_MetricOwner]
						where MetricID = @MetricID and OwnershipType = @OwnershipType and Deleted = 0  
					)
					begin
						select concat(@OwnershipTypeC, ' owner already exists in for this metric. Please remove the current ',@OwnershipTypeC,' owner to add a new one.') as ReturnMessage;
						return;
					end

				INSERT INTO stng.[Metric_MetricOwner]
				([MetricID], MetricOwner, OwnershipType, RAB, RAD, Deleted)
				values
				(@MetricID, @MetricOwner, @OwnershipType, @CurrentUser, stng.GetBPTime(getdate()), 0);
			
			end 

		else if @Operation = 36 --Remove Metric Owner
			begin

				if not exists(
					select 1
					from [stng].VV_Metric_MetricOwner
					where MetricID = @MetricID and OwnershipTypeC = 'Primary' and MetricOwner = @CurrentUser 
				)  and 
				not exists(
					SELECT 1
					FROM [stng].[VV_Admin_AllUserPermission]
					where permission = 'MetricAdmin' and employeeid = @CurrentUser
				)
					begin
						select 'You are not a Primary Metric owner, cannot edit Metric owner' as ReturnMessage;
						return;
					end

				update stng.Metric_MetricOwner
					set Deleted = 1,
					DeletedBy = @CurrentUser,
					DeletedOn = stng.GetBPTime(getdate())
					where [UniqueID] = @MetricIntID

			end

		else if @Operation = 37 --Get Data Owner
			begin

				SELECT [MeasureInfoID]
					  ,[MetricID]
					  ,[DataOwner]
					  ,[DataOwnerC]
					  ,[OwnershipTypeC]
					  ,[AssignedByC]
					  ,[RAD]
				FROM stng.VV_Metric_DataOwner
				where [MetricID] = @MetricID
				ORDER BY RAD ASC

			end 

		else if @Operation = 38 --Add Data Owner
			begin

				select @OwnershipTypeC = OwnershipType
				from stng.Metric_OwnershipType
				where UniqueID = @OwnershipType

				if not exists(
					select 1
					from [stng].VV_Metric_DataOwner
					where MetricID = @MetricID and OwnershipTypeC = 'Primary' and DataOwner = @CurrentUser 
				) and 
				not exists(
					select 1
					from [stng].VV_Metric_MetricOwner
					where MetricID = @MetricID and MetricOwner = @CurrentUser 
				) and 
				not exists(
					SELECT 1
					FROM [stng].[VV_Admin_AllUserPermission]
					where permission = 'MetricAdmin' and employeeid = @CurrentUser
				)
					begin
						select 'You are not a Primary Data owner or Metric owner, cannot edit Data owner' as ReturnMessage;
						return;
					end

				-- check if there's already a primary owner
				if @OwnershipTypeC = 'Primary' 
					and  exists
					(
						select 1
						from [stng].Metric_DataOwner
						where MetricID = @MetricID and OwnershipType = @OwnershipType and Deleted = 0  
					)
					begin
						select concat(@OwnershipTypeC, ' owner already exists in for this metric. Please remove the current ',@OwnershipTypeC,' owner to add a new one.') as ReturnMessage;
						return;
					end

				INSERT INTO stng.Metric_DataOwner
				([MetricID], DataOwner, OwnershipType, RAB, RAD, Deleted)
				values
				(@MetricID, @DataOwner, @OwnershipType, @CurrentUser, stng.GetBPTime(getdate()), 0);
				
			end 


		else if @Operation = 39 --Remove Data Owner
			begin

			
				if not exists(
					select 1
					from [stng].VV_Metric_DataOwner
					where MetricID = @MetricID and OwnershipTypeC = 'Primary' and DataOwner = @CurrentUser 
				) and 
				not exists(
					select 1
					from [stng].VV_Metric_MetricOwner
					where MetricID = @MetricID and MetricOwner = @CurrentUser 
				) and 
				not exists(
					SELECT 1
					FROM [stng].[VV_Admin_AllUserPermission]
					where permission = 'MetricAdmin' and employeeid = @CurrentUser
				)
					begin
						select 'You are not a Primary Data owner or Metric owner, cannot edit Data owner' as ReturnMessage;
						return;
					end

				update stng.Metric_DataOwner
					set Deleted = 1,
					DeletedBy = @CurrentUser,
					DeletedOn = stng.GetBPTime(getdate())
					where [UniqueID] = @MetricIntID

			end 

		--Get Monthly Variance (text box) 
		else if @Operation = 40 
			begin

				set @Year = Left(@MonthYear, CHARINDEX('-', @MonthYear) - 1)
				set @Month = SUBSTRING(@MonthYear, CHARINDEX('-', @MonthYear) + 1, LEN(@MonthYear)) 

				SELECT Top 1 [MonthlyVariance]
				FROM stng.Metric_MonthlyVarianceLog
				where Deleted = 0 and MetricID = @MetricID
				and [Year] = @Year and [Month] = @Month
				order by RAD desc

			end 
		
		--Update Monthly Variance (text box)
		else if @Operation = 41 
			begin
				
				set @Year = Year(getdate())
				set @Month = Month(getdate())

				if @Month - 1 = 0
					begin
						set @Month = 12
						set @Year = @Year - 1
					end
				else 
					begin
						set @Month = @Month - 1
					end

				--if @MonthYear = concat(@Year, '-', @Month)
				--	begin
				--		UPDATE stng.Metric_Main
				--		set MonthlyVariance = @MonthlyVariance
				--		where UniqueID = @UniqueID
				--	end
				--else
				--	begin
						set @Year = Left(@MonthYear, CHARINDEX('-', @MonthYear) - 1)
						set @Month = SUBSTRING(@MonthYear, CHARINDEX('-', @MonthYear) + 1, LEN(@MonthYear)) 
						set @CurrentYear = YEAR(DATEADD(MONTH, -1, GETDATE()))
						set @CurrentMonth = MONTH(DATEADD(MONTH, -1, GETDATE()))

						if (
								(@CurrentMonth = @Month and @CurrentYear = @Year) or
								((@CurrentMonth <> @Month or @CurrentYear <> @Year) and exists(
									SELECT 1
									FROM [stng].[VV_Admin_AllUserPermission]
									where permission = 'MetricAdmin' and employeeid = @CurrentUser
									)	
								)
							)
							begin
								if exists(
									SELECT 1
									FROM stng.Metric_MonthlyVarianceLog
									where Deleted = 0 and MetricID = @UniqueID
										and [Year] = @Year and [Month] = @Month
								)
									begin
										Update [stng].[Metric_MonthlyVarianceLog]
										set
										MonthlyVariance = @MonthlyVariance
										where MetricID = @UniqueID and [Year] = @Year and [Month] = @Month
									end

								else
									begin
										Insert into [stng].[Metric_MonthlyVarianceLog]
										([MetricID], [Year], [Month], [MonthlyVariance], [RAD], [RAB])
										values
										(@UniqueID, @Year, @Month, @MonthlyVariance, stng.GetBPTime(getdate()), @CurrentUser)
									end
							end
						else
							begin
								
									select 'Cannot update the variance note of a historic metric month' as ReturnMessage;
									return;
							end

					--end

			end 

		--Update Data Inputs Actuals
		else if @Operation = 43
			begin

				UPDATE [stng].[Metric_Actuals]
				SET [Value] = @TargetVal
				WHERE MetricID = @MetricID and [Year] = @Year and [Month] = @Month
				
			end

		--Add Data Inputs Actuals
		else if @Operation = 44
			begin
				if(exists(select 1
					from [stng].[VV_Metric_DataInputs_Actuals]
					where [Year] = @Year and [MetricID] = @MetricID))
					begin
						select concat(@Year,' already exists') as ReturnMessage;
						return;
					end

				INSERT INTO [stng].[Metric_Actuals]
				([MetricID], [Year], [Month], RAD, RAB)
				SELECT @MetricID, @Year, [Month], stng.GetBPTime(getdate()), @CurrentUser
				FROM [stng].[Metric_Month]

			end

		----Remove Data Inputs Actual
		else if @Operation = 45
			begin

				update [stng].[Metric_Actuals]
						set Deleted = 1,
						DeletedBy = @CurrentUser,
						DeletedOn = stng.GetBPTime(getdate())
						where [MetricID] = @MetricID and [Year] = @Year						
			end

		else if @Operation = 46 --Edit Action
			begin
				UPDATE stng.Metric_ActionsReview
				SET
				[Action] = @Action,
				[StatusID] = @StatusID,
				[DueDate] = @DueDate,
				[Responsibility] = @Responsibility,
				[ReportingYear] = @ReportingYear
				WHERE [UniqueID] = @MetricIntID
			end	

		else if @Operation = 47 --Get criteria
			begin

				SELECT *
				FROM [stng].[VV_Metric_Criteria]

			end 

		else if @Operation = 48 --Get criteria
			begin

				SELECT *
				FROM [stng].[VV_Metric_Criteria]
				where MetricID = @MetricID
				order by
					case 
						when Criteria = 'Green' then 1
						when Criteria = 'White' then 2
						when Criteria = 'Yellow' then 3
						when Criteria = 'Red' then 4
						else 5
					end
				

			end 

		--Update Criteria
		else if @Operation = 49
			begin
				UPDATE [stng].[Metric_Criteria]
				set	
				  [Operator1] = @Operator1
				  ,[Value1] = @Decimal1
				  ,[Operator2] = @Operator2
				  ,[Value2] = @Decimal2
				  ,[LUD] = stng.GetBPTime(getdate())
				  ,[LUB] = @CurrentUser
				  ,[Deleted] = 0
				  where [MetricID] = @MetricID and Criteria = @Criteria
			end

		--Get criteria operators
		else if @Operation = 50 
			begin
				
				SELECT [UniqueID]
					, [Operator]
				FROM [stng].[Metric_CriteriaOperators]
			end

		--Get Data Inputs Actuals
		else if @Operation = 51
			begin

				select *
				from stng.[VV_Metric_DataInputs_Actuals]
				where [MetricID] = @MetricID
				order by [Year] desc
				
			end

		--Get Data Inputs Targets
		else if @Operation = 52
			begin

				select *
				from stng.[VV_Metric_DataInputs_Targets]
				where [MetricID] = @MetricID
				order by [Year] desc
				
			end

		--Update Data Inputs Targets
		else if @Operation = 53
			begin

			if exists(
				select 1
				from [stng].[Metric_Targets]
				WHERE MetricID = @MetricID and [Year] = @Year and [Month] = @Month
			)
				begin 
					UPDATE [stng].[Metric_Targets]
					SET [Value] = @TargetVal
					WHERE MetricID = @MetricID and [Year] = @Year and [Month] = @Month
				end

			else
				begin 
					INSERT INTO [stng].[Metric_Targets]
					([MetricID], [Year], [Month], [Value], RAD, RAB)
					values
					(@MetricID, @Year, @Month, @TargetVal, stng.GetBPTime(getdate()), @CurrentUser)
				end

				
			end

		--Remove Data Inputs targets
		else if @Operation = 54
			begin

				update [stng].[Metric_Targets]
				set Deleted = 1,
				DeletedBy = @CurrentUser,
				DeletedOn = stng.GetBPTime(getdate())
				where  [MetricID] = @MetricID and [Year] = @Year						
			end

		-- add data inputs targets
		else if @Operation = 55
			begin

				if(exists(select 1
					from [stng].[VV_Metric_DataInputs_Targets]
					where [Year] = @Year and [MetricID] = @MetricID))
					begin
						select concat(@Year,' already exists') as ReturnMessage;
						return;
					end
				
				if (
					Select count(UniqueID)
					From [stng].[Metric_Targets]
					where MetricID = @MetricID and [Year] = @Year - 1 and Deleted = 0
				) = 12
					begin 
						INSERT INTO [stng].[Metric_Targets]
						([MetricID], [Year], [Month], [Value], RAD, RAB)
						select @MetricID, @Year, [Month], [Value], stng.GetBPTime(getdate()), @CurrentUser
						From stng.[Metric_Targets]
						where MetricID = @MetricID and [Year] = @Year - 1 and Deleted = 0
					end

				else
					begin 
						INSERT INTO [stng].[Metric_Targets]
						([MetricID], [Year], [Month], RAD, RAB)
						SELECT @MetricID, @Year, [Month], stng.GetBPTime(getdate()), @CurrentUser
						FROM [stng].[Metric_Month]
					end


								
				--INSERT INTO [stng].[Metric_Targets]
				--([MetricID], [Year], [Month], RAD, RAB)
				--SELECT @MetricID, @Year, [Month], stng.GetBPTime(getdate()), @CurrentUser
				--FROM [stng].[Metric_Month]

			end

		-- select current monthly target
		else if @Operation = 56
		begin
			SELECT TOP 1 
				[MeasureInfoID],
				[MetricID],
				CASE 
					WHEN MONTH([RAD]) = 12 THEN [JanuaryTarget]
					WHEN MONTH([RAD]) = 1 THEN [FebruaryTarget]
					WHEN MONTH([RAD]) = 2 THEN [MarchTarget]
					WHEN MONTH([RAD]) = 3 THEN [AprilTarget]
					WHEN MONTH([RAD]) = 4 THEN [MayTarget]
					WHEN MONTH([RAD]) = 5 THEN [JuneTarget]
					WHEN MONTH([RAD]) = 6 THEN [JulyTarget]
					WHEN MONTH([RAD]) = 7 THEN [AugustTarget]
					WHEN MONTH([RAD]) = 8 THEN [SeptemberTarget]
					WHEN MONTH([RAD]) = 9 THEN [OctoberTarget]
					WHEN MONTH([RAD]) = 10 THEN [NovemberTarget]
					WHEN MONTH([RAD]) = 11 THEN [DecemberTarget]
				END AS TargetForMonth,
				[RAD],
				[RAB],
				[RABC]
			FROM stng.[VV_Metric_DataInputs_Targets]
			WHERE [MetricID] = @MetricID
			ORDER BY [RAD] DESC;
		end

		-- select current monthly actual
		else if @Operation = 57
		begin
			SELECT TOP 1 
				[MeasureInfoID],
				[MetricID],
				CASE 
					WHEN MONTH([RAD]) = 12 THEN [JanuaryActual]
					WHEN MONTH([RAD]) = 1 THEN [FebruaryActual]
					WHEN MONTH([RAD]) = 2 THEN [MarchActual]
					WHEN MONTH([RAD]) = 3 THEN [AprilActual]
					WHEN MONTH([RAD]) = 4 THEN [MayActual]
					WHEN MONTH([RAD]) = 5 THEN [JuneActual]
					WHEN MONTH([RAD]) = 6 THEN [JulyActual]
					WHEN MONTH([RAD]) = 7 THEN [AugustActual]
					WHEN MONTH([RAD]) = 8 THEN [SeptemberActual]
					WHEN MONTH([RAD]) = 9 THEN [OctoberActual]
					WHEN MONTH([RAD]) = 10 THEN [NovemberActual]
					WHEN MONTH([RAD]) = 11 THEN [DecemberActual]
				END AS ActualForMonth
			FROM stng.[VV_Metric_DataInputs_Actuals]
			WHERE [MetricID] = @MetricID
			ORDER BY [RAD] DESC;
		end

		-- get grid monthly variance table
		else if @Operation = 58
			begin
				
				set @Year = Left(@MonthYear, CHARINDEX('-', @MonthYear) - 1)
				set @Month = SUBSTRING(@MonthYear, CHARINDEX('-', @MonthYear) + 1, LEN(@MonthYear)) 
			
				if exists(
					SELECT 1 
					FROM stng.VV_Metric_Main
					where UniqueID = @MetricID and UnitC = 'Percentage'
				)
					begin
						SELECT a.UniqueID, Round(nullif(b.[Value]/nullif(c.[Value], 0), 0) * 100, 2) as ActualsValue, a.TargetPercent as TargetValue
						,abs(Round((b.[Value]/nullif(c.[Value], 0) *100) - a.TargetPercent, 2)) as Variance
						FROM stng.VV_Metric_Main as a
						LEFT JOIN stng.Metric_Actuals as b on a.UniqueID = b.MetricID and b.[Year] = @Year and b.[Month] = @Month and b.Deleted = 0
						LEFT JOIN stng.Metric_Targets as c on a.UniqueID = c.MetricID and c.[Year] = @Year and c.[Month] = @Month and c.Deleted = 0
						WHERE a.UniqueID = @MetricID
					end
				else
					begin
						SELECT a.UniqueID, b.[Value] as ActualsValue, c.[Value] as TargetValue
						,abs(Round(c.[Value] - b.[Value], 2)) as Variance
						FROM stng.VV_Metric_Main as a
						LEFT JOIN stng.Metric_Actuals as b on a.UniqueID = b.MetricID and b.[Year] = @Year and b.[Month] = @Month and b.Deleted = 0
						LEFT JOIN stng.Metric_Targets as c on a.UniqueID = c.MetricID and c.[Year] = @Year and c.[Month] = @Month and c.Deleted = 0
						WHERE a.UniqueID = @MetricID
					end
				

			end

		-- get grid YTD variance table
		else if @Operation = 59
			begin

				SELECT @UnitC = UnitC
				FROM stng.VV_Metric_Main
				WHERE UniqueID = @MetricID
				
				set @Year = Left(@MonthYear, CHARINDEX('-', @MonthYear) - 1)
				set @Month = SUBSTRING(@MonthYear, CHARINDEX('-', @MonthYear) + 1, LEN(@MonthYear)) 

				if @UnitC ='Number' or @UnitC = 'Dollars' or @UnitC = 'Number Count'
					begin
						SELECT a.UniqueID, Round(b.[CumulativeValue], 2) as ActualsValue, Round(c.[CumulativeValue],2) as TargetValue
						,Round(Round(nullif(c.[CumulativeValue], 0), 2) - Round(nullif(b.[CumulativeValue], 0),2), 2) as Variance
						FROM stng.VV_Metric_Main as a
						LEFT JOIN stng.VV_Metric_YTDActuals as b on a.UniqueID = b.MetricID and b.[Year] = @Year and b.[Month] = @Month 
						LEFT JOIN stng.VV_Metric_YTDTargets as c on a.UniqueID = c.MetricID and c.[Year] = @Year and c.[Month] = @Month 
						WHERE a.UniqueID = @MetricID
					end
				else if @UnitC = 'Percentage'
					begin
						SELECT a.UniqueID, Round((b.[CumulativeValue]/nullif(c.[CumulativeValue], 0)) * 100, 2) as ActualsValue, Round(a.YTDTargetPercent,2) as TargetValue
						,abs(Round((b.[CumulativeValue]/nullif(c.[CumulativeValue], 0) * 100) - a.YTDTargetPercent, 2)) as Variance
						FROM stng.VV_Metric_Main as a
						LEFT JOIN stng.VV_Metric_YTDActuals as b on a.UniqueID = b.MetricID and b.[Year] = @Year and b.[Month] = @Month 
						LEFT JOIN stng.VV_Metric_YTDTargets as c on a.UniqueID = c.MetricID and c.[Year] = @Year and c.[Month] = @Month 
						WHERE a.UniqueID = @MetricID
					end
				
				
		  end

		-- get grid YTD variance table
		else if @Operation = 60
			begin
				SELECT *
				FROM [stng].[VV_Metric_Criteria]
				WHERE [MetricID] = @MetricID
			  end

		-- get list of all departments
		else if @Operation = 61
			begin
				SELECT [UniqueID]
					  ,[Department]
					  ,Deleted
				FROM stng.Metric_Department
				--where deleted = 0
				ORDER BY Department ASC
			end

		-- get list of all sections
		else if @Operation = 62
			begin
				SELECT [UniqueID]
					  ,[Section]
					  ,Deleted
				FROM stng.Metric_Section
				--where deleted = 0
				ORDER BY Section ASC
			end

		-- export reportbook
		--else if @Operation = 63
		--	BEGIN
		--		SELECT DISTINCT
		--			   [MeasureName]
		--			  ,[Department]
		--			  ,[Section]
		--			  ,[PreviousMonth]
		--			  ,[Objective]
		--			  ,[Definition]
		--			  ,[Driver]
		--			  ,[DataSource]
		--			  ,[RedRecoveryDate]
		--			  ,[FrequencyC]
		--			  ,[MeasureTypeC]
		--			  ,[KPICategorizationC]
		--			  ,[UnitC]
		--			  ,[PeriodC]
		--			  ,[MeasureCategoryC]
		--			  ,[DataOwnerC]
		--			  ,[MetricOwnerC]
		--			  ,[RedCriteriaC]
		--			  ,[YellowCriteriaC]
		--			  ,[GreenCriteriaC]
		--			  ,[WhiteCriteriaC]
		--			  ,[RAD]
		--		FROM 
		--			[stng].[VV_Metric_Export]
		--		--WHERE Deleted = 0
		--		ORDER BY [RAD] DESC;
		--	END

		-- get all month years
		else if @Operation = 64
			BEGIN
				SELECT UniqueID, [label]
				FROM [stng].[VV_Metric_MonthYear]
				order by [Year] desc, [Month] desc
			END

		--Monthly Chart Targets
		else if @Operation = 65
			begin

				set @Year = Left(@monthYear, CHARINDEX('-', @monthYear) - 1)
				set @Month = SUBSTRING(@monthYear, CHARINDEX('-', @monthYear) + 1, LEN(@monthYear))

				select  MonthDate
				,MetricID
				,case when b.[Year] is null then Year(MonthDate) else b.[Year] end as [Year]
				,case when b.[Month] is null then Month(MonthDate) else b.[Month] end as [Month]
				,case 
					when c.UnitC = 'Percentage' then c.TargetPercent
					else b.[Value]
				end as [Value]
				--,b.[Value]
				from (
					SELECT	
						DateAdd(Month, -n, DatefromParts(@Year, @Month, 1)) as MonthDate
					FROM (Values (0), (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11)) as X(n)
				)as Months
				left join stng.Metric_Targets as b on Year(MonthDate) = b.[Year] and Month(MonthDate) = b.[Month] and deleted = 0 and MetricID = @MetricID
				left join stng.VV_Metric_Main as c on b.MetricID = c.UniqueID
				order by [Year] desc, [Month] desc
				
			end

		--Monthly Chart Actuals
		else if @Operation = 66
			begin

				set @Year = Left(@monthYear, CHARINDEX('-', @monthYear) - 1)
				set @Month = SUBSTRING(@monthYear, CHARINDEX('-', @monthYear) + 1, LEN(@monthYear))
				
				select MonthDate
				,b.MetricID
				,case when b.[Year] is null then Year(MonthDate) else b.[Year] end as [Year]
				,case when b.[Month] is null then Month(MonthDate) else b.[Month] end as [Month]
				,case 
					when d.UnitC = 'Percentage' then (b.[Value]/nullif(c.[Value], 0))*100
					else b.[Value]
				end as [Value]
				--,b.[Value]
				from (
					SELECT	
						DateAdd(Month, -n, DatefromParts(@Year, @Month, 1)) as MonthDate
					FROM (Values (0), (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11)) as X(n)
				)as Months
				left join stng.Metric_Actuals as b on Year(MonthDate) = b.[Year] and Month(MonthDate) = b.[Month] and b.deleted = 0 and b.MetricID = @MetricID
				left join stng.Metric_Targets as c on Year(MonthDate) = c.[Year] and Month(MonthDate) = c.[Month] and c.deleted = 0 and c.MetricID = @MetricID
				left join stng.VV_Metric_Main as d on b.MetricID = d.UniqueID
				order by [Year] desc, [Month] desc
				
				
			end

		--YTD Chart Target
		else if @Operation = 67
			begin

				set @Year = Left(@monthYear, CHARINDEX('-', @monthYear) - 1)
				set @Month = SUBSTRING(@monthYear, CHARINDEX('-', @monthYear) + 1, LEN(@monthYear))

				select MonthDate
				,MetricID
				,case when b.[Year] is null then Year(MonthDate) else b.[Year] end as [Year]
				,case when b.[Month] is null then Month(MonthDate) else b.[Month] end as [Month]
				,CumulativeValue
				,CumulativeCount
				,AverageValue
				,case 
					when c.UnitC = 'Percentage' then c.YTDTargetPercent
					else b.AverageValue
				end as [Value]
				from (
					SELECT	
						DateAdd(Month, -n, DatefromParts(@Year, @Month, 1)) as MonthDate
					FROM (Values (0), (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11)) as X(n)
				)as Months
				left join stng.VV_Metric_YTDTargets as b on Year(MonthDate) = b.[Year] and Month(MonthDate) = b.[Month] and MetricID = @MetricID
				left join stng.VV_Metric_Main as c on c.UniqueID = @MetricID
				order by [Year] desc, [Month] desc
					
			end

		--YTD Chart Actuals
		else if @Operation = 68
			begin

				set @Year = Left(@monthYear, CHARINDEX('-', @monthYear) - 1)
				set @Month = SUBSTRING(@monthYear, CHARINDEX('-', @monthYear) + 1, LEN(@monthYear))

				select MonthDate
				,b.MetricID
				,case when b.[Year] is null then Year(MonthDate) else b.[Year] end as [Year]
				,case when b.[Month] is null then Month(MonthDate) else b.[Month] end as [Month]
				,b.CumulativeValue
				,b.CumulativeCount
				,case 
					when d.UnitC = 'Percentage' then Round((b.[CumulativeValue]/nullif(c.[CumulativeValue], 0)) * 100, 2) 
					else b.AverageValue
				end as [Value]
				from (
					SELECT	
						DateAdd(Month, -n, DatefromParts(@Year, @Month, 1)) as MonthDate
					FROM (Values (0), (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11)) as X(n)
				)as Months
				left join stng.VV_Metric_YTDActuals as b on Year(MonthDate) = b.[Year] and Month(MonthDate) = b.[Month] and b.MetricID = @MetricID
				left join stng.VV_Metric_YTDTargets as c on Year(MonthDate) = c.[Year] and Month(MonthDate) = c.[Month] and c.MetricID = @MetricID
				left join stng.VV_Metric_Main as d on d.UniqueID = @MetricID
				order by [Year] desc, [Month] desc
				
			end

			--Workflow
		else if @Operation = 69
			begin
				if @StatusShort is null or @MetricID is null
				begin

					select 'StatusShort and/or UniqueID is required' as ReturnMessage;
					return;

				end 

			if not exists(SELECT 1
				FROM stng.Metric_Status
				WHERE StatusShort = @StatusShort)
				begin

					select concat(@StatusShort, ' is not a valid shortform status') as ReturnMessage;
					return;

				end

			declare @PriorStatus varchar(10) = null
			declare @StatusC varchar(50) = null

			-- Extract Month and Year from @MonthYear
			set @Year = Left(@monthYear, CHARINDEX('-', @monthYear) - 1)
			set @Month = SUBSTRING(@monthYear, CHARINDEX('-', @monthYear) + 1, LEN(@monthYear))

			select @PriorStatus = StatusShort
			from stng.FN_Metric_Main_ReportingMonth(@Year, @Month, @CurrentUser)
			where UniqueID = @MetricID

			select @StatusC = [Status], @StatusID = UniqueID
			from stng.Metric_Status
			where StatusShort = @StatusShort

			if (@StatusShort = 'RFE' and @PriorStatus not in ('AI', 'RR', 'A')) or
				(@StatusShort = 'A' and @PriorStatus not in ('RFE')) or 
				(@StatusShort = 'RR' and @PriorStatus not in ('RFE')) or
				(@StatusShort = 'AI' and @PriorStatus not in ('A', 'RFE'))
				begin
							
					select concat('You cannot change the status to ', @StatusC, ' from the current status') as ReturnMessage;
					return
			
				end
			
				--implement for admin user only, currently front end handles it
			--else if @PriorStatus = 'A' and @CurrentUser is not MetricAdmin
			--	begin 
			--		select 'Only admin can perform this action' as ReturnMessage;
			--		return
			--	end

			----If submitting for review
			--if @StatusShort = 'RFE'
			--	begin
			--		--Only Data Owners can submit for review
			--		if not exists(SELECT 1
			--			FROM [stng].[VV_Metric_DataOwner]
			--			WHERE MetricID = @MetricID and DataOwner = @CurrentUser
			--			)
			--			begin
			--				select 'Only a Data Owner can submit for review' as ReturnMessage;
			--			end
			--	end

			--if @StatusShort = 'A'
			--	begin
			--		--Only Data Owners can submit for review
			--		if not exists(SELECT 1
			--			FROM [stng].[VV_Metric_MetricOwner]
			--			WHERE MetricID = @MetricID and MetricOwner = @CurrentUser
			--			)
			--			begin
			--				select 'Only a Metric Owner can approve' as ReturnMessage;
			--			end
			--	end

				--Get the current editable year and month, so todays date minus one month
				set @CurrentYear = YEAR(DATEADD(MONTH, -1, GETDATE()))
				set @CurrentMonth = MONTH(DATEADD(MONTH, -1, GETDATE()))

				if @CurrentMonth = @Month and @CurrentYear = @Year	
					begin
						--update stng.Metric_Main
						--set [Status] = @StatusID
						--where UniqueID = @MetricID

						Insert into stng.Metric_StatusLog
						(MetricID, [Year], [Month], [Status], RAD, RAB)
						values
						(@MetricID, @Year, @Month, @StatusID, stng.GetBPTime(getdate()), @CurrentUser)
					end
				else
					begin
						select 'Cannot update the status of a historic metric month' as ReturnMessage;
						return
					end

				

			--Possibly add monthly vaiance here, right now im thinking of doing it in the etl
				--if @StatusShort = 'A'
				--	begin
				--		return 
				--	end
			
			end

		-- Oversight Area
		else if @Operation = 70 --Get All Oversight Area
			begin

				SELECT UniqueID, OversightArea
				FROM stng.Metric_OversightArea
				where Deleted = 0

			end 
		
		else if @Operation = 71 --Add Oversight Area Admin
			begin

				if exists(
					select UniqueID
					from stng.Metric_OversightArea
					where OversightArea = @AdminOptionText and Deleted = 1
				)
					begin
						UPDATE stng.Metric_OversightArea
						set 
						Deleted = 0,
						DeletedBy = null,
						DeletedOn = null
					end

				else 
					begin

						INSERT INTO stng.Metric_OversightArea
						([OversightArea], RAB)
						values
						(@AdminOptionText, @CurrentUser)

					end

			end 

		else if @Operation = 72 --Remove Oversight Area Admin
			begin

				UPDATE stng.Metric_OversightArea
				set
				Deleted = 1,
				DeletedBy = @CurrentUser,
				DeletedOn = stng.GetBPTime(getdate())
				WHERE UniqueID = @UniqueID

			end 

		else if @Operation = 73 --Get record Oversight Area
			begin

				SELECT a.UniqueID, a.OversightArea
				FROM [stng].[Metric_OversightArea_Map] as a
				inner join stng.Metric_OversightArea as b on a.OversightArea = b.UniqueID and Deleted = 0
				WHERE MetricID = @UniqueID 

			end 

		else if @Operation = 74 --Update Oversight Area
			begin
				
				DELETE stng.[Metric_OversightArea_Map]
				from stng.[Metric_OversightArea_Map] as a
				left join @MultiSelectList as b on a.OversightArea = b.ID
				where MetricID = @UniqueID and b.ID is null
				
				INSERT into stng.[Metric_OversightArea_Map]
				(MetricID, OversightArea, RAB)
				select @UniqueID, b.ID, @CurrentUser
				from stng.Metric_OversightArea as a 
				inner join @MultiSelectList as b on a.UniqueID = b.ID
				left join stng.[Metric_OversightArea_Map] as c on b.ID = c.OversightArea and c.MetricID = @UniqueID
				where c.OversightArea is null

			end 

		else if @Operation = 75 --Get Year values
			begin
				
				SELECT UniqueID, YearString, [Year]
				FROM stng.Metric_Year 
				order by [Year] desc

			end 

		else if @Operation = 76 --Update record monthly percentage target
			begin
				
				UPDATE stng.Metric_Main 
				SET TargetPercent = @TargetVal
				WHERE UniqueID = @MetricID 

			end 

		else if @Operation = 77 --Update record ytd percent target
			begin
				
				UPDATE stng.Metric_Main 
				SET YTDTargetPercent = @TargetVal
				WHERE UniqueID = @MetricID 

			end 

		else if @Operation = 78 --Update Red Recovery date
			begin
				
			UPDATE stng.Metric_Main SET
				[RedRecoveryDate] = @RedRecoveryDate
				WHERE [UniqueID] = @UniqueID

			end 

		else if @Operation = 79 --Get Active Status'
			begin
				
				SELECT [UniqueID]
					  ,[ActiveStatus]
					  ,Deleted
				FROM stng.Metric_ActiveStatus
				ORDER BY [ActiveStatus] ASC

			end 
		else if @Operation = 80 -- Emails
			begin
				
				if @SubOp = 1 --Get all metrics and the listed emails
					begin
					
						--For testing different days of the month
						-- set @Date1  = '2026-02-02';
						set @CurrentYear = YEAR(DATEADD(MONTH, -1, GETDATE()));
						set @CurrentMonth = MONTH(DATEADD(MONTH, -1, GETDATE()));
						
						with monthBusinessDays as (
							SELECT 
							[Date],
							ROW_NUMBER() OVER (ORDER BY [Date]) AS BusinessDayNumber
							FROM [stng].[Common_WorkDate]
							WHERE YEAR(@Date1)  = YEAR([Date])
							AND MONTH(@Date1) = MONTH([Date])
							AND IsWorkday = 1
						)

						SELECT @Num1 = BusinessDayNumber
						FROM monthBusinessDays
						where cast([Date] as Date) = cast(@Date1 as Date);


						with PerformanceEmailGroups as (
							SELECT PerformanceLevel, OwnerType
							FROM stng.Metric_PerformanceLevelEmail 
							where @Num1 BETWEEN [From] AND [To]
						)

						SELECT a.UniqueID, a.MeasureName, a.StatusC
						, case
							when b.OwnerType = 'Data Owner'
								then c.DataOwnerC
							when b.OwnerType = 'Metric Owner'
								then d.MetricOwnerC
							end as [OwnerC]
						, case
							when b.OwnerType = 'Data Owner'
								then c.DataOwner
							when b.OwnerType = 'Metric Owner'
								then d.MetricOwner
							end as [Owner]
						, case
							when b.OwnerType = 'Data Owner'
								then e.Email
							when b.OwnerType = 'Metric Owner'
								then f.Email
							end as [Email]
						, case
							when b.OwnerType = 'Data Owner'
								then e.FirstName
							when b.OwnerType = 'Metric Owner'
								then f.FirstName
							end as [FirstName]
						, case
							when b.OwnerType = 'Data Owner'
								then e.LastName
							when b.OwnerType = 'Metric Owner'
								then f.LastName
							end as [LastName]
						FROM [stng].[FN_Metric_Main_ReportingMonth](@CurrentYear, @CurrentMonth, @CurrentUser) AS a
						INNER JOIN PerformanceEmailGroups AS b 
							ON a.KPICategorizationC = b.PerformanceLevel

						LEFT JOIN stng.VV_Metric_DataOwner AS c
							ON a.UniqueID = c.MetricID
						   AND b.OwnerType = 'Data Owner'

						LEFT JOIN stng.VV_Metric_MetricOwner AS d
							ON a.UniqueID = d.MetricID
						   AND b.OwnerType = 'Metric Owner'

						left join stng.Admin_User as e on c.DataOwner = e.EmployeeID
						left join stng.Admin_User as f on d.MetricOwner = f.EmployeeID
						where a.ActiveStatusC <> 'Archived' 
						and 
						(
							(b.OwnerType = 'Data Owner'   AND a.StatusC IN ('Awaiting Input', 'Revision Required'))
							OR (b.OwnerType = 'Metric Owner' AND a.StatusC = 'Ready for Review')
						)

					end

				else if @SubOp = 2 --Get Email Template
					begin

						SELECT [Name], [Subject], Body
						FROM [stng].[Common_EmailTemplate]
						where [Name] = 'MetricDailyReminder' 

					end 

				else if @SubOp = 3 
					begin

						return 

					end 

			end 

		else if @Operation = 81 -- Report Data
			begin

				SET @Year = CAST(LEFT(@MonthYear, CHARINDEX('-', @MonthYear) - 1) AS int);
				SET @Month = CAST(SUBSTRING(@MonthYear, CHARINDEX('-', @MonthYear) + 1, 2) AS int);

				DECLARE @AsOfMonth date = DATEFROMPARTS(@Year, @Month, 1);
				DECLARE @Start12   date = DATEADD(MONTH, -11, @AsOfMonth);
				DECLARE @StartYTD  date = DATEFROMPARTS(YEAR(@AsOfMonth), 1, 1);


				;WITH Months AS (
					SELECT DATEADD(MONTH, v.n, @Start12) AS MonthDate
					FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11)) v(n)
				),
				MetricSet AS (
					SELECT
						a.ID AS MetricID,
						b.UnitC AS Unit,
						b.TargetPercent,
						b.YTDTargetPercent
					FROM @MultiSelectList a
					LEFT JOIN stng.VV_Metric_Main b
						ON a.ID = b.UniqueID
				),
				Base AS (
					SELECT
						ms.MetricID,
						ms.Unit,
						ms.TargetPercent,
						ms.YTDTargetPercent,
						m.MonthDate,
						CONVERT(char(7), m.MonthDate, 120) AS MonthKey, 
						LEFT(DATENAME(month, m.MonthDate), 3) + ' ' + CAST(YEAR(m.MonthDate) AS char(4)) AS MonthLabel, 
						c.[Value] AS ActualValue,
						d.[Value] AS TargetValue
					FROM MetricSet ms
					CROSS JOIN Months m
					LEFT JOIN stng.Metric_Actuals c
						ON c.MetricID = ms.MetricID
					   AND c.Deleted = 0
					   AND c.[Year]  = YEAR(m.MonthDate)
					   AND c.[Month] = MONTH(m.MonthDate)
					LEFT JOIN stng.Metric_Targets d
						ON d.MetricID = ms.MetricID
					   AND d.Deleted = 0
					   AND d.[Year]  = YEAR(m.MonthDate)
					   AND d.[Month] = MONTH(m.MonthDate)
				),
				YTD AS (
					SELECT
						MetricID,
						Unit,

						CASE WHEN Unit = 'Number'
							 THEN SUM(CASE WHEN MonthDate >= @StartYTD AND MonthDate <= @AsOfMonth THEN ActualValue END)
						END AS YTDActual,

						CASE WHEN Unit = 'Number'
							 THEN SUM(CASE WHEN MonthDate >= @StartYTD AND MonthDate <= @AsOfMonth THEN TargetValue END)
						END AS YTDTarget,
						
						CASE WHEN Unit = 'Percentage'
							 THEN
							   100.0
							   * AVG(CASE WHEN MonthDate >= @StartYTD AND MonthDate <= @AsOfMonth THEN ActualValue END)
							   / NULLIF(
								   AVG(CASE WHEN MonthDate >= @StartYTD AND MonthDate <= @AsOfMonth THEN TargetValue END),
								   0
								 )
						END AS YTDPercent

					FROM Base
					GROUP BY MetricID, Unit
				)
				SELECT
					ms.MetricID           AS UniqueID,
					ms.Unit,
					ms.TargetPercent,
					ms.YTDTargetPercent,

					y.YTDActual,
					y.YTDTarget,
					y.YTDPercent,
					a.*,

					JSON_QUERY(
					  (
						SELECT
							b.MonthKey    AS [monthKey],
							b.MonthLabel  AS [monthLabel],
							b.ActualValue AS [actual],
							b.TargetValue AS [target]
						FROM Base b
						WHERE b.MetricID = ms.MetricID
						ORDER BY b.MonthDate
						FOR JSON PATH, INCLUDE_NULL_VALUES
					  )
					) AS MonthlyData

				FROM MetricSet ms
				LEFT JOIN YTD y
					ON y.MetricID = ms.MetricID
				LEFT JOIN stng.VV_Metric_Main as a on a.UniqueID = ms.MetricID
				ORDER BY ms.MetricID;

			end
				
	end

				else if @SubOp = 2 --Get Email Template
					begin

						SELECT [Name], [Subject], Body
						FROM [stng].[Common_EmailTemplate]
						where [Name] = 'MetricDailyReminder' 

					end 

				else if @SubOp = 3 
					begin

						return 

					end 

			end 

		else if @Operation = 81 -- Report Data
			begin

				SET @Year = CAST(LEFT(@MonthYear, CHARINDEX('-', @MonthYear) - 1) AS int);
SET @Month = CAST(SUBSTRING(@MonthYear, CHARINDEX('-', @MonthYear) + 1, 2) AS int);

DECLARE @AsOfMonth date = DATEFROMPARTS(@Year, @Month, 1);
DECLARE @Start12   date = DATEADD(MONTH, -11, @AsOfMonth);
DECLARE @StartYTD  date = DATEFROMPARTS(YEAR(@AsOfMonth), 1, 1);

-- selected reporting month window (for action filtering)
DECLARE @MonthStart     date = @AsOfMonth;
DECLARE @NextMonthStart date = DATEADD(MONTH, 1, @MonthStart);

;WITH Months AS (
    SELECT DATEADD(MONTH, v.n, @Start12) AS MonthDate
    FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11)) v(n)
),
MetricSet AS (
    SELECT
        a.ID AS MetricID,
        b.UnitC AS Unit,
        b.TargetPercent,
        b.YTDTargetPercent
    FROM @MultiSelectList a
    LEFT JOIN stng.VV_Metric_Main b
        ON a.ID = b.UniqueID
),
Base AS (
    SELECT
        ms.MetricID,
        ms.Unit,
        ms.TargetPercent,
        ms.YTDTargetPercent,
        m.MonthDate,
        CONVERT(char(7), m.MonthDate, 120) AS MonthKey,
        LEFT(DATENAME(month, m.MonthDate), 3) + ' ' + CAST(YEAR(m.MonthDate) AS char(4)) AS MonthLabel,
        c.[Value] AS ActualValue,
        d.[Value] AS TargetValue
    FROM MetricSet ms
    CROSS JOIN Months m
    LEFT JOIN stng.Metric_Actuals c
        ON c.MetricID = ms.MetricID
       AND c.Deleted = 0
       AND c.[Year]  = YEAR(m.MonthDate)
       AND c.[Month] = MONTH(m.MonthDate)
    LEFT JOIN stng.Metric_Targets d
        ON d.MetricID = ms.MetricID
       AND d.Deleted = 0
       AND d.[Year]  = YEAR(m.MonthDate)
       AND d.[Month] = MONTH(m.MonthDate)
),
YTD AS (
    SELECT
        MetricID,
        Unit,

        CASE WHEN Unit = 'Number'
             THEN SUM(CASE WHEN MonthDate >= @StartYTD AND MonthDate <= @AsOfMonth THEN ActualValue END)
        END AS YTDActual,

        CASE WHEN Unit = 'Number'
             THEN SUM(CASE WHEN MonthDate >= @StartYTD AND MonthDate <= @AsOfMonth THEN TargetValue END)
        END AS YTDTarget,

        CASE WHEN Unit = 'Percentage'
             THEN
               100.0
               * AVG(CASE WHEN MonthDate >= @StartYTD AND MonthDate <= @AsOfMonth THEN ActualValue END)
               / NULLIF(
                   AVG(CASE WHEN MonthDate >= @StartYTD AND MonthDate <= @AsOfMonth THEN TargetValue END),
                   0
                 )
        END AS YTDPercent

    FROM Base
    GROUP BY MetricID, Unit
),
ActionsBase AS (
    SELECT
        ms.MetricID AS ReportMetricID,
        ar.*,
        b.MeasureName AS MetricMeasureName,
        c.MeasureName AS ParentMeasureName
    FROM MetricSet ms
    JOIN stng.VV_Metric_ActionsReview ar
        ON 1 = 1
    LEFT JOIN stng.VV_Metric_Main b
        ON ar.MetricID = b.UniqueID
    LEFT JOIN stng.VV_Metric_Main c
        ON ar.ParentMeasure = c.UniqueID
    WHERE
        (
            ar.MetricID = ms.MetricID
            OR
            (b.Department = c.Department AND c.Section IS NULL AND ar.ParentMeasure = ms.MetricID)
        )
        AND
        (
            -- keep your intent: include all open actions regardless of due date
            ar.ActionStatusC IN ('In Progress', 'Overdue')

            OR
            (
                ar.ActionStatusC IN ('Complete','Cancelled')
                AND
                (
                    -- DueDate in selected month
                    (ar.DueDate >= @MonthStart AND ar.DueDate < @NextMonthStart)

                    OR

                    -- (RAD - 1 month) in selected month
                    (DATEADD(MONTH, -1, ar.RAD) >= @MonthStart AND DATEADD(MONTH, -1, ar.RAD) < @NextMonthStart)
                )
            )
        )
)

SELECT
    ms.MetricID           AS UniqueID,
    ms.Unit,
    ms.TargetPercent,
    ms.YTDTargetPercent,

    y.YTDActual,
    y.YTDTarget,
    y.YTDPercent,
    a.*,

    JSON_QUERY(
      (
        SELECT
            b.MonthKey    AS [monthKey],
            b.MonthLabel  AS [monthLabel],
            b.ActualValue AS [actual],
            b.TargetValue AS [target]
        FROM Base b
        WHERE b.MetricID = ms.MetricID
        ORDER BY b.MonthDate
        FOR JSON PATH, INCLUDE_NULL_VALUES
      )
    ) AS MonthlyData,
    JSON_QUERY(
        ISNULL(
            (
                SELECT
                    ab.*,
                    ab.MetricMeasureName,
                    ab.ParentMeasureName
                FROM ActionsBase ab
                WHERE ab.ReportMetricID = ms.MetricID
                ORDER BY ab.DueDate DESC
                FOR JSON PATH, INCLUDE_NULL_VALUES
            ),
            '[]'
        )
    ) AS Actions

FROM MetricSet ms
LEFT JOIN YTD y
    ON y.MetricID = ms.MetricID
LEFT JOIN stng.VV_Metric_Main as a
    ON a.UniqueID = ms.MetricID
ORDER BY ms.MetricID;

			end
				
	end
