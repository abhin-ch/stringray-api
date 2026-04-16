CREATE OR ALTER     VIEW [stng].[VV_TOQ_Main] AS 
	WITH CTE_TOQStatusLog AS (
		SELECT TOQMainID, CreatedDate
		FROM (
			SELECT TOQMainID, CreatedDate,
				ROW_NUMBER() OVER (PARTITION BY TOQMainID ORDER BY CreatedDate DESC) AS rn
			FROM stng.TOQ_StatusLog A
			INNER JOIN stng.VV_TOQ_Status S ON S.StatusID = A.TOQStatusID
			WHERE S.Value = 'INIT'
		) t
		WHERE rn = 1
	),
	CTE_CorrespondenceAwaitingAnswer AS (
		SELECT 
			C.TOQMainID,
			SUM(CASE WHEN C3.[Label] IN ('Techical', 'Date Extension') THEN 1 ELSE 0 END) AS VCO,
			SUM(CASE WHEN C3.[Label] = 'Business' THEN 1 ELSE 0 END) AS VCE
		FROM stng.TOQ_Correspondence C
		INNER JOIN stng.Common_ValueLabel C3 ON C3.UniqueID = C.TypeID
		INNER JOIN stng.TOQ_Main T ON T.UniqueID = C.TOQMainID
		INNER JOIN stng.VV_TOQ_Status S ON S.StatusID = T.StatusID
		LEFT JOIN stng.TOQ_Correspondence C2 ON C2.ParentUID = C.UniqueID AND C2.TOQMainID = C.TOQMainID
		WHERE C.QuestionAnswer = 'Q' AND C2.UniqueID IS NULL AND S.Value NOT IN ('ACC', 'SUPER', 'ARIP', 'CANC', 'CLOSE', 'CANCO', 'CANCS')
		GROUP BY C.TOQMainID
	),
	CTE_AllVendorAssigned AS (
		SELECT 
			TOQMainID,
			STRING_AGG(v.Label, ', ') WITHIN GROUP (ORDER BY T.TOQNumber) AS AllVendors,
			STRING_AGG(T.TOQNumber, ', ') WITHIN GROUP (ORDER BY T.TOQNumber) AS AllVendorTOQNumber
		FROM stng.TOQ_VendorAssigned T
		LEFT JOIN stng.Common_ValueLabel v ON v.UniqueID = T.VendorID  
		WHERE T.DeleteRecord = 0 AND T.TOQMainID IS NOT NULL
		GROUP BY T.TOQMainID
	),
	CTE_PartialAmount AS (
		SELECT 
			VA.TOQMainID, 
			SUM(CASE WHEN P.DateApproved IS NOT NULL 
				THEN COALESCE(P.PartialRequestAmount, 0) 
				ELSE 0 
			END) AS TotalApprovedPartialAmount,
			SUM(COALESCE(P.PartialRequestAmount, 0)) AS TotalPartialAmount
		FROM stng.TOQ_VendorAssigned VA
		LEFT JOIN stng.TOQ_Partial P ON P.VendorAssignedID = VA.UniqueID 
		WHERE VA.Awarded = 1
		GROUP BY VA.TOQMainID
	),
	CTE_EBSBin AS (
		SELECT 
			tm.UniqueID,
			STRING_AGG(tbt.Bin, ', ') AS EBSBin
		FROM stng.TOQ_Main tm
		LEFT JOIN stng.TOQ_Binning tb ON tb.TOQMainID = tm.UniqueID AND tb.Deleted = 0
		JOIN stng.TOQ_BinningType tbt ON tbt.UniqueID = tb.BinningTypeID
		GROUP BY tm.UniqueID
	),
	CTE_PrevRevTotal AS (
		SELECT 
			T2.UniqueID,
			CASE 
				WHEN T2.Rev = 0 THEN NULL
				ELSE T_prev_value.PrevValue
			END AS PrevRevTotalRelease
		FROM stng.TOQ_Main T2
		LEFT JOIN (
			SELECT 
				T_prev.BPTOQID,
				T_prev.Rev,
				CASE 
				WHEN T_prev.PartialEmergent = 'P' THEN PR_prev.TotalApprovedPartialAmount
				ELSE VSS_prev.CostSummary
				END AS PrevValue
			FROM stng.TOQ_Main T_prev
			LEFT JOIN stng.VV_TOQ_VendorSubmission VSS_prev ON VSS_prev.TOQMainID = T_prev.UniqueID AND VSS_prev.Awarded = 1
			LEFT JOIN CTE_PartialAmount PR_prev ON PR_prev.TOQMainID = T_prev.UniqueID
			WHERE T_prev.DeleteRecord = 0
		) T_prev_value ON T_prev_value.BPTOQID = T2.BPTOQID AND T_prev_value.Rev = T2.Rev - 1
	)
	SELECT 
		T.[UniqueID],
		T.[TMID],
		T.BPTOQID,
		T.[Rev],
		T.[RequestFrom],
		U.EmpName AS RequestFromName,
		EB.EBSBin,
		T.[PartialEmergent],
		T.[StatusID],
		T.[StatusDate],
		T.[ClassVUniqueID],
		T.[Title],
		T.[TDSNo],
		T.[Comment],
		T.[Project],
		T.[InternalID],
		T.[VendorSubmissionDate],
		T.[VendorClarificationDate],
		T.[EBSRoutingOption],
		T.[DeleteRecord],
		T.[DeleteBy],
		T.[DeleteDate],
		T.[CreatedDate],
		T.[CreatedBy],
		T.[ERPUpdated],
		T.[PPSD],
		T.[ContractType],
		T.[Resource],
		T.[ScopeOfWork],
		T.[TDSRev],
		T.[ParentUniqueID],
		T.[TypeID],
		T.[ScopeManagedBy],
		T.[Phase],
		T.[Customer],
		T.[EmergentID],
		UP.EmpName UpdatedBy,
		T.UpdatedDate,
		VSS.UniqueID AS VendorAwardID,
		T.[VendorWorkTypeID],
		T.[WorkTypeID],
		T.[VendorStartDate],
		S.Label AS Status,
		S.Value AS StatusValue,
		W.Label AS WorkType,
		WT.Value AS VendorWorkType,
		WT.Label As VendorWorkTypeDesc,
		TT.Label AS Type,
		TT.Value AS TypeValue,
		M.PCSID,
		M.PCS,
		M.OEID,
		M.OE,  
		M.SMID,
		M.SM,
		M.DMEPID,
		M.DMEP,
		M.DivM,
		M.DivMID,
		T.VendorSubWorkTypeID,
		VSS.Vendor AS AwardedVendor,
		CASE 
			WHEN ED.VendorTOQNumber IS NOT NULL THEN ED.VendorTOQNumber 
			ELSE VSS.TOQNumber
		END AS AwardedVendorTOQNumber,
		CONCAT(VS.VSSCode, ' ', VS.TotalVendorsSubmitted, ' / ', VS.TotalVendors) AS VSS,
		VS.VSSCode,
		VSS.TOQStartDate AS AwardedStartDate,
		VSS.TOQEndDate AS AwardedEndDate,
		NULLIF(COALESCE(EChildACC.EmergentRelease, 0)+ COALESCE(EParent.RequestAmount, 0),0) AS EmergentRelease,
		CASE 
			WHEN VSS.Vendor <> '' THEN 
				COALESCE(VSS.CostSummary, 0)
			ELSE NULL 
		END AS TOQEstimate,
		CASE 
			WHEN T.PartialEmergent = 'P' AND VSS.Vendor <> '' THEN PR.TotalApprovedPartialAmount
			WHEN VSS.Vendor <> '' THEN VSS.CostSummary
			ELSE NULL 
		END AS AwardedTotalCost,
		CASE 
			WHEN T.PartialEmergent = 'P' AND VSS.Vendor <> '' AND S.Value IN ('ACC', 'SUPER', 'ADPR', 'VDU', 'ODU', 'ARIP') THEN
				COALESCE(PR.TotalApprovedPartialAmount, 0)
			WHEN VSS.Vendor <> '' AND S.Value IN ('ACC', 'SUPER', 'ADPR', 'VDU', 'ODU', 'ARIP') THEN
				COALESCE(VSS.CostSummary, 0) 
			WHEN (COALESCE(EChildACC.EmergentRelease, 0) + COALESCE(EParent.RequestAmount, 0)) > 0 THEN
				COALESCE(EChildACC.EmergentRelease, 0) + COALESCE(EParent.RequestAmount, 0) + COALESCE(PRT.PrevRevTotalRelease, 0)
			ELSE COALESCE(PRT.PrevRevTotalRelease, NULL) 
		END AS TotalRelease,
		CASE 
			WHEN VSS.Vendor <> '' THEN 
				PR.TotalPartialAmount
			ELSE NULL 
		END AS PartialRelease,
		T.LinkedSDQ, 
		SDQ.Status as SDQStatus,
		T.JustificationForNaLinkedSDQ,
		T.[ERPUpdated] AS ERPUpdatedC,
		CASE 
			WHEN S.Value IN ('CANC', 'SUPER') THEN NULL 
			ELSE DATEDIFF(DAY, T.StatusDate, GETDATE()) 
		END AS SD,
		CASE 
			WHEN S.Value IN ('CANC', 'SUPER', 'ACC') THEN NULL 
			ELSE DATEDIFF(DAY, TSL.CreatedDate, GETDATE()) 
		END AS TD,
		C.VCO,
		C.VCE,
		CASE 
			WHEN T.VendorSubmissionDate IS NOT NULL AND S.Value = 'AVS' 
			THEN DATEDIFF(DAY, GETDATE(), T.VendorSubmissionDate) 
			ELSE NULL 
		END AS VSDR,
		CASE 
			WHEN T.VendorSubmissionDate IS NOT NULL AND S.Value = 'AVS' 
			THEN 'T' + CAST(SIGN(DATEDIFF(DAY, GETDATE(), T.VendorSubmissionDate)) AS CHAR(1)) + CAST(ABS(DATEDIFF(WEEK, GETDATE(), T.VendorSubmissionDate)) AS VARCHAR(10))
			ELSE NULL 
		END AS VST,
		CASE 
			WHEN MPL.ProjectName IS NOT NULL THEN MPL.ProjectName
			ELSE T.Title 
		END AS ProjectTitle,
		CASE 
			WHEN RAM.PDESubmitToRAM = 1 THEN 'PDE'
			WHEN RAM.ComparisonSubmitToRAM = 1 THEN 'Comparison'
			ELSE NULL
		END AS SeekingRAMApproval,
		CASE 
			WHEN RAM.PDESubmitToRAM = 1 THEN RAM.EBSDateRAMSubmit
			WHEN RAM.ComparisonSubmitToRAM = 1 THEN RAM.ComparisonDateRAMSubmit
			ELSE NULL
		END AS RAMSubmissionDate,
		T.ClassVTotalAmount as CVEstimate,
		AVA.AllVendors,
		AVA.AllVendorTOQNumber,
		VSS.ContractNumber AS AwardedContractNumber,
		VSS.OrderNumber AS AwardedOrderNumber,
		(SELECT TOP 1 CAST(CreatedDate AS DATE) FROM stng.TOQ_StatusLog AS SL 
			INNER JOIN stng.VV_TOQ_Status S ON S.StatusID = SL.TOQStatusID
			WHERE SL.TOQMainID = T.UniqueID AND S.Value = 'AVS' ORDER BY CreatedDate DESC) AS DateSentToVendor,
        (SELECT TOP 1 CAST(CreatedDate AS DATE) FROM stng.TOQ_StatusLog AS SL 
			INNER JOIN stng.VV_TOQ_Status S ON S.StatusID = SL.TOQStatusID
			WHERE SL.TOQMainID = T.UniqueID AND S.Value = 'ACC' ORDER BY CreatedDate DESC) AS DateAwarded
	FROM stng.TOQ_Main T
	INNER JOIN stng.VV_TOQ_Status S ON S.StatusID = T.StatusID
	LEFT JOIN stng.VV_TOQ_Common W ON W.UniqueID = T.WorkTypeID AND W.[Group] = 'Header' AND W.[Field] = 'WorkType'
	LEFT JOIN stng.Common_ValueLabel WT ON WT.UniqueID = T.VendorWorkTypeID
	LEFT JOIN stng.VV_TOQ_Common TT ON TT.UniqueID = T.TypeID
	LEFT JOIN stng.VV_MPL_RecordPersonnel M ON M.RecordUniqueID = T.UniqueID AND M.RecordType = 'TOQ'
	LEFT JOIN stng.VV_MPL_ENG MPL ON MPL.SharedProjectID = T.Project  
	LEFT JOIN stng.VV_TOQ_VendorSubmissionAgg VS ON VS.TMID = T.TMID
	LEFT JOIN stng.VV_Admin_UserView U ON U.EmployeeID = T.RequestFrom
	LEFT JOIN stng.VV_Admin_UserView UP ON UP.EmployeeID = T.UpdatedBy
	LEFT JOIN stng.VV_TOQ_VendorSubmission VSS ON VSS.TOQMainID = T.UniqueID AND VSS.Awarded = 1
	LEFT JOIN (
		SELECT ParentTOQID, SUM(RequestAmount) AS EmergentRelease 
		FROM stng.VV_TOQ_EmergentACC 
		WHERE ParentTOQID IS NOT NULL 
		GROUP BY ParentTOQID
	) EChildACC ON EChildACC.ParentTOQID = T.UniqueID
	LEFT JOIN stng.VV_TOQ_EmergentParent EParent ON EParent.UniqueID = T.UniqueID
	LEFT JOIN stng.TOQ_EmergentDetail ED ON ED.UniqueID = T.UniqueID 
	LEFT JOIN CTE_PartialAmount PR ON PR.TOQMainID = T.UniqueID
	LEFT JOIN CTE_TOQStatusLog TSL ON TSL.TOQMainID = T.UniqueID
	LEFT JOIN CTE_CorrespondenceAwaitingAnswer C ON C.TOQMainID = T.UniqueID
	LEFT JOIN CTE_AllVendorAssigned AVA ON AVA.TOQMainID = T.UniqueID
	LEFT JOIN (
		SELECT DISTINCT
		A.SDQUID RecordTypeUniqueID
		,H.SDQStatusLong [Status]
		FROM stng.Budgeting_SDQMain AS A
		LEFT JOIN stng.Budgeting_SDQ_Status AS H on A.StatusID = H.SDQStatusID
		where a.DeleteRecord = 0
	) SDQ ON T.LinkedSDQ = SDQ.RecordTypeUniqueID
	LEFT JOIN CTE_EBSBin EB ON EB.UniqueID = T.UniqueID
	LEFT JOIN stng.TOQ_RAM_AllFields RAM ON RAM.TOQMainID = T.UniqueID
	LEFT JOIN CTE_PrevRevTotal PRT ON PRT.UniqueID = T.UniqueID
	WHERE T.DeleteRecord = 0;
GO
