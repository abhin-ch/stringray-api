/****** Object:  StoredProcedure [stng].[SP_EI_CRUD]    Script Date: 1/7/2026 9:34:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [stng].[SP_EI_CRUD] (
									@Operation TINYINT,
									@SubOp int = null,

									@CurrentUser VARCHAR(50) = null,
									@UniqueID varchar(40) = null,
									@Title varchar(max) = null,
									@Details varchar(max) = null,
									@Section varchar(50) = null,
									@QualityRating varchar(40) = null,
									@Status varchar(40) = null,
									@Outcome varchar(50) = null,
									@FocusArea varchar(50) = null,
									@CR varchar(50) = null,
									@SubmissionDate date = null,
									@QualityScore decimal(10,2) = null,
									@ObservedGroup nvarchar(100) = null,
									@ErrorDetected bit = null,
									@Value1 AS varchar(250) = null,

									@MultiSelectList stng.TYPE_MultiSelectList READONLY,

									@AdminOptionText varchar(1000) = null,
      
																
									@Error INTEGER = NULL OUTPUT,
									@ErrorDescription VARCHAR(8000) = NULL OUTPUT)
AS
    BEGIN
		if @Operation = 1 -- Get Insights
			begin

				SELECT *
				FROM [stng].[VV_EI_Main]
				where RAB = @CurrentUser or StatusC = 'Submitted'
				order by RAD desc

			end 

		else if @Operation = 2 -- Create Insight
			begin

				SELECT top 1 @Section =  PersonGroup
				FROM stng.General_Organization 
				where Supervisor = @CurrentUser

				SELECT @Status = UniqueID
				FROM [stng].[EI_Status]
				where [Status] = 'DRAFT'
				
				SET @UniqueID = LOWER(newid())

				INSERT into [stng].[EI_Main]
				(UniqueID, InsightTitle, [Status], Section, RAB, LUB)
				values
				(@UniqueID,@Title, @Status, @Section, @CurrentUser, @CurrentUser)

				Select @UniqueID as UniqueID

			end
		else if @Operation = 3 -- Update Insight
			begin
			-- cannot update an insight that is in submitted status

				UPDATE [stng].[EI_Main]
				set
				[InsightTitle] = @Title,
				[InsightDetails] = @Details,
				[Section] = @Section,
				[QualityRating] = @QualityRating,
				[Outcome] = @Outcome,
				[FocusArea] = @FocusArea,
				[CR] = @CR,
				[SubmissionDate] = @SubmissionDate,
				[QualityScore] = @QualityScore,
				[ObservedGroup] = @ObservedGroup,
				[ErrorDetected] = @ErrorDetected,
				LUB = @CurrentUser,
				LUD = stng.GetBPTime(getdate())
				where UniqueID = @UniqueID

			end
		else if @Operation = 4 --Delete Insight
			begin
				
				if exists(select uniqueid
					from [stng].[EI_Main]
					where UniqueID = @UniqueID and RAB = @CurrentUser)

					begin
						UPDATE [stng].[EI_Main]
						set
						LUB = @CurrentUser,
						LUD = stng.GetBPTime(getdate()),
						Deleted =  1,
						DeletedBy = @CurrentUser,
						DeletedOn = stng.GetBPTime(getdate())
						where UniqueID = @UniqueID and RAB = @CurrentUser
					end
				else
					begin
						select 'You cannot delete a record that was not created by you' as ReturnMessage;
						return
					end
			end

		else if @Operation = 5 --Change Status
			begin
			--cannot change status if you are not the initiator
				declare @StatusID varchar(40) = null

				SELECT @StatusID = UniqueID
				FROM [stng].[EI_Status]
				where [Status] = @Status

				UPDATE [stng].[EI_Main]
				set
				[Status] = @StatusID,
				LUB = @CurrentUser,
				LUD = stng.GetBPTime(getdate())
				where UniqueID = @UniqueID

			end

		else if @Operation = 6 --Get Rating Options
			begin
			
				SELECT UniqueID, QualityRating
				FROM stng.EI_QualityRating
				where Deleted = 0
				order by SortOrder asc
			end

		else if @Operation = 7 --Get Section and Department data
			begin
			
				SELECT a.PersonGroup as UniqueID, a.[Description] as Section, b.[Description] as Department
				FROM stng.General_Organization as a
				left join stng.General_Organization as b on a.ParentPersonGroup = b.PersonGroup and a.[Type] = 'Section'
				where a.[Type] = 'Division' or a.[Type] = 'Department' or a.[Type] = 'Section'
			end


		-- Categories
		else if @Operation = 8 --Get All Categories
			begin

				SELECT UniqueID, Category
				FROM stng.EI_Category
				where Deleted = 0

			end 
		
		else if @Operation = 9 --Add Category Admin
			begin

				if exists(
					select UniqueID
					from stng.EI_Category
					where Category = @AdminOptionText and Deleted = 1
				)
					begin
						UPDATE stng.EI_Category
						set 
						Deleted = 0,
						DeletedBy = null,
						DeletedOn = null
					end

				else 
					begin

						INSERT INTO stng.EI_Category
						([Category], RAB)
						values
						(@AdminOptionText, @CurrentUser)

					end

			end 

		else if @Operation = 10 --Remove Category Admin
			begin

				UPDATE stng.EI_Category
				set
				Deleted = 1,
				DeletedBy = @CurrentUser,
				DeletedOn = stng.GetBPTime(getdate())
				WHERE UniqueID = @UniqueID

			end 

		else if @Operation = 11 --Get record Categories
			begin

				SELECT a.UniqueID, a.Category
				FROM [stng].[EI_Category_Map] as a
				inner join stng.EI_Category as b on a.Category = b.UniqueID and Deleted = 0
				WHERE EIID = @UniqueID 

			end 

		else if @Operation = 12 --Update Category
			begin
				
				DELETE stng.[EI_Category_Map]
				from stng.[EI_Category_Map] as a
				left join @MultiSelectList as b on a.Category = b.ID
				where EIID = @UniqueID and b.ID is null
				
				INSERT into stng.[EI_Category_Map]
				(EIID, Category, RAB)
				select @UniqueID, b.ID, @CurrentUser
				from stng.EI_Category as a 
				inner join @MultiSelectList as b on a.UniqueID = b.ID
				left join stng.[EI_Category_Map] as c on b.ID = c.Category and c.EIID = @UniqueID
				where c.Category is null

			end 

		-- Organization
		else if @Operation = 13 --Get All Organization
			begin

				SELECT UniqueID, Organization
				FROM stng.EI_Organization
				where Deleted = 0

			end 
		
		else if @Operation = 14 --Add Organization Admin
			begin

				if exists(
					select UniqueID
					from stng.EI_Organization
					where Organization = @AdminOptionText and Deleted = 1
				)
					begin
						UPDATE stng.EI_Organization
						set 
						Deleted = 0,
						DeletedBy = null,
						DeletedOn = null
					end

				else 
					begin

						INSERT INTO stng.EI_Organization
						([Organization], RAB)
						values
						(@AdminOptionText, @CurrentUser)

					end

			end 

		else if @Operation = 15 --Remove Organization Admin
			begin

				UPDATE stng.EI_Organization
				set
				Deleted = 1,
				DeletedBy = @CurrentUser,
				DeletedOn = stng.GetBPTime(getdate())
				WHERE UniqueID = @UniqueID

			end 

		else if @Operation = 16 --Get record Organization
			begin

				SELECT a.UniqueID, a.Organization
				FROM [stng].[EI_Organization_Map] as a
				inner join stng.EI_Organization as b on a.Organization = b.UniqueID and Deleted = 0
				WHERE EIID = @UniqueID 

			end 

		else if @Operation = 17 --Update Organization
			begin
				
				DELETE stng.[EI_Organization_Map]
				from stng.[EI_Organization_Map] as a
				left join @MultiSelectList as b on a.Organization = b.ID
				where EIID = @UniqueID and b.ID is null
				
				INSERT into stng.[EI_Organization_Map]
				(EIID, Organization, RAB)
				select @UniqueID, b.ID, @CurrentUser
				from stng.EI_Organization as a 
				inner join @MultiSelectList as b on a.UniqueID = b.ID
				left join stng.[EI_Organization_Map] as c on b.ID = c.Organization and c.EIID = @UniqueID
				where c.Organization is null

			end 

		-- Deliverable
		else if @Operation = 18 --Get All Deliverable
			begin

				SELECT UniqueID, Deliverable
				FROM stng.EI_Deliverable
				where Deleted = 0

			end 
		
		else if @Operation = 19 --Add Deliverable Admin
			begin

				if exists(
					select UniqueID
					from stng.EI_Deliverable
					where Deliverable = @AdminOptionText and Deleted = 1
				)
					begin
						UPDATE stng.EI_Deliverable
						set 
						Deleted = 0,
						DeletedBy = null,
						DeletedOn = null
					end

				else 
					begin

						INSERT INTO stng.EI_Deliverable
						([Deliverable], RAB)
						values
						(@AdminOptionText, @CurrentUser)

					end

			end 

		else if @Operation = 20 --Remove Deliverable Admin
			begin

				UPDATE stng.EI_Deliverable
				set
				Deleted = 1,
				DeletedBy = @CurrentUser,
				DeletedOn = stng.GetBPTime(getdate())
				WHERE UniqueID = @UniqueID

			end 

		else if @Operation = 21 --Get record Deliverable
			begin

				SELECT a.UniqueID, a.Deliverable
				FROM [stng].[EI_Deliverable_Map] as a
				inner join stng.EI_Deliverable as b on a.Deliverable = b.UniqueID and Deleted = 0
				WHERE EIID = @UniqueID 

			end 

		else if @Operation = 22 --Update Deliverable
			begin
				
				DELETE stng.[EI_Deliverable_Map]
				from stng.[EI_Deliverable_Map] as a
				left join @MultiSelectList as b on a.Deliverable = b.ID
				where EIID = @UniqueID and b.ID is null
				
				INSERT into stng.[EI_Deliverable_Map]
				(EIID, Deliverable, RAB)
				select @UniqueID, b.ID, @CurrentUser
				from stng.EI_Deliverable as a 
				inner join @MultiSelectList as b on a.UniqueID = b.ID
				left join stng.[EI_Deliverable_Map] as c on b.ID = c.Deliverable and c.EIID = @UniqueID
				where c.Deliverable is null

			end 

		-- Condition
		else if @Operation = 23 --Get All Condition
			begin

				SELECT UniqueID, Condition
				FROM stng.EI_Condition
				where Deleted = 0

			end 
		
		else if @Operation = 24 --Add Condition Admin
			begin

				if exists(
					select UniqueID
					from stng.EI_Condition
					where Condition = @AdminOptionText and Deleted = 1
				)
					begin
						UPDATE stng.EI_Condition
						set 
						Deleted = 0,
						DeletedBy = null,
						DeletedOn = null
					end

				else 
					begin

						INSERT INTO stng.EI_Condition
						([Condition], RAB)
						values
						(@AdminOptionText, @CurrentUser)

					end

			end 

		else if @Operation = 25 --Remove Condition Admin
			begin

				UPDATE stng.EI_Condition
				set
				Deleted = 1,
				DeletedBy = @CurrentUser,
				DeletedOn = stng.GetBPTime(getdate())
				WHERE UniqueID = @UniqueID

			end 

		else if @Operation = 26 --Get record Condition
			begin

				SELECT a.UniqueID, a.Condition
				FROM [stng].[EI_Condition_Map] as a
				inner join stng.EI_Condition as b on a.Condition = b.UniqueID and Deleted = 0
				WHERE EIID = @UniqueID 

			end 

		else if @Operation = 27 --Update Condition
			begin
				
				DELETE stng.[EI_Condition_Map]
				from stng.[EI_Condition_Map] as a
				left join @MultiSelectList as b on a.Condition = b.ID
				where EIID = @UniqueID and b.ID is null
				
				INSERT into stng.[EI_Condition_Map]
				(EIID, Condition, RAB)
				select @UniqueID, b.ID, @CurrentUser
				from stng.EI_Condition as a 
				inner join @MultiSelectList as b on a.UniqueID = b.ID
				left join stng.[EI_Condition_Map] as c on b.ID = c.Condition and c.EIID = @UniqueID
				where c.Condition is null

			end 
		
		-- Project
		else if @Operation = 28 --Get All Project
			begin

				SELECT distinct PROJECTID as UniqueID, PROJECTID as Project
				FROM stng.MPL

			end 

		else if @Operation = 29 --Get record Project
			begin

				SELECT a.UniqueID, a.Project
				FROM [stng].[EI_Project_Map] as a
				inner join stng.MPL as b on a.Project = b.PROJECTID 
				WHERE EIID = @UniqueID 

			end 

		else if @Operation = 30 --Update Project
			begin
				
				DELETE stng.EI_Project_Map
				from stng.EI_Project_Map as a
				left join @MultiSelectList as b on a.Project = b.ID
				where EIID = @UniqueID and b.ID is null
				
				INSERT into stng.EI_Project_Map
				(EIID, Project, RAB)
				select @UniqueID, b.ID, @CurrentUser
				from stng.MPL as a 
				inner join @MultiSelectList as b on a.PROJECTID = b.ID
				left join stng.EI_Project_Map as c on b.ID = c.Project and c.EIID = @UniqueID
				where c.Project is null

			end 

			-- Review
		else if @Operation = 31 --Get All Review
			begin

				SELECT UniqueID, Review
				FROM stng.EI_Review
				where Deleted = 0

			end 
		
		else if @Operation = 32 --Add Review Admin
			begin

				if exists(
					select UniqueID
					from stng.EI_Review
					where Review = @AdminOptionText and Deleted = 1
				)
					begin
						UPDATE stng.EI_Review
						set 
						Deleted = 0,
						DeletedBy = null,
						DeletedOn = null
					end

				else 
					begin

						INSERT INTO stng.EI_Review
						([Review], RAB)
						values
						(@AdminOptionText, @CurrentUser)

					end

			end 

		else if @Operation = 33 --Remove Review Admin
			begin

				UPDATE stng.EI_Review
				set
				Deleted = 1,
				DeletedBy = @CurrentUser,
				DeletedOn = stng.GetBPTime(getdate())
				WHERE UniqueID = @UniqueID

			end 

		else if @Operation = 34 --Get record Review
			begin

				SELECT a.UniqueID, a.Review
				FROM [stng].[EI_Review_Map] as a
				inner join stng.EI_Review as b on a.Review = b.UniqueID and Deleted = 0
				WHERE EIID = @UniqueID 

			end 

		else if @Operation = 35 --Update Review
			begin
				
				DELETE stng.[EI_Review_Map]
				from stng.[EI_Review_Map] as a
				left join @MultiSelectList as b on a.Review = b.ID
				where EIID = @UniqueID and b.ID is null
				
				INSERT into stng.[EI_Review_Map]
				(EIID, Review, RAB)
				select @UniqueID, b.ID, @CurrentUser
				from stng.EI_Review as a 
				inner join @MultiSelectList as b on a.UniqueID = b.ID
				left join stng.[EI_Review_Map] as c on b.ID = c.Review and c.EIID = @UniqueID
				where c.Review is null

			end 

			-- Outcome
		else if @Operation = 36 --Get All Outcome
			begin

				SELECT UniqueID, Outcome
				FROM stng.EI_Outcome
				where Deleted = 0

			end 
		
		else if @Operation = 37 --Add Outcome Admin
			begin

				if exists(
					select UniqueID
					from stng.EI_Outcome
					where Outcome = @AdminOptionText and Deleted = 1
				)
					begin
						UPDATE stng.EI_Outcome
						set 
						Deleted = 0,
						DeletedBy = null,
						DeletedOn = null
					end

				else 
					begin

						INSERT INTO stng.EI_Outcome
						([Outcome], RAB)
						values
						(@AdminOptionText, @CurrentUser)

					end

			end 

		else if @Operation = 38 --Remove Outcome Admin
			begin

				UPDATE stng.EI_Outcome
				set
				Deleted = 1,
				DeletedBy = @CurrentUser,
				DeletedOn = stng.GetBPTime(getdate())
				WHERE UniqueID = @UniqueID

			end 
			
		-- Focus Area

		
		else if @Operation = 39 --Get All Focus
				begin

					SELECT UniqueID, FocusArea
					FROM stng.EI_FocusArea
					where Deleted = 0

				end 

		else if @Operation = 40
			begin
		
			if @SubOp = 1 --Add FocusArea Admin
				begin

					if exists(
						select UniqueID
						from stng.EI_FocusArea
						where FocusArea = @AdminOptionText and Deleted = 1
					)
						begin
							UPDATE stng.EI_FocusArea
							set 
							Deleted = 0,
							DeletedBy = null,
							DeletedOn = null
						end

					else 
						begin

							INSERT INTO stng.EI_FocusArea
							([FocusArea], RAB)
							values
							(@AdminOptionText, @CurrentUser)

						end

				end 

			else if @SubOp = 2 --Remove FocusArea Admin
				begin

					UPDATE stng.EI_FocusArea
					set
					Deleted = 1,
					DeletedBy = @CurrentUser,
					DeletedOn = stng.GetBPTime(getdate())
					WHERE UniqueID = @UniqueID

				end 

			end

		-- Get list of CRs
		else if @Operation = 41
			begin
				SELECT distinct top 25 CR label, CR value 
				from stngetl.General_AllCR
				WHERE CR like  @Value1 + '%'
				ORDER BY CR
				option(optimize for (@Value1 unknown));
			end
			

		-- Verify CR
		else if @Operation = 42
			begin
				SELECT 
				CR label, CR value 
				FROM stngetl.General_AllCR
				WHERE CR = @Value1 
				ORDER BY CR
				option(optimize for (@Value1 unknown));
			end

		-- Get sec and dept dropdown
		else if @Operation = 43
			begin
				SELECT [PersonGroup] as UniqueID
				,[Description] as ObservedGroup
				FROM [stng].[General_Organization]
				where type in ('Department', 'Section') and PersonGroup is not null
			end

		-- Get insights report
		else if @Operation = 44
			begin
				with projects as (
					select EIID, string_agg(Project, '; ') as Projects
					from  [stng].[EI_Project_Map]
					group by EIID
				)

				SELECT ID, SubmissionDate as [Observation Date],  concat('"',REPLACE(InsightTitle, '"', '""'),'"') as [Insight Title], 
				Section, SectionC, DepartmentC, StatusC
				, QualityRatingC, QualityCategory, QualityCondition, SubjectDeliverable, SubjectOrganization
				,FocusAreaC
				,Review, OutcomeC, b.Projects
				, RAD, Initiator, concat('"',REPLACE(InsightDetails, '"', '""'),'"') as InsightDetails
				  FROM [stng].[VV_EI_Main] as a 
				  left join projects as b on a.UniqueID = b.EIID
				  where StatusC not in ( 'DRAFT', 'Private') 
				  order by RAD desc
			end
    END
