ALTER PROCEDURE [stng].[SP_CMDS_CRUD] (
									@Operation TINYINT,
									@CurrentUser VARCHAR(50) = null,
									
									@UniqueID varchar(40) = null,

									@Title VARCHAR(MAX) = null,
									@Section varchar(40) = null,
									@WorkProgram varchar(40) = null,
									@GoalLevel varchar(200) = null,
									@Status varchar(200) = null,
									@Category varchar(200) = null,
									@Year varchar(200) = null,
									@Quarter varchar(200) = null,
									@Value varchar(200) = null,
									@ActionStatus varchar(2000) = null,
									@Description varchar(MAX) = null,
									@Owner varchar(20) = null,
									@AssignedTo varchar(20) = null,
									@Action varchar(2000) = null,
									@TCD datetime = null,
									@CompletionNotes varchar(MAX) = null,
									@DateType varchar(20) = null,

									@ActionID bigint = null,

									
									@Comment varchar(max) = null,
									@CommentID bigint = null,

									@Error int = NULL OUTPUT,
									@ErrorDescription VARCHAR(8000) = NULL OUTPUT)
AS
    BEGIN

		if @Operation = 1 --Get Goals
			begin
				
				SELECT *
				FROM stng.VV_CMDS_Main
				order by RAD desc
			end

		else if @Operation = 2 --Add Goal
			begin

				declare @WorkingUUID uniqueidentifier = newid();

				INSERT INTO stng.CMDS_Goal
				(UniqueID, Title, RAB)
				values
				(@WorkingUUID, @Title, @CurrentUser)

			end

		else if @Operation = 3 --Edit Goal
			begin

				declare @CurrentStatus varchar(200) = null

				SELECT @CurrentStatus = [Status]
				FROM stng.CMDS_Goal
				WHERE [UniqueID] = @UniqueID

				UPDATE stng.CMDS_Goal SET
				[Title] = @Title,
				[Section] = @Section,
				[WorkProgram] = @WorkProgram,
				[GoalLevel] = @GoalLevel,
				[Status] = @Status,
				[Description] = @Description,
				[Owner] = @Owner,
				[TCD] = @TCD,
				[CompletionNotes] = @CompletionNotes,
				[Year] = @Year,
				[Quarter] = @Quarter
				WHERE [UniqueID] = @UniqueID

				if (@CurrentStatus is NULL and @Status is not null) or @Status <> @CurrentStatus	
					begin
						INSERT into [stng].[CMDS_StatusLog]
						(CMDSID, StatusID, RAB)
						values
						(@UniqueID, @Status, @CurrentUser)
					end

			end		
		
		
		else if @Operation = 4 -- Get Comments
			begin

				SELECT a.UniqueID, a.Comment, a.RAD, b.EmpName as AddedBy
				FROM [stng].[CMDS_Comment] as a
				LEFT JOIN [stng].[VV_Admin_UserView] as b on a.RAB = b.EmployeeID
				WHERE a.CMDSID = @UniqueID and a.Deleted = 0
				order by a.RAD

			end


		else if @Operation = 5 --Add Comment
			begin
			
				insert into [stng].[CMDS_Comment]
				(CMDSID, Comment, RAD, RAB, LUB, LUD)
				values
				(@UniqueID, @Comment, GETDATE(), @CurrentUser, @CurrentUser, GETDATE());

				select SCOPE_IDENTITY() as CommentID

			end

		else if @Operation = 6 --Delete Comment
			begin

				update [stng].[CMDS_Comment]
				set Deleted = 1,
				LUD = GETDATE(),
				LUB = @CurrentUser,
				DeletedBy = @CurrentUser,
				DeletedOn = GETDATE()
				where UniqueID = @CommentID;

			end

		else if @Operation = 7 --Edit Comment
			begin

				update [stng].[CMDS_Comment]
				set Comment = @Comment,
				LUD = GETDATE(),
				LUB = @CurrentUser
				where UniqueID = @CommentID;

			end 

		else if @Operation = 8 --Get Status Admin
			begin

				SELECT *
				FROM stng.CMDS_Status
				where Deleted = 0

			end 
		
		else if @Operation = 9 --Add Status Admin
			begin

				if (SELECT count(Status)
					FROM [stng].[CMDS_Status]
					where Status = @Status) > 0
					begin

						UPDATE [stng].[CMDS_Status] set
						Deleted = 0,
						DeletedOn = Null,
						DeletedBy = @CurrentUser
						where Status = @Status

					end
				else
					begin
						INSERT INTO stng.CMDS_Status
						([Status], RAB)
						values
						(@Status, @CurrentUser)
					end

			end 

		else if @Operation = 10 --Remove Status Admin
			begin

				UPDATE [stng].[CMDS_Status] set
				Deleted = 1,
				DeletedBy = @CurrentUser,
				DeletedOn = [stng].[GetBPTime](getdate())
				WHERE UniqueID = @Status

			end 

		else if @Operation = 11 --Get Goal Level Admin
			begin

				SELECT *
				FROM stng.CMDS_GoalLevel

			end 
		
		else if @Operation = 12 --Add Goal Level Admin
			begin

				INSERT INTO stng.CMDS_GoalLevel
				(GoalLevel, RAB)
				values
				(@GoalLevel, @CurrentUser)

			end 

		else if @Operation = 13 --Remove Goal Level Admin
			begin

				DELETE FROM stng.CMDS_GoalLevel
				WHERE UniqueID = @GoalLevel

			end 

		else if @Operation = 14 --Get Work Program Admin
			begin

				SELECT *
				FROM stng.CMDS_WorkProgram

			end 
		
		else if @Operation = 15 --Add Work Program Admin
			begin

				INSERT INTO stng.CMDS_WorkProgram
				(WorkProgram, RAB)
				values
				(@WorkProgram, @CurrentUser)

			end 

		else if @Operation = 16 --Remove Work Program Admin
			begin

				DELETE FROM stng.CMDS_WorkProgram
				WHERE UniqueID = @WorkProgram

			end 

		else if @Operation = 17 --Get Section Admin
			begin

				SELECT *
				FROM stng.CMDS_AssignedSection

			end 
		
		else if @Operation = 18 --Add Section Admin
			begin

				INSERT INTO stng.CMDS_AssignedSection
				(AssignedSection, RAB)
				values
				(@Section, @CurrentUser)

			end 

		else if @Operation = 19 --Remove Section Admin
			begin

				DELETE FROM stng.CMDS_AssignedSection
				WHERE UniqueID = @Section

			end 

		else if @Operation = 20 --Get Actions
			begin

				SELECT *
				FROM stng.VV_CMDS_Action 
				WHERE CMDSID = @UniqueID and Deleted <> 1

			end 

		else if @Operation = 21 --Add Actions
			begin

				INSERT into stng.CMDS_Action
				([CMDSID], [Action], [ActionStatus], [ActionTCD], [ActionAssignedTo], [RAB], [LUB])
				values
				(@UniqueID, @Action, @ActionStatus, @TCD, @AssignedTo, @CurrentUser, @CurrentUser)

			end 

		else if @Operation = 22 --Edit Actions
			begin

				UPDATE stng.CMDS_Action
				SET
				[Action] = @Action,
				[ActionStatus] = @ActionStatus,
				[ActionTCD] = @TCD,
				[ActionAssignedTo] = @AssignedTo,
				[LUD] = [stng].[GetBPTime](getdate()),
				[LUB] = @CurrentUser
				WHERE UniqueID = @ActionID

			end 

		else if @Operation = 23 --Remove Actions
			begin

				UPDATE stng.CMDS_Action
				SET
				Deleted = 1,
				DeletedOn = [stng].[GetBPTime](getdate()),
				DeletedBy = @CurrentUser
				WHERE UniqueID = @ActionID

			end 

		else if @Operation = 24 --Get Date Admin
			begin

				SELECT *
				FROM stng.CMDS_Date
				WHERE DateType = @DateType
				Order By [Value] asc

			end 
		
		else if @Operation = 25 --Add Date Admin
			begin

				INSERT INTO stng.CMDS_Date
				(DateType, [Value], RAB)
				values
				(@DateType, @Value, @CurrentUser)

			end 

		else if @Operation = 26 --Remove Date Admin
			begin

				DELETE FROM stng.CMDS_Date
				WHERE UniqueID = @Value

			end 

			
		else if @Operation = 27 --Get Category Admin
			begin

				SELECT *
				FROM stng.CMDS_Category

			end 
		
		else if @Operation = 28 --Add Category Admin
			begin

				INSERT INTO stng.CMDS_Category
				([Category], RAB)
				values
				(@Category, @CurrentUser)

			end 

		else if @Operation = 29 --Remove Category Admin
			begin

				DELETE FROM stng.CMDS_Category
				WHERE UniqueID = @Category

			end 

		else if @Operation = 30 --Get Goal Category
			begin

				SELECT *
				FROM [stng].[CMDS_Category_Map]
				WHERE CMDSID = @UniqueID

			end 

		else if @Operation = 31 --Check Category
			begin

				SELECT DISTINCT Category
				FROM [stng].[CMDS_Category_Map]
				WHERE [CMDSID] = @UniqueID and [Category] = @Category

			end 

		else if @Operation = 32 --Add Category to Goal
			begin

				INSERT INTO [stng].[CMDS_Category_Map]
				([CMDSID], [Category], [RAB])
				values
				(@UniqueID, @Category, @CurrentUser)

			end 

		else if @Operation = 33 --Delete Category to Goal
			begin

				DELETE FROM [stng].[CMDS_Category_Map]
				WHERE [CMDSID] = @UniqueID and [Category] = @Category

			end 

		else if @Operation = 34 --Get Status log
			begin

				SELECT * 
				FROM [stng].[VV_CMDS_StatusLog]
				where CMDSID = @UniqueID
				order by RAD desc

			end 

		else if @Operation = 35 --Get Action Status Admin
			begin

				SELECT *
				FROM stng.CMDS_ActionStatus

			end 
		
		else if @Operation = 36 --Add Action Status Admin
			begin

				INSERT INTO stng.CMDS_ActionStatus
				([Status], RAB)
				values
				(@Status, @CurrentUser)

			end 

		else if @Operation = 37 --Remove Action Status Admin
			begin

				DELETE FROM stng.CMDS_ActionStatus
				WHERE UniqueID = @Status

			end 

		else if @Operation = 38 --Remove Goal
			begin

				UPDATE stng.CMDS_Goal
				set
				Deleted = 1,
				DeletedOn = stng.GetBPTime(getDate()),
				DeletedBy = @CurrentUser
				WHERE [UniqueID] = @UniqueID

			end 

    END
