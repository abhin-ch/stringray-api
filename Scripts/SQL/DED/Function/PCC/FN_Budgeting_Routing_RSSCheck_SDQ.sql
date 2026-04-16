CREATE OR ALTER FUNCTION [stng].[FN_Budgeting_Routing_RSSCheck_SDQ]
(	
	@SDQUID bigint,
	@EmployeeID varchar(20),
	@NextStatus varchar(20)
)
RETURNS @ReturnTbl table
(
	NextStatus varchar(20),
	NextStatusLong varchar(200),
	LabelOverride bit,
	ReturnMessage varchar(250),
	ReturnMessageUnauthorized varchar(250)
)
AS
BEGIN

	if not exists
	(
		select *
		from stng.Admin_User
		where Active = 1 and EmployeeID = @EmployeeID
	)
		begin

			insert into @ReturnTbl
			(ReturnMessageUnauthorized)
			values
			('EmployeeID does not exist');
			return;

		end

	--Get current record 
	declare @WorkingRecord table
	(
		SDQUID bigint,
		PCS varchar(20),
		PCSLead varchar(20),
		OE varchar(20),
		PM varchar(20),
		PMIsContractor bit,
		ProgM varchar(20),
		DPTEPDM varchar(20),
		CurrentStatus varchar(20),
		PMAnticipatedApprovalDate date
	);

	declare @RelevantApprovals table
	(
		Approver varchar(20),
		ApprovalType varchar(50)
	);

	insert into @RelevantApprovals
	(Approver, ApprovalType)
	select Approver, SDQApprovalType
	from stng.VV_Budgeting_SDQ_Approval
	where SDQUID = @SDQUID and Approved = 0;

	insert into @WorkingRecord
	(SDQUID, PCS, PCSLead, OE, PM, PMIsContractor, ProgM, DPTEPDM, CurrentStatus, PMAnticipatedApprovalDate)
	select RecordTypeUniqueID, PCSID, VerifierID, OEID, ProjMID, ProjMContractor, ProgMID, DMEPID, StatusValue, PMAnticipatedApprovalDate
	from stng.VV_Budgeting_SDQMain
	where RecordTypeUniqueID = @SDQUID;

	if not exists
	(
		select * from @WorkingRecord
	)
	begin

		insert into @ReturnTbl
		(ReturnMessage)
		values
		('SDQ does not exist');
		return;

	end

	--RSS Checks
	declare @CurrentStatus varchar(20);
	declare @PCS varchar(20);
	declare @PCSLead varchar(20);
	declare @OE varchar(20);
	declare @PM varchar(20);
	declare @PMIsContractor bit;
	declare @ProgM varchar(20);
	declare @DPTEPDM varchar(20);
	declare @PMAnticipatedApprovalDate date;
	select @CurrentStatus = CurrentStatus,
	@PCS = PCS, @PCSLead = PCSLead, @OE = OE, @PM = PM, @PMIsContractor = PMIsContractor, @ProgM = ProgM, @DPTEPDM = DPTEPDM,
	@PMAnticipatedApprovalDate = PMAnticipatedApprovalDate
	from @WorkingRecord;

	IF EXISTS(
		SELECT * FROM stng.VV_Admin_ActualUserPermission U WHERE U.EmployeeID = @EmployeeID AND Permission = 'PCCAdmin'
	) RETURN

	--INIT/CORR/APCSC
	--Must be the PCS
	if @CurrentStatus in ('INIT','CORR','APCSC','APRE','PCSCR','PCSCRPROG','APCSC') 
	and (@PCS NOT IN (SELECT EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID)) or @PCS is null)
		begin

			insert into @ReturnTbl
			(ReturnMessageUnauthorized)
			values
			('PCS can only alter this SDQ');
			return;
		
		end

	--AVER
	--Must be the PCS Lead, Lead Planner, or PCS 
	else if @CurrentStatus = 'AVER' and ((@PCS NOT IN (SELECT EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID)) or @PCS is null) and 
	not exists(
		select *
		from @RelevantApprovals
		CROSS APPLY (
			SELECT EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID)
		) D
		where Approver like '%' +  D.EmployeeID + '%' and ApprovalType in ('Verifier','LeadPlanner')
	))
		begin

			insert into @ReturnTbl
			(ReturnMessageUnauthorized)
			values
			('Verifiers/Lead Planners with Pending Approvals or PCS can only alter this SDQ');
			return;
		
		end

	--AOEA/AOEFR
	--Must be the OE (PCS can route AOEA)
	else if 
	(@CurrentStatus in ('AOEA','AOEFR') and (@OE NOT IN (SELECT EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID)) or @OE is null))
	and
	(@CurrentStatus = 'AOEA' and (@PCS NOT IN (SELECT EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID)) OR @PCS is null))
		begin

			insert into @ReturnTbl
			(ReturnMessageUnauthorized)
			values
			('Owner''s Engineer can only alter this SDQ');
			return;

		end

	--ASMA
	--Must be a SM or PCS
	else if @CurrentStatus = 'ASMA' and (not exists
	(
		select *
		from @RelevantApprovals
		where Approver IN (SELECT EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID)) and ApprovalType = 'SectionManager'
	) and (@PCS NOT IN (SELECT EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID)) or @PCS is null)
	)
		begin

			insert into @ReturnTbl
			(ReturnMessageUnauthorized)
			values
			('SM(s) with Pending Approvals or PCS can only alter this SDQ');
			return;

		end

	--ADPA
	--Must be the DM DPTEP or PCS
	else if @CurrentStatus = 'ADPA' and (@DPTEPDM NOT IN (SELECT EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID))
	and @PCS NOT IN (SELECT EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID)) or (@DPTEPDM is null or @PCS is null))
		begin

			insert into @ReturnTbl
			(ReturnMessageUnauthorized)
			values
			('Department Manager of DPTEP or PCS can only alter this SDQ');
			return;

		end

	--APJMA
	--Must be the PM
	else if @CurrentStatus = 'APJMA' and (@PM NOT IN (SELECT EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID)) or @PM is null)
		begin

			insert into @ReturnTbl
			(ReturnMessageUnauthorized)
			values
			('Project Manager can only alter this SDQ');
			return;

		end

	--APGMA
	--Must be the ProgM
	else if @CurrentStatus = 'APGMA' and (@ProgM NOT IN (SELECT EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID)) or @ProgM is null)
		begin

			insert into @ReturnTbl
			(ReturnMessageUnauthorized)
			values
			('Program Manager can only alter this SDQ');
			return;

		end

	--Get Next Statuses
	declare @NextStatuses table
	(
		NextStatus varchar(20),
		NextStatusLong varchar(200)
	);

	declare @NextStatusesAutomatic table
	(
		NextStatus varchar(20),
		NextStatusLong varchar(200),
		Permitted bit
	);
	
	--First, get the "simple" statuses (i.e., with no automatic checks)
	IF @PCS IN (SELECT EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID))
	and @CurrentStatus in ('AOEA','AVER','ASMA','ADPA')
		begin

			insert into @NextStatuses
			(NextStatus, NextStatusLong)
			select SDQStatus, concat('Route to ', SDQStatusLong)
			from stng.Budgeting_SDQ_Status 
			where SDQStatus in ('CANC','CORR');

		end

	else
		begin

			insert into @NextStatuses
			(NextStatus, NextStatusLong)
			select [Status], StatusLong
			from stng.VV_Budgeting_SDQ_Status
			where [ParentStatus] = @CurrentStatus and HasAutomaticCheck = 0;

			if @PCS IN (SELECT EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID))
			and @CurrentStatus in ('PCSCR','PCSCRPROG')
				begin

					insert into @NextStatuses
					(NextStatus, NextStatusLong)
					select SDQStatus, concat('Route to ', SDQStatusLong)
					from stng.Budgeting_SDQ_Status 
					where SDQStatus in ('CANC','CORR');

				end

		end

	--Next, get the "complex" statuses
	insert into @NextStatusesAutomatic
	(NextStatus, NextStatusLong, Permitted)
	select [Status], StatusLong, 0
	from stng.VV_Budgeting_SDQ_Status
	where [ParentStatus] = @CurrentStatus and HasAutomaticCheck = 1;

	if exists
	(
		select *
		from @NextStatusesAutomatic
	)
		begin

			--If APGMA
			if @CurrentStatus = 'APGMA'
				begin
					
					if stng.FN_General_WorkDateDelta(@PMAnticipatedApprovalDate,null) > 0
					and exists
					(
						select a.*
						from stngetl.VV_Budgeting_SDQ_P6_DeliverablesSummary as a
						where a.BPDQCommitment = 'DQ' and a.EndActualized = 0 and a.SDQUID = @SDQUID
					)
					and not exists
					(
						select *
						from stng.VV_Budgeting_SDQ_RevisedCommitment
						where SDQUID = @SDQUID
					)
						begin
												
							update @NextStatusesAutomatic
							set Permitted = 1
							where NextStatus = 'AOERC';

						end

					else if exists
					(
						select *
						from stng.VV_Budgeting_SDQ_CustomerApproval_2
						where SDQUID = @SDQUID and Active = 1 and IsPartial = 1
					)
						begin

							update @NextStatusesAutomatic
							set Permitted = 1
							where NextStatus = 'AOEFR';

						end

					else if exists
					(
						select *
						from stng.Budgeting_MinorChangeLog as a
						where a.SDQUID = @SDQUID
					)
						begin

							update @NextStatusesAutomatic
							set Permitted = 1
							where NextStatus = 'APCSC';

						end

					else
						begin

							update @NextStatusesAutomatic
							set Permitted = 1
							where NextStatus = 'AFRE';

						end
								

				end

			else if @CurrentStatus = 'AOERC'
				begin

					if exists
					(
						select *
						from stng.VV_Budgeting_SDQ_CustomerApproval_2
						where SDQUID = @SDQUID and Active = 1 and IsPartial = 1
					)
						begin

							update @NextStatusesAutomatic
							set Permitted = 1
							where NextStatus = 'AOEFR';

						end

					else if exists
					(
						select *
						from stng.Budgeting_MinorChangeLog as a
						where a.SDQUID = @SDQUID
					)
						begin

							update @NextStatusesAutomatic
							set Permitted = 1
							where NextStatus = 'APCSC';

						end

					else
						begin

							update @NextStatusesAutomatic
							set Permitted = 1
							where NextStatus = 'AFRE';

						end

				end

			else if @CurrentStatus = 'AOEFR'
				begin

					if exists
					(
						select *
						from stng.Budgeting_MinorChangeLog as a
						where a.SDQUID = @SDQUID
					)
						begin

							update @NextStatusesAutomatic
							set Permitted = 1
							where NextStatus = 'APCSC';

						end

					else
						begin

							update @NextStatusesAutomatic
							set Permitted = 1
							where NextStatus = 'APRE';

						end


				end

			else if @CurrentStatus = 'APCSC'
				begin

					if exists
					(
						select *
						from stng.VV_Budgeting_SDQ_CustomerApproval_2
						where SDQUID = @SDQUID and Active = 1 and IsPartial = 1
					)
						begin

							update @NextStatusesAutomatic
							set Permitted = 1
							where NextStatus = 'APRE';

						end

					else
						begin

							update @NextStatusesAutomatic
							set Permitted = 1
							where NextStatus = 'AFRE';

						end


				end


			insert into @NextStatuses
			(NextStatus, NextStatusLong)
			select NextStatus, NextStatusLong
			from @NextStatusesAutomatic
			where Permitted = 1;

		end

	--Field Checks
	if @NextStatus is not null
		begin
			
			--Check if @NextStatus is real
			if not exists
			(
				select *
				from stng.Budgeting_SDQ_Status
				where SDQStatus = @NextStatus
			)
				begin

					insert into @ReturnTbl
					(ReturnMessage)
					values
					('NextStatus does not exist');
					return;

				end

			--Check if @NextStatus = CurrentStatus
			else if @NextStatus = @CurrentStatus
				begin 

					insert into @ReturnTbl
					(ReturnMessage)
					values
					('SDQ is already at specified status. Routing must involve a different status');
					return;
				end

			--Check if NextStatus is permitted
			else if not exists
			(
				select *
				from @NextStatuses
				where NextStatus = @NextStatus
			)
				begin

					insert into @ReturnTbl
					(ReturnMessage)
					values
					('Requested NextStatus is not permitted on this SDQ');
					return;

				end

			declare @FieldCheckReturn table
			(
				ReturnMessage varchar(250)
			);

			declare @ChecklistType varchar(20);

			if exists
			(
				select *
				from @RelevantApprovals
				CROSS APPLY (
					SELECT EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID)
				) D
				where Approver like '%' +  D.EmployeeID + '%' and ApprovalType in ('LeadPlanner')
			)
				begin

					set @ChecklistType = 'Planner';

				end

			else if exists
			(
				select *
				from @RelevantApprovals
				where Approver IN (SELECT EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID))
				and ApprovalType in ('Verifier')
			)
				begin

					set @ChecklistType = 'Verifier';

				end

			--Activity field checks
			insert into @FieldCheckReturn
			(ReturnMessage)
			select ReturnMessage
			from stng.FN_Budgeting_Routing_FieldCheck_SDQ(@SDQUID, @NextStatus, @ChecklistType);

			if exists
			(
				select * 
				from @FieldCheckReturn
			)

				begin

					insert into @ReturnTbl
					(ReturnMessage)
					select ReturnMessage
					from @FieldCheckReturn;
					return;

				end

		end

	else
		begin

			insert into @ReturnTbl
			(NextStatus, NextStatusLong)
			select NextStatus, NextStatusLong
			from @NextStatuses;

		end

	return;
END
GO


