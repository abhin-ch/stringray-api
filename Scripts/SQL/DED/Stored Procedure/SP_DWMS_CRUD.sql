/****** Object:  StoredProcedure [stng].[SP_DWMS_CRUD]    Script Date: 8/16/2024 9:42:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [stng].[SP_DWMS_CRUD] (
									@Operation TINYINT,
									@CurrentUser VARCHAR(50) = null,
									
									@UniqueID varchar(40) = null,

									@Project varchar(MAX) = null,
									@Source varchar(MAX) = null,
									@SourceNum varchar(10) = null,
									@Type varchar(50) = null,
									@Rev varchar(10) = null,
									@SubJob varchar(50) = null,
									@SubJobNum varchar(50) = null,
									@Disciple varchar(50) = null,
									@Unit varchar(10) = null,
									@Category varchar(10) = null,
									@Drafter varchar(50) = null,
									@Checker varchar(50) = null,
									@Customer varchar(50) = null,
									@ReceivedDate datetime = null,
									@AssessedDate datetime = null,
									@StartedDate datetime = null,
									@RequiredDate datetime = null,
									@CompletedDate datetime = null,
									@TCD datetime = null,
									@Estimate varchar(10) = null,
									@Actual varchar(10) = null,
									@PercentComplete varchar(10) = null,
									@Status varchar(50) = null,
									@Comments varchar(MAX) = null,
									@Description varchar(MAX) = null,
									@RAD datetime = null,
									@RAB varchar(20) = null,
									@Owner varchar(20) = null,


									@DateType varchar(20) = null,

									@ActionID bigint = null,

									
									@Comment varchar(max) = null,
									@CommentID bigint = null,

									@Error int = NULL OUTPUT,
									@ErrorDescription VARCHAR(8000) = NULL OUTPUT)
AS
    BEGIN
	    BEGIN

		if @Operation = 1 --Get job
			begin
				
				SELECT [UniqueID]
					  ,[DWMSID]
					  ,[Project]
					  ,[Source]
					  ,[SourceNum]
					  ,[Type]
					  ,[Rev]
					  ,[SubJob]
					  ,[SubJobNum]
					  ,[Disciple]
					  ,[Unit]
					  ,[Category]
					  ,[Drafter]
					  ,[Checker]
					  ,[Customer]
					  ,[ReceivedDate]
					  ,[AssessedDate]
					  ,[StartedDate]
					  ,[RequiredDate]
					  ,[CompletedDate]
					  ,[TCD]
					  ,[Estimate]
					  ,[Actual]
					  ,[PercentComplete]
					  ,[Status]
					  ,[Comments]
					  ,[Description]
					  ,[RAD]
				FROM [stng].[DWMS_Job]
				order by RAD desc

			end

		else if @Operation = 2 --Add job
			begin

				declare @WorkingUUID uniqueidentifier = newid();

				INSERT INTO stng.DWMS_Job
				(UniqueID, Source, RAB, RAD)
				values
				(@WorkingUUID,@Source,@CurrentUser,stng.GetBPTime(getdate()));

			end

		else if @Operation = 3 --Edit job
			begin
				UPDATE stng.DWMS_Job SET
				[Project] = @Project,
				[Source] = @Source,
				[SourceNum] = @SourceNum,
				[Type] = @Type,
				[Rev] = @Rev,
				[SubJob] = @SubJob,
				[SubJobNum] = @SubJobNum,
				[Disciple] = @Disciple,
				[Unit] = @Unit,
				[Category] = @Category,
				[Drafter] = @Drafter,
				[Checker] = @Checker,
				[Customer] = @Customer,
				[ReceivedDate] = @ReceivedDate,
				[AssessedDate] = @AssessedDate,
				[StartedDate] = @StartedDate,
				[RequiredDate] = @RequiredDate,
				[CompletedDate] = @CompletedDate,
				[TCD] = @TCD,
				[Estimate] = @Estimate,
				[Actual] = @Actual,
				[PercentComplete] = @PercentComplete,
				[Status] = @Status,
				[Comments] = @Comments,
				[Description] = @Description,
				[Owner] = @Owner
				
				WHERE [UniqueID] = @UniqueID
			end	

		else if @Operation = 8 --Get Status Admin
			begin

				SELECT [UniqueID]
					  ,[Status]
					  ,[RAD]
					  ,[RAB]
				FROM stng.DWMS_Status

			end 
		
		else if @Operation = 9 --Add Status Admin
			begin

				INSERT INTO stng.DWMS_Status
				(Status, RAB, RAD)
				values
				(@Status,@CurrentUser,stng.GetBPTime(getdate()));

			end 

		else if @Operation = 10 --Remove Status Admin
			begin

				DELETE FROM stng.DWMS_Status
				WHERE UniqueID = @Status

			end 

		else if @Operation = 11 --Get Source Admin
			begin

				SELECT [UniqueID]
					  ,[Source]
					  ,[RAD]
					  ,[RAB]
				FROM stng.DWMS_Source

			end 
		
		else if @Operation = 12 --Add Source Admin
			begin

				INSERT INTO stng.DWMS_Source
				(Source, RAB, RAD)
				values
				(@Source, @CurrentUser,stng.GetBPTime(getdate()));

			end 

		else if @Operation = 13 --Remove Source Admin
			begin

				DELETE FROM stng.DWMS_Source
				WHERE UniqueID = @Source

			end 

		else if @Operation = 14 --Get Type Admin
			begin

				SELECT [UniqueID]
					  ,[Type]
					  ,[RAD]
					  ,[RAB]
				FROM stng.DWMS_Type

			end 
		
		else if @Operation = 15 --Add Type Admin
			begin

				INSERT INTO stng.DWMS_Type
				(Type, RAB,RAD)
				values
				(@Type, @CurrentUser,stng.GetBPTime(getdate()));

			end 

		else if @Operation = 16 --Remove Type Admin
			begin

				DELETE FROM stng.DWMS_Type
				WHERE UniqueID = @Type

			end 

		else if @Operation = 17 --Get Sub Job Admin
			begin

				SELECT [UniqueID]
					  ,[SubJob]
					  ,[RAD]
					  ,[RAB]
				FROM stng.DWMS_SubJob

			end 
		
		else if @Operation = 18 --Add Sub Job Admin
			begin

				INSERT INTO stng.DWMS_SubJob
				(SubJob, RAB, RAD)
				values
				(@SubJob, @CurrentUser,stng.GetBPTime(getdate()));

			end 

		else if @Operation = 19 --Remove Sub Job Admin
			begin

				DELETE FROM stng.DWMS_SubJob
				WHERE UniqueID = @SubJob

			end 
			
		else if @Operation = 20 --Get Category Admin
			begin

				SELECT [UniqueID]
					  ,[Category]
					  ,[RAD]
					  ,[RAB]
				FROM stng.DWMS_Category

			end 
		
		else if @Operation = 21 --Add Category Admin
			begin

				INSERT INTO stng.DWMS_Category
				([Category], RAB, RAD)
				values
				(@Category, @CurrentUser,stng.GetBPTime(getdate()));

			end 

		else if @Operation = 22 --Remove Category Admin
			begin

				DELETE FROM stng.DWMS_Category
				WHERE UniqueID = @Category

			end 

		else if @Operation = 23 --Get Disciple Admin
			begin

				SELECT [UniqueID]
					  ,[Disciple]
					  ,[RAD]
					  ,[RAB]
				FROM stng.DWMS_Disciple

			end 
		
		else if @Operation = 24 --Add Disciple Admin
			begin

				INSERT INTO stng.DWMS_Disciple
				([Disciple], RAB, RAD)
				values
				(@Disciple, @CurrentUser,stng.GetBPTime(getdate()));

			end 

		else if @Operation = 25 --Remove Disciple Admin
			begin

				DELETE FROM stng.DWMS_Disciple
				WHERE UniqueID = @Disciple

			end 

		else if @Operation = 26 --Get Unit Admin
			begin

				SELECT [UniqueID]
					  ,[Unit]
					  ,[RAD]
					  ,[RAB]
				FROM stng.DWMS_Unit

			end 
		
		else if @Operation = 27 --Add Unit Admin
			begin

				INSERT INTO stng.DWMS_Unit
				([Unit], RAB, RAD)
				values
				(@Unit, @CurrentUser,stng.GetBPTime(getdate()));

			end 

		else if @Operation = 28 --Remove Unit Admin
			begin

				DELETE FROM stng.DWMS_Unit
				WHERE UniqueID = @Unit

			end 

		else if @Operation = 29 --Get Drafter Admin
			begin

				SELECT [UniqueID]
					  ,[Drafter]
					  ,[RAD]
					  ,[RAB]
				FROM stng.DWMS_Drafter

			end 
		
		else if @Operation = 30 --Add Drafter Admin
			begin

				INSERT INTO stng.DWMS_Drafter
				([Drafter], RAB, RAD)
				values
				(@Drafter, @CurrentUser,stng.GetBPTime(getdate()));

			end 

		else if @Operation = 31 --Remove Drafter Admin
			begin

				DELETE FROM stng.DWMS_Drafter
				WHERE UniqueID = @Drafter

			end 

		else if @Operation = 32 --Get Checker Admin
			begin

				SELECT [UniqueID]
					  ,[Checker]
					  ,[RAD]
					  ,[RAB]
				FROM stng.DWMS_Checker

			end 
		
		else if @Operation = 33 --Add Checker Admin
			begin

				INSERT INTO stng.DWMS_Checker
				([Checker], RAB, RAD)
				values
				(@Checker, @CurrentUser,stng.GetBPTime(getdate()));

			end 

		else if @Operation = 34 --Remove Checker Admin
			begin

				DELETE FROM stng.DWMS_Checker
				WHERE UniqueID = @Checker

			end 

		else if @Operation = 35 --Get Customer Admin
			begin

				SELECT [UniqueID]
					  ,[Customer]
					  ,[RAD]
					  ,[RAB]
				FROM [stng].[DWMS_Customer]

			end 
		
		else if @Operation = 36 --Add Customer Admin
			begin

				INSERT INTO stng.DWMS_Customer
				([Customer], RAB, RAD)
				values
				(@Customer, @CurrentUser,stng.GetBPTime(getdate()));

			end 

		else if @Operation = 37 --Remove Customer Admin
			begin

				DELETE FROM stng.DWMS_Customer
				WHERE UniqueID = @Customer

			end 

		else if @Operation = 38 --Get Status log
			begin

				SELECT [UniqueID]
					  ,[DWMSID]
					  ,[StatusID]
					  ,[RAD]
					  ,[RAB]
				FROM [stng].[VV_DWMS_StatusLog]
				where DWMSID = @UniqueID
				order by RAD desc

			end 

		else if @Operation = 39 --Get Action Status Admin
			begin

				SELECT [UniqueID]
					  ,[Status]
					  ,[RAD]
					  ,[RAB]
				FROM [stng].[DWMS_JobAdminStatus]

			end 
		
		else if @Operation = 40 --Add Action Status Admin
			begin

				INSERT INTO [stng].[DWMS_JobAdminStatus]
				([Status], RAB, RAD)
				values
				(@Status, @CurrentUser,stng.GetBPTime(getdate()));

			end 

		else if @Operation = 41 --Remove Action Status Admin
			begin

				DELETE FROM [stng].[DWMS_JobAdminStatus]
				WHERE UniqueID = @Status

			end 

		else if @Operation = 42 --Get Job
			begin

				SELECT [UniqueID]
					  ,[DWMSID]
					  ,[Project]
					  ,[Source]
					  ,[SourceNum]
					  ,[Type]
					  ,[Rev]
					  ,[SubJob]
					  ,[SubJobNum]
					  ,[Disciple]
					  ,[Unit]
					  ,[Category]
					  ,[Drafter]
					  ,[Checker]
					  ,[Customer]
					  ,[ReceivedDate]
					  ,[AssessedDate]
					  ,[StartedDate]
					  ,[RequiredDate]
					  ,[CompletedDate]
					  ,[TCD]
					  ,[Estimate]
					  ,[Actual]
					  ,[PercentComplete]
					  ,[Status]
					  ,[Comments]
					  ,[Description]
					  ,[RAD]
				FROM [stng].[DWMS_Job]
				WHERE UniqueID = @UniqueID
			end 
	end
end