CREATE OR ALTER PROCEDURE [stng].[SP_Budgeting_SDQStatusChange] (
	@EmployeeID NVARCHAR(255) = NULL
	,@SDQUID BIGINT = NULL
	,@ToStatus NVARCHAR(255) = NULL
)
AS
BEGIN 
	IF @ToStatus = 'AVER' /*Awaiting Verification*/
		BEGIN
			/*C. Special case if Status is GOING to "AVER" Awaiting Verification for SM approvals*/
			/*C1.Update as if all records are deleted*/
			UPDATE stng.Budgeting_SDQSMApproval SET DeletedBy = @EmployeeID,DeletedDate = stng.GetDate() WHERE SDQUID = @SDQUID

			/*C2. Add approval required in table. Fresh everytime status goes to AVERI*/
			INSERT INTO stng.Budgeting_SDQSMApproval(SDQUID,SectionID,SectionManagerID,CreatedBy)
			SELECT @SDQUID
				,S.UniqueID
				,S.SM
				,@EmployeeID
			FROM stng.VV_General_Organization_Section S
			WHERE 1 = 0
			/*
				FROM dems.TT_0310_SDQHourByDiscipline AS TT_0310 INNER JOIN
					dems.TT_0309_SDQAvailableSchedule AS TT_0309 ON TT_0309.SASID = TT_0310.SASID INNER JOIN
					dems.TT_0219_SDQMain AS TT_0219 ON TT_0219.SDID = TT_0309.SDID INNER JOIN
					dems.TT_0154_Section AS TT_0154 ON TT_0154.SECID = TT_0310.SECID
					WHERE TT_0219.SDID = @SDID AND TT_0309.Linked = 1 AND TT_0309.DeleteRecord = 0 AND TT_0310.RemainingMeasuringUnit >= 20 AND TT_0310.SECID <> TT_0219.PrimaryDiscipline /*Don't worry about primary discipline even if the have hours*/
			*/
			UNION /*Always add primary discipline*/
			SELECT S.RecordTypeUniqueID,O.UniqueID,COALESCE(S.SMID,O.SM),@EmployeeID FROM stng.VV_Budgeting_SDQMain S 
			LEFT JOIN stng.VV_MPL_ENG as M on M.SharedProjectID = S.ProjectNo
			LEFT JOIN stng.VV_General_Organization_Section O ON O.PrimaryDiscipline = M.Discipline  
			WHERE S.RecordTypeUniqueID = @SDQUID
			/*UNION
			SELECT S.SDQUID,O.UniqueID,O.SM,@EmployeeID FROM stng.Budgeting_SDQMain S 
			LEFT JOIN stng.VV_MPL_ENG as M on M.SharedProjectID = S.ProjectNo
			LEFT JOIN stng.VV_General_Organization_Section O ON O.PrimaryDiscipline = M.Discipline  
			WHERE S.SDQUID = @SDQUID
			*/
			/*C2B Add Incomplete DQ Commitment */
			INSERT INTO stng.Budgeting_SDQSMApproval(SDQUID,SectionID,SectionManagerID,CreatedBy)
			SELECT @SDQUID
				,S.UniqueID
				,S.SM
				,@EmployeeID
			FROM stng.VV_General_Organization_Section S
			WHERE 1 = 0
			/*
				FROM dems.VV_0288_Section AS VV_0288 INNER JOIN 
				dems.VV_0320_DQMilestone AS VV_0320 ON VV_0288.P6CodeShort = VV_0320.G4009BPResponsibleDiscipline 
				WHERE VV_0320.SDID = @SDID AND RIGHT(VV_0320.Finish,1) <>'A' AND VV_0288.SECID NOT IN (SELECT SECID FROM dems.TT_0331_SDQSMApproval WHERE SDID = @SDID AND DeleteRecord = 0)
			*/
			/*C2C Update if LAMP4 BIMS*/
			DECLARE @IsLAMP4BIMS VARCHAR(1), @IsThereALAMP4Record BIGINT
			SELECT @IsLAMP4BIMS = 'Y'-- LAMP4BIMS FROM dems.VV_0227_View0219 WHERE SDID = @SDID

			/*There is no LAMP record in Approvals. Add new record*/
			INSERT INTO stng.Budgeting_SDQSMApproval(SDQUID,SectionID,LAMP4,CreatedBy)
			SELECT @SDQUID,A.UniqueID,1,@EmployeeID FROM stng.VV_General_Organization_Section A WHERE Section = 'Digital Engineering'
			AND NOT EXISTS (SELECT * FROM stng.Budgeting_SDQSMApproval B WHERE SDQUID = @SDQUID AND B.SectionID = A.UniqueID AND B.Deleted = 0)
			AND @IsLAMP4BIMS = 'Y'

			/*There is LAMP record in Approvals. Update existing*/
			UPDATE stng.Budgeting_SDQSMApproval SET LAMP4 = 1
			WHERE SDQUID = @SDQUID AND SectionID = (SELECT A.UniqueID FROM stng.VV_General_Organization_Section A WHERE Section = 'Digital Engineering') 
			AND EXISTS (SELECT * FROM stng.Budgeting_SDQSMApproval B WHERE SDQUID = @SDQUID AND B.SectionID = SectionID AND B.Deleted = 0)
			AND @IsLAMP4BIMS = 'Y'

			/*C3. Add initial record to approval status log*/
			INSERT INTO stng.Budgeting_SDQApprovalStatusLog(SDQUID,Status,SectionManagerID,Comment,CreatedBy,SectionID)
			SELECT S.SDQUID,S.Status,S.SectionManagerID,'Initial P6 Import','SYSTEM',S.SectionID
			FROM stng.Budgeting_SDQSMApproval S
			WHERE S.Deleted = 0 AND S.SDQUID = @SDQUID 

			--/*C4 Mark Class II as read only*/							
			--UPDATE dems.TT_0273_WBSMain
			--	SET WBSReadOnly = 0 
			--WHERE WBSID = 162

			--UPDATE dems.TT_0116_ClassVMain
			--	SET CVReadOnly = 0
			--WHERE CVID = 945

			UPDATE stng.Budgeting_SDQVerificationChecklistLink SET [Current] = 0 WHERE SDQUID = @SDQUID

			/*Create Verification list*/
			DECLARE @VFID NVARCHAR(255)
			
			--Prepare Verification Checklist
			SET @VFID = NEWID()
			INSERT INTO stng.Budgeting_SDQVerificationChecklistLink(UniqueID,SDQUID,CreatedBy,P6LinkID,[Current])
			SELECT @VFID,A.SDQUID,@EmployeeID,A.UniqueID,1 FROM stng.Budgeting_SDQP6Link A WHERE A.SDQUID = @SDQUID AND A.Active = 1

			INSERT INTO stng.Budgeting_SDQVerificationChecklist(VerificationChecklistLinkID,QuestionID,CreatedBy) 
			SELECT @VFID,C.UniqueID,@EmployeeID FROM stng.VV_Budgeting_SDQCommon C WHERE C.Field = 'VerificationChecklist'
	/*
			--insert into Verification LINK table
			INSERT INTO dems.TT_0410_SDQVerificationChecklistLink(SDID)
				VALUES(@SDID)

			SELECT @VCLIDReturn = SCOPE_IDENTITY()
							
			--Create new checklist
			INSERT INTO dems.TT_0403_SDQVerificationChecklist (SDID,VCTID, VCLID ,RAD,RAB)
				SELECT @SDID, VCTID, @VCLIDReturn, GETDATE(), @CurrentUser FROM dems.TT_0405_VerificationChecklistTemplate WHERE DeleteRecord = 0

			--link Checklist and support data 
			DECLARE @VCLIDExist BIGINT
			SELECT @VCLIDExist = TT0434.VCLID FROM dems.TT_0434_SDQChecklistSupportingData AS TT0434 INNER JOIN dems.VV_0311_SDQAvailableSchedule AS VV0311 ON TT0434.SASID = VV0311.SASID
								WHERE TT0434.SDID = @SDID AND VV0311.Linked = 1
			IF @VCLIDExist IS NULL
				BEGIN 
					UPDATE TT0434 
						SET 
							VCLID = @VCLIDReturn
						FROM dems.TT_0434_SDQChecklistSupportingData AS TT0434 INNER JOIN 
						dems.VV_0311_SDQAvailableSchedule AS VV0311 ON TT0434.SASID = VV0311.SASID
					WHERE TT0434.SDID = @SDID AND VV0311.Linked = 1
				END
			ELSE
				BEGIN
					INSERT INTO dems.TT_0434_SDQChecklistSupportingData(SDID, SASID, VCLID, VCTID, SupportData, RAD, RAB)
					SELECT 
						@SDID,
						TT0434.SASID,
						@VCLIDReturn,
						VCTID, 
						SupportData,
						GETDATE(),
						@CurrentUser
					FROM  dems.TT_0434_SDQChecklistSupportingData AS TT0434 INNER JOIN dems.VV_0311_SDQAvailableSchedule AS VV0311 ON TT0434.SASID = VV0311.SASID
					WHERE TT0434.SDID = @SDID AND VV0311.Linked = 1										
				END

			/*C4. When the SDQ goes to Awaiting Verification, need to update EcosysEAC value for this particular SDQ*/
			SELECT @EstimateAtCompletion = SUM(EstimateAtCompletion) FROM dems.TT_0828_PMCEAC 
			WHERE ProjectNo = (SELECT ProjectNo FROM dems.TT_0219_SDQMain WHERE SDID = @SDID)
			UPDATE dems.TT_0219_SDQMain
					SET EcosysEAC = @EstimateAtCompletion
			WHERE SDID = @SDID
	*/

			UPDATE stng.Budgeting_SDQPlannerChecklistLink SET [Current] = 0 WHERE SDQUID = @SDQUID

			/*Create Verification list*/
			DECLARE @PCID NVARCHAR(255)
			
			--Prepare Verification Checklist
			SET @PCID = NEWID()
			INSERT INTO stng.Budgeting_SDQPlannerChecklistLink(UniqueID,SDQUID,CreatedBy,P6LinkID,[Current])
			SELECT @PCID,A.SDQUID,@EmployeeID,A.UniqueID,1 FROM stng.Budgeting_SDQP6Link A WHERE A.SDQUID = @SDQUID AND A.Active = 1

			INSERT INTO stng.Budgeting_SDQPlannerChecklist(VerificationChecklistLinkID,QuestionID,CreatedBy) 
			SELECT @PCID,C.UniqueID,@EmployeeID FROM stng.VV_Budgeting_SDQCommon C WHERE C.Field = 'PlannerChecklist'
		END

	ELSE IF @ToStatus = 'CORR'
		BEGIN

			UPDATE stng.Budgeting_SDQSMApproval SET DeletedBy = @EmployeeID,DeletedDate = stng.GetDate() WHERE SDQUID = @SDQUID
			
		/*
			/*D1. Class II*/
			UPDATE A
				SET WBSReadOnly = 0,
					LUD = GETDATE(),
					LUB = @CurrentUser
				FROM dems.TT_0273_WBSMain AS A INNER JOIN dems.TT_0219_SDQMain AS TT_0219  ON TT_0219.WBSID = A.WBSID
				WHERE SDID = @SDID

			/*D2 Class V*/
			UPDATE A
				SET CVReadOnly = 0,
					LUD = GETDATE(),
					LUB = @CurrentUser
				FROM dems.TT_0116_ClassVMain AS A INNER JOIN dems.TT_0298_SDQClassV AS TT_0298 ON TT_0298.CVID = A.CVID
				WHERE SDID = @SDID
							
			/*D4 When the SDQ goes to Initial Correction Required, need to update EcosysEAC value for this particular SDQ*/
			SELECT @EstimateAtCompletion = SUM(EstimateAtCompletion) FROM dems.TT_0828_PMCEAC WHERE ProjectNo = (SELECT ProjectNo FROM dems.TT_0219_SDQMain WHERE SDID = @SDID)
			UPDATE dems.TT_0219_SDQMain
					SET EcosysEAC = @EstimateAtCompletion
			WHERE  SDID = @SDID
			*/
							
		END
		ELSE IF @ToStatus = 'APJMA' -- Awaiting Project Manager Approval (Customer)
		BEGIN	
			INSERT INTO stng.Budgeting_SDQCustomerApprovalDetail(CustomerApprovalID,CreatedBy,PreviouslyApproved,CurrentRequest,CurrentApproval)
			SELECT TOP 1 A.CustomerApprovalID,'SYSTEM',A.CurrentApproval,S.RequestedScope,S.RequestedScope-COALESCE(A.CurrentApproval,0)
				FROM stng.Budgeting_SDQCustomerApprovalDetail A
			INNER JOIN stng.Budgeting_SDQCustomerApproval B ON B.UniqueID = A.CustomerApprovalID AND SDQUID = @SDQUID
			INNER JOIN stng.Budgeting_SDQMain S ON S.SDQUID = B.SDQUID 
			ORDER BY A.CreatedDate DESC
			/*
			INSERT INTO stng.Budgeting_SDQCustomerApprovalDetail(
				CustomerApprovalID
				,[SunkCost]
				,[RemainingClassII]
				,[FutureClassV]
				,[TotalEAC]
				,[Saving]
				,[PreviouslyApproved]
				,[CurrentRequest]
				,[CurrentApproval]
				,[ApprovedScope]
				,[ApprovedTrend]
				,[TotalApproved])
			SELECT @UID,TotalSunkCost,TotalRemainingCost,FutureClassV 
			,TotalEAC,LAMPEstimate, Saving
			,PreviouslyApproved, AdditionalRequired, ApprovedAmount,ApprovedScopeAmount
			,(ISNULL(ApprovedAmount,0) - ISNULL(ApprovedScopeAmount,0))
			, (ISNULL(ApprovedAmount,0) - ISNULL(PreviouslyApproved,0))  
			FROM dems.VV_0352_SDQCalc AS A 
			INNER JOIN [dems].[TT_0753_SDQCustomerApproval] AS B ON A.SDID = B.SDID 
			WHERE B.SDID = @SDID
			*/
		END	

		-- ProgM has Approved. Now set the ApprovedScope
		ELSE IF @ToStatus = 'AOEFR' 
		BEGIN
			UPDATE A SET A.ApprovedScope = A.CurrentApproval FROM 
			stng.Budgeting_SDQCustomerApprovalDetail A
			INNER JOIN (
				SELECT TOP 1 A.UniqueID FROM stng.Budgeting_SDQCustomerApprovalDetail A
				INNER JOIN stng.Budgeting_SDQCustomerApproval B ON B.UniqueID = A.CustomerApprovalID AND SDQUID = @SDQUID
				ORDER BY A.CreatedDate DESC
			) B ON B.UniqueID = A.UniqueID
		END
END 
