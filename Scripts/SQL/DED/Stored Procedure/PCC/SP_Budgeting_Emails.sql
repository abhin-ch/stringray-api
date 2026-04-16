/*
Author: Dawson Kelly
Description: Email Operations for PCC
CreatedDate: 8 Nov 2024
RevisedDate: 
RevisedBy:
*/
CREATE OR ALTER     PROCEDURE [stng].[SP_Budgeting_Emails] (
	@Operation INT
	,@SubOp		TINYINT = NULL
	,@EmployeeID NVARCHAR(255) = NULL
	,@Value1 NVARCHAR(255) = NULL
	,@Value2 NVARCHAR(255) = NULL
	,@Value3 NVARCHAR(255) = NULL
	,@Value4 NVARCHAR(255) = NULL
	,@Value5 NVARCHAR(max) = NULL
	,@Value6 NVARCHAR(max) = NULL
	,@Num1 INT = NULL
	,@Num2 INT = NULL
	,@Num3 INT = NULL
	,@IsTrue1 BIT = NULL
	,@IsTrue2 BIT = NULL
	,@Date1 DATETIME = NULL
	,@Date2 DATETIME = NULL
	,@MinorChanges [stng].[Budgeting_MinorChange] READONLY
	,@TrackChange BIT = NULL
	,@EmailName varchar(50) = NULL
	,@Activity varchar(255) = NULL
	,@ProjectID varchar(40) = null
	,@DVNID varchar(50) = null
	,@DVNNumber int = null
	,@ActivityID varchar(50) = null
	,@DVNActivityRevisedCommitmentDate datetime = null
	,@ReasonCodeID varchar(50) = null
	,@SCR varchar(20) = null
	,@NextStatus varchar(20) = null
	,@Comment varchar(500) =null
	,@DVNRationale varchar(500) = null
	,@VerifyActivity bit = 0
	,@SDQID bigint = null
	,@P6RunID varchar(50) = null
	,@Phase int = null
	,@RecordType varchar(20) = null
	,@PBRID bigint = null
	,@MyRecords bit = null
	,@SDSWPOverride int = null
	,@WBSCode varchar(50) = null
	,@CV bit = null
	,@RecordUID bigint = null
	,@ChecklistType varchar(50) = null
	,@InstanceQuestionID varchar(50) = null
	,@QuestionResponse varchar(10) = null
	,@ChecklistSupportingData varchar(500) = null
	,@CurrentApproval decimal(23,9) = null
	,@CurrentApprovalScope decimal(23,9) = null
	,@CustomerApprovalID varchar(50) = null
	,@RevisedCommitmentDate date = null
	,@TOQID varchar(50) = null
	,@DVNActivities stng.TYPE_Budgeting_DVNActivities readonly
	,@Legacy bit = 0
	,@ActivityNoChange bit = 0
	,@ScopeOrTrendID uniqueidentifier = null
	,@FundingAllocation decimal(23,2) =0
	,@RespOrg varchar(20) = null
	,@PipelineID varchar(50) = null
	,@MultipleVendor varchar(20) = null
)
AS

BEGIN
		/*
		1 -- Get Email Data
		*/
		IF (@Operation = 1)
		BEGIN
			--get main details (to be refactored into single select statements)
			IF (@SubOp = 1)
			BEGIN
				DECLARE @EmailType nvarchar (50) = 'Status Change General'

				DECLARE @RecipientTable table (
					RecipientEID nvarchar(10)
				);

				DECLARE @CCTable table(
					CCEID nvarchar(10)
				)

				DECLARE @EBSList table(
					EmployeeID nvarchar(10)
				);
				DECLARE @EBSSMList table(
					EmployeeID nvarchar(10)
				)
				DECLARE @BPProjectControlsTeam table(
					EmployeeID nvarchar(10)
				)
				DECLARE @PCSSMs table(
					EmployeeID nvarchar(10)
				)
				DECLARE @LeadPlanners table(
					EmployeeID nvarchar(10)
				)
				DECLARE @DigitalEngineeringReceiver table(
					EmployeeID nvarchar(10)
				)

				DECLARE @CurrentStatus varchar(20);

				INSERT INTO @EBSList
				SELECT DISTINCT EmployeeID FROM stng.VV_Admin_ActualUserPermission WHERE PermissionID = '336E4F3B-6D67-4D80-8E8F-3BEC1ABC309B'
				AND (Origin = 'Direct Permission' OR Origin = 'Direct Permission (Delegated)' OR Origin = 'Role, Direct Permission' OR Origin = 'Role, Direct Permission (Delegated)')
				

				INSERT INTO @EBSSMList
				SELECT DISTINCT EmployeeID FROM stng.VV_Admin_ActualUserPermission WHERE PermissionID = 'DAE6F225-D07E-4228-A3C3-8E149AF2ACCD'
				AND (Origin = 'Direct Permission' OR Origin = 'Direct Permission (Delegated)' OR Origin = 'Role, Direct Permission' OR Origin = 'Role, Direct Permission (Delegated)')
			
				INSERT INTO @BPProjectControlsTeam
				SELECT DISTINCT EmployeeID FROM stng.VV_Admin_ActualUserPermission WHERE PermissionID = '040D83C1-57E1-4601-9E40-16A02E9D9105'
				AND (Origin = 'Direct Permission' OR Origin = 'Direct Permission (Delegated)' OR Origin = 'Role, Direct Permission' OR Origin = 'Role, Direct Permission (Delegated)')
				
				INSERT INTO @PCSSMs
				SELECT DISTINCT EmployeeID FROM stng.VV_Admin_ActualUserPermission WHERE Permission = 'PCS SM Emails'
				AND (Origin = 'Direct Permission' OR Origin = 'Direct Permission (Delegated)' OR Origin = 'Role, Direct Permission' OR Origin = 'Role, Direct Permission (Delegated)')
				
				INSERT INTO @LeadPlanners
				SELECT DISTINCT EmployeeID FROM stng.VV_Admin_ActualUserPermission WHERE Permission = 'Lead Planner Emails'
				AND (Origin = 'Direct Permission' OR Origin = 'Direct Permission (Delegated)' OR Origin = 'Role, Direct Permission' OR Origin = 'Role, Direct Permission (Delegated)')

				INSERT INTO @DigitalEngineeringReceiver
				SELECT DISTINCT EmployeeID FROM stng.VV_Admin_ActualUserPermission WHERE PermissionID = '075DF5D9-6D5F-440F-9426-CEF989F4F231'
				AND (Origin = 'Direct Permission' OR Origin = 'Direct Permission (Delegated)' OR Origin = 'Role, Direct Permission' OR Origin = 'Role, Direct Permission (Delegated)')
		

				DECLARE @WorkingType varchar(255) = @RecordType

				IF (@WorkingType = 'PBRF')
				BEGIN
					SET @EmailType = 'Status Change PBRF'

					IF (@Value2 = 'INIT')--initiated
					BEGIN
						INSERT INTO @RecipientTable
						SELECT EmployeeID FROM @LeadPlanners
					END
					ELSE 
					IF (@Value2 = 'ASMA')--awaiting SM Approval
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_PBRFMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.SMID
						WHERE t.RecordTypeUniqueID = @Value1

						INSERT INTO @CCTable(CCEID)
						SELECT t.RequestFromID
						FROM stng.VV_Budgeting_PBRFMain t
						WHERE t.RecordTypeUniqueID = @Value1

					END

					ELSE IF (@Value2 = 'ADMA')--awaiting DM Approval
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_PBRFMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.DMID
						WHERE t.RecordTypeUniqueID = @Value1

						INSERT INTO @CCTable(CCEID)
						SELECT t.SMID
						FROM stng.VV_Budgeting_PBRFMain t
						WHERE t.RecordTypeUniqueID = @Value1
						UNION
						SELECT t.RequestFromID
						FROM stng.VV_Budgeting_PBRFMain t
						WHERE t.RecordTypeUniqueID = @Value1
					END
				
					ELSE IF (@Value2 = 'AEBSP')--awaiting EBS Processing
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM @EBSList t
						JOIN stng.Admin_User u ON u.EmployeeID = t.EmployeeID
				
						INSERT INTO @CCTable(CCEID)
						SELECT t.RequestFromID
						FROM stng.VV_Budgeting_PBRFMain t
						WHERE t.RecordTypeUniqueID = @Value1
						UNION
						SELECT t.DMID
						FROM stng.VV_Budgeting_PBRFMain t
						WHERE t.RecordTypeUniqueID = @Value1
						UNION
						SELECT t.SMID
						FROM stng.VV_Budgeting_PBRFMain t
						WHERE t.RecordTypeUniqueID = @Value1
					END
				
					ELSE IF (@Value2 = 'ADIVM')--awaiting DivM approval
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_PBRFMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.DivMID
						WHERE t.RecordTypeUniqueID = @Value1

						INSERT INTO @CCTABLE(CCEID)
						SELECT t.SMID
						FROM stng.VV_Budgeting_PBRFMain t
						WHERE t.RecordTypeUniqueID = @Value1
						UNION
						SELECT t.DMID
						FROM stng.VV_Budgeting_PBRFMain t
						WHERE t.RecordTypeUniqueID = @Value1
						UNION
						SELECT t.RequestFromID
						FROM stng.VV_Budgeting_PBRFMain t
						WHERE t.RecordTypeUniqueID = @Value1
						UNION
						SELECT EmployeeID
						FROM @EBSList
					END
				
					ELSE IF (@Value2 = 'AAEBS')--approved awaiting EBS
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM @EBSList t
						JOIN stng.Admin_User u ON u.EmployeeID = t.EmployeeID

						INSERT INTO @CCTABLE(CCEID)
						SELECT t.SMID
						FROM stng.VV_Budgeting_PBRFMain t
						WHERE t.RecordTypeUniqueID = @Value1
						UNION
						SELECT t.DMID
						FROM stng.VV_Budgeting_PBRFMain t
						WHERE t.RecordTypeUniqueID = @Value1
						UNION
						SELECT t.RequestFromID
						FROM stng.VV_Budgeting_PBRFMain t
						WHERE t.RecordTypeUniqueID = @Value1
					END
				
					ELSE IF (@Value2 = 'APPC')--approved AND complete
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT au.EmployeeID
						FROM stng.VV_Budgeting_PBRFMain tm
						JOIN stng.Admin_User au ON au.EmployeeID = tm.RequestFromID
						WHERE tm.RecordTypeUniqueID = @Value1;

						INSERT INTO @CCTABLE(CCEID)
						SELECT t.SMID
						FROM stng.VV_Budgeting_PBRFMain t
						WHERE t.RecordTypeUniqueID = @Value1
						UNION
						SELECT t.DMID
						FROM stng.VV_Budgeting_PBRFMain t
						WHERE t.RecordTypeUniqueID = @Value1
						UNION
						SELECT EmployeeID
						FROM @EBSList
						UNION
						SELECT EmployeeID
						FROM @PCSSMs
						UNION
						SELECT EmployeeID
						FROM @LeadPlanners
						UNION
						SELECT EmployeeID
						FROM @EBSSMList


						SET @EmailType = 'Notification PBRF';

					END
				
					ELSE IF (@Value2 = 'CANC')--cancelled
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT au.EmployeeID
						FROM stng.VV_Budgeting_PBRFMain tm
						JOIN stng.Admin_User au ON au.EmployeeID = tm.RequestFromID
						WHERE tm.RecordTypeUniqueID = @Value1;
						SET @EmailType = 'Notification PBRF';
					END
				
					ELSE IF (@Value2 = 'NTAPP')--not approved
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT au.EmployeeID
						FROM stng.VV_Budgeting_PBRFMain tm
						JOIN stng.Admin_User au ON au.EmployeeID = tm.RequestFromID
						WHERE tm.RecordTypeUniqueID = @Value1;
						--include customer, posibly multiple
						SET @EmailType = 'Notification PBRF'

						INSERT INTO @CCTABLE(CCEID)
						SELECT @EmployeeID
						FROM stng.VV_Budgeting_PBRFMain t
						WHERE t.RecordTypeUniqueID = @Value1 and (@EmployeeID = t.DMID or @EmployeeID = t.SMID or @EmployeeID in (SELECT EmployeeID FROM @EBSList))
					END
				
					ELSE IF (@Value2 = 'ICORR' OR @Value2 = 'CORR')--initial correction required
					--PCS, usually initiator
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_PBRFMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.RequestFromID
						WHERE t.RecordTypeUniqueID = @Value1

						INSERT INTO @CCTable(CCEID)
						SELECT @EmployeeID
						FROM stng.VV_Budgeting_PBRFMain t
						WHERE t.RecordTypeUniqueID = @Value1 and (@EmployeeID = t.SMID or @EmployeeID = t.DMID) 
				
					END
				
					ELSE IF (@Value2 = 'SUPER')--superceded
					BEGIN
						--notification, was superceded by another request
						SELECT au.EmployeeID
						FROM stng.VV_Budgeting_PBRFMain tm
						JOIN stng.Admin_User au ON au.EmployeeID = tm.SMID OR au.EmployeeID = tm.DMID OR au.EmployeeID = tm.DivMID OR au.EmployeeID = tm.RequestFromID
						WHERE tm.RecordTypeUniqueID = @Value1
						SET @EmailType = 'Notification PBRF'
					END

					--include all stakeholders in CC
					--INSERT INTO @CCTable(CCEID)
					--SELECT au.EmployeeID
					--FROM stng.VV_Budgeting_PBRFMain tm
					--JOIN stng.Admin_User au ON au.EmployeeID = tm.SMID OR au.EmployeeID = tm.DMID OR au.EmployeeID = tm.DivMID OR au.EmployeeID = tm.RequestFromID
					--WHERE tm.RecordTypeUniqueID = @Value1

					(SELECT uv.Username AS EmailTo, uv.EmpName AS Recipient 
					FROM @RecipientTable r
					JOIN stng.VV_Admin_UserView uv on uv.EmployeeID = r.RecipientEID
					WHERE uv.EmpName is not null
					UNION
					SELECT alt.AlternateEmail AS EmailTo, uv.EmpName AS Recipient
					FROM @RecipientTable r
					JOIN stng.Admin_UserAlternateEmail alt on alt.EmployeeID = r.RecipientEID
					JOIN stng.VV_Admin_UserView uv on uv.EmployeeID = r.RecipientEID
					WHERE alt.AlternateEmail is not null
					
					);
					
					
					(SELECT au.Username AS EmailCC FROM stng.Admin_User au JOIN @CCTable e ON au.EmployeeID = e.CCEID WHERE au.Username is not null
					UNION
					SELECT DISTINCT alt.AlternateEmail AS EmailCC FROM stng.Admin_UserAlternateEmail alt JOIN @CCTable e on alt.EmployeeID = e.CCEID WHERE alt.AlternateEmail is not null
					);
					
					
					SELECT
					@WorkingType AS Workflow,
					be.EmailBody AS EmailBody,
					be.EmailSubject,
					tm.RequestFrom, 
					tm.Revision AS Rev, 
					tm.UniqueID AS ID, 
					tm.ProjectNo AS ProjNum, 
					tm.ProjectTitle AS TaskOrderTitle, 
					tm.ProblemStatement, 
					tm.StatusValue,
					tm.RecordTypeUniqueID,
					(SELECT TOP(1) PBRFStatusLong FROM stng.Budgeting_PBRF_Status cvl WHERE @Value2 = cvl.[PBRFStatus])  AS [Status]
					FROM stng.Budgeting_Emails be
					left JOIN stng.VV_Budgeting_PBRFMain tm ON tm.RecordTypeUniqueID = @Value1
					WHERE be.EmailType = @EmailType




				
				END

				ELSE IF(@WorkingType = 'SDQ')--initiator is PCS

				BEGIN
					--find routed from status
					DECLARE @RoutedFromStatus NVARCHAR(255) = (SELECT TOP 1 [Value] FROM (
					SELECT TOP 2 v.[Value], s.CreatedDate from stng.Budgeting_StatusLog s
					join stng.Common_ValueLabel v on s.StatusID = v.UniqueID
					WHERE s.RecordTypeUID = @Value1 and s.Type = 'SDQ' 
					ORDER BY s.CreatedDate DESC) AS test ORDER BY CreatedDate ASC)--2nd last status

					--find current status in DB
					SELECT @CurrentStatus = StatusValue
					FROM stng.VV_Budgeting_SDQMain
					WHERE RecordTypeUniqueID = @Value1;

					--Front end always sends ASMA even if AVER isn't done yet
					IF (@CurrentStatus = 'AVER' and @Value2 = 'ASMA')
					BEGIN
						SET @Value2 = 'AVER'
					END
					--same with sending ADPA, even if ASMA isn't done yet
					IF (@CurrentStatus = 'ASMA' and @Value2 = 'ADPA')
					BEGIN
						SET @Value2 = 'ASMA'
					END

					SET @EmailType = 'Status Change SDQ';

					IF (@Value2 = 'BNPD')--BNPD EMAIL notification
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.PCSID
						WHERE t.RecordTypeUniqueID = @Value1


						SET @EmailType = 'BNPD Notification';
					END
					ELSE IF (@Value2 = 'ADMA')--Awaiting DivM Approval
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.DivMID
						WHERE t.RecordTypeUniqueID = @Value1
					END

					ELSE IF (@Value2 = 'AOEA')--Awaiting OE Approval
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.OEID
						WHERE t.RecordTypeUniqueID = @Value1

						INSERT INTO @CCTable(CCEID)
						SELECT t.PCSID
						FROM stng.VV_Budgeting_SDQMain t
						WHERE t.RecordTypeUniqueID = @Value1
					END

					ELSE IF (@Value2 = 'ASMA')--Awaiting SM(s) Approval
					BEGIN
						
						IF ((SELECT TOP(1) Legacy FROM stng.VV_Budgeting_SDQMain WHERE RecordTypeUniqueID = @Value1) = 1)
						BEGIN
							INSERT INTO @RecipientTable(RecipientEID)
							SELECT u.EmployeeID
							from stng.Budgeting_SDQ_SMApproval_Legacy t
							JOIN temp.TT_0003_UserInfo u on u.[UID] = t.SectionManager
							where t.SDID = @Value1
						END
						ELSE
						BEGIN
							INSERT INTO @RecipientTable(RecipientEID)
							SELECT u.EmployeeID
							from stng.VV_Budgeting_SDQ_Approval t
							inner JOIN stng.Admin_User u ON u.EmployeeID = t.Approver
							where t.SDQApprovalType = 'SectionManager' and t.SDQUID = @Value1
						END


						INSERT INTO @CCTable(CCEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u on u.EmployeeID = t.SMID or u.EmployeeID = t.PCSID
						WHERE t.RecordTypeUniqueID = @Value1
					END

					ELSE IF (@Value2 = 'APRE')--Approved, Partial Release
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.PCSID
						WHERE t.RecordTypeUniqueID = @Value1

						INSERT INTO @CCTable(CCEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.OEID or u.EmployeeID = t.ProjMID or u.EmployeeID = t.ProgMID
						WHERE t.RecordTypeUniqueID = @Value1
						UNION
						SELECT EmployeeID FROM @BPProjectControlsTeam
						UNION
						SELECT EmployeeID FROM @DigitalEngineeringReceiver

						SET @EmailType = 'Notification General'
					END

					ELSE IF (@Value2 = 'ACAPP')--Awaiting Customer Approval
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID) 
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.ProjMID
						WHERE t.RecordTypeUniqueID = @Value1
					
						INSERT INTO @CCTable(CCEID)
						SELECT t.DMEPID
						FROM stng.VV_Budgeting_SDQMain t
						WHERE t.RecordTypeUniqueID = @Value1 and t.StatusValue <> 'APRE'
						UNION 
						SELECT t.PCSID
						FROM stng.VV_Budgeting_SDQMain t
						WHERE t.RecordTypeUniqueID = @Value1
					END

					ELSE IF (@Value2 = 'APJMA')--Awaiting PM Approval
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.ProjMID
						WHERE t.RecordTypeUniqueID = @Value1

						INSERT INTO @CCTable(CCEID)
						SELECT t.DMEPID
						FROM stng.VV_Budgeting_SDQMain t
						WHERE t.RecordTypeUniqueID = @Value1 and t.StatusValue <> 'APRE'
						UNION 
						SELECT t.PCSID
						FROM stng.VV_Budgeting_SDQMain t
						WHERE t.RecordTypeUniqueID = @Value1
					END

					ELSE IF (@Value2 = 'PCSCRPROG')
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.PCSID OR u.EmployeeID = t.OEID
						WHERE t.RecordTypeUniqueID = @Value1

						INSERT INTO @CCTable(CCEID)
						SELECT t.ProgMID
						FROM stng.VV_Budgeting_SDQMain t
						WHERE t.RecordTypeUniqueID = @Value1
					END

					ELSE IF (@Value2 = 'APGMA')--Awaiting Prog.M Approval
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.ProgMID
						WHERE t.RecordTypeUniqueID = @Value1

						INSERT INTO @CCTable(CCEID)
						SELECT t.ProjMID
						FROM stng.VV_Budgeting_SDQMain t
						WHERE t.RecordTypeUniqueID = @Value1
						UNION 
						SELECT t.PCSID
						FROM stng.VV_Budgeting_SDQMain t
						WHERE t.RecordTypeUniqueID = @Value1
					END

					ELSE IF (@Value2 = 'AFRE')--Approved, Full Release
					BEGIN
						--notify all stakeholders
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT au.EmployeeID
						FROM stng.VV_Budgeting_SDQMain tm
						JOIN stng.Admin_User au ON au.EmployeeID = tm.PCSID
						WHERE tm.RecordTypeUniqueID = @Value1

						INSERT INTO @CCTable(CCEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.OEID or u.EmployeeID = t.ProjMID or u.EmployeeID = t.ProgMID
						WHERE t.RecordTypeUniqueID = @Value1
						UNION
						SELECT EmployeeID FROM @BPProjectControlsTeam
						UNION
						SELECT EmployeeID FROM @DigitalEngineeringReceiver

						SET @EmailType = 'Notification General'
					END

					ELSE IF (@Value2 = 'ADPA')--Awaiting DM EP Approval
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.DMEPID
						WHERE t.RecordTypeUniqueID = @Value1

						INSERT INTO @CCTable(CCEID)
						SELECT t.Approver
						FROM stng.VV_Budgeting_SDQ_Approval t
						WHERE t.SDQUID = @Value1
						AND t.SDQApprovalTypeID = 'AA2FCB14-B1B3-41D5-B8AC-0E22E1AA305D'--section managers
					END

					ELSE IF (@Value2 = 'CORR')--Initial Correction Required
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.PCSID
						WHERE t.RecordTypeUniqueID = @Value1

						INSERT INTO @CCTable(CCEID)
						SELECT @EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						WHERE t.RecordTypeUniqueID = @Value1 and (@EmployeeID = t.OEID or @EmployeeID = t.SMID or @EmployeeID = t.DMEPID)
						UNION
						SELECT @EmployeeID
						FROM stng.VV_Budgeting_SDQ_Approval t
						WHERE t.SDQUID = @Value1 AND SDQApprovalTypeID = 'AA2FCB14-B1B3-41D5-B8AC-0E22E1AA305D'--section manager
						AND Approver = @EmployeeID
						UNION
						SELECT @EmployeeID
						FROM stng.VV_Budgeting_SDQ_Approval t
						WHERE t.SDQUID = @Value1 AND SDQApprovalTypeID = '41F400C2-45DC-4540-9AEA-B907B8E99CC7'--lead planner
						AND Approver = @EmployeeID
						UNION
						SELECT @EmployeeID
						FROM stng.VV_Budgeting_SDQ_Approval t
						WHERE t.SDQUID = @Value1 AND SDQApprovalTypeID = '0D0ABC3E-FF13-4CB8-87B3-2F955D310F9A'--verifier
						AND Approver = @EmployeeID
					END

					ELSE IF (@Value2 = 'AVER')--Awaiting Verification
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQ_Approval t
						JOIN stng.Admin_User u ON u.EmployeeID = t.Approver
						WHERE t.SDQUID = @Value1
						AND (t.SDQApprovalTypeID = '41F400C2-45DC-4540-9AEA-B907B8E99CC7' OR t.SDQApprovalTypeID = '0D0ABC3E-FF13-4CB8-87B3-2F955D310F9A')--lead planner or verifier

						INSERT INTO @CCTable(CCEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.OEID or u.EmployeeID = t.PCSID
						WHERE RecordTypeUniqueID = @Value1
					END

					ELSE IF (@Value2 = 'PCSCR')--PCS/OE Clarification Required
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.PCSID OR u.EmployeeID = t.OEID
						WHERE t.RecordTypeUniqueID = @Value1

						INSERT INTO @CCTable(CCEID)
						SELECT t.ProjMID
						FROM stng.VV_Budgeting_SDQMain t
						WHERE t.RecordTypeUniqueID = @Value1
					END

					ELSE IF (@Value2 = 'AOERC')
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.OEID
						WHERE t.RecordTypeUniqueID = @Value1

						INSERT INTO @CCTable(CCEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						join STNG.Admin_User u ON u.EmployeeID = t.ProjMID or u.EmployeeID = t.ProgMID or u.EmployeeID = t.PCSID
						WHERE t.RecordTypeUniqueID = @Value1
					END

					ELSE IF (@Value2 = 'PRP6')--Processing P6
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID) SELECT null
					END
					--step not in workflow

					ELSE IF (@Value2 = 'CANC')--Canceled
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.PCSID
						WHERE t.RecordTypeUniqueID = @Value1
						SET @EmailType = 'Notification General'
					END

					ELSE IF (@Value2 = 'NTAPP')--Not Approved
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.PCSID
						WHERE t.RecordTypeUniqueID = @Value1

						INSERT INTO @CCTable(CCEID)
						SELECT @EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						WHERE t.RecordTypeUniqueID = @Value1 and (@EmployeeID = t.ProjMID or @EmployeeID = t.ProgMID)

						SET @EmailType = 'Notification General'
					END

					ELSE IF (@Value2 = 'AOEFR')--Awaiting OE Funding Release
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.OEID
						WHERE t.RecordTypeUniqueID = @Value1

						INSERT INTO @CCTable(CCEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.ProgMID or u.EmployeeID = t.PCSID or u.EmployeeID = t.ProjMID
						WHERE t.RecordTypeUniqueID = @Value1
						UNION
						SELECT @EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						WHERE t.RecordTypeUniqueID = @Value1 and (@EmployeeID = t.ProjMID or @EmployeeID = t.ProgMID)
					END

					ELSE IF (@Value2 = 'APCSC')--Approved & PCS Review Minor Comment Change
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.PCSID
						WHERE t.RecordTypeUniqueID = @Value1;
					
						INSERT INTO @CCTable(CCEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.OEID or u.EmployeeID = t.ProjMID or u.EmployeeID = t.ProgMID
						WHERE t.RecordTypeUniqueID = @Value1
						UNION
						SELECT EmployeeID
						FROM @BPProjectControlsTeam
					END

					ELSE IF (@Value2 = 'APPCSC')--Partially Approved & PCS Review Minor Comment Change
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.PCSID
						WHERE t.RecordTypeUniqueID = @Value1;

						INSERT INTO @CCTable(CCEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.OEID or u.EmployeeID = t.ProjMID or u.EmployeeID = t.ProgMID
						WHERE t.RecordTypeUniqueID = @Value1
						UNION
						SELECT EmployeeID
						FROM @BPProjectControlsTeam
					END

					ELSE IF (@Value2 = 'AAMC')--Approved & Awaiting Minor Comment Change
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID) SELECT null--not in workflow?
					END

					ELSE IF (@Value2 = 'APAMC')--Partially Approved & Awaiting Minor Comment Change
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID) SELECT null--not in workflow
					END
					ELSE IF (@Value2 = 'AOERCLS')
					BEGIN
						SET @EmailType = 'AOERC Late Start';

						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.PCSID
						WHERE t.RecordTypeUniqueID = @Value1;

						INSERT INTO @CCTable(CCEID)
						SELECT EmployeeID
						FROM @EBSList
					END
					ELSE IF (@Value2 = 'APCSCLS')
					BEGIN
						SET @EmailType = 'APCSC Late Start';

						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.PCSID
						WHERE t.RecordTypeUniqueID = @Value1;

						INSERT INTO @CCTable(CCEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.OEID or u.EmployeeID = t.ProjMID or u.EmployeeID = t.ProgMID
						WHERE t.RecordTypeUniqueID = @Value1
						UNION
						SELECT EmployeeID
						FROM @BPProjectControlsTeam
					
					END
					ELSE IF (@Value2 = 'AOEFRLS')
					BEGIN
						SET @EmailType = 'AOEFR Late Start';

						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.PCSID
						WHERE t.RecordTypeUniqueID = @Value1;

						INSERT INTO @CCTable(CCEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.OEID or u.EmployeeID = t.ProjMID or u.EmployeeID = t.ProgMID
						WHERE t.RecordTypeUniqueID = @Value1
						UNION
						SELECT EmployeeID
						FROM @BPProjectControlsTeam
					END
					ELSE IF (@Value2 = 'APRELS')
					BEGIN
						SET @EmailType = 'APRE Late Start';

						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.PCSID
						WHERE t.RecordTypeUniqueID = @Value1;

						INSERT INTO @CCTable(CCEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.OEID or u.EmployeeID = t.ProjMID or u.EmployeeID = t.ProgMID
						WHERE t.RecordTypeUniqueID = @Value1
						UNION
						SELECT EmployeeID
						FROM @BPProjectControlsTeam
					END
					ELSE IF (@Value2 = 'AFRELS')
					BEGIN
						SET @EmailType = 'AFRE Late Start';

						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_SDQMain t
						JOIN stng.Admin_User u ON u.EmployeeID = t.PCSID
						WHERE t.RecordTypeUniqueID = @Value1;

						INSERT INTO @CCTable(CCEID)
						SELECT EmployeeID
						FROM @EBSList
					END

				

					(SELECT uv.Username AS EmailTo, uv.EmpName AS Recipient 
					FROM @RecipientTable r
					join stng.VV_Admin_UserView uv on uv.EmployeeID = r.RecipientEID
					WHERE uv.Username is not null
					UNION
					SELECT alt.AlternateEmail AS EmailTo, uv.EmpName AS Recipient
					FROM @RecipientTable r
					JOIN stng.Admin_UserAlternateEmail alt on alt.EmployeeID = r.RecipientEID
					JOIN stng.VV_Admin_UserView uv on uv.EmployeeID = r.RecipientEID
					WHERE alt.AlternateEmail is not null
					);
					
					(SELECT au.Username AS EmailCC FROM stng.Admin_User au JOIN @CCTable e ON au.EmployeeID = e.CCEID WHERE au.Username is not null
					UNION
					SELECT DISTINCT alt.AlternateEmail AS EmailCC FROM stng.Admin_UserAlternateEmail alt JOIN @CCTable e on alt.EmployeeID = e.CCEID WHERE alt.AlternateEmail is not null
					);

					SELECT
					@WorkingType AS Workflow,
					be.EmailBody AS EmailBody,
					be.EmailSubject,
					tm.RequestFrom, 
					tm.Revision AS Rev, 
					tm.UniqueID AS ID, 
					tm.[Status],
					tm.ProjectNo AS ProjNum, 
					tm.ProjectTitle AS TaskOrderTitle, 
					tm.ProblemStatement,
					tm.RecordTypeUniqueID,
					tm.StatusValue,
					@RoutedFromStatus AS PreviousStatusValue
					--(SELECT TOP(1) SDQStatusLong FROM stng.Budgeting_SDQ_Status cvl WHERE @Value2 = cvl.[SDQStatus])  AS [Status]
					FROM stng.Budgeting_Emails be
					left JOIN stng.VV_Budgeting_SDQMain tm ON tm.RecordTypeUniqueID = @Value1
					WHERE be.EmailType = @EmailType


				END
				ELSE IF (@WorkingType = 'DVN')
				BEGIN
					SET @EmailType = 'Status Change DVN'

					IF (@Value2 = 'CORR')
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_DVN t
						JOIN stng.Admin_User u ON u.EmployeeID = t.PCS
						WHERE t.DVNID = @Value1
					
						INSERT INTO @CCTable(CCEID)
						SELECT @EmployeeID
						FROM stng.VV_Budgeting_DVN t
						WHERE t.DVNID = @Value1 and (@EmployeeID = t.OE or @EmployeeID = t.DPTEPDM or @EmployeeID = t.Verifier
						or @EmployeeID in (select a.ApproverID from stng.VV_Budgeting_DVN_Approval a where a.DVNID = @Value1 ))
					END
					ELSE IF (@Value2 = 'CAN')--Cancelled
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID) 
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_DVN t
						JOIN stng.Admin_User u ON u.EmployeeID = t.PCS
						WHERE t.DVNID = @Value1

					END
					ELSE IF (@Value2 = 'AVER')--Awaiting Verification
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID) 
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_DVN t
						JOIN stng.Admin_User u ON u.EmployeeID = t.Verifier
						WHERE t.DVNID = @Value1

						INSERT INTO @CCTable(CCEID)
						SELECT t.PCS
						FROM stng.VV_Budgeting_DVN t
						WHERE t.DVNID = @Value1
					END

					ELSE IF (@Value2 = 'AOEA')--Awaiting OE Approval
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_DVN t
						JOIN stng.Admin_User u ON u.EmployeeID = t.OE
						WHERE t.DVNID = @Value1

						INSERT INTO @CCTable(CCEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_DVN t
						JOIN stng.Admin_User u ON u.EmployeeID = t.PCS
						WHERE t.DVNID = @Value1

					END

					ELSE IF (@Value2 = 'ASMA')--Awaiting SM Approval
					BEGIN--Discipline SM
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_DVN_Approval t
						JOIN stng.Admin_User u ON u.EmployeeID = t.ApproverID--must be sm too
						WHERE t.DVNID = @Value1
						UNION
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_DVN t
						JOIN stng.Admin_User u ON u.EmployeeID = t.SM
						WHERE t.DVNID = @Value1

						INSERT INTO @CCTable(CCEID)
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_DVN t
						JOIN stng.Admin_User u ON u.EmployeeID = t.OE or u.EmployeeID = t.PCS
						WHERE t.DVNID = @Value1

					END

					ELSE IF (@Value2 = 'ADMA')--Awaiting DM EP Approval
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID) 
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_DVN t
						JOIN stng.Admin_User u ON u.EmployeeID = t.DPTEPDM
						WHERE t.DVNID = @Value1

						INSERT INTO @CCTable(CCEID)
						SELECT t.ApproverID
						FROM stng.VV_Budgeting_DVN_Approval t
						WHERE t.DVNID = @Value1
						UNION
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_DVN t
						JOIN stng.Admin_User u on u.EmployeeID = t.SM or u.EmployeeID = t.PCS
						WHERE t.DVNID = @Value1
					END

					ELSE IF (@Value2 = 'APMA')--Awaiting Customer Approval
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID) 
						SELECT u.EmployeeID
						FROM stng.VV_Budgeting_DVN t
						JOIN stng.Admin_User u ON u.EmployeeID = t.PM
						WHERE t.DVNID = @Value1

						INSERT INTO @CCTable(CCEID)
						SELECT t.DPTEPDM
						FROM stng.VV_Budgeting_DVN t
						WHERE t.DVNID = @Value1
						UNION
						SELECT
						CASE WHEN t.PreviousDVNStatusShort = 'ADMA' THEN 
						t.PCS
						ELSE NULL
						END AS PCS
						FROM stng.VV_Budgeting_DVN t
						WHERE t.DVNID = @Value1 
					END

					ELSE IF (@Value2 = 'COMP')--Approved AND Completed
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT au.EmployeeID
						FROM stng.VV_Budgeting_DVN tm
						JOIN stng.Admin_User au ON au.EmployeeID = tm.PCS
						WHERE tm.DVNID = @Value1

						INSERT INTO @CCTable(CCEID)
						SELECT t.OE
						FROM stng.VV_Budgeting_DVN t
						WHERE t.DVNID = @Value1
						UNION
						SELECT EmployeeID FROM @BPProjectControlsTeam

						SET @EmailType = 'Notification General'
					END

					ELSE IF (@Value2 = 'NTAPP')--Not Approved
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT au.EmployeeID
						FROM stng.VV_Budgeting_DVN tm
						JOIN stng.Admin_User au ON au.EmployeeID = tm.PCS
						WHERE tm.DVNID = @Value1

						INSERT INTO @CCTable(CCEID)
						SELECT t.PM
						FROM stng.VV_Budgeting_DVN t
						WHERE t.DVNID = @Value1


						SET @EmailType = 'Notification General'
					END

					ELSE IF (@Value2 = 'PCSCR')
					BEGIN
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT au.EmployeeID
						FROM stng.VV_Budgeting_DVN tm
						JOIN stng.Admin_User au ON au.EmployeeID = tm.PCS or au.EmployeeID = tm.OE
						WHERE tm.DVNID = @Value1

						INSERT INTO @CCTable(CCEID) 
						SELECT t.PM
						FROM stng.VV_Budgeting_DVN t
						WHERE t.DVNID = @Value1
						UNION
						SELECT t.OE
						FROM stng.VV_Budgeting_DVN t
						WHERE t.DVNID = @Value1

					END

					--include all stakeholders in CC
					--INSERT INTO @CCTable(CCEID)
					--SELECT au.EmployeeID
					--FROM stng.VV_Budgeting_DVN tm
					--JOIN stng.Admin_User au ON au.EmployeeID = tm.SM OR au.EmployeeID = tm.DM
					--OR au.EmployeeID = tm.PCS OR au.EmployeeID = tm.OE 
					--WHERE tm.DVNID = @Value1

					(SELECT uv.Username AS EmailTo, uv.EmpName AS Recipient 
					FROM @RecipientTable r
					join stng.VV_Admin_UserView uv on uv.EmployeeID = r.RecipientEID
					WHERE uv.Username is not null
					UNION
					SELECT alt.AlternateEmail AS EmailTo, uv.EmpName AS Recipient
					FROM @RecipientTable r
					JOIN stng.Admin_UserAlternateEmail alt on alt.EmployeeID = r.RecipientEID
					JOIN stng.VV_Admin_UserView uv on uv.EmployeeID = r.RecipientEID
					WHERE alt.AlternateEmail is not null
					);
					
					(SELECT DISTINCT au.Username AS EmailCC FROM stng.Admin_User au JOIN @CCTable e ON au.EmployeeID = e.CCEID WHERE au.Username is not null
					UNION
					SELECT DISTINCT alt.AlternateEmail AS EmailCC FROM stng.Admin_UserAlternateEmail alt JOIN @CCTable e on alt.EmployeeID = e.CCEID WHERE alt.AlternateEmail is not null
					);
					
					SELECT
					@WorkingType AS Workflow,
					be.EmailBody AS EmailBody,
					be.EmailSubject,
					tm.PreparerName AS RequestFrom,
					'0' AS Rev, 
					concat('DVN-(SDQ-',tm.SDQUID,')-',tm.DVNNumber) AS ID, 
					tm.DVNStatus AS [Status], 
					tm.PreviousDVNStatusShort AS PreviousStatusValue,
					tm.ProjectID AS ProjNum, 
					tm.PROJECTNAME AS TaskOrderTitle, 
					tm.DVNStatusShort as StatusValue,
					null AS ProblemStatement,
					@Value1 AS RecordTypeUniqueID
					FROM stng.Budgeting_Emails be
					left JOIN stng.VV_Budgeting_DVN tm ON tm.DVNID = @Value1
					WHERE be.EmailType = @EmailType
				END 
			END
			--get BCC List
			ELSE IF (@SubOp = 2)
			BEGIN
				SELECT DISTINCT au.Username as EmailBCC
				FROM stng.VV_Admin_ActualUserPermission ap
				JOIN stng.Admin_User au on au.EmployeeID  = ap.EmployeeID
				WHERE Permission = 'BCC On All Emails PCC/TOQ' AND (Origin = 'Direct Permission' OR Origin = 'Direct Permission (Delegated)' OR Origin = 'Role, Direct Permission' OR Origin = 'Role, Direct Permission (Delegated)')
				UNION
				SELECT DISTINCT a.AlternateEmail as EmailBCC
				FROM stng.Admin_UserAlternateEmail a
				JOIN stng.VV_Admin_ActualUserPermission ap on ap.EmployeeID = a.EmployeeID
				WHERE Permission = 'BCC On All Emails PCC/TOQ' AND (Origin = 'Direct Permission' OR Origin = 'Direct Permission (Delegated)' OR Origin = 'Role, Direct Permission' OR Origin = 'Role, Direct Permission (Delegated)')
			END
			--SDQ, get SMs
			ELSE IF (@Subop = 3)
			BEGIN
				--get SMs
				SELECT g.[Description] as Discipline, 
				uv.EmpName as Approver,
				CASE WHEN t.Approved = 1 THEN 'Approved' ELSE 'Not Approved' END AS [Status]
				FROM stng.VV_Budgeting_SDQ_Approval t 
				JOIN stng.VV_Admin_UserView uv ON uv.EmployeeID = t.Approver
				JOIN stng.General_Organization g ON g.PersonGroup = t.PersonGroup
				WHERE t.SDQUID = @Value1 and t.SDQApprovalTypeID = 'AA2FCB14-B1B3-41D5-B8AC-0E22E1AA305D' -- SMs Only
			END
			--SDQ, get verifiers
			ELSE IF (@Subop = 4)
			BEGIN
				SELECT uv.EmpName as Approver,
				t.SDQApprovalType as ApprovalType,
				CASE WHEN t.Approved = 1 THEN 'Approved' ELSE 'Not Approved' END AS [Status]
				FROM stng.VV_Budgeting_SDQ_Approval t 
				JOIN stng.VV_Admin_UserView uv ON uv.EmployeeID = t.Approver
				WHERE t.SDQUID = @Value1 
				and (t.SDQApprovalTypeID = '41F400C2-45DC-4540-9AEA-B907B8E99CC7' -- Lead Planner
				or t.SDQApprovalTypeID = '0D0ABC3E-FF13-4CB8-87B3-2F955D310F9A') -- Verifier
			END
			
		END
		
	END
