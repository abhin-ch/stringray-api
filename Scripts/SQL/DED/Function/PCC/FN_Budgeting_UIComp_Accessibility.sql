ALTER FUNCTION [stng].[FN_Budgeting_UIComp_Accessibility]
(	
	@RecordUID bigint,
	@EmployeeID varchar(20),
	@RecordType varchar(50),
	@RecordID varchar(50) = null
)
RETURNS @ReturnTbl table
(
	UIComp varchar(50),
	UICompType varchar(50),
	Visible bit,
	Editable bit,
	ReturnMessage varchar(250),
	ReturnMessageUnauthorized varchar(250)
)
AS
BEGIN

	-- Cache delegators to avoid repeated function calls
	DECLARE @Delegators TABLE (EmployeeID VARCHAR(255));
 
	INSERT INTO @Delegators (EmployeeID)
	SELECT EmployeeID 
	FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID);

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

	--Get current record fields
	declare @CurrentStatus varchar(20);
	declare @PCS varchar(20);
	declare @Verifier varchar(20);
	declare @VerifierActive varchar(20);
	declare @LeadPlanners varchar(100);
	declare @OE varchar(20);
	declare @PM varchar(20);
	declare @ProgM varchar(20);
	declare @DPTEPDM varchar(20);
	declare @DIVMDED varchar(20);
	declare @isEBS bit = 0;
	declare @Initiator varchar(20);
	declare @SM varchar(250);
	declare @SMActive varchar(250);
	declare @DM varchar(20);

	if exists
	(
		select 1
		from stng.VV_Admin_ActualUserPermission as a
		where EmployeeID IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A) 
		and Permission = 'Receive EBS Emails' and Origin in ('Direct Permission','Role, Direct Permission')
	)
	Set @isEBS = 1;

	if @RecordType in ('SDQ','PBRF')
		begin

			with leadplanners as
			(
				select string_agg(EmployeeID, ',') as leadplanners
				from stng.VV_Admin_ActualUserPermission
				where Permission = 'SDQ Visibility/Editability for Lead Planner'
			),
			divmded as
			(
				select Supervisor as DIVMDED
				from stng.General_Organization
				where PersonGroup = 'DIVDMES'
			),
			sdqsm as
			(
				select string_agg(Approver, ',') as sms
				from stng.VV_Budgeting_SDQ_Approval
				where SDQUID = @RecordUID and SDQApprovalType = 'SectionManager'
			)

			select @PCS = a.PCSID, 
			@Verifier = a.VerifierID, @LeadPlanners = b.leadplanners, 
			@OE = a.OEID, @PM = a.ProjMID, 
			@ProgM = a.ProgMID, @DPTEPDM = a.DMEPID, @DIVMDED = c.DIVMDED, @Initiator = a.CreatedBy, 
			@SM = case when a.[Type] = 'SDQ' then d.sms else a.SMID end, 
			@DM = a.DMID, 
			@CurrentStatus = a.StatusValue
			from stng.VV_Budgeting_Main as a, leadplanners as b, divmded as c,sdqsm as d
			where a.RecordTypeUniqueID = @RecordUID and a.[Type] = @RecordType;

			if @RecordType = 'SDQ'
				begin
					select @VerifierActive =  Approver
					from stng.VV_Budgeting_SDQ_Approval
					where SDQUID = @RecordUID and SDQApprovalType in ('Verifier') and Approved = 0;
				end

		end

	else if @RecordType = 'DVN'
		begin		
			select @PCS = a.PCSID, @Verifier = a.VerifierID, @OE = a.OEID, @PM = a.ProjMID, 
			@ProgM = a.ProgMID, @DPTEPDM = a.DMEPID, @SM = a.SMID,
			@CurrentStatus = a.StatusValue
			from stng.VV_Budgeting_Main as a
			where a.RecordID = @RecordID and a.[Type] = 'DVN';

		end

	if @CurrentStatus is null
		begin

			insert into @ReturnTbl
			(ReturnMessage)
			values
			('Record does not exist');
			return;

		end

	--Logic per RecordType
	declare @WorkingVisible bit = 0;
	declare @WorkingEditable bit = 0;

	--Add all tabs (Default invisible and RO)
	insert into @ReturnTbl
	(UIComp, UICompType, Visible, Editable)
	select UIComp, UICompType, 0, 0
	from stng.VV_Budgeting_UIComp
	where Submodule = @RecordType;

	-- if PCC Admin, return view all
	if exists 
	(
		SELECT * FROM stng.VV_Admin_ActualUserPermission
		WHERE EmployeeID = @EmployeeID AND Permission = 'BudgetingAdmin'
	)
	BEGIN
		update @ReturnTbl SET Visible = 1, Editable = 1
		return;
	END	

	if @RecordType = 'PBRF'
		begin
			--PBRF Header Editability
			if 
			(@CurrentStatus in ('INIT','CORR') and @Initiator IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A))
			or
			(@CurrentStatus in ('AEBSP','AAEBS') and @isEBS = 1)
				begin
					update @ReturnTbl
					set Editable = 1
					where UIComp = 'PBRFHeader';

				end

			--Header and Status Log Visibility
			if @Initiator IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A)
				set @WorkingVisible = 1;
			else if @CurrentStatus = 'ASMA' and (@SM IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A))
				set @WorkingVisible = 1;
			else if @CurrentStatus = 'ADMA' and (@SM IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A) 
			or @DM IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A))
				set @WorkingVisible = 1;
			else if @CurrentStatus = 'ADIVM' and (@SM IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A)
			or @DM IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A) 
			or @DIVMDED IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A))
				set @WorkingVisible = 1;
			else if @CurrentStatus = 'AEBSP' and (@SM IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A)
			or @DM IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A) 
			or @DIVMDED IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A)
			or @isEBS = 1)
				set @WorkingVisible = 1;
			else if @CurrentStatus = 'CANC' and @isEBS = 1
				set @WorkingVisible = 1;
			else if @CurrentStatus in ('AAEBS','NTAPP','APPC') and (@SM IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A)
			or @DM IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A)
			or @DIVMDED IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A) or @isEBS = 1)
				set @WorkingVisible = 1;

			update @ReturnTbl
			set Visible = @WorkingVisible;
			
		end

	else if @RecordType = 'DVN'
		begin

			--DVN Header Editability
			if @CurrentStatus in ('INIT','CORR','PCSCR') and @PCS IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A)
				begin
					update @ReturnTbl
					set Editable = 1
					where UIComp = 'DVNHeader' OR UIComp = 'P6'
				end

			--Header and Status Log Visibility
			if @PCS IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A)
				begin
					set @WorkingVisible = 1;
				end

			else if @CurrentStatus = 'AVER' and (@Verifier IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A))
				begin
					set @WorkingVisible = 1;
				end

			else if @CurrentStatus = 'AOEA' and (@OE IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A) 
			or @Verifier IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A))
				begin
					set @WorkingVisible = 1;
				end

			else if @CurrentStatus = 'ASMA' and (@SM IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A)
			or @OE IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A)
			or @Verifier IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A))
				begin
					set @WorkingVisible = 1;
				end

			else if @CurrentStatus = 'ADMA' and (@DPTEPDM IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A)
			or @SM IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A)
			or @OE IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A)
			or @Verifier IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A))
				begin
					set @WorkingVisible = 1;
				end			

			else if @CurrentStatus = 'APMA' and (@PM IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A)
			or @DPTEPDM IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A)
			or @SM IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A)
			or @OE IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A)
			or @Verifier IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A))
				begin
					set @WorkingVisible = 1;
				end	

			else if @CurrentStatus = 'PCSCR' and (@OE IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A))
				begin
					set @WorkingVisible = 1;
				end	

			else if @CurrentStatus = 'COMP' and (@PM IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A)
			or @DPTEPDM IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A)
			or @SM IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A)
			or @OE IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A)
			or @Verifier IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A))
				begin
					set @WorkingVisible = 1;
				end	

			update @ReturnTbl
			set Visible = @WorkingVisible;

		end

	else if @RecordType = 'SDQ'
		begin
			if @CurrentStatus in ('INIT','CORR')
				begin

					update @ReturnTbl
					set Visible = case when @PCS IN (SELECT A.EmployeeID FROM @Delegators A) or @isEBS = 1 then 1 else 0 end
					where UIComp in ('SDQHeader','P6','SelfCheck','StatusLog','RelatedTOQ');

					update @ReturnTbl
					set Editable = case when @PCS IN (SELECT A.EmployeeID FROM @Delegators A) then 1 else 0 end
					where UIComp in ('SDQHeader','P6','SelfCheck','RelatedTOQ');

				end

			else if @CurrentStatus = 'AVER'
				begin
	
					UPDATE @ReturnTbl
					SET Visible = CASE 
						WHEN 
							-- PCS is in delegators
							@PCS IN (SELECT A.EmployeeID FROM @Delegators A)
							OR EXISTS (
								SELECT 1
								FROM STRING_SPLIT(@LeadPlanners, ',') LP
								JOIN stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A
									ON TRIM(LP.value) = A.EmployeeID
							)
							OR @isEBS = 1
							OR @OE IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A)
							OR @Verifier IN (SELECT A.EmployeeID FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A)
						THEN 1 
						ELSE 0 
					END
					WHERE UIComp IN ('SDQHeader','P6','SelfCheck','Verification','PlannerCheck','StatusLog','MinorChange');

					UPDATE @ReturnTbl
					SET Editable = CASE 
						WHEN EXISTS (
							SELECT 1 
							FROM stng.FN_Admin_GetDelegatorsAndSelf(@EmployeeID) A
							WHERE A.EmployeeID = @VerifierActive
								OR A.EmployeeID IN (
									SELECT TRIM(value)
									FROM STRING_SPLIT(@LeadPlanners, ',')
								)
						)
						THEN 1 
						ELSE 0 
					END
					WHERE UIComp IN ('MinorChange');

					-- Update for 'Verification' UI component
					UPDATE @ReturnTbl
					SET Editable = 1
					WHERE UIComp = 'Verification'
					  AND @VerifierActive IN (SELECT EmployeeID FROM @Delegators);
 
					-- Update for 'PlannerCheck' UI component
					UPDATE @ReturnTbl
					SET Editable = 1
					WHERE UIComp = 'PlannerCheck'
					  AND EXISTS (
						SELECT 1
						FROM STRING_SPLIT(@LeadPlanners, ',') LP
						JOIN @Delegators D ON TRIM(LP.value) = CAST(D.EmployeeID AS VARCHAR)
					);
				end

			else if @CurrentStatus = 'AOEA'
				begin
				
					UPDATE R
					SET R.Visible = CASE 
						WHEN 
							@PCS = D.EmployeeID
							OR @Verifier = D.EmployeeID
							OR @isEBS = 1
							OR EXISTS (
								SELECT 1
								FROM STRING_SPLIT(@LeadPlanners, ',') LP
								WHERE TRIM(LP.value) = CAST(D.EmployeeID AS VARCHAR)
							)
							OR @OE = D.EmployeeID
						THEN 1 ELSE 0 
					END
					FROM @ReturnTbl R
					JOIN @Delegators D ON 1 = 1
					WHERE R.UIComp IN ('SDQHeader','P6','SelfCheck','StatusLog','MinorChange','RelatedTOQ');
 
					UPDATE @ReturnTbl
					SET Editable = 1
					WHERE UIComp IN ('MinorChange','RelatedTOQ')
					  AND @OE IN (SELECT EmployeeID FROM @Delegators);

				end

			else if @CurrentStatus = 'ASMA'
				begin
							
					UPDATE R
					SET R.Visible = CASE 
						WHEN 
							@PCS = D.EmployeeID
							OR @Verifier = D.EmployeeID
							OR @SM = D.EmployeeID
							OR @isEBS = 1
							OR @OE = D.EmployeeID
							OR EXISTS (
								SELECT 1
								FROM STRING_SPLIT(@LeadPlanners, ',') LP
								WHERE TRIM(LP.value) = CAST(D.EmployeeID AS VARCHAR)
							)
						THEN 1 ELSE 0 
					END
					FROM @ReturnTbl R
					JOIN @Delegators D ON 1 = 1
					WHERE R.UIComp IN (
						'SDQHeader','P6','SelfCheck','Verification','PlannerCheck','StatusLog','SMApproval','MinorChange'
					);
 
					-- Step 3: Update Editable for SM role
					UPDATE @ReturnTbl
					SET Editable = 1
					WHERE UIComp = 'MinorChange'
					  AND @SM IN (SELECT EmployeeID FROM @Delegators);

				end

			else if @CurrentStatus = 'ADPA'
				begin
					UPDATE R
					SET R.Visible = CASE 
						WHEN 
							@PCS = D.EmployeeID
							OR @Verifier = D.EmployeeID
							OR @SM = D.EmployeeID
							OR @DPTEPDM = D.EmployeeID
							OR @OE = D.EmployeeID
							OR @isEBS = 1
							OR EXISTS (
								SELECT 1
								FROM STRING_SPLIT(@LeadPlanners, ',') LP
								WHERE TRIM(LP.value) = CAST(D.EmployeeID AS VARCHAR)
							)
						THEN 1 ELSE 0
					END
					FROM @ReturnTbl R
					JOIN @Delegators D ON 1 = 1
					WHERE R.UIComp IN (
						'SDQHeader','P6','SelfCheck','Verification','PlannerCheck','StatusLog','SMApproval','MinorChange'
					);
 
					-- Step 3: Update Editable for DPTEPDM role
					UPDATE @ReturnTbl
					SET Editable = 1
					WHERE UIComp = 'MinorChange'
					  AND @DPTEPDM IN (SELECT EmployeeID FROM @Delegators);
				end

			else if @CurrentStatus = 'APCSC'
				begin
					UPDATE R
					SET R.Visible = CASE 
						WHEN 
							@PCS = D.EmployeeID
							OR @Verifier = D.EmployeeID
							OR @SM = D.EmployeeID
							OR @DPTEPDM = D.EmployeeID
							OR @OE = D.EmployeeID
							OR @isEBS = 1
							OR EXISTS (
								SELECT 1
								FROM STRING_SPLIT(@LeadPlanners, ',') LP
								WHERE TRIM(LP.value) = CAST(D.EmployeeID AS VARCHAR)
							)
						THEN 1 ELSE 0
					END
					FROM @ReturnTbl R
					JOIN @Delegators D ON 1 = 1
					WHERE R.UIComp IN (
						'SDQHeader','P6','SelfCheck','Verification','PlannerCheck','StatusLog','SMApproval','MinorChange','RelatedTOQ'
					);
 
					-- Step 3: Update Editable for PCS role
					UPDATE @ReturnTbl
					SET Editable = 1
					WHERE UIComp IN ('SDQHeader','P6','RelatedTOQ')
					  AND @PCS IN (SELECT EmployeeID FROM @Delegators);
				end

			else if @CurrentStatus = 'APJMA'
				begin						
					UPDATE R
					SET R.Visible = CASE
						WHEN
							D.EmployeeID IN (@PCS, @Verifier, @SM, @DPTEPDM, @OE)
							OR @isEBS = 1
							OR EXISTS (
								SELECT 1
								FROM STRING_SPLIT(@LeadPlanners, ',') LP
								WHERE TRIM(LP.value) = CAST(D.EmployeeID AS VARCHAR)
							)
							OR (
								@PM = D.EmployeeID AND 
								R.UIComp IN ('P6', 'SDQHeader', 'CustomerApproval', 'StatusLog','MinorChange')
							)
						THEN 1 ELSE 0
					END
					FROM @ReturnTbl R
					JOIN @Delegators D ON 1 = 1
					WHERE R.UIComp IN (
						'SDQHeader', 'P6', 'SelfCheck', 'Verification', 'PlannerCheck',
						'StatusLog', 'SMApproval', 'CustomerApproval', 'MinorChange'
					);
 
					-- Step 3: Update Editable
					UPDATE @ReturnTbl
					SET Editable = 1
					WHERE UIComp IN ('CustomerApproval','MinorChange')
					  AND @PM IN (SELECT EmployeeID FROM @Delegators);
				end

			else if @CurrentStatus = 'APGMA'
				begin

					UPDATE R
					SET R.Visible = CASE
						WHEN 
							-- Check if any of these match the EmployeeID
							@PCS = D.EmployeeID
							OR @Verifier = D.EmployeeID
							OR @OE = D.EmployeeID
							OR @SM = D.EmployeeID
							OR @DPTEPDM = D.EmployeeID
							OR @isEBS = 1
							-- Safe LeadPlanners matching
							OR EXISTS (
								SELECT 1
								FROM STRING_SPLIT(@LeadPlanners, ',') LP
								WHERE TRIM(LP.value) = CAST(D.EmployeeID AS VARCHAR)
							)
							-- Check for PM or ProgM for specific UI components
							OR ((@PM = D.EmployeeID OR @ProgM = D.EmployeeID) 
								AND R.UIComp IN ('P6', 'SDQHeader', 'CustomerApproval', 'StatusLog', 'MinorChange'))
						THEN 1 ELSE 0
					END
					FROM @ReturnTbl R
					JOIN @Delegators D ON 1 = 1
					WHERE R.UIComp IN (
						'SDQHeader', 'P6', 'SelfCheck', 'Verification', 'PlannerCheck', 
						'StatusLog', 'SMApproval', 'CustomerApproval', 'MinorChange'
					);
 
					-- Step 3: Update Editable for ProgM role
					UPDATE @ReturnTbl
					SET Editable = 1
					WHERE UIComp IN ('CustomerApproval','MinorChange')
					  AND @ProgM IN (SELECT EmployeeID FROM @Delegators);

				end

			else if @CurrentStatus in ('PCSCR','PCSCRPROG')
				begin
					UPDATE R
					SET R.Visible = CASE
						WHEN 
							-- Check if any of these match the EmployeeID
							@PCS = D.EmployeeID
							OR @isEBS = 1
							OR @OE = D.EmployeeID
							-- Check for PM or ProgM for specific UI components
							OR ((@PM = D.EmployeeID OR @ProgM = D.EmployeeID) 
								AND R.UIComp IN ('P6', 'SDQHeader', 'CustomerApproval', 'StatusLog'))
						THEN 1 ELSE 0
					END
					FROM @ReturnTbl R
					JOIN @Delegators D ON 1 = 1
					WHERE R.UIComp IN (
						'SDQHeader', 'P6', 'SelfCheck', 'Verification', 'PlannerCheck', 
						'StatusLog', 'SMApproval', 'CustomerApproval', 'MinorChange'
					);
				end

			else if @CurrentStatus = 'AOEFR'
				begin
					UPDATE R
					SET R.Visible = CASE
						WHEN 
							-- Check if any of these conditions match the EmployeeID
							@PCS = D.EmployeeID
							OR @Verifier = D.EmployeeID
							OR @isEBS = 1
							OR EXISTS (
								SELECT 1
								FROM STRING_SPLIT(@LeadPlanners, ',') LP
								WHERE TRIM(LP.value) = CAST(D.EmployeeID AS VARCHAR)
							)
							OR @OE = D.EmployeeID
							OR @SM = D.EmployeeID
							OR @DPTEPDM = D.EmployeeID
							-- Check for PM or ProgM for specific UI components
							OR ((@PM = D.EmployeeID OR @ProgM = D.EmployeeID) 
								AND R.UIComp IN ('P6', 'SDQHeader', 'CustomerApproval', 'StatusLog'))
						THEN 1 
						ELSE 0 
					END
					FROM @ReturnTbl R
					JOIN @Delegators D ON 1 = 1
					WHERE R.UIComp IN (
						'SDQHeader', 'P6', 'SelfCheck', 'Verification', 'PlannerCheck', 
						'StatusLog', 'SMApproval', 'CustomerApproval', 'MinorChange', 
						'FundingAllocation', 'RelatedTOQ'
					);
 
					UPDATE @ReturnTbl
					SET Editable = CASE 
						WHEN @OE IN (SELECT EmployeeID FROM @Delegators) 
						THEN 1 
						ELSE 0 
					END
					WHERE UIComp IN ('RelatedTOQ', 'FundingAllocation');
				end

			else if @CurrentStatus = 'AOERC'
				begin
					UPDATE R
					SET R.Visible = CASE
						WHEN 
							-- PCS matches EmployeeID
							@PCS = D.EmployeeID
							OR 
							-- Verifier matches EmployeeID
							@Verifier = D.EmployeeID
							OR 
							-- isEBS is set
							@isEBS = 1
							OR 
							-- LeadPlanners contains EmployeeID
							EXISTS (
								SELECT 1
								FROM STRING_SPLIT(@LeadPlanners, ',') LP
								WHERE TRIM(LP.value) = CAST(D.EmployeeID AS VARCHAR)
							)
							OR 
							-- OE matches EmployeeID
							@OE = D.EmployeeID
							OR 
							-- SM matches EmployeeID
							@SM = D.EmployeeID
							OR 
							-- DPTEPDM matches EmployeeID
							@DPTEPDM = D.EmployeeID
							OR 
							-- PM or ProgM for specific UI components
							((@PM = D.EmployeeID OR @ProgM = D.EmployeeID) 
								AND R.UIComp IN ('P6', 'SDQHeader', 'CustomerApproval', 'StatusLog'))
						THEN 1 
						ELSE 0 
					END
					FROM @ReturnTbl R
					JOIN @Delegators D ON 1 = 1  -- Ensures every row in @ReturnTbl is joined with delegators
					WHERE R.UIComp IN (
						'SDQHeader', 'P6', 'SelfCheck', 'Verification', 'PlannerCheck', 
						'StatusLog', 'SMApproval', 'CustomerApproval', 'RevisedCommitments', 'MinorChange'
					);
 
					-- Step 3: Update Editable based on PCS and OE conditions
					UPDATE @ReturnTbl
					SET Editable = CASE 
						WHEN @PCS IN (SELECT EmployeeID FROM @Delegators)
						OR @OE IN (SELECT EmployeeID FROM @Delegators)
						THEN 1 
						ELSE 0 
					END
					WHERE UIComp IN ('RevisedCommitments');
				end

			else if @CurrentStatus in ('APRE')
				begin
					UPDATE R
					SET R.Visible = CASE 
						WHEN 
							-- PCS matches EmployeeID
							@PCS = A.EmployeeID
							OR 
							-- Verifier matches EmployeeID
							@Verifier = A.EmployeeID
							OR 
							-- isEBS flag is set
							@isEBS = 1
							OR 
							-- LeadPlanners contains EmployeeID
							@LeadPlanners LIKE '%' + CAST(A.EmployeeID AS VARCHAR) + '%'
							OR 
							-- OE matches EmployeeID
							@OE = A.EmployeeID
							OR 
							-- SM matches EmployeeID
							@SM = A.EmployeeID
							OR 
							-- DPTEPDM matches EmployeeID
							@DPTEPDM = A.EmployeeID
							OR 
							-- PM or ProgM matches EmployeeID for specific UIComp values
							((@PM = A.EmployeeID OR @ProgM = A.EmployeeID) 
								AND UIComp IN ('P6','SDQHeader','CustomerApproval','StatusLog','RevisedCommitments'))
						THEN 1 
						ELSE 0 
					END
					FROM @ReturnTbl R
					CROSS APPLY (SELECT EmployeeID FROM @Delegators) A
					WHERE UIComp IN ('SDQHeader', 'P6', 'SelfCheck', 'Verification', 'PlannerCheck', 
									 'StatusLog', 'SMApproval', 'CustomerApproval', 'MinorChange', 
									 'RelatedTOQ', 'FundingAllocation', 'RevisedCommitments');

					UPDATE @ReturnTbl
					SET Editable = 1
					WHERE UIComp IN ('MinorChange')
						AND @PM IN (SELECT EmployeeID FROM @Delegators);
				end
			ELSE IF (@CurrentStatus = 'AFRE')
			BEGIN
				UPDATE R
					SET R.Visible = CASE 
						WHEN 
							-- PCS matches EmployeeID
							@PCS = A.EmployeeID
							OR 
							-- Verifier matches EmployeeID
							@Verifier = A.EmployeeID
							OR 
							-- isEBS flag is set
							@isEBS = 1
							OR 
							-- LeadPlanners contains EmployeeID
							@LeadPlanners LIKE '%' + CAST(A.EmployeeID AS VARCHAR) + '%'
							OR 
							-- OE matches EmployeeID
							@OE = A.EmployeeID
							OR 
							-- SM matches EmployeeID
							@SM = A.EmployeeID
							OR 
							-- DPTEPDM matches EmployeeID
							@DPTEPDM = A.EmployeeID
							OR 
							-- PM or ProgM matches EmployeeID for specific UIComp values
							((@PM = A.EmployeeID OR @ProgM = A.EmployeeID) 
								AND UIComp IN ('P6','SDQHeader','CustomerApproval','StatusLog','RevisedCommitments'))
						THEN 1 
						ELSE 0 
					END
					FROM @ReturnTbl R
					CROSS APPLY (SELECT EmployeeID FROM @Delegators) A
					WHERE UIComp IN ('SDQHeader', 'P6', 'SelfCheck', 'Verification', 'PlannerCheck', 
									 'StatusLog', 'SMApproval', 'CustomerApproval', 'MinorChange', 
									 'RelatedTOQ','RevisedCommitments');

				UPDATE @ReturnTbl
				SET Editable = 1
				WHERE UIComp IN ('MinorChange')
					AND @PM IN (SELECT EmployeeID FROM @Delegators);

			END
			else if @CurrentStatus = 'CANC'
				begin	
					UPDATE @ReturnTbl
					SET Editable = 1
					WHERE UIComp IN ('MinorChange')
					  AND @PM IN (SELECT EmployeeID FROM @Delegators);

					update R
					SET R.Visible = CASE
						WHEN
							D.EmployeeID IN (@PCS)
							OR @isEBS = 1						
							OR (
								@PM = D.EmployeeID AND 
								R.UIComp IN ('P6', 'SDQHeader', 'CustomerApproval', 'StatusLog','MinorChange')
							)
						THEN 1 ELSE 0
					END
					FROM @ReturnTbl R
					JOIN @Delegators D ON 1 = 1
					where UIComp in ('SDQHeader','P6','SelfCheck','StatusLog','RelatedTOQ','MinorChange');

				end
			else if @CurrentStatus = 'MIGR'
				begin
					update @ReturnTbl
					set Visible = case when @PCS IN  (SELECT EmployeeID FROM @Delegators)
					or @isEBS = 1 then 1 else 0 end
				end
		end

	-- if has PCCViewAll, need to enable visibility on appropriate tabs at all stages
	if exists
	(
		SELECT 1 FROM stng.VV_Admin_ActualUserPermission
		WHERE EmployeeID IN (SELECT EmployeeID FROM @Delegators) AND Permission = 'PCCViewAll'
	)
	BEGIN
		UPDATE @ReturnTbl 
		SET Visible = 1 
		WHERE 
		(@RecordType = 'PBRF'
		) OR
		(@RecordType = 'DVN'
		) OR
		(@RecordType = 'SDQ' AND
			(
				(@CurrentStatus = 'INIT' AND UIComp in ('SDQHeader','P6','SelfCheck','RelatedTOQ')) OR
				(@CurrentStatus = 'CORR' AND UIComp in ('SDQHeader','P6','SelfCheck','RelatedTOQ','Verification','PlannerCheck','MinorChange')) OR
				(@CurrentStatus = 'AVER' AND UIComp in ('SDQHeader','P6','SelfCheck','Verification','PlannerCheck','StatusLog','MinorChange','RelatedTOQ')) OR
				(@CurrentStatus = 'AOEA' AND UIComp in ('SDQHeader','P6','SelfCheck','StatusLog','MinorChange','RelatedTOQ','Verification','PlannerCheck')) OR
				(@CurrentStatus = 'ASMA' AND UIComp in ('SDQHeader','P6','SelfCheck','Verification','PlannerCheck','StatusLog','SMApproval','MinorChange','RelatedTOQ')) OR
				(@CurrentStatus = 'ADPA' AND UIComp in ('SDQHeader','P6','SelfCheck','Verification','PlannerCheck','StatusLog','SMApproval','MinorChange','RelatedTOQ')) OR
				(@CurrentStatus = 'APCSC' AND UIComp in ('SDQHeader','P6','SelfCheck','Verification','PlannerCheck','StatusLog','SMApproval','MinorChange','RelatedTOQ')) OR
				(@CurrentStatus = 'APJMA' AND UIComp in ('SDQHeader','P6','SelfCheck','Verification','PlannerCheck','StatusLog','SMApproval','CustomerApproval','MinorChange','RelatedTOQ')) OR
				(@CurrentStatus = 'APGMA' AND UIComp in ('SDQHeader','P6','SelfCheck','Verification','PlannerCheck','StatusLog','SMApproval','CustomerApproval','MinorChange','RelatedTOQ')) OR
				(@CurrentStatus in ('PCSCR','PCSCRPROG') AND UIComp in ('SDQHeader','P6','SelfCheck','Verification','PlannerCheck','StatusLog','SMApproval','CustomerApproval','MinorChange','RelatedTOQ')) OR
				(@CurrentStatus = 'AOEFR' AND UIComp in ('SDQHeader','P6','SelfCheck','Verification','PlannerCheck','StatusLog','SMApproval','CustomerApproval','MinorChange','FundingAllocation','RelatedTOQ')) OR
				(@CurrentStatus = 'AOERC' AND UIComp in ('SDQHeader','P6','SelfCheck','Verification','PlannerCheck','StatusLog','SMApproval','CustomerApproval','RevisedCommitments','MinorChange','RelatedTOQ')) OR
				(@CurrentStatus in ('APRE','AFRE') AND UIComp in ('SDQHeader','P6','SelfCheck','Verification','PlannerCheck','StatusLog','SMApproval','CustomerApproval','MinorChange','RelatedTOQ','FundingAllocation','RevisedCommitments')) OR
				(@CurrentStatus = 'CANC' AND UIComp in ('SDQHeader','P6','SelfCheck','StatusLog','RelatedTOQ','Verification','PlannerCheck','SMApproval')) OR
				(@CurrentStatus = 'MIGR')
			)
		)
		
	END
	return;
END
GO