ALTER PROCEDURE [stng].[SP_ECRA_CRUD] (
	@Operation TINYINT,
	@SubOp int = null,

	@EmployeeID NVARCHAR(10) = null,
	@UniqueID varchar(40) = null,
	@EC varchar(100) = null,
	@Details varchar(max) = null,
	@Discipline varchar(40) = null,
	@PerceptionImpact int = null,
	@PerceptionProbability int = null,
	@FastTrack bit = null,
	@FirstInAWhile bit = null,
	@FirstTime bit = null,
	@Digital bit = null,
	@Knowledge int = null,
	@Skill int = null,
	@Familiarity int = null,
	@Understanding int = null,
	@Currency int = null,
	@PerceptionComment varchar(max) = null,
	@ProficiencyComment varchar(max) = null,
	@Value1 varchar(max) = null,
	@UniqueIDNum bigint = null,

	@SearchText varchar(50) = null,

	@MultiSelectList stng.TYPE_MultiSelectList READONLY,

	@AdminOptionText varchar(1000) = null
)
AS
    BEGIN
		if @Operation = 1 -- Get EC Risk
			begin

				Select distinct *
				From [stng].[VV_ECRA_Main_V2]
				union
				Select distinct *
				From [stng].[VV_ECRA_RelatedDCNs_V2]
				

				order by EC desc

			end 

		else if @Operation = 2 -- Add EC Risk
			begin

				INSERT into [stng].[ECRA_Main]
				(UniqueID, EC, RAB, LUB)
				values
				(@UniqueID, @EC, @EmployeeID, @EmployeeID)

				Select @EC as UniqueID

			end 

		else if @Operation = 3 -- Edit EC Risk
			begin

				if not exists(
					SELECT 1
					FROM [stng].[ECRA_Main]
					WHERE EC = @EC
				)
					begin
						INSERT into [stng].[ECRA_Main]
						(EC,Details, DisciplineType, ManagerRiskPerceptionImpact, ManagerRiskPerceptionProbability, Knowledge, Skill, Familiarity,
						Understanding, Currency, FastTrack, FirstInAWhile, FirstTime, Digital, PerceptionComment, ProficiencyComment, RAB, LUB)
						values
						(@EC, @Details, @Discipline, @PerceptionImpact, @PerceptionProbability, @Knowledge, @Skill, @Familiarity,
						@Understanding, @Currency, @FastTrack, @FirstInAWhile, @FirstTime, @Digital, @PerceptionComment, @ProficiencyComment, @EmployeeID, @EmployeeID)
						
					end
				else 
					begin
					
						UPDATE [stng].[ECRA_Main]
						set 
						Details = @Details,
						DisciplineType = @Discipline,
						ManagerRiskPerceptionImpact = @PerceptionImpact,
						ManagerRiskPerceptionProbability = @PerceptionProbability,
						Knowledge = @Knowledge,
						Skill = @Skill,
						Familiarity = @Familiarity,
						Understanding = @Understanding,
						Currency = @Currency,
						FastTrack = @FastTrack,
						FirstInAWhile = @FirstInAWhile,
						FirstTime = @FirstTime,
						Digital = @Digital,
						PerceptionComment = @PerceptionComment,
						ProficiencyComment = @ProficiencyComment,
						LUB = @EmployeeID,
						LUD = stng.GetBPTime(getdate())
						where EC = @EC
					end
				
			end 

		else if @Operation = 4 -- Remove EC Risk
			begin

				if exists(select 1
					from [stng].[VV_ECRA_Main]
					where UniqueID = @UniqueID and RAB = @EmployeeID)

					begin
						UPDATE [stng].[ECRA_Main]
						set
						LUB = @EmployeeID,
						LUD = stng.GetBPTime(getdate()),
						Deleted =  1,
						DeletedBy = @EmployeeID,
						DeletedOn = stng.GetBPTime(getdate())
						where EC = @EC and RAB = @EmployeeID
					end
				else
					begin
						select 'You cannot delete a record that was not created by you' as ReturnMessage;
						return
					end

			end 

		else if @Operation = 5 -- Search for ECs
			begin

				select distinct top 20 EC as [label], EC as [value]
				from [stngetl].[General_AllEC] as a
				where EC like '%' + @SearchText + '%'
				option(optimize for (@SearchText unknown));

			end 

		else if @Operation = 6 -- Verify valid EC
			begin

				select distinct EC as [label], EC as [value]
				from [stngetl].[General_AllEC] as a
				where EC = @SearchText
				option(optimize for (@SearchText unknown));

			end 

		ELSE IF @Operation = 7 -- Get Discipline
			BEGIN
				SELECT UniqueID, Discipline
				FROM [stng].[ECRA_Discipline]
				WHERE Deleted = 0
			
			END 

		else if @Operation = 8 -- Get AEL
			begin

				SELECT *
				FROM stngetl.General_AEL
				WHERE RecordKey = @EC
				option(optimize for (@EC unknown));

			end 

		else if @Operation = 9 -- Get Related DCNs
			begin

				Select distinct *
				From [stng].[VV_ECRA_RelatedDCNs_V2]
				where Parent = @EC
				order by EC desc

			end 

		else if @Operation = 10 --Perception Comments
			begin
				if @SubOp = 1
					begin

						select *
						from stng.VV_ECRA_PerceptionComment
						where EC = @EC
						order by CommentDate desc
						option(optimize for (@EC unknown));

					end

				else if @SubOp = 2
					begin

						INSERT into [stng].[ECRA_PerceptionComment] (
							EC
							,[Comment]
							,[RAB]
						)
						values 
						(@EC, @Value1, @EmployeeID)

					end

				else if @SubOp = 3
					begin

						UPDATE [stng].[ECRA_PerceptionComment] set
						[Deleted] = 1
						,[DeletedOn] = stng.GetBPTime(getdate())
						,[DeletedBy] = @EmployeeID
						where UniqueID = @UniqueIDNum

					end

				else if @SubOp = 4
					begin

						update [stng].[ECRA_PerceptionComment]
						set Comment = @Value1
						where UniqueID = @UniqueIDNum

					end
			end

		else if @Operation = 11 --Proficiency Comments
			begin
				if @SubOp = 1
					begin

						select *
						from stng.VV_ECRA_ProficiencyComment
						where EC = @EC
						order by CommentDate desc
						option(optimize for (@EC unknown));

					end

				else if @SubOp = 2
					begin

						INSERT into [stng].[ECRA_ProficiencyComment] (
							EC
							,[Comment]
							,[RAB]
						)
						values 
						(@EC, @Value1, @EmployeeID)

					end

				else if @SubOp = 3
					begin

						UPDATE [stng].[ECRA_ProficiencyComment] set
						[Deleted] = 1
						,[DeletedOn] = stng.GetBPTime(getdate())
						,[DeletedBy] = @EmployeeID
						where UniqueID = @UniqueIDNum

					end

				else if @SubOp = 4
					begin

						update [stng].[ECRA_ProficiencyComment]
						set Comment = @Value1
						where UniqueID = @UniqueIDNum

					end
			end

    END
