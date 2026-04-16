CREATE OR ALTER PROCEDURE [stng].[SP_Budgeting_UpdateStatusFlow] (
	@EmployeeID NVARCHAR(255) = NULL
	,@SDQUID BIGINT = NULL
	,@RecordType NVARCHAR(255) = NULL
	,@NextStatus NVARCHAR(255) = NULL
	,@Comment NVARCHAR(max) = NULL
)
AS
BEGIN
	DECLARE @CurrentStatus NVARCHAR(255)
		,@NextStatusID NVARCHAR(255)
		,@WorkingChecklistInstanceID UNIQUEIDENTIFIER
		,@WorkingSDQApprovalSetID UNIQUEIDENTIFIER

	IF(@RecordType = 'SDQ')
		BEGIN
			--Get CurrentStatus
			SELECT @CurrentStatus = StatusValue
			FROM stng.VV_Budgeting_SDQMain
			WHERE RecordTypeUniqueID = @SDQUID;

			--If CurrentStatus is ASMA, approve SMApproval record IF not CORR
			IF @CurrentStatus = 'ASMA' and @NextStatus <> 'CORR'
			BEGIN
				UPDATE stng.Budgeting_SDQ_Approval
				SET Approved = 1,
				ApprovalDate = stng.GetDate(),
				Comment = @Comment
				FROM stng.Budgeting_SDQ_Approval AS a
				INNER JOIN stng.VV_Budgeting_SDQ_Approval AS b on a.SDQApprovalID = b.SDQApprovalID
				WHERE b.SDQUID = @SDQUID and b.SDQApprovalType = 'SectionManager' and b.Approver = @EmployeeID;

				--Check IF all approvals are done; IF so, continue
				IF EXISTS
				(
					SELECT *
					FROM stng.VV_Budgeting_SDQ_Approval
					WHERE SDQUID = @SDQUID and SDQApprovalType = 'SectionManager' and Approved = 0
				)
				RETURN;

			END 

			ELSE IF @CurrentStatus = 'AVER' and @NextStatus <> 'CORR'
			BEGIN
				UPDATE stng.Budgeting_SDQ_Approval
				SET Approved = 1,
				ApprovalDate = stng.GetBPTime(GETDATE()),
				Comment = @Comment
				FROM stng.Budgeting_SDQ_Approval AS a
				INNER JOIN stng.VV_Budgeting_SDQ_Approval AS b on a.SDQApprovalID = b.SDQApprovalID
				WHERE b.SDQUID = @SDQUID and b.SDQApprovalType in ('Verifier','LeadPlanner') and b.Approver like '%' +  @EmployeeID + '%';

				--Check IF all approvals are done; IF so, continue
				IF exists
				(
					SELECT *
					FROM stng.VV_Budgeting_SDQ_Approval
					WHERE SDQUID = @SDQUID and SDQApprovalType in ('Verifier','LeadPlanner') and Approved = 0
				)
				RETURN;

			END
						
			--Perform status change	
			SELECT @NextStatusID = SDQStatusID
			FROM stng.Budgeting_SDQ_Status
			WHERE SDQStatus = @NextStatus;

			UPDATE stng.Budgeting_SDQMain
			SET StatusID = @NextStatusID
			WHERE SDQUID = @SDQUID;
													
			INSERT INTO stng.Budgeting_StatusLog([Type],RecordTypeUID,StatusID,Comment,CreatedBy) VALUES 
			('SDQ',@SDQUID, @NextStatusID,@Comment, @EmployeeID);

			--Post-status change actions				
			IF @NextStatus in ('CORR')
				BEGIN
					--Create new Checklist records (And new Checklist Instance)
					SET @WorkingChecklistInstanceID = newid();

					INSERT INTO stng.Budgeting_SDQ_Checklist_Instance
					(ChecklistInstanceID, RAB)
					values
					(@WorkingChecklistInstanceID, @EmployeeID);

					INSERT INTO stng.Budgeting_SDQ_Checklist_Instance_Question
					(ChecklistInstanceID, QuestionID, RAB, LUB)
					SELECT @WorkingChecklistInstanceID, UniqueID, @EmployeeID, @EmployeeID
					FROM stng.VV_Budgeting_SDQ_Checklist_Template
					WHERE SDQChecklistType <> 'LegacyVerifier';

					UPDATE stng.Budgeting_SDQ_Checklist_Instance_Mapping
					SET Active = 0
					WHERE SDQUID = @SDQUID;

					INSERT INTO stng.Budgeting_SDQ_Checklist_Instance_Mapping
					(ChecklistInstanceID, SDQUID, Active, RAB)
					values
					(@WorkingChecklistInstanceID, @SDQUID, 1, @EmployeeID);

					--Create new SDQApprovalSet
					SET @WorkingSDQApprovalSetID = newid();

					INSERT INTO stng.Budgeting_SDQ_Approval_Set
					(SDQApprovalSetID, RAB)
					values
					(@WorkingSDQApprovalSetID, @EmployeeID);

					UPDATE stng.Budgeting_SDQMain
					SET SDQApprovalSetID = @WorkingSDQApprovalSetID
					WHERE SDQUID = @SDQUID;

				END

			--Create Verifier and LeadPlanner records
			ELSE IF @NextStatus = 'AVER'
				BEGIN				

					INSERT INTO @ApprovalTemp
					(SDQApprovalID, SDQApprovalTypeID, RAB)
					SELECT newid(), a.SDQApprovalTypeID,  @EmployeeID
					FROM stng.Budgeting_SDQ_Approval_Type AS a
					WHERE a.SDQApprovalType in ('Verifier','LeadPlanner');

					INSERT INTO stng.Budgeting_SDQ_Approval
					(SDQApprovalID, SDQApprovalTypeID, PersonGroup, RAB)
					SELECT SDQApprovalID, SDQApprovalTypeID, PersonGroup, RAB
					FROM @ApprovalTemp;

					--Add mapping records
					SELECT top 1 @WorkingSDQApprovalSetID = SDQApprovalSetID
					FROM stng.VV_Budgeting_SDQMain
					WHERE RecordTypeUniqueID = @SDQUID;

					INSERT INTO stng.Budgeting_SDQ_Approval_Mapping
					(SDQApprovalID, SDQApprovalSetID, RAB)
					SELECT SDQApprovalID, @WorkingSDQApprovalSetID, @EmployeeID
					FROM @ApprovalTemp;

				END

			--Create SM Approval records
			ELSE IF @NextStatus = 'ASMA'
				BEGIN

					with p6records AS
					(
						SELECT PersonGroup
						FROM stngetl.VV_Budgeting_SDQ_P6_Discipline
						WHERE SDQUID = @SDQUID and LabourRemainingUnits >= 20
						union
						SELECT distinct b.PersonGroup
						FROM stngetl.VV_Budgeting_SDQ_P6_DeliverablesSummary AS a
						INNER JOIN stng.General_Organization_RespDisciplineCode_Mapping AS b on a.G4009BPResponsibleDiscipline = b.G4009BPResponsibleDiscipline
						WHERE a.SDQUID = @SDQUID and a.EndActualized = 0
						union
						SELECT Section AS PersonGroup
						FROM stng.VV_Budgeting_SDQMain
						WHERE RecordTypeUniqueID = @SDQUID
					)

					INSERT INTO @ApprovalTemp
					(SDQApprovalID, SDQApprovalTypeID, PersonGroup, RAB)
					SELECT newid(), a.SDQApprovalTypeID, b.PersonGroup, @EmployeeID
					FROM stng.Budgeting_SDQ_Approval_Type AS a, p6records AS b
					WHERE a.SDQApprovalType = 'SectionManager';

					INSERT INTO stng.Budgeting_SDQ_Approval
					(SDQApprovalID, SDQApprovalTypeID, PersonGroup, RAB)
					SELECT SDQApprovalID, SDQApprovalTypeID, PersonGroup, RAB
					FROM @ApprovalTemp;

					--Add mapping records
					SELECT top 1 @WorkingSDQApprovalSetID = SDQApprovalSetID
					FROM stng.VV_Budgeting_SDQMain
					WHERE RecordTypeUniqueID = @SDQUID;

					INSERT INTO stng.Budgeting_SDQ_Approval_Mapping
					(SDQApprovalID, SDQApprovalSetID, RAB)
					SELECT SDQApprovalID, @WorkingSDQApprovalSetID, @EmployeeID
					FROM @ApprovalTemp;

				END

			--If routing to APJMA FROM ADPA, SET PM Anticipated Due Date
			ELSE IF @NextStatus = 'APJMA'
				BEGIN

					IF @CurrentStatus = 'ADPA'
						BEGIN
						
							UPDATE stng.Budgeting_SDQMain
							SET PMAnticipatedApprovalDate = stng.FN_General_NextWorkDate(cast(stng.getbptime(getdate()) AS date), 10)
							WHERE SDQUID = @SDQUID;

						END

					IF @CurrentStatus in ('APRE','ADPA')
						BEGIN
								
							--Create CustomerApproval Record
							SET @WorkingCustomerApprovalID = NEWID();

							with allapprovals AS 
							(
								SELECT a.SDQUID, sum(b.ApprovalAmount) AS ApprovalAmount
								FROM stng.Budgeting_SDQ_CustomerApproval_Mapping AS a
								INNER JOIN stng.Budgeting_SDQ_CustomerApproval_2 AS b on a.CustomerApprovalID = b.CustomerApprovalID
								WHERE b.Approved = 1
								group by a.SDQUID
							),
							pastrevapprovals AS
							(
								SELECT a.SDQUID, sum(a.PreviouslyApprovedManual  + isnull(b.ApprovalAmount,0)) AS PreviouslyApproved
								FROM stng.VV_Budgeting_SDQ_PreviousRevision AS a
								left JOIN allapprovals AS b on a.PrevSDQUID = b.SDQUID
								WHERE a.SDQUID = @SDQUID
								group by a.SDQUID
							),
							pastpartialapprovals AS
							(
								SELECT a.SDQUID, sum(b.ApprovalAmount) AS ApprovalAmount
								FROM stng.Budgeting_SDQ_CustomerApproval_Mapping AS a
								INNER JOIN stng.Budgeting_SDQ_CustomerApproval_2 AS b on a.CustomerApprovalID = b.CustomerApprovalID
								WHERE b.Approved = 1 and a.SDQUID = @SDQUID
								group by a.SDQUID
							),
							previouslyapproved AS
							(
								SELECT a.SDQUID, a.PreviouslyApproved + isnull(b.ApprovalAmount,0) AS PreviouslyApproved
								FROM pastrevapprovals AS a
								left JOIN pastpartialapprovals AS b on a.SDQUID = b.SDQUID
							)

							INSERT INTO stng.Budgeting_SDQ_CustomerApproval_2
							(CustomerApprovalID, SunkCost, RemainingCII, FutureCV, PreviouslyApproved, RAB, LUB)
							SELECT @WorkingCustomerApprovalID, a.SunkCost, a.RemainingCII, a.FutureCost, b.PreviouslyApproved, @EmployeeID, @EmployeeID
							FROM stngetl.VV_Budgeting_SDQ_P6_EAC_2 AS a
							left JOIN previouslyapproved AS b on a.SDQUID = b.SDQUID
							WHERE a.SDQUID = @SDQUID;

							--Reset Active
							UPDATE stng.Budgeting_SDQ_CustomerApproval_Mapping
							SET Active = 0
							WHERE SDQUID = @SDQUID;

							INSERT INTO stng.Budgeting_SDQ_CustomerApproval_Mapping
							(CustomerApprovalID, SDQUID, RAB, Active)
							values
							(@WorkingCustomerApprovalID, @SDQUID, @EmployeeID, 1);


						END

				END

			--If routing FROM APGMA, approve In Progress Customer Approval record
			ELSE IF @CurrentStatus = 'APGMA' and @NextStatus not in ('NTAPP','PCSCR')
				BEGIN
								
					UPDATE stng.Budgeting_SDQ_CustomerApproval_2
					SET Approved = 1,
					ApprovalDate= stng.GetBPTime(GETDATE()),
					ApprovedBy = @EmployeeID
					FROM stng.Budgeting_SDQ_CustomerApproval_2 AS a
					INNER JOIN stng.Budgeting_SDQ_CustomerApproval_Mapping AS b on a.CustomerApprovalID = b.CustomerApprovalID and b.SDQUID = @SDQUID and b.Active = 1;

					IF @NextStatus = 'AOERC'
						BEGIN

							INSERT INTO stng.Budgeting_SDQ_RevisedCommitment
							(RunID, ActivityID, PriorCommitment, MaximumRevisedCommitmentDate, RevisedCommitmentDate, RAB)
							SELECT RunID, ActivityID, PriorCommitment, MaximumRevisedCommitmentDate, MaximumRevisedCommitmentDate, @EmployeeID
							FROM stng.VV_Budgeting_SDQ_RevisedCommitment_Preview
							WHERE SDQUID = @SDQUID;

						END

				END

	END -- RecordType = 'SDQ'

		-- PBRF
		ELSE IF(@RecordType = 'PBRF')
		BEGIN

			--RSS and Field Check
			--INSERT INTO @ReturnTbl
			--(NextStatus, ReturnMessage, ReturnMessageUnauthorized)
			--SELECT NextStatus, ReturnMessage, ReturnMessageUnauthorized
			--FROM stng.FN_Budgeting_Routing_RSSCheck_PBRF(@PBRID,@EmployeeID,@NextStatus);

			--Perform status change
			SELECT @NextStatusID = PBRFStatusID
			FROM stng.Budgeting_PBRF_Status
			WHERE PBRFStatus = @NextStatus;

			UPDATE stng.Budgeting_PBRMain
			SET StatusID = @NextStatusID
			WHERE PBRUID = @PBRID;
													
			INSERT INTO stng.Budgeting_StatusLog
			([Type],RecordTypeUID,StatusID,Comment,CreatedBy) 
			VALUES 
			('PBRF',@PBRID, @NextStatusID,@Comment, @EmployeeID);

			--Create new revision
			IF @NextStatus = 'SUPER'
				BEGIN
					SELECT @OldID = max(PBRID) FROM stng.Budgeting_PBRMain;

					IF @OldID IS NULL
						SET @NewID = 1;
					ELSE
						SET @NewID = @OldID + 1;

					SELECT @StartStatus = PBRFStatusID
					FROM stng.Budgeting_PBRF_Status
					WHERE PBRFStatus = 'INIT';

					INSERT INTO stng.Budgeting_PBRMain
					(PBRID, StatusID, RAB,CustomerNeedDate,FundingSource,InformationReferences,Objective, ProblemStatement,ProjectNo,ProjectTitle,RC,Scope,Section,Station,Revision) 
					SELECT @NewID, @StartStatus, @EmployeeID
						,A.CustomerNeedDate
						,A.FundingSource
						,A.InformationReferences
						,A.Objective
						,A.ProblemStatement
						,A.ProjectNo
						,A.ProjectTitle
						,A.RC
						,A.Scope
						,A.Section
						,A.Station
						,A.Revision + 1
					FROM stng.Budgeting_PBRMain A 
					WHERE PBRUID = @PBRID
					OPTION(optimize FOR (@EmployeeID unknown));
				
					SET @Num2 = SCOPE_IDENTITY();

					INSERT INTO stng.Budgeting_StatusLog
					([Type],RecordTypeUID,StatusID,CreatedBy) 
					VALUES 
					('PBRF',@Num2, @StartStatus,@EmployeeID);

					INSERT INTO stng.Budgeting_PBRFCostEstimate
					(Year1,Year2,PBRFUID,Internal,[External], CreatedBy,[Year])
					SELECT [Year1],Year2,@Num2,A.Internal,A.[External],@EmployeeID,A.[Year] 
					FROM stng.Budgeting_PBRFCostEstimate A 
					WHERE PBRFUID = @PBRID; 

					SELECT UniqueID AS PrimaryKey, Revision 
					FROM stng.VV_Budgeting_PBRFMain 
					WHERE RecordTypeUniqueID = @Num2;

				END
		END
		--DVN
		/*
		IF(@SubOp = 3)
		BEGIN
			SET @Value5 = (SELECT StatusID FROM stng.VV_Budgeting_DVNStatus V WHERE V.Value = @Value2)
			UPDATE stng.Budgeting_DVNMain
			SET StatusID = @Value5
			WHERE UniqueID = @Num1
			OPTION(optimize FOR (@Num1 unknown));
			INSERT INTO stng.Budgeting_StatusLog(Type,RecordTypeUID,StatusID,CreatedBy,Comment) VALUES ('DVN',@Num1, @Value5, @EmployeeID,@Value3);
		END
		*/
	END 
END