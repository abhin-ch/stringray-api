CREATE OR ALTER PROCEDURE [stng].[SP_Budgeting_CreateSDQ](
	@ProjectID NVARCHAR(255) = NULL
	,@Phase NVARCHAR(255) = NULL
	,@EmployeeID NVARCHAR(255) = NULL
)
AS
BEGIN
	declare @NewID bigint;
	declare @maxPhase int;
	declare @WorkingChecklistInstanceID uniqueidentifier;
	declare @WorkingSDQApprovalSetID uniqueidentifier;
	declare @StartStatus uniqueidentifier;
	declare @ID bigint;
	DECLARE @Value6 NVARCHAR(4000);

	declare @WorkingSDQRecord table
	(
		SDQUID bigint,
		Phase int,
		Revision int
	);

	--ProjectID and Phase null/existence checks
	if @ProjectID is null or @Phase is null
		BEGIN

			SELECT 'ProjectID and Phase are required' as ReturnMessage;
			return;

		END 

	ELSE IF not exists
	(
		SELECT *
		FROM stng.VV_MPL_ENG
		where [Status] in ('Active','On Hold') and ProjectID = @ProjectID and PCSID = @EmployeeID
		
	) AND NOT EXISTS 
	(
		SELECT * FROM stng.VV_Admin_ActualUserPermission
		WHERE EmployeeID = @EmployeeID AND (Permission = 'BudgetingAdmin' OR Permission = 'PCCAdmin')
	)
		BEGIN
			SELECT 'ProjectID is not an active/on hold Engineering project or you are not the PCS listed for this project' as ReturnMessage;
			return;
		END

	ELSE IF not exists
	(
		SELECT *
		FROM stng.Budgeting_SDQ_Phase
		where Phase = @Phase
	)
		BEGIN

			SELECT 'Phase is not valid' as ReturnMessage;
			return;

		END

	--Check if there's an active SDQ revision against this project
	--TODO (Rewire with terminal statuses FROM NextStatus view)
	ELSE IF exists
	(
		SELECT * 
		FROM stng.Budgeting_SDQMain as a
		inner join stng.Budgeting_SDQ_Status as b on a.StatusID = b.SDQStatusID
		WHERE ProjectNo = @ProjectID AND b.SDQStatus not in ('CANC','AFRE','APRE','NTAPP')
	)
		BEGIN

			SELECT concat('Project ',@ProjectID, ' already has an active SDQ revision against it') as ReturnMessage;
			return;

		END 

	--Check if provided Phase is equal to or greater than max SDQ phase
	else
		BEGIN

			SELECT @maxPhase = max(Phase)
			FROM stng.VV_Budgeting_SDQMain
			WHERE ProjectNo = @ProjectID
			AND StatusValue != 'CANC'

			if @maxPhase is not null and @Phase < @maxPhase
				BEGIN
								
					SELECT concat('The latest Phase SDQ on Project ',@ProjectID,' is greater than the requested Phase. Please pick a Phase equal to or greater than Phase ',@maxPhase) 
					as ReturnMessage;
					return;

				END
						
		END

	-- CREATE SDQ
	SELECT @NewID = IIF(max(SDQID) IS NULL,1,max(SDQID)+1) 
	FROM stng.Budgeting_SDQMain;

	SELECT @StartStatus = SDQStatusID
	FROM stng.Budgeting_SDQ_Status 
	WHERE SDQStatus = 'INIT';
			
	declare @PhaseID uniqueidentifier;
	SELECT @PhaseID = SDQPhaseID
	FROM stng.Budgeting_SDQ_Phase
	where Phase = @Phase;

	declare @WorkingRevision int;
	SELECT @WorkingRevision = max(SubRevision)
	FROM stng.VV_Budgeting_SDQMain
	WHERE ProjectNo = @ProjectID
	AND PhaseID = @PhaseID

	if @WorkingRevision is null 
		BEGIN						
			set @WorkingRevision = 0;
		END
	else
		BEGIN
			set @WorkingRevision = @WorkingRevision + 1;

		END

		--Constants
	SELECT @Value6 = [Value] 
	FROM stng.Budgeting_SDQConstant 
	WHERE [Description] = 'AssumptionLong';

	INSERT INTO stng.Budgeting_SDQMain
	(SDQID, StatusID, Phase, Revision, ProjectNo, RAB, AssumptionLong, UseDQTrend) 
	VALUES
	(@NewID, @StartStatus, @PhaseID, @WorkingRevision, @ProjectID, @EmployeeID, @Value6, 1);

	SET @ID = SCOPE_IDENTITY();

	insert into @WorkingSDQRecord
	(SDQUID, Phase, Revision)
	SELECT top 1 a.PrevSDQUID, a.PrevSDQPhase, a.PrevSDQRevision
	FROM stng.VV_Budgeting_SDQ_PreviousRevision as a
	where a.SDQUID = @ID
	order by PrevSDQPhase desc, PrevSDQRevision desc;

	--/*Update SDQ Revision*/
	--	BEGIN
 			UPDATE A 
			SET 
				A.[FundingSource] = B.FundingSource
				,A.[Verifier] = B.Verifier
				--,A.[TargetDMApprovalDate] = B.TargetDMApprovalDate
				,A.[TargetExecutionWindow] = B.TargetExecutionWindow
				,A.[Complexity] = B.Complexity
				,A.[ProblemStatement] = B.ProblemStatement
				,A.[ProblemStatementLong] = B.ProblemStatementLong
				,A.[CurrentScopeDefinition] = B.CurrentScopeDefinition
				,A.[CurrentScopeDefinitionLong] = B.CurrentScopeDefinitionLong
				,A.[Assumption] = B.Assumption
				,A.[AssumptionLong] = B.AssumptionLong
				,A.[Risk] = B.Risk
				,A.[RiskLong] = B.RiskLong
				,A.[VarianceComment] = B.VarianceComment
				,A.LAMP3 = B.LAMP3
				,A.[PreviouslyApproved] = B.TotalApproved
				,A.[RequestedScope] = B.CurrentRequest
				,A.[NoTOQFunding] = B.NoTOQFunding
				,A.RevisionHeader = CONCAT('Previous DQ: ',B.Revision,' Approval Date: ',B.DMApprovalDate,' Approved Amount: $',B.CurrentRequest)
			FROM stng.Budgeting_SDQMain A
			CROSS APPLY 
			(
				SELECT x.*,C.CurrentRequest,C.TotalApproved, S.DMApprovalDate
				FROM stng.Budgeting_SDQMain as x
				inner join @WorkingSDQRecord as y on x.SDQUID = y.SDQUID	
				LEFT JOIN stng.VV_Budgeting_SDQ_CustomerApproval_2 C ON C.SDQUID = y.SDQUID
				LEFT JOIN (  
					SELECT [SDQUID], max(CreatedDate) as DMApprovalDate
					FROM stng.VV_Budgeting_SDQStatusLog
					WHERE [Status] = 'Awaiting Customer (PM) Approval'
					group by [SDQUID]
				) S ON S.SDQUID = X.SDQUID
			) as B
			WHERE A.SDQUID = @ID;

			INSERT INTO stng.Budgeting_SDQExecution
			(SDQUID,Execution,CreatedBy)
			SELECT @ID,a.Execution,@EmployeeID 
			FROM stng.Budgeting_SDQExecution as a
			inner join @WorkingSDQRecord as b on a.SDQUID = b.SDQUID;

			INSERT INTO stng.Budgeting_SDQUnit
			(SDQUID,Unit,CreatedBy)
			SELECT @ID,a.Unit,@EmployeeID 
			FROM stng.Budgeting_SDQUnit as a
			inner join @WorkingSDQRecord as b on a.SDQUID = b.SDQUID;

			insert into stng.Budgeting_SDQAMOT
			(SDQUID, AMOT, AMOTOption, CreatedDate, CreatedBy)
			SELECT @ID, a.AMOT, a.AMOTOption, stng.GetDate(), @EmployeeID
			FROM stng.Budgeting_SDQAMOT as a
			inner join @WorkingSDQRecord as b on a.SDQUID = b.SDQUID;


		--END
			
	INSERT INTO stng.Budgeting_StatusLog
	([Type],RecordTypeUID,[StatusID],CreatedBy) 
	VALUES 
	('SDQ',@ID,@StartStatus,@EmployeeID)
	OPTION(optimize FOR (@EmployeeID unknown));

	--Add Self Checklist records
	set @WorkingChecklistInstanceID = newid();

	insert into stng.Budgeting_SDQ_Checklist_Instance
	(ChecklistInstanceID, RAB)
	values
	(@WorkingChecklistInstanceID, @EmployeeID);

	insert into stng.Budgeting_SDQ_Checklist_Instance_Question
	(ChecklistInstanceID, QuestionID, RAB, LUB)
	SELECT @WorkingChecklistInstanceID, UniqueID, @EmployeeID, @EmployeeID
	FROM stng.VV_Budgeting_SDQ_Checklist_Template
	where SDQChecklistType <> 'LegacyVerifier';

	insert into stng.Budgeting_SDQ_Checklist_Instance_Mapping
	(ChecklistInstanceID, SDQUID, Active, RAB)
	values
	(@WorkingChecklistInstanceID, @ID, 1, @EmployeeID);

	--Create SDQApprovalSet
	set @WorkingSDQApprovalSetID = newid();

	insert into stng.Budgeting_SDQ_Approval_Set
	(SDQApprovalSetID, RAB)
	values
	(@WorkingSDQApprovalSetID, @EmployeeID);

	SET @WorkingChecklistInstanceID = newid();
	INSERT INTO stng.PCC_SDQ_Checklist(SDQUID,CreatedBy,UniqueID, [Current],ChecklistTypeID)
	SELECT @ID,@EmployeeID,@WorkingChecklistInstanceID, 1, ChecklistTypeID FROM stng.VV_PCC_ref_ChecklistType WHERE ChecklistType = 'OE'

	INSERT INTO stng.PCC_SDQ_ChecklistItem(CreatedBy,ChecklistID,QuestionID)
	SELECT @EmployeeID,@WorkingChecklistInstanceID,QuestionID FROM stng.VV_PCC_ref_ChecklistOE

	update stng.Budgeting_SDQMain
	set SDQApprovalSetID = @WorkingSDQApprovalSetID
	where SDQUID = @ID;

	SELECT CONCAT('SDQ-',@ID) PrimaryKey

END	
GO