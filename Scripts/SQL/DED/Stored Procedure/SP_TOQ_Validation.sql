/*
Author: Habib Shakibanejad
Description: TOQ Module Validation
CreatedDate: 1 Jan 2024
RevisedDate:
RevisedBy: 
*/
CREATE OR ALTER   PROCEDURE [stng].[SP_TOQ_Validation](
	@Status NVARCHAR(255) = NULL
	,@SubOp		TINYINT = NULL
	,@EmployeeID INT = NULL
	,@Value1 NVARCHAR(255) = NULL
	,@Value2 NVARCHAR(255) = NULL
	,@Value3 NVARCHAR(255) = NULL
	,@Value4 NVARCHAR(255) = NULL
	,@Value5 NVARCHAR(255) = NULL
	,@Value6 NVARCHAR(max) = NULL
	,@Num1 INT = NULL
	,@Num2 INT = NULL
	,@Num3 INT = NULL
	,@IsTrue1 BIT = NULL
	,@IsTrue2 BIT = NULL
	,@Date1 DATETIME = NULL
	,@Date2 DATETIME = NULL
) AS 
BEGIN
	/*
	Operations:
		1 - 
        2 - 
		3 - 
        4 - 
		5 - 
		6 - 
		7 - 
		8 - 
		9 - 
	*/  
    BEGIN TRY
		IF(@Status= 'INIT' OR @Status= 'ICORR')
			BEGIN
				-- Data 1
				SELECT T.BPTOQID,IIF(T.ClassVUniqueID IS NULL,0,1) HasClassVEstimate,T.UniqueID, EmergentID, 
				CASE WHEN T.WorkTypeID = (SELECT TOP(1) UniqueID from stng.VV_TOQ_Common WHERE [Value] = 'EMERGENT' and [Field] = 'WorkType' and [Group] = 'Header') 
				THEN
				'EMERGENT'
				WHEN T.WorkTypeID = (SELECT TOP(1) UniqueID from stng.VV_TOQ_Common WHERE [Value] = 'NONEMERG' and [Field] = 'WorkType' and [Group] = 'Header')
				THEN
				'NONEMERG'
				ELSE
				'UNSELECTED'
				END AS WorkType
				FROM stng.TOQ_Main T 
				LEFT JOIN stng.TOQ_ClassVMain V ON T.ClassVUniqueID = V.UniqueID 
				WHERE T.UniqueID = @Value1 

				-- Data 2
				SELECT COUNT(*) TotalTDSAttachments FROM stng.Common_FileMeta C 
				INNER JOIN stng.Admin_Module M ON M.UniqueID = C.ModuleID
				WHERE M.NameShort = 'TOQ' AND C.GroupBy = 'TDS'
				AND C.ParentID = @Value1 AND Deleted = 0

				-- Data 3
				SELECT 
				T.Title,
				T.TDSNo,
				T.UniqueID,
				T.RequestFrom,
				T.StatusID,
				T.StatusDate,
				T.ClassVUniqueID,
				T.VendorSubmissionDate,
				T.VendorClarificationDate,
				T.Resource,
				T.TDSRev,
				VT.Type,
				T.TypeID,
				T.ScopeManagedBy,
				T.Phase,
				T.Customer,
				T.VendorWorkTypeID,
				T.VendorStartDate,
				T.Project,
				CASE 
					WHEN EXISTS (
						SELECT *
						FROM stng.TOQ_VendorAssigned VA
						WHERE VA.DeleteRecord = 0 AND VA.TOQMainID = T.UniqueID
					) THEN CAST(1 AS bit)
					ELSE CAST(0 AS bit)
				END AS VendorsSelected,
				M.PCS,
				M.OE,  
				M.SM,
				M.DMEP
				FROM stng.TOQ_Main T
				LEFT JOIN stng.VV_TOQ_Types VT ON T.TypeID = VT.TypeID
				LEFT JOIN stng.VV_MPL_RecordPersonnel M ON M.RecordUniqueID = T.UniqueID AND M.RecordType = 'TOQ'
				WHERE T.UniqueID = @Value1 

				-- Data 4
				-- PDE Estimating fields, the where clause is to account for logic (RAM is not mandatory for TOQ that have Tier 1 vendor)
				SELECT 
				[EBSRAMLock],
				[PreviouslyRAMApproved],
				(SELECT COUNT(*) 
					 FROM stng.Common_FileMeta C 
					 INNER JOIN stng.Admin_Module M ON M.UniqueID = C.ModuleID
					 WHERE M.NameShort = 'TOQ' 
					   AND C.GroupBy = 'RAMDocs'
					   AND C.ParentID = @Value1 
					   AND C.Deleted = 0) AS TotalRAMAttachments,
				CASE WHEN EXISTS (
						SELECT 1
						FROM stng.TOQ_Main m
						INNER JOIN stng.TOQ_VendorWorkType vwt 
							ON m.VendorWorkTypeID = vwt.WorkTypeID
						INNER JOIN stng.TOQ_VendorAssigned va 
							ON m.UniqueID = va.TOQMainID
							AND vwt.VendorID = va.VendorID
						WHERE m.UniqueID = @Value1 
						AND va.DeleteRecord = 0
						AND vwt.Tier = 1
					) THEN 1 ELSE 0 END AS hasTierOneVendor
				FROM [stng].[TOQ_RAM_AllFields] 
				WHERE [TOQMainID] = @Value1 

			END

		ELSE IF(@Status = 'AOEVA') 
			BEGIN
				-- Data 1
				SELECT 
				CONVERT(NVARCHAR(255),T.VendorAwardID) VendorAwardID, 
				CONVERT(NVARCHAR(255), T.LinkedSDQ) LinkedSDQ, 
				T.JustificationForNaLinkedSDQ, T.AwardedVendor 
				FROM stng.VV_TOQ_Main T WHERE T.UniqueID = @Value1

				-- Data 2
				SELECT COUNT(*) AS SubmissionCount
				FROM [stng].[VV_TOQ_VendorSubmission]
				WHERE TOQMainID = @Value1 
				AND DeleteRecord = 0
				AND SubmissionStatus IN ('Submitted', 'Submitted Editable');

				-- Data 3
				SELECT 
					t.ComparisonEBSRAMLock, 
					t.VendorLowestCostOption, 
					t.VendorBucketOwner,
					CASE 
						WHEN MAX(CASE WHEN v.VendorTotalCost > 500000 THEN 1 ELSE 0 END) = 1 THEN 1
						ELSE 0
					END AS hasSubmissionGreaterThan500k
				FROM [stng].[TOQ_RAM_AllFields] t
				LEFT JOIN (
					SELECT 
						cs.TOQMainID,
						cs.VendorAssignedID,
						SUM(cs.TotalCost) AS VendorTotalCost
					FROM [stng].[VV_TOQ_CostSummary] cs
					INNER JOIN [stng].[VV_TOQ_VendorSubmissionIncludeRemoved] vs
						ON cs.VendorAssignedID = vs.UniqueID
					WHERE vs.SubmissionStatus <> 'Removed'
					GROUP BY cs.TOQMainID, cs.VendorAssignedID
				) v ON t.TOQMainID = v.TOQMainID
				WHERE 
					t.TOQMainID = @Value1
				GROUP BY 
					t.ComparisonEBSRAMLock, 
					t.VendorLowestCostOption, 
					t.VendorBucketOwner;

				-- Data 4
				Select 
					[ReasonForRevision], 
					[AdditionalInfoForRevision], 
					[TOQRevisionAmount], 
					[ScopeDecision], 
					[TrendDecision]  
				FROM [stng].[TOQ_RAM_Revision] where TOQMainID = @Value1

			END
		ELSE IF (@Status = 'AEBSP') SELECT T.VSSCode FROM stng.VV_TOQ_Main T WHERE T.UniqueID = @Value1 

		ELSE IF(@Status = 'ACC')
		BEGIN
			-- add logic to ensure “a TOQ that has a child SVN that is not at Approved and Complete Status cannot have a revision initiated.
			SELECT COUNT(*) HasSVN FROM stng.VV_TOQ_Main_Child A WHERE A.ParentTOQID = @Value1 AND A.TypeValue = 'SVN' AND A.StatusValue not in ('ACC','CANC','NTAPP','SUPER')
		END

		ELSE IF(@Status = 'ADPR')
		BEGIN
			-- add logic so cannot send to EBS Partial review, if there is not a new Partial row (without an approved date)
			SELECT COUNT(*) AS NumDateNotApproved
			FROM stng.TOQ_Partial P
			INNER JOIN stng.TOQ_VendorAssigned V ON V.UniqueID = P.VendorAssignedID
			WHERE V.TOQMainID = @Value1
			AND P.DateApproved IS NULL
		END

    END TRY
	BEGIN CATCH
        INSERT INTO stng.App_ErrorLog([Number],[Procedure],[Line],[Message],SubOp) VALUES (
                     ERROR_NUMBER(),
                     ERROR_PROCEDURE(),
                     ERROR_LINE(),
                     ERROR_MESSAGE(),
					 @SubOp
              );
			  THROW
	END CATCH
	
END
