CREATE OR ALTER   PROCEDURE [stng].[SP_TOQ_Emails](
	 @Operation TINYINT
	,@SubOp		TINYINT = NULL
	,@EmployeeID INT = NULL
	,@Value1 NVARCHAR(255) = NULL
	,@Value2 NVARCHAR(255) = NULL
	,@Value3 NVARCHAR(255) = NULL
	,@Value4 NVARCHAR(255) = NULL
	,@Value5 NVARCHAR(255) = NULL
	,@Value6 NVARCHAR(255) = NULL
	,@Value7 NVARCHAR(255) = NULL
	,@Value8 NVARCHAR(255) = NULL
) AS 
BEGIN
	/*
	Operations:
	1 -- Get Email Data
	*/
	IF (@Operation = 1)
	BEGIN
		--ALL:
		--Value1 -> UniqueID (TOQMain)
		--Value2 -> Next Status Code / Made up code
			
		--Question from Vendor Correspondence:
		--Value2 -> QUES
		--Value6 -> UniqueID (TOQ_Correspondence)

		--Notify Non-Awarded Vendors:
		--Value2 -> NONAW
		--Value6 -> UniqueID (TOQ_VendorAssigned / TOQ_VendorStatusLog)

		--Vendor Submission Update
		--Value2 -> SUBUP
		--Value6 -> UniqueID (TOQ_VendorAssigned / TOQ_VendorStatusLog)
		--Value7 -> Submission Type
		IF (@SubOp > 0 and @SubOp < 5)
		BEGIN
			

			--need to get value1 from table in these cases
			IF @Value2 = 'SUBUP' OR @Value2 = 'AEBSP'
			BEGIN
				SET @Value1 = (SELECT TOP(1) TOQMainID FROM stng.VV_TOQ_VendorSubmission WHERE UniqueID = @Value6);
			END


			--default email type
			DECLARE @EmailType NVARCHAR (50) = 'Status Change General';

			DECLARE @WorkItemType NVARCHAR(50) = 'TOQ';

			DECLARE @IsChild NVARCHAR(1) = 
			CASE WHEN (Exists(select UniqueID FROM stng.TOQ_Child WHERE ChildTOQID = @Value1)) THEN
			'1'
			ELSE '0'
			END;

			DECLARE @VOE nvarchar(20);
			DECLARE @VOEMessage nvarchar(200);
			DECLARE @QuestionAnswer nvarchar(10);

			--lists for diff queries
			DECLARE @EBSList TABLE (
				EmployeeID NVARCHAR(10) 
			);
			DECLARE @EBSSMList TABLE (
				EmployeeID NVARCHAR(10) 
			);
			DECLARE @VPList TABLE (
				EmployeeID NVARCHAR(10)
			);
			DECLARE @BPProjControlsTeam TABLE (
				EmployeeID NVARCHAR(10)
			);
			DECLARE @DesignEngineeringList TABLE (
				EmployeeID NVARCHAR(10)
			);
			DECLARE @LeadPlanners TABLE (
				EmployeeID NVARCHAR(10)
			);
			DECLARE @PCSLeads TABLE (
				EmployeeID NVARCHAR(10)
			);
			DECLARE @EmailTestTeam table(
				EmployeeID nvarchar(10)
			);
			DECLARE @MPLTestTeam table(
				EmployeeID nvarchar(10)
			);

			INSERT INTO @MPLTestTeam
			SELECT DISTINCT ap.EmployeeID
			FROM stng.VV_Admin_ActualUserPermission ap
			JOIN stng.Admin_User au on au.EmployeeID  = ap.EmployeeID
			WHERE Permission = 'CC On MPL Missing Emails' AND (Origin = 'Direct Permission' OR Origin = 'Direct Permission (Delegated)' OR Origin = 'Role, Direct Permission' OR Origin = 'Role, Direct Permission (Delegated)')
		

			INSERT INTO @EmailTestTeam(EmployeeID)
			SELECT DISTINCT ap.EmployeeID
			FROM stng.VV_Admin_ActualUserPermission ap
			JOIN stng.Admin_User au on au.EmployeeID  = ap.EmployeeID
			WHERE Permission = 'BCC On All Emails PCC/TOQ' AND (Origin = 'Direct Permission' OR Origin = 'Direct Permission (Delegated)' OR Origin = 'Role, Direct Permission' OR Origin = 'Role, Direct Permission (Delegated)')
		
			INSERT INTO @VPList(EmployeeID)
			SELECT DISTINCT ap.EmployeeID
			FROM stng.VV_Admin_ActualUserPermission ap
			WHERE Permission = 'TOQ VP Emails' AND (Origin = 'Direct Permission' OR Origin = 'Direct Permission (Delegated)' OR Origin = 'Role, Direct Permission' OR Origin = 'Role, Direct Permission (Delegated)')

			--list of vendors, available after AVS is done
			DECLARE @SourceVendorList TABLE (
				UniqueID UNIQUEIDENTIFIER,
				VendorID UNIQUEIDENTIFIER,
				Email NVARCHAR(100),
				[Name] NVARCHAR(100),
				TOQNumber NVARCHAR(100),
				TOQVendorRev NVARCHAR(50),
				Awarded BIT,
				EmployeeID NVARCHAR(20)
			);

			--If record changed is a child, sometimes this table is needed
			DECLARE @ChildVendorList TABLE (
				UniqueID UNIQUEIDENTIFIER,
				VendorID UNIQUEIDENTIFIER,
				Email NVARCHAR(100),
				[Name] NVARCHAR(100),
				TOQNumber NVARCHAR(100),
				TOQVendorRev NVARCHAR(50),
				Awarded BIT,
				EmployeeID NVARCHAR(20)
			);

			--Submission Update variables
			DECLARE @SubmissionType NVARCHAR(50) = NULL;
			DECLARE @Vendor NVARCHAR(50) = NULL;
			DECLARE @StatusUpdateComment NVARCHAR(50) = NULL;

			--if child record is entered, some cases need to use parent ('source') data
			--source TOQ ID will either be the record entered (Value1) or the parent ID if the record is a child
			DECLARE @SourceTOQUniqueID UNIQUEIDENTIFIER = 
			(SELECT TOP(1) ParentTOQID FROM stng.TOQ_Child WHERE ChildTOQID = @Value1);

			IF (@SourceTOQUniqueID IS NULL)
			BEGIN
				SET @SourceTOQUniqueID = @Value1;
			END

			DECLARE @AVSStarted bit = (
			SELECT
			CASE WHEN EXISTS(
			SELECT * FROM stng.TOQ_StatusLog sl
			JOIN stng.Common_ValueLabel cvl on sl.TOQStatusID = cvl.UniqueID and cvl.[Value] = 'AVS'
			WHERE sl.TOQMainID = @Value1
			)
			THEN 1
			ELSE 0
			END AS AVSStarted
			)

			--type of request, is request partial
			DECLARE @WorkingType UNIQUEIDENTIFIER, @Partial NVARCHAR(50);
			
			
			SELECT @WorkingType = TypeID, @Partial = PartialEmergent
			FROM stng.TOQ_Main WHERE UniqueID = @Value1;

			IF (@AVSStarted = 1 
			OR NOT (@WorkingType = '145ED3D3-E286-4621-8468-07CFB59E420A'--Standard
			OR @WorkingType = '1916B0B8-80CD-441D-AA54-E04C955033A9'--Standard OE/ADE
			OR @WorkingType = 'B64F2447-981C-4BA2-ACAC-444E0E1341D3'--Consulting
			OR @WorkingType = 'F7E23BFF-CC2B-4BE7-AE33-7F49E73E75D5'--Mini-drawdown (ER)
			OR @WorkingType = '185435F4-4E82-44DC-91C6-6414A517C711'--Mini-drawdown (General)
			OR @WorkingType = '7F12F62C-52A6-4E20-AB8D-EAEBB47C38B8'--Mini-drawdown (OE/ADE)
			OR @WorkingType = 'D2AFC849-BFAA-4E14-8D17-6795CFD092B4'--Mini-drawdown (Core Consulting)
			OR @WorkingType = 'CE0A0A24-A026-4AC0-BB59-D1E162118D50'--Mini-drawdown (Section Consulting)
			)
			)
			BEGIN
				INSERT INTO @SourceVendorList (UniqueID, VendorID, Email, [Name], TOQNumber, TOQVendorRev, Awarded, EmployeeID)
				SELECT va.UniqueID, va.VendorID, uv.Username, uv.Empname, va.TOQNumber, va.TOQVendorRev, va.Awarded, uv.EmployeeID
				FROM stng.VV_Admin_ActualUserPermission up  
				JOIN stng.VV_Admin_UserAttribute ua ON ua.EmployeeID = up.EmployeeID
				JOIN stng.VV_Common_VendorIDAttributeID vid ON vid.AttributeID = ua.AttributeID
				JOIN stng.TOQ_VendorAssigned va ON va.VendorID = vid.VendorID
				JOIN stng.VV_Admin_UserView uv ON uv.EmployeeID = up.EmployeeID
				WHERE va.TOQMainID = @SourceTOQUniqueID
				and up.PermissionID = '15CEBF40-935D-40B5-8EFE-BA4CEDBBDB88' 
				and va.DeleteRecord = 0

				IF (@IsChild = 1)
				BEGIN
					INSERT INTO @ChildVendorList (UniqueID, VendorID, Email, [Name], TOQNumber, TOQVendorRev, Awarded, EmployeeID)
					SELECT va.UniqueID, va.VendorID, uv.Username, uv.Empname, va.TOQNumber, va.TOQVendorRev, va.Awarded, uv.EmployeeID
					FROM stng.VV_Admin_ActualUserPermission up  
					JOIN stng.VV_Admin_UserAttribute ua ON ua.EmployeeID = up.EmployeeID
					JOIN stng.VV_Common_VendorIDAttributeID vid ON vid.AttributeID = ua.AttributeID
					JOIN stng.TOQ_VendorAssigned va ON va.VendorID = vid.VendorID
					JOIN stng.VV_Admin_UserView uv ON uv.EmployeeID = up.EmployeeID
					WHERE va.TOQMainID = @Value1--difference is vendors associated with current record, not parent
					and up.PermissionID = '15CEBF40-935D-40B5-8EFE-BA4CEDBBDB88' 
					and va.DeleteRecord = 0
				END
			END
			


			--who to send to
			DECLARE @RecipientTable TABLE (
				RecipientEID nvarchar(10)
			);

			--who to CC
			DECLARE @CCTable TABLE(
				CCEID NVARCHAR(10)
			);

			--WHO TO bcc
			DECLARE @BCCTable TABLE(
				BCCEID NVARCHAR(10)
			);

			

			DECLARE @RoutedFromStatus NVARCHAR(255) = (SELECT TOP 1 [Value] FROM (
			SELECT TOP 2 v.[Value], s.CreatedDate from stng.TOQ_StatusLog s
			join stng.Common_ValueLabel v on s.TOQStatusID = v.UniqueID
			WHERE TOQMainID = @Value1
			ORDER BY s.CreatedDate DESC) AS test ORDER BY CreatedDate ASC)--2nd last status

			--fill tables
			INSERT INTO @EBSList (EmployeeID)
			SELECT DISTINCT EmployeeID FROM stng.VV_Admin_ActualUserPermission WHERE PermissionID = '336E4F3B-6D67-4D80-8E8F-3BEC1ABC309B' 
			AND (Origin = 'Direct Permission' OR Origin = 'Direct Permission (Delegated)' OR Origin = 'Role, Direct Permission' OR Origin = 'Role, Direct Permission (Delegated)')
		

			INSERT INTO @EBSSMList (EmployeeID)
			SELECT DISTINCT EmployeeID FROM stng.VV_Admin_ActualUserPermission WHERE PermissionID = 'DAE6F225-D07E-4228-A3C3-8E149AF2ACCD'
			AND (Origin = 'Direct Permission' OR Origin = 'Direct Permission (Delegated)' OR Origin = 'Role, Direct Permission' OR Origin = 'Role, Direct Permission (Delegated)')
		

			INSERT INTO @BPProjControlsTeam (EmployeeID)
			SELECT DISTINCT EmployeeID FROM stng.VV_Admin_ActualUserPermission WHERE PermissionID = '040D83C1-57E1-4601-9E40-16A02E9D9105'
			AND (Origin = 'Direct Permission' OR Origin = 'Direct Permission (Delegated)' OR Origin = 'Role, Direct Permission' OR Origin = 'Role, Direct Permission (Delegated)')
	
			INSERT INTO @DesignEngineeringList (EmployeeID)
			SELECT DISTINCT EmployeeID from stng.VV_Admin_UserAttribute WHERE Attribute = 'Design Engineering' and AttributeType = 'BPRole'

			INSERT INTO @LeadPlanners (EmployeeID)
			SELECT DISTINCT EmployeeID from stng.VV_Admin_UserAttribute WHERE Attribute = 'Lead Planner' and AttributeType = 'BPRole'

			INSERT INTO @PCSLeads (EmployeeID)
			SELECT DISTINCT EmployeeID from stng.VV_Admin_UserAttribute WHERE Attribute = 'PCS Lead' and AttributeType = 'BPRole'


			IF @Value2 = 'QUES'  -- Question from vendor correspondence / oe correspondence
			BEGIN
				SET @VOE = (SELECT TOP(1) FromVOE FROM stng.TOQ_Correspondence WHERE UniqueID = @Value6)
				SET @QuestionAnswer = 'Q';
				IF @VOE = 'VENDOR'--vendor correspondence question
				BEGIN
					SET @VOEMessage = 'A vendor has asked a question or seeks clarification';
					DECLARE @QType NVARCHAR(50) = (SELECT TOP(1) [Label] FROM stng.Common_ValueLabel WHERE UniqueID = (SELECT TOP(1) TypeID FROM stng.TOQ_Correspondence WHERE UniqueID = @Value6));
					IF @QType = 'Technical'
					BEGIN
						--OE is recipient
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_TOQ_Main t
						JOIN stng.Admin_User u ON u.EmployeeID = t.OEID
						WHERE t.UniqueID = @Value1;
					END
					ELSE IF @QType = 'Date Extension'
					BEGIN
						--OE is recipient
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM stng.VV_TOQ_Main t
						JOIN stng.Admin_User u ON u.EmployeeID = t.OEID
						WHERE t.UniqueID = @Value1;

						--CC Question Asker
						INSERT INTO @CCTable(CCEID)
						SELECT CreatedBy 
						FROM stng.TOQ_Correspondence
						WHERE UniqueID = @Value6

					END
					ELSE IF @QType = 'Business'
					BEGIN
						--EBS is recipient
						INSERT INTO @RecipientTable(RecipientEID)
						SELECT u.EmployeeID
						FROM @EBSList t
						JOIN stng.Admin_User u ON u.EmployeeID = t.EmployeeID
					END

					--for all, bcc all selected vendors
					INSERT INTO @BCCTable(BCCEID)
					SELECT DISTINCT EmployeeID FROM
					@SourceVendorList 
						
				END
				ELSE --OE Correspondence question
				BEGIN
					SET @VOEMessage = 'The OEL has asked a question or seeks clarification';
					--to question creator because someone needs to be in the TO
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.OEID
					WHERE t.UniqueID = @Value1;

					--goes to all vendors
					INSERT INTO @BCCTable
					SELECT DISTINCT EmployeeID FROM @SourceVendorList
				END
				SET @EmailType = 'Question General';
			END

			ELSE IF @Value2 = 'ANSR' -- vendor correspondence or oe correspondence answer
			BEGIN
				SET @VOE = (SELECT TOP(1) FromVOE FROM stng.TOQ_Correspondence WHERE UniqueID = @Value6)
				SET @QuestionAnswer = 'A'
				IF @VOE = 'VENDOR' --vendor correspondence answer
				BEGIN -- from OE
					SET @VOEMessage = 'OEL has provided an answer';
					--find parent UID and select createdby as recipient
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM stng.TOQ_Correspondence t
					JOIN stng.Admin_User u ON u.EmployeeID = t.CreatedBy
					WHERE t.UniqueID = @Value6; 


					--bcc all selected vendors
					INSERT INTO @BCCTable(BCCEID)
					SELECT DISTINCT EmployeeID FROM
					@SourceVendorList;
				END
				ELSE
				BEGIN -- oe correspondence answer, from vendor
					SET @VOEMessage = 'Vendor has provided an answer';
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.OEID
					WHERE t.UniqueID = @Value1;


					--goes to all vendors
					INSERT INTO @BCCTable
					SELECT DISTINCT EmployeeID FROM @SourceVendorList
				END

				SET @EmailType = 'Question General';
			END

			ELSE IF (@Value2 = 'AWARD') -- send awarded email
			BEGIN
				INSERT INTO @RecipientTable(RecipientEID)
				SELECT DISTINCT EmployeeID FROM
				@SourceVendorList
				WHERE Awarded = 1
				UNION
				SELECT e.EmployeeID
				FROM @EBSList e

				INSERT INTO @CCTable(CCEID)
				SELECT EmployeeID
				FROM @BPProjControlsTeam
				UNION
				SELECT OEID
				FROM stng.VV_TOQ_Main
				WHERE UniqueID = @SourceTOQUniqueID
				UNION
				SELECT PCSID
				FROM stng.VV_TOQ_Main
				WHERE UniqueID = @SourceTOQUniqueID
				UNION
				SELECT SMID
				FROM stng.VV_TOQ_Main
				WHERE UniqueID = @SourceTOQUniqueID

				IF ((SELECT TOP(1) StatusID FROM stng.TOQ_Main WHERE UniqueID = @Value1) = 'CE3B8C9E-526A-4353-BEAA-AAA172788F59')
				BEGIN
					SET @EmailType = 'Awarded Late Start 1';
				END
				ELSE IF (@RoutedFromStatus = 'ODU')
				BEGIN
					SET @EmailType = 'Awarded Late Start 2';
				END
				ELSE
				BEGIN
					SET @EmailType = 'Awarded General';
				END
				
			END
			ELSE IF @Value2 = 'NONAW' -- Notify non-awarded vendors
			BEGIN
				INSERT INTO @RecipientTable(RecipientEID)
				SELECT e.EmployeeID FROM @EBSList e 

				INSERT INTO @BCCTable(BCCEID)
				SELECT DISTINCT EmployeeID FROM
				@SourceVendorList
				WHERE (Awarded = 0 or Awarded is null)

				INSERT INTO @CCTable(CCEID)
				SELECT EmployeeID
				FROM @EBSSMList
				UNION
				SELECT u.EmployeeID
				FROM stng.VV_TOQ_Main t
				JOIN stng.Admin_User u ON u.EmployeeID = t.SMID OR u.EmployeeID = t.OEID OR u.EmployeeID = t.RequestFrom OR u.EmployeeID = t.PCSID				
				WHERE t.UniqueID = @SourceTOQUniqueID;

				SET @EmailType = 'Non Awarded General';
			END
			ELSE IF @Value2 = 'REMOV' -- removed from TOQ
			BEGIN
				SET @EmailType = 'Vendor Removed'
				
				INSERT INTO @RecipientTable(RecipientEID)
				SELECT EmployeeID
				FROM @EBSList

				INSERT INTO @BCCTable(BCCEID)
				SELECT up.EmployeeID
				FROM stng.VV_Admin_ActualUserPermission up
				JOIN stng.Admin_UserAttribute ua on ua.EmployeeID = up.EmployeeID
				JOIN stng.VV_Common_VendorIDAttributeID vid ON vid.AttributeID = ua.AttributeID
				JOIN stng.TOQ_VendorAssigned va ON va.VendorID = vid.VendorID
				WHERE va.TOQMainID = @Value1
				and up.PermissionID = '15CEBF40-935D-40B5-8EFE-BA4CEDBBDB88'
				and va.DeleteRecord = 1 and va.RemovedNotified = 0

			END
			ELSE IF @Value2 = 'SUBUP' -- Submission update (all stakeholders)
			BEGIN
				
				SET @EmailType = 'Submission Update General'
				SET @Vendor = (SELECT TOP(1) Vendor FROM stng.VV_TOQ_VendorSubmission WHERE UniqueID = @Value6 )
				SET @SubmissionType = (SELECT TOP(1) SubmissionStatus FROM stng.VV_TOQ_VendorSubmission WHERE UniqueID = @Value6)
				SET @StatusUpdateComment = (SELECT TOP(1) Comment FROM stng.TOQ_VendorStatusLog WHERE VendorAssignedID = @Value6 order by CreatedDate desc );
				
				IF @SubmissionType <> 'Submitted Editable'
				BEGIN

					INSERT INTO @RecipientTable(RecipientEID)
					SELECT au.EmployeeID
					FROM stng.VV_TOQ_Main tm
					JOIN stng.Admin_User au ON au.EmployeeID = tm.PCSID OR au.EmployeeID = tm.SMID OR au.EmployeeID = OEID OR au.EmployeeID = tm.RequestFrom
					WHERE tm.UniqueID = @SourceTOQUniqueID
					UNION
					SELECT au.EmployeeID
					FROM @EBSList e
					JOIN stng.Admin_User au ON au.EmployeeID = e.EmployeeID

					INSERT INTO @CCTable(CCEID)
					 --specific to value6
					SELECT up.EmployeeID
					FROM stng.VV_Admin_ActualUserPermission up
					JOIN stng.Admin_UserAttribute ua on ua.EmployeeID = up.EmployeeID
					JOIN stng.VV_Common_VendorIDAttributeID cid on cid.AttributeID = ua.AttributeID
					JOIN stng.VV_TOQ_VendorSubmission vs on vs.VendorID = cid.VendorID
					where vs.UniqueID = @Value6 and up.PermissionID = '15CEBF40-935D-40B5-8EFE-BA4CEDBBDB88'

				END
				ELSE--submission editable subup
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT au.EmployeeID
					FROM stng.Admin_User au
					JOIN stng.VV_Admin_ActualUserPermission up on up.EmployeeID = au.EmployeeID
					JOIN stng.Admin_UserAttribute ua on ua.EmployeeID = up.EmployeeID
					JOIN stng.VV_Common_VendorIDAttributeID cid on cid.AttributeID = ua.AttributeID
					JOIN stng.VV_TOQ_VendorSubmission vs on vs.VendorID = cid.VendorID
					where vs.UniqueID = @Value6 and up.PermissionID = '15CEBF40-935D-40B5-8EFE-BA4CEDBBDB88'
					
					INSERT INTO @CCTable
					SELECT au.EmployeeID
					FROM stng.VV_TOQ_Main tm
					JOIN stng.Admin_User au ON au.EmployeeID = tm.PCSID OR au.EmployeeID = tm.SMID OR au.EmployeeID = OEID OR au.EmployeeID = tm.RequestFrom
					WHERE tm.UniqueID = @SourceTOQUniqueID
					UNION
					SELECT e.EmployeeID
					FROM @EBSList e
				END

			END
			ELSE IF @Value2 = 'MPL' -- project not in MPL yet
			BEGIN
				INSERT INTO @RecipientTable
				SELECT EmployeeID
				FROM @EBSSMList
				UNION
				SELECT EmployeeID
				FROM @LeadPlanners
				UNION
				SELECT EmployeeID
				FROM @PCSLeads

				INSERT INTO @CCTable
				SELECT EmployeeID
				FROM @MPLTestTeam

				SET @EmailType = 'Missing in MPL'
			END
			ELSE

			

			BEGIN
			IF @WorkingType = '145ED3D3-E286-4621-8468-07CFB59E420A'--Standard
			OR @WorkingType = '1916B0B8-80CD-441D-AA54-E04C955033A9'--Standard OE/ADE
			OR @WorkingType = 'B64F2447-981C-4BA2-ACAC-444E0E1341D3'--Consulting
			OR @WorkingType = 'F7E23BFF-CC2B-4BE7-AE33-7F49E73E75D5'--Mini-drawdown (ER)
			OR @WorkingType = '185435F4-4E82-44DC-91C6-6414A517C711'--Mini-drawdown (General)
			OR @WorkingType = '7F12F62C-52A6-4E20-AB8D-EAEBB47C38B8'--Mini-drawdown (OE/ADE)
			OR @WorkingType = 'D2AFC849-BFAA-4E14-8D17-6795CFD092B4'--Mini-drawdown (Core Consulting)
			OR @WorkingType = 'CE0A0A24-A026-4AC0-BB59-D1E162118D50'--Mini-drawdown (Section Consulting)
			BEGIN

				--WHEN (@Value2 = 'INIT') --Initialized, someone clicked create a toq
				--THEN RequestFrom--may not be necessary
				IF (@Value2 = 'DELIV') --Deliverable Accounts Email
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT DISTINCT EmployeeID FROM
					@SourceVendorList
					WHERE (Awarded = 1)

					INSERT INTO @CCTable(CCEID)
					SELECT EmployeeID
					FROM @BPProjControlsTeam;

					IF ((SELECT TOP(1) StatusID FROM stng.TOQ_Main WHERE UniqueID = @Value1) = 'CE3B8C9E-526A-4353-BEAA-AAA172788F59')
					BEGIN
						SET @EmailType = 'Deliverable Accounts Late Start 1';
					END
					ELSE IF (@RoutedFromStatus = 'ODU')
					BEGIN
						SET @EmailType = 'Deliverable Accounts Late Start 2';
					END
					ELSE
					BEGIN
						SET @EmailType = 'Deliverable Accounts General';
					END
					
				END
				ELSE IF (@Value2 = 'ASMIA') --Awaiting SM Initial Approval
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.SMID
					WHERE t.UniqueID = @Value1
				END

				ELSE IF (@Value2 = 'AEIA') --Awaiting EBS Initial Approval
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM @EBSList t
					JOIN stng.Admin_User u ON u.EmployeeID = t.EmployeeID

				END

				ELSE IF (@Value2 = 'AVS') --Awaiting Vendor Submission
				--send to all selected vendors (not available until we determine who to send to at vendors)
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT e.EmployeeID
					FROM @EBSList e 

					INSERT INTO @BCCTable(BCCEID)
					SELECT DISTINCT EmployeeID FROM
					@SourceVendorList
					
					INSERT INTO @CCTable
					SELECT t.RequestFrom
					FROM stng.VV_TOQ_Main t
					WHERE t.UniqueID = @Value1
					UNION
					SELECT t.PCSID
					FROM stng.VV_TOQ_Main t
					WHERE t.UniqueID = @Value1

					SET @EmailType = 'Vendor Selected General'
				END

				--ELSE IF (@Value2 = 'AEBSP') --Vendors Have Submitted - Awaiting EBS Processing
				--send to all ebs
				--BEGIN
				--	INSERT INTO @RecipientTable(RecipientEID)
				--	SELECT u.EmployeeID
				--	FROM @EBSList t
				--	JOIN stng.Admin_User u ON u.EmployeeID = t.EmployeeID
				--END

				ELSE IF (@Value2 = 'AOEVA') --Awaiting OE Vendor Award
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.OEID
					WHERE t.UniqueID = @Value1

					INSERT INTO @CCTable(CCEID)
					SELECT t.RequestFrom
					FROM stng.VV_TOQ_Main t
					WHERE t.UniqueID = @Value1
				END

				ELSE IF (@Value2 = 'ALAMS') --Awaiting LAMP Submission
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.OEID
					WHERE t.UniqueID = @Value1
				END

				ELSE IF (@Value2 = 'ASAA') --Awaiting SM Award Approval
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.SMID
					WHERE t.UniqueID = @Value1

					INSERT INTO @CCTable(CCEID)
					SELECT t.RequestFrom
					FROM stng.VV_TOQ_Main t
					WHERE t.UniqueID = @Value1
					UNION
					SELECT t.PCSID
					FROM stng.VV_TOQ_Main t
					WHERE t.UniqueID = @Value1
					UNION
					SELECT t.OEID
					FROM stng.VV_TOQ_Main t
					WHERE t.UniqueID = @Value1
				END

				ELSE IF (@Value2 = 'AVSA') --Awaiting SM Award Approval (full)
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.SMID
					WHERE t.UniqueID = @Value1

					INSERT INTO @CCTable(CCEID)
					SELECT t.RequestFrom
					FROM stng.VV_TOQ_Main t
					WHERE t.UniqueID = @Value1
					UNION
					SELECT t.PCSID
					FROM stng.VV_TOQ_Main t
					WHERE t.UniqueID = @Value1
					UNION
					SELECT t.OEID
					FROM stng.VV_TOQ_Main t
					WHERE t.UniqueID = @Value1
				END


				ELSE IF (@Value2 = 'HSDQ') --Hold for SDQ
				BEGIN 
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.OEID
					WHERE t.UniqueID = @Value1
				END

				ELSE IF (@Value2 = 'ACOR') --Awaiting Commercial Review
				--send to all ebs
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM @EBSList t
					JOIN stng.Admin_User u ON u.EmployeeID = t.EmployeeID
				END

				ELSE IF (@Value2 = 'AESAA') --Awaiting EBS SM Award Approval
				--send to all EBS SM
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM @EBSSMList t
					JOIN stng.Admin_User u ON u.EmployeeID = t.EmployeeID
				END

				ELSE IF (@Value2 = 'ADMSA') --Awaiting DM EP Scope Approval (consulting)
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.DMEPID
					WHERE t.UniqueID = @Value1

					INSERT INTO @CCTable(CCEID)
					SELECT t.RequestFrom
					FROM stng.VV_TOQ_Main t
					WHERE t.UniqueID = @Value1
					UNION
					SELECT t.PCSID
					FROM stng.VV_TOQ_Main t
					WHERE t.UniqueID = @Value1
				END
				ELSE IF (@Value2 = 'ADMA') -- Awaiting DM EP Approval
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.DMEPID
					WHERE t.UniqueID = @Value1
				END

				ELSE IF (@Value2 = 'ADIVA') --Awaiting DivM Approval
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.DivMID
					WHERE t.UniqueID = @Value1

				END

				ELSE IF (@Value2 = 'AVPA') -- Awaiting VP Approval
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT EmployeeID
					FROM @VPList
				END

				ELSE IF (@Value2 = 'AEFP') --Awaiting EBS Final Processing
				--send to all EBS
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM @EBSList t
					JOIN stng.Admin_User u ON u.EmployeeID = t.EmployeeID

					
				END

				--ELSE IF (@Value2 = 'ASVPA') --Awaiting SVP Approval
				----send to all EBS SPOC
				--BEGIN
				--	INSERT INTO @RecipientTable(RecipientEID)
				--	SELECT u.EmployeeID
				--	FROM @EBSSMList t
				--	JOIN stng.Admin_User u ON u.EmployeeID = t.EmployeeID
				--END

				ELSE IF (@Value2 = 'FULLR')--Fully Released
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT au.EmployeeID
					FROM stng.VV_TOQ_Main tm
					JOIN stng.Admin_User au ON au.EmployeeID = tm.PCSID OR au.EmployeeID = tm.SMID OR au.EmployeeID = OEID OR au.EmployeeID = tm.RequestFrom
					WHERE tm.UniqueID = @Value1;

					INSERT INTO @CCTable(CCEID)
					SELECT EmployeeID
					FROM @EBSList
					UNION
					SELECT EmployeeID
					FROM @BPProjControlsTeam;

					SET @EmailType = 'Complete General';
				END

				--Requested to remove ACC emails

				--ELSE IF (@Value2 = 'ACC') --Approved AND Complete
				--BEGIN
					
					--TOQ CRUD sets status to VDU when late start
					--IF ((SELECT TOP(1) StatusID FROM stng.TOQ_Main WHERE UniqueID = @Value1) = 'CE3B8C9E-526A-4353-BEAA-AAA172788F59')
					--BEGIN
					--	SET @EmailType = 'Complete Late Start 1';
					--END
					--ELSE IF (@RoutedFromStatus = 'ODU')
					--BEGIN
					--	SET @EmailType = 'Complete Late Start 2';
					--END
					--ELSE
					--BEGIN
					--	SET @EmailType = 'Complete General';
					--END

					--INSERT INTO @RecipientTable(RecipientEID)
					--SELECT au.EmployeeID
					--FROM stng.VV_TOQ_Main tm
					--JOIN stng.Admin_User au ON au.EmployeeID = tm.PCSID OR au.EmployeeID = tm.SMID OR au.EmployeeID = OEID OR au.EmployeeID = tm.RequestFrom
					--WHERE tm.UniqueID = @Value1;

					--INSERT INTO @CCTable(CCEID)
					--SELECT EmployeeID
					--FROM @EBSList
					--UNION
					--SELECT EmployeeID
					--FROM @BPProjControlsTeam;
				--END

				ELSE IF (@Value2 = 'ADPR') --Additional Partial Release
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.OEID
					WHERE t.UniqueID = @Value1


				END

				ELSE IF (@Value2 = 'APCOR') --Awaiting Partial Commercial Review
				--send to all EBS
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM @EBSList t
					JOIN stng.Admin_User u ON u.EmployeeID = t.EmployeeID

				END

				ELSE IF (@Value2 = 'ICORR') --Initial Correction Required
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.RequestFrom
					WHERE t.UniqueID = @Value1

					INSERT INTO @CCTable(CCEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u on u.EmployeeID = t.PCSID or u.EmployeeID = t.OEID
					WHERE t.UniqueID = @Value1
					UNION
					SELECT EmployeeID
					FROM @EBSSMList
					UNION
					SELECT EmployeeID
					FROM @SourceVendorList
				END

				ELSE IF (@Value2 = 'CORR') --Correction Required
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.OEID
					WHERE t.UniqueID = @Value1

					INSERT INTO @CCTable(CCEID)
					SELECT t.PCSID
					FROM stng.VV_TOQ_Main t
					WHERE t.UniqueID = @Value1
					UNION
					SELECT EmployeeID
					FROM @EBSSMList
				END


				ELSE IF (@Value2 = 'ACANC') --Awaiting Cancellation Approval
				--send to all EBS SM
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM @EBSSMList t
					JOIN stng.Admin_User u ON u.EmployeeID = t.EmployeeID

				END

				ELSE IF (@Value2 = 'CANC') --Cancelled
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.RequestFrom
					WHERE t.UniqueID = @Value1
					--union awarded vendor
					UNION
					SELECT EmployeeID
					FROM @SourceVendorList
					
					INSERT INTO @CCTable(CCEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.OEID OR u.EmployeeID = t.SMID OR u.EmployeeID = t.PCSID
					WHERE t.UniqueID = @Value1
					UNION 
					SELECT EmployeeID
					FROM @EBSList

					set @EmailType = 'Notification General'
				END
				

				--ELSE IF (@Value2 = 'REP') --Replaced
				----need to change format of email
				--BEGIN
				--	INSERT INTO @RecipientTable(RecipientEID)
				--	SELECT u.EmployeeID
				--	FROM stng.VV_TOQ_Main t
				--	JOIN stng.Admin_User u ON u.EmployeeID = t.RequestFrom
				--	WHERE t.UniqueID = @Value1
					
				--	set @EmailType = 'Notification General'
				--END

				--ELSE IF (@Value2 = 'SUPER') --Revised
				----need to change format of email
				--BEGIN
				--	INSERT INTO @RecipientTable(RecipientEID)
				--	SELECT u.EmployeeID
				--	FROM stng.VV_TOQ_Main t
				--	JOIN stng.Admin_User u ON u.EmployeeID = t.RequestFrom
				--	WHERE t.UniqueID = @Value1
					
				--	set @EmailType = 'Notification General'
				--END

				ELSE IF (@Value2 = 'NTAPP') --Not Approved
				--need to change format of email
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.RequestFrom
					WHERE t.UniqueID = @Value1

					INSERT INTO @BCCTable(BCCEID)
					SELECT DISTINCT EmployeeID FROM
					@SourceVendorList
					WHERE (Awarded = 0 or Awarded is null)

					set @EmailType = 'Notification General'
				END

				ELSE IF (@Value2 = 'CLOSE') --Closed
				--need to change format of email
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.RequestFrom
					WHERE t.UniqueID = @Value1
					UNION
					SELECT EmployeeID
					FROM @SourceVendorList
					WHERE Awarded = 1
					
					INSERT INTO @CCTable(CCEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.OEID OR u.EmployeeID = t.PCSID
					WHERE t.UniqueID = @Value1

					SET @EmailType = 'Notification General'
				END

				ELSE IF (@Value2 = 'VDU' AND @RoutedFromStatus <> 'ODU')--Vendor Date Update
				BEGIN
					INSERT INTO @RecipientTable
					SELECT EmployeeID
					FROM @SourceVendorList
					WHERE Awarded = 1
					
					INSERT INTO @CCTable(CCEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.PCSID OR u.EmployeeID = t.RequestFrom OR u.EmployeeID = t.OEID
					WHERE t.UniqueID = @Value1
					SET @EmailType = 'Vendor Date Update General'
				END
				ELSE IF (@Value2 = 'VDU' AND @RoutedFromStatus = 'ODU')--Vendor Date Update--correction required
				BEGIN
					INSERT INTO @RecipientTable
					SELECT EmployeeID
					FROM @SourceVendorList
					WHERE Awarded = 1

					INSERT INTO @CCTable(CCEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.PCSID OR u.EmployeeID = t.RequestFrom
					WHERE t.UniqueID = @Value1
					SET @EmailType = 'Vendor Date Update Correction'
				END
				ELSE IF (@Value2 = 'ODU')--OE Date Update
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.OEID
					WHERE t.UniqueID = @Value1

					INSERT INTO @CCTable(CCEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.PCSID OR u.EmployeeID = t.RequestFrom
					WHERE t.UniqueID = @Value1
					SET @EmailType = 'OE Date Update'
				END

			END

			ELSE IF @WorkingType = '6CFD5F05-75E2-4246-AB48-16AF64F4007B'--Emergent
			BEGIN


				--IF (@Value2 = 'INIT') --Initialized, someone clicked create a toq
				-- RequestFrom--may not be necessary

				IF (@Value2 = 'ADMA') --2. BP: Awaiting DM EP Approval
				BEGIN
				INSERT INTO @RecipientTable(RecipientEID)
				SELECT u.EmployeeID
				FROM stng.VV_TOQ_Main t
				JOIN stng.Admin_User u ON u.EmployeeID = t.DMEPID
				WHERE t.UniqueID = @SourceTOQUniqueID;

				INSERT INTO @CCTable(CCEID)
				SELECT t.RequestFrom
				FROM stng.VV_TOQ_Main t
				WHERE t.UniqueID = @Value1
				UNION
				SELECT t.PCSID
				FROM stng.VV_TOQ_Main t
				WHERE t.UniqueID = @SourceTOQUniqueID;
				END

				ELSE IF (@Value2 = 'AVENA') --3. All: Awaiting Vendor Acceptance
				BEGIN
				

				IF (@IsChild = 0)
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT DISTINCT EmployeeID FROM
					@SourceVendorList
				END
				ELSE
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT DISTINCT EmployeeID FROM
					@ChildVendorList
				END

				--insert Design Engineer attribute users into table--internal emergent
				IF ((select top(1) VendorID from stng.TOQ_VendorAssigned WHERE TOQMainID = @Value1) = 'B4FF447B-3197-4F6D-93F6-305180486BDB')
				BEGIN 
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT e.EmployeeID
					FROM @DesignEngineeringList e
				END

				END

				ELSE IF (@Value2 = 'ACC') --4. All: Approved AND Complete
				--every ebs
				BEGIN
				INSERT INTO @RecipientTable(RecipientEID)
				SELECT u.EmployeeID
				FROM @EBSList t
				JOIN stng.Admin_User u ON u.EmployeeID = t.EmployeeID
				

				INSERT INTO @CCTable(CCEID)
				SELECT au.EmployeeID
				FROM stng.VV_TOQ_Main tm
				JOIN stng.Admin_User au ON au.EmployeeID = tm.PCSID OR au.EmployeeID = tm.SMID OR au.EmployeeID = OEID
				WHERE tm.UniqueID = @SourceTOQUniqueID
				UNION
				SELECT au.EmployeeID
				FROM stng.VV_TOQ_Main tm
				JOIN stng.Admin_User au ON au.EmployeeID  = tm.RequestFrom
				WHERE tm.UniqueID = @Value1
				UNION
				SELECT EmployeeID
				FROM @BPProjControlsTeam
				UNION
				SELECT
				CASE WHEN @IsChild = 1 THEN
				(SELECT DISTINCT EmployeeID FROM @ChildVendorList)
				ELSE
				(SELECT DISTINCT EmployeeID FROM @SourceVendorList)
				END AS EmployeeID

				--insert Design Engineer attribute users into table--internal emergent
				IF ((select top(1) VendorID from stng.TOQ_VendorAssigned WHERE TOQMainID = @Value1) = 'B4FF447B-3197-4F6D-93F6-305180486BDB')
				BEGIN 
					INSERT INTO @CCTable(CCEID)
					SELECT e.EmployeeID
					FROM @DesignEngineeringList e
				END

				

				SET @EmailType = 'Notification General';
				END

				ELSE IF (@Value2 = 'RES') --5. All: Resolved
				BEGIN
				INSERT INTO @RecipientTable(RecipientEID)
				SELECT u.EmployeeID
				FROM stng.VV_TOQ_Main t
				JOIN stng.Admin_User u ON u.EmployeeID = t.RequestFrom
				WHERE t.UniqueID = @Value1

				set @EmailType = 'Notification General'
				END

				ELSE IF (@Value2 = 'REDDMEP') --6. BP: Request Denied (DM EP)
				--email all stakeholders
				BEGIN
				INSERT INTO @RecipientTable(RecipientEID)
				SELECT u.EmployeeID
				FROM stng.VV_TOQ_Main t
				JOIN stng.Admin_User u ON u.EmployeeID = t.RequestFrom
				WHERE t.UniqueID = @Value1
				
				set @EmailType = 'Notification General'
				END

				ELSE IF (@Value2 = 'RDV') --7. All: Request Denied (Vendor)
				--email all stakeholders
				BEGIN
				INSERT INTO @RecipientTable(RecipientEID)
				SELECT u.EmployeeID
				FROM stng.VV_TOQ_Main t
				JOIN stng.Admin_User u ON u.EmployeeID = t.RequestFrom
				WHERE t.UniqueID = @Value1

				set @EmailType = 'Notification General'
				END

				ELSE IF (@Value2 = 'CANC') --8. All: Cancelled
				--email all stakeholders
				BEGIN

				IF (@IsChild = 0)
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.RequestFrom
					WHERE t.UniqueID = @Value1
					--union awarded vendor
					UNION
					SELECT EmployeeID 
					FROM @SourceVendorList
					WHERE Awarded = 1;
				END
				ELSE
				BEGIN
					INSERT INTO @RecipientTable(RecipientEID)
					SELECT u.EmployeeID
					FROM stng.VV_TOQ_Main t
					JOIN stng.Admin_User u ON u.EmployeeID = t.RequestFrom
					WHERE t.UniqueID = @Value1
					--union awarded vendor
					UNION
					SELECT EmployeeID 
					FROM @ChildVendorList
					WHERE Awarded = 1;
				END



				INSERT INTO @CCTable(CCEID)
				SELECT u.EmployeeID
				FROM stng.VV_TOQ_Main t
				JOIN stng.Admin_User u ON u.EmployeeID = t.OEID OR u.EmployeeID = t.SMID OR u.EmployeeID = t.PCSID
				WHERE t.UniqueID = @SourceTOQUniqueID
				UNION 
				SELECT EmployeeID
				FROM @EBSList

				set @EmailType = 'Notification General'
				END

				ELSE IF (@Value2 = 'CORR') --9. All: Correction Required
				BEGIN
				INSERT INTO @RecipientTable(RecipientEID)
				SELECT u.EmployeeID
				FROM stng.VV_TOQ_Main t
				JOIN stng.Admin_User u ON u.EmployeeID = t.RequestFrom
				WHERE t.UniqueID = @Value1

				INSERT INTO @CCTable(CCEID)
				SELECT u.EmployeeID
				FROM stng.VV_TOQ_Main t
				JOIN stng.Admin_User u ON u.EmployeeID = t.OEID OR u.EmployeeID = t.SMID OR u.EmployeeID = t.PCSID
				WHERE t.UniqueID = @SourceTOQUniqueID
				END
			END

				

			ELSE IF @WorkingType = 'E07BEF3A-D60A-4FD7-9624-C510A02AA01F'--SVN
			BEGIN
				SET @EmailType = 'Status Change General'

				--WHEN (@Value2 = 'INIT') --1. Initiated (Only ON vendor side)
				--THEN RequestFrom--send to vendor PM aka creator

				IF (@Value2 = 'AOEA') --2. Awaiting OE Approval (Only ON BP Side)
				BEGIN
				INSERT INTO @RecipientTable(RecipientEID)
				SELECT u.EmployeeID
				FROM stng.VV_TOQ_Main t
				JOIN stng.Admin_User u ON u.EmployeeID = t.OEID
				WHERE t.UniqueID = @SourceTOQUniqueID

				INSERT INTO @CCTable(CCEID)
				SELECT t.RequestFrom
				FROM stng.VV_TOQ_Main t
				WHERE t.UniqueID = @Value1
				END

				ELSE IF (@Value2 = 'ICORR') --9. Initial Correction
				--vendor pm
				BEGIN
				INSERT INTO @RecipientTable(RecipientEID)
				SELECT u.EmployeeID
				FROM stng.VV_TOQ_Main t
				JOIN stng.Admin_User u ON u.EmployeeID = t.RequestFrom
				WHERE t.UniqueID = @Value1--requestfrom needs to use child toq row
				END


				ELSE IF (@Value2 = 'ADMA') --3. Awaiting DM EP Approval (Only ON BP Side)
				BEGIN
				INSERT INTO @RecipientTable(RecipientEID)
				SELECT u.EmployeeID
				FROM stng.VV_TOQ_Main t
				JOIN stng.Admin_User u ON u.EmployeeID = t.DMEPID
				WHERE t.UniqueID = @SourceTOQUniqueID;

				INSERT INTO @CCTable(CCEID)
				SELECT t.OEID
				FROM stng.VV_TOQ_Main t
				WHERE t.UniqueID = @SourceTOQUniqueID
				END


				ELSE IF (@Value2 = 'SVNEBA') --4. Awaiting EBS SM Approval (ON BP Side)
				--all EBS SM
				BEGIN
				INSERT INTO @RecipientTable(RecipientEID)
				SELECT u.EmployeeID
				FROM @EBSSMList t
				JOIN stng.Admin_User u ON u.EmployeeID = t.EmployeeID

				INSERT INTO @CCTable(CCEID)
				SELECT t.OEID
				FROM stng.VV_TOQ_Main t
				WHERE t.UniqueID = @SourceTOQUniqueID
				END

				ELSE IF (@Value2 = 'CANC') --6. Canceled
				--all stakeholders
				BEGIN
				INSERT INTO @RecipientTable(RecipientEID)
				SELECT u.EmployeeID
				FROM stng.VV_TOQ_Main t
				JOIN stng.Admin_User u ON u.EmployeeID = t.RequestFrom
				WHERE t.UniqueID = @Value1

				INSERT INTO @CCTable(CCEID)
				SELECT u.EmployeeID
				FROM stng.VV_TOQ_Main t
				JOIN stng.Admin_User u ON u.EmployeeID = t.OEID 
				WHERE t.UniqueID = @SourceTOQUniqueID

				set @EmailType = 'Notification General'
				END

				ELSE IF (@Value2 = 'NTAPP') --7. Not Approved
				BEGIN
				INSERT INTO @RecipientTable(RecipientEID)
				SELECT u.EmployeeID
				FROM stng.VV_TOQ_Main t
				JOIN stng.Admin_User u ON u.EmployeeID = t.RequestFrom
				WHERE t.UniqueID = @Value1

				INSERT INTO @CCTable(CCEID)
				SELECT t.OEID
				FROM stng.VV_TOQ_Main t
				WHERE t.UniqueID = @Value1
				
				END

				ELSE IF (@Value2 = 'SVNVI') --9. Approved – Awaiting Vendor Input
				--vendor pm
				BEGIN
				INSERT INTO @RecipientTable(RecipientEID)
				SELECT u.EmployeeID
				FROM stng.VV_TOQ_Main t
				JOIN stng.Admin_User u ON u.EmployeeID = t.RequestFrom
				WHERE t.UniqueID = @Value1

				INSERT INTO @CCTable(CCEID)
				SELECT EmployeeID
				FROM @SourceVendorList
				WHERE Awarded = 1
				END

				ELSE IF (@Value2 = 'SVNOI') --10. Approved - Awaiting OE input
				BEGIN
				INSERT INTO @RecipientTable(RecipientEID)
				SELECT u.EmployeeID
				FROM stng.VV_TOQ_Main t
				JOIN stng.Admin_User u ON u.EmployeeID = t.OEID
				WHERE t.UniqueID = @SourceTOQUniqueID



				END

				ELSE IF (@Value2 = 'SVND') --11. Dispositioned
				--all ebs
				BEGIN
				INSERT INTO @RecipientTable(RecipientEID)
				SELECT u.EmployeeID
				FROM @EBSList t
				JOIN stng.Admin_User u ON u.EmployeeID = t.EmployeeID
				END	

				ELSE IF (@Value2 = 'ACC') --11. Approved and Complete
				--to whom?
				BEGIN
				INSERT INTO @RecipientTable(RecipientEID)
				SELECT u.EmployeeID
				FROM stng.VV_TOQ_Main t
				JOIN stng.Admin_User u ON u.EmployeeID = t.RequestFrom
				WHERE t.UniqueID = @Value1


				END	
					
			END

			ELSE IF @WorkingType = '88DE5866-E0FF-4F46-A8AF-C3E29A828D6B'--Rework
			BEGIN
				
				
				--WHEN (@Value2 = 'INIT') --1. Initiated
				--THEN OEID--

				IF (@Value2 = 'ASMA') --2. Awaiting SM Approval
				BEGIN
				INSERT INTO @RecipientTable(RecipientEID)
				SELECT u.EmployeeID
				FROM stng.VV_TOQ_Main t
				JOIN stng.Admin_User u ON u.EmployeeID = t.SMID
				WHERE t.UniqueID = @SourceTOQUniqueID



				END

				ELSE IF (@Value2 = 'AVNR') --3. Awaiting Vendor Response
				BEGIN
				INSERT INTO @RecipientTable(RecipientEID)
				SELECT DISTINCT EmployeeID FROM
				@SourceVendorList
				WHERE Awarded = 1

				INSERT INTO @CCTable(CCEID)
				SELECT EmployeeID 
				FROM @EBSList

				END

				ELSE IF (@Value2 = 'VACC') --4. Vendor Accepted
				--all stakeholders
				BEGIN
				INSERT INTO @RecipientTable(RecipientEID)
				SELECT u.EmployeeID
				FROM stng.VV_TOQ_Main t
				JOIN stng.Admin_User u ON u.EmployeeID = t.SMID OR u.EmployeeID = t.DMEPID OR u.EmployeeID = t.OEID OR u.EmployeeID IN (SELECT EmployeeID FROM @EBSList)
				WHERE t.UniqueID = @SourceTOQUniqueID
				UNION
				SELECT u.EmployeeID
				FROM stng.VV_TOQ_Main t
				JOIN stng.Admin_User u ON u.EmployeeID = t.RequestFrom
				WHERE t.UniqueID = @Value1

				--UNION awarded vendor
				UNION
				SELECT DISTINCT EmployeeID FROM
				@SourceVendorList
				WHERE Awarded = 1

				set @EmailType = 'Notification General'
				END

				ELSE IF (@Value2 = 'VDEC') --5. Vendor Declined
				--all stakeholders
				BEGIN
				INSERT INTO @RecipientTable(RecipientEID)
				SELECT u.EmployeeID
				FROM stng.VV_TOQ_Main t
				JOIN stng.Admin_User u ON u.EmployeeID = t.SMID OR u.EmployeeID = t.DMEPID OR u.EmployeeID = t.OEID OR u.EmployeeID IN (SELECT EmployeeID FROM @EBSList)
				WHERE t.UniqueID = @SourceTOQUniqueID
				UNION
				SELECT u.EmployeeID
				FROM stng.VV_TOQ_Main t
				JOIN stng.Admin_User u ON u.EmployeeID = t.RequestFrom
				WHERE t.UniqueID = @Value1
				--UNION awarded vendor
				UNION
				SELECT DISTINCT EmployeeID FROM
				@SourceVendorList
				WHERE Awarded = 1


				set @EmailType = 'Notification General'
				END
				


			END
			END

			IF(@SubOp = 1)
			BEGIN
				(SELECT DISTINCT uv.Username AS EmailTo, uv.EmpName AS Recipient 
				FROM @RecipientTable r
				JOIN stng.VV_Admin_UserView uv on uv.EmployeeID = r.RecipientEID
				WHERE uv.Username is not null
				UNION
				SELECT DISTINCT alt.AlternateEmail AS EmailTo, uv.EmpName AS Recipient
				FROM @RecipientTable r
				JOIN stng.Admin_UserAlternateEmail alt on alt.EmployeeID = r.RecipientEID
				JOIN stng.VV_Admin_UserView uv on uv.EmployeeID = r.RecipientEID
				WHERE alt.AlternateEmail is not null
				);
			END
			IF(@SubOp = 2)
			BEGIN
				(SELECT DISTINCT au.Username AS EmailCC FROM stng.Admin_User au JOIN @CCTable e ON au.EmployeeID = e.CCEID WHERE au.Username is not null
				UNION
				SELECT DISTINCT alt.AlternateEmail AS EmailCC FROM stng.Admin_UserAlternateEmail alt JOIN @CCTable e on alt.EmployeeID = e.CCEID WHERE alt.AlternateEmail is not null
				) 
			END
			IF(@SubOp = 3)
			BEGIN
				SELECT
				be.EmailBody AS EmailBody,
				be.EmailSubject,
				tm.BPTOQID AS TOQID,
				tm.Rev,
				(select TOP(1) Comment from stng.TOQ_StatusLog where TOQMainID = @Value1 order by CreatedDate desc) as Comment,
				st.DMEP as DM, 
				st.OE, 
				st.SM, 
				tm.TMID AS ID, 
				st.TMID AS SourceID,
				tm.[Status] AS DatabaseStatus, 
				tm.TDSNo AS TDSNum, 
				st.Project AS ProjectNum, 
				st.Title AS TaskOrderTitle,
				tm.AwardedTotalCost,
				tm.[Type],
				tm.PartialRelease,
				tm.VendorClarificationDate,
				tm.VendorSubmissionDate,
				@RoutedFromStatus AS RoutedFromStatus,--2nd last status
				@Vendor AS Vendor,
				@SubmissionType AS SubmissionStatus,
				@StatusUpdateComment AS StatusUpdateComment,
				@EmailType AS EmailType,

				CASE WHEN (@WorkingType = '6CFD5F05-75E2-4246-AB48-16AF64F4007B') THEN
				'<p><b>Request Amount:</b> $' + CAST((SELECT TOP(1) RequestAmount FROM stng.TOQ_EmergentDetail WHERE UniqueID = @Value1) AS varchar) + ' </p>'
				ELSE NULL
				END AS [EmergentTotalRow],

				CASE WHEN (@Partial is not null) THEN
				(SELECT 'Yes')
				ELSE 'No'
				END AS [Partial],

				CASE WHEN (@Value2 = 'ACC') THEN
				(SELECT TOP(1) [Value] FROM stng.Common_ValueLabel cvl WHERE cvl.UniqueID = tm.StatusID)
				ELSE Null
				END AS [DatabaseStatusID],

				CASE WHEN (@EmailType = 'Status Change General' OR @EmailType = 'Notification General') THEN
				(SELECT TOP(1) [Label] FROM stng.Common_ValueLabel cvl WHERE @Value2 = cvl.[Value] AND cvl.ModuleID = '774EDE6C-58D2-4DF7-8D1A-4667CC30BBB4' AND [Group] = (SELECT TOP(1) Type FROM stng.VV_TOQ_Types WHERE TypeID = @WorkingType))  
				ELSE null
				END AS NewStatus,
			
				CASE WHEN (@EmailType = 'Question General') THEN
				(SELECT TOP(1) [Subject] FROM stng.TOQ_Correspondence WHERE UniqueID = @Value6)
				ELSE NULL 
				END AS QuestionSubject,

				CASE 
				WHEN (@EmailType = 'Question General') 
				THEN
				(SELECT TOP(1) Detail FROM stng.TOQ_Correspondence WHERE UniqueID = @Value6)
				ELSE NULL 
				END AS QuestionDetails,

				CASE WHEN (@EmailType = 'Question General') THEN
				(SELECT TOP(1) DetailLong FROM stng.TOQ_Correspondence WHERE UniqueID = @Value6) 
				ELSE NULL 
				END AS AdditionalQuestionDetails,

				CASE WHEN (@EmailType = 'Question General' AND @QuestionAnswer = 'A') THEN
				(SELECT ('<br><br>' + STRING_AGG(CONVERT(NVARCHAR(MAX), CONCAT('(', CreatedDate, '): ' , DetailLong)), '<br><br>') WITHIN GROUP (ORDER BY CreatedDate DESC))
				FROM stng.TOQ_Correspondence WHERE ParentUID = @Value6) 
				ELSE NULL 
				END AS Answer,

				CASE WHEN (@Value2 = 'DELIV' OR @Value2 = 'AWARD') THEN
				(SELECT TOP(1) gv.Vendor FROM stng.VV_General_Vendors gv JOIN @SourceVendorList vl ON  vl.VendorID = gv.VendorID WHERE vl.Awarded = 1)
				ELSE NULL
				END AS AwardedVendor,

				CASE WHEN (@Value2 = 'DELIV' OR @Value2 = 'AWARD') THEN
				(SELECT TOP(1) TOQNumber FROM @SourceVendorList WHERE Awarded = 1)
				ELSE NULL
				END AS AwardedTOQNumber,

				CASE WHEN (@Value2 = 'AWARD') THEN
				(SELECT TOP(1) TOQVendorRev FROM @SourceVendorList WHERE Awarded = 1)
				ELSE NULL
				END AS AwardedRev,

				CASE WHEN (@Value2 = 'AWARD') THEN
				(SELECT stng.GetBPTime(GETDATE()))
				ELSE NULL
				END AS AwardedDate,

				CASE WHEN (@Value2 = 'AWARD' OR @Value2 = 'DELIV') THEN
				(SELECT TOP(1) cvl.Label FROM stng.TOQ_Main tm
				JOIN stng.Common_ValueLabel cvl on cvl.UniqueID = tm.ScopeManagedBy
				WHERE tm.UniqueID = @SourceTOQUniqueID)
				ELSE NULL
				END AS Scope,

				@IsChild as IsChild,
				@VOE as VOE,
				@VOEMessage as VOEMessage
			

				FROM stng.TOQ_Emails be
				LEFT JOIN stng.VV_TOQ_Main tm ON tm.UniqueID = @Value1
				LEFT JOIN stng.VV_TOQ_Main st ON st.UniqueID = @SourceTOQUniqueID
				WHERE be.EmailType = @EmailType
			END

			IF (@SubOp = 4)
			BEGIN
				(SELECT DISTINCT uv.Username AS EmailBCC 
				FROM @BCCTable bcc 
				JOIN stng.Admin_User uv on uv.EmployeeID = bcc.BCCEID
				UNION
				SELECT DISTINCT alt.AlternateEmail AS EmailBCC
				FROM @BCCTable bcc
				JOIN stng.Admin_UserAlternateEmail alt on alt.EmployeeID = bcc.BCCEID
				UNION 
				SELECT uv.UserName AS EmailBCC
				FROM @EmailTestTeam ett
				JOIN stng.Admin_User uv on uv.EmployeeID = ett.EmployeeID
				UNION
				SELECT DISTINCT alt.AlternateEmail AS EmailBCC
				FROM @EmailTestTeam ett
				JOIN stng.Admin_UserAlternateEmail alt on alt.EmployeeID = ett.EmployeeID)
			END
			
		END
		--get deliverable accounts table
		ELSE IF (@SubOp = 5)
		BEGIN

			--if child record is entered, some cases need to use parent ('source') data
			--source TOQ ID will either be the record entered (Value1) or the parent ID if the record is a child
			DECLARE @SourceTOQID UNIQUEIDENTIFIER = 
			(SELECT TOP(1) ParentTOQID FROM stng.TOQ_Child WHERE ChildTOQID = @Value1);

			IF (@SourceTOQID IS NULL)
			BEGIN
				SET @SourceTOQID = @Value1;
			END

			--make specific to TOQ and Awarded vendor, using @Value1 and @SourceVendorList where awarded = 1
			SELECT DeliverableTitle, TotalHour, TotalCost, DistributedPartial, DeliverableStartDate, DeliverableEndDate, DeliverableAccount, DeliverableCode, CurrentTOQCommitmentDate 
			FROM stng.VV_TOQ_CostSummary cs
			JOIN stng.TOQ_VendorAssigned va on cs.VendorAssignedID = va.UniqueID AND va.Awarded = 1 and va.TOQMainID = @SourceTOQID--is this right? with source and all?
			WHERE cs.TOQMainID = @Value1
			ORDER BY DeliverableAccount asc;


		END
		--deleted vendors not notified
		ELSE IF (@SubOp = 6)
		BEGIN
			select UniqueID as VendorAssignedID 
			from stng.TOQ_VendorAssigned 
			where DeleteRecord = 1 and RemovedNotified = 0 and TOQMainID = @Value1
		END
		--mark all vendors for toq as notified
		ELSE IF (@SubOp = 7)
		BEGIN
			update stng.TOQ_VendorAssigned
			set RemovedNotified = 1
			where TOQMainID = @Value1 and DeleteRecord = 1
		END
		--check if emerg
		ELSE IF (@SubOp = 8)
		BEGIN
			SELECT
			CASE WHEN Exists(
			SELECT cvl.Value, cvl.UniqueID, m.UniqueID FROM stng.TOQ_Main m
			join stng.Common_ValueLabel cvl on cvl.UniqueID = m.TypeID
			WHERE m.UniqueID = @Value1 and cvl.Value = 'EMERG'
			) THEN 1
			ELSE 0
			END AS isEmergent
		END
		--check if need to send awarded email
		ELSE IF (@SubOp = 9)
		BEGIN
			SELECT
			CASE WHEN (Not Exists(
			SELECT m.UniqueID FROM stng.TOQ_Main m
			JOIN stng.TOQ_Child c on c.ChildTOQID = m.UniqueID
			WHERE m.UniqueID = @Value1
			)) THEN 1
			ELSE 0
			END AS sendAward
		END
		--should send nonaw email?
		ELSE IF (@SubOp = 10)
		BEGIN
			DECLARE @RoutedFrom NVARCHAR(255) = (SELECT TOP 1 [Value] FROM (
			SELECT TOP 2 v.[Value], s.CreatedDate from stng.TOQ_StatusLog s
			join stng.Common_ValueLabel v on s.TOQStatusID = v.UniqueID
			WHERE TOQMainID = @Value1
			ORDER BY s.CreatedDate DESC) AS test ORDER BY CreatedDate ASC)--2nd last status

			SELECT
			CASE WHEN Exists(
			SELECT m.UniqueID FROM stng.TOQ_Main m
			join stng.Common_ValueLabel cvl on cvl.UniqueID = m.TypeID
			join stng.TOQ_VendorAssigned va on va.TOQMainID = m.UniqueID and va.Awarded = 0--make sure non-awarded vendors exist
			WHERE m.UniqueID = @Value1 and cvl.Value <> 'EMERG' and @RoutedFrom <> 'ODU' and @RoutedFrom <> 'APCOR'
			) THEN 1
			ELSE 0
			END AS sendNONAW
		END
		--Get how many times TOQ has been at AVS
		ELSE IF (@SubOp = 11)
		BEGIN
			--the status is generated before the email right?
			SELECT COUNT(*) as AVSCount FROM stng.TOQ_StatusLog sl
			JOIN stng.Common_ValueLabel cvl on sl.TOQStatusID = cvl.UniqueID and cvl.[Value] = 'AVS'
			WHERE sl.TOQMainID = @Value1
		END	
	END
END
GO