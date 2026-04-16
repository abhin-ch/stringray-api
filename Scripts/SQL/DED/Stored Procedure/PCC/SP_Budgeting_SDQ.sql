
CREATE OR ALTER procedure [stngetl].[SP_Budgeting_SDQ]
(
	@Operation int,
	
	@SDQUID bigint = null,
	@EmployeeID varchar(50) = null,
	@RunID varchar(250) = null,

	@ReturnUUID varchar(250) = null output,
	@ReturnProjectID varchar(20) = null output

)

as 
begin

	--Working variables
	declare @CurrentRunSubID int;
	declare @NewRunSubID int;

	--Add new run
	if @Operation = 1
		begin

			select @CurrentRunSubID = max(RunSubID)
			from stngetl.Budgeting_SDQ_Run
			where SDQUID = @SDQUID;

			if @CurrentRunSubID is null set @NewRunSubID = 1
			else set @NewRunSubID = @CurrentRunSubID + 1;

			insert into stngetl.Budgeting_SDQ_Run
			(SDQUID, RunSubID, RAB)
			values
			(@SDQUID,@NewRunSubID,@EmployeeID);

			select @ReturnUUID = RunID
			from stngetl.Budgeting_SDQ_Run
			where SDQUID = @SDQUID and RunSubID = @NewRunSubID;

			select @ReturnProjectID = ProjectNo
			from stng.Budgeting_SDQMain
			where SDQUID = @SDQUID;

			select @ReturnUUID as RunID,concat('ENG-',@ReturnProjectID) as ProjectID;
		end

	--Add completion time
	else if @Operation = 2
		begin

			update stngetl.Budgeting_SDQ_Run
			set PipelineCompleteTime = stng.GetBPTime(getdate())
			where RunID = @RunID;

			-- Refresh materialized ActivityResource table 
			EXEC stngetl.SP_Budgeting_P6_ActivityResource_RefreshMaterialized;

		end

end

