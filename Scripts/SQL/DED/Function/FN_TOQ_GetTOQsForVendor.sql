CREATE OR ALTER FUNCTION [stng].[FN_TOQ_GetTOQsForVendor]
(
   @EmployeeID NVARCHAR(10)
)
RETURNS TABLE
AS
RETURN
(
   -- CTE #1: Gets a list of vendors associated with the employee.
   WITH UserVendors AS (
       SELECT Attribute
       FROM stng.VV_Admin_UserAttribute
       WHERE EmployeeID = @EmployeeID AND AttributeType = 'Vendor'
   ),
   -- CTE #2: Counts the number of vendors assigned to each TOQ.
   VendorCounts AS (
       SELECT TOQMainID, COUNT(*) AS VendorTotal
       FROM stng.TOQ_VendorAssigned
       WHERE DeleteRecord = 0
       GROUP BY TOQMainID
   ),
    -- CTE #3: Joins the main TOQ data with the pre-calculated vendor counts.
   MainWithCounts AS (
       SELECT  M.UniqueID, M.TMID, M.BPTOQID, M.Rev, M.InternalID, M.ParentUniqueID,
        M.RequestFrom, M.RequestFromName, M.Project, M.ProjectTitle,
        M.Status, M.StatusID, M.StatusValue, M.StatusDate, M.CreatedDate, M.CreatedBy,
        M.UpdatedDate, M.DeleteRecord, M.DeleteBy, M.DeleteDate,
        M.Title, M.TDSNo, M.Comment, M.TDSRev, M.PPSD, M.ContractType,
        M.Resource, M.ScopeOfWork, M.PartialEmergent, M.TypeID, M.TypeValue, M.Type,
        M.VendorAwardID, M.VendorSubmissionDate, M.VendorClarificationDate,
        M.VendorWorkTypeID, M.WorkTypeID, M.VendorStartDate, M.WorkType,
        M.VendorWorkType, M.VendorWorkTypeDesc, M.VendorSubWorkTypeID,
        M.AwardedVendor, M.AwardedVendorTOQNumber, M.AwardedTotalCost,
        M.DateAwarded, M.AwardedStartDate, M.AwardedEndDate, M.AllVendors,
        M.PartialRelease, M.TotalRelease, M.ClassVUniqueID, M.ScopeManagedBy, M.Phase, M.Customer,
        M.PCSID, M.PCS, M.OEID, M.OE, M.SMID, M.SM, M.DMEPID, M.DMEP, M.DivMID, M.DivM,
        M.VSSCode, M.EmergentRelease, M.SD, M.TD, M.VCO, M.VCE, M.VSDR, M.VST,
        M.DateSentToVendor,
        VC.VendorTotal

       FROM stng.VV_TOQ_Main_Parent M
       LEFT JOIN VendorCounts VC ON M.UniqueID = VC.TOQMainID
	   -- Don't show Emergent rows to vendor if has not been approved by DM
	   -- where (
	   -- 	M.TypeValue != 'EMERG'
	   --	OR (M.TypeValue = 'EMERG' AND M.StatusValue NOT IN ('INIT', 'ADMA', 'REDDMEP'))
	   --)
   )
   SELECT
       -- Base columns from the TOQ record
       M.[UniqueID]
      ,M.[TMID]
      ,M.[BPTOQID]
      ,M.[Rev]
      ,M.[RequestFrom]
      ,M.[RequestFromName]
      ,NULL as [EBSBin]
      ,M.[PartialEmergent]
      ,M.[StatusID]
      ,M.[StatusDate]
      ,M.[ClassVUniqueID]
      ,M.[Title]
      ,M.[TDSNo]
      ,M.[Comment]
      ,M.[Project]
      ,M.[InternalID]
      ,M.[VendorSubmissionDate]
      ,M.[VendorClarificationDate]
      ,NULL as [EBSRoutingOption]
      ,M.[DeleteRecord]
      ,M.[DeleteBy]
      ,M.[DeleteDate]
      ,M.[CreatedDate]
      ,M.[CreatedBy]
      ,NULL as [ERPUpdated]
      ,M.[PPSD]
      ,M.[ContractType]
      ,M.[Resource]
      ,M.[ScopeOfWork]
      ,M.[TDSRev]
      ,M.[ParentUniqueID]
      ,M.[TypeID]
      ,M.[ScopeManagedBy]
      ,M.[Phase]
      ,M.[Customer]
      ,Null as [UpdatedBy]
      ,M.[UpdatedDate]
      ,M.[VendorAwardID]
      ,M.[VendorWorkTypeID]
      ,M.[WorkTypeID]
      ,M.[VendorStartDate]
      ,M.[Status]
      ,M.[StatusValue]
      ,M.[WorkType]
      ,M.[VendorWorkType]
      ,M.[VendorWorkTypeDesc]
      ,M.[Type]
      ,M.[TypeValue]
      ,M.[PCSID]
      ,M.[PCS]
      ,M.[OEID]
      ,M.[OE]
      ,M.[SMID]
      ,M.[SM]
      ,M.[DMEPID]
      ,M.[DMEP]
      ,M.[DivM]
      ,M.[DivMID]
      ,M.[VendorSubWorkTypeID]
      ,M.[AwardedVendor]
      ,M.[AwardedVendorTOQNumber]
      ,NULL as [VSS]
      ,M.[VSSCode]
      ,M.[EmergentRelease]
      ,NULL as [TOQEstimate]
      ,M.[AwardedTotalCost]
      ,NULL as [LinkedSDQ]
      ,NULL as [SDQStatus]
      ,NULL as [JustificationForNaLinkedSDQ]
      ,NULL as [ERPUpdatedC]
      ,M.[SD]
      ,M.[TD]
      ,M.[VCO]
      ,M.[VCE]
      ,M.[VSDR]
      ,M.[VST]
      ,M.[ProjectTitle]
      ,NULL as [SeekingRAMApproval]
      ,NULL as [RAMSubmissionDate]
      ,NULL as [CVEstimate]
      ,NULL as [AllVendors]
      ,NULL as [AllVendorTOQNumber]
      ,NULL as [AwardedContractNumber]
      ,NULL as [AwardedOrderNumber]
      ,M.[DateSentToVendor],
        -- Show award details only if the user's vendor was awarded the TOQ.
       CASE WHEN UV_Awarded.Attribute IS NOT NULL THEN M.DateAwarded ELSE NULL END AS DateAwarded,
       CASE WHEN UV_Awarded.Attribute IS NOT NULL THEN M.AwardedStartDate ELSE NULL END AS AwardedStartDate,
       CASE WHEN UV_Awarded.Attribute IS NOT NULL THEN M.AwardedEndDate ELSE NULL END AS AwardedEndDate,
       CASE WHEN UV_Awarded.Attribute IS NOT NULL THEN M.PartialRelease ELSE NULL END AS PartialRelease,
       CASE WHEN UV_Awarded.Attribute IS NOT NULL THEN M.TotalRelease ELSE NULL END AS TotalRelease,
        -- Get pending actions from the JOIN, replacing a correlated subquery.
       CASE
           WHEN UV_Awarded.Attribute IS NOT NULL OR M.VendorTotal = 1 THEN CA.PendingChildActions
           ELSE NULL
       END AS PendingChildActions,
       CASE
           WHEN UV_Awarded.Attribute IS NOT NULL OR M.VendorTotal = 1 THEN CA.PendingChildActionsIDs
           ELSE NULL
       END AS PendingChildActionsIDs,
        -- Derive Vendor status using data from JOINs and static business rules.
       COALESCE(    
           CASE
               -- Priority check: If Status is "Cancelled"
               WHEN M.StatusValue = 'CANC' THEN 'TOQ Cancelled'
               -- Priority check: If SubmissionStatus is "Submitted Editable" for non-special types, return that
               WHEN M.TypeValue NOT IN ('SVN', 'REWORK', 'EMERG') AND VS.SubmissionStatus = 'Submitted Editable' THEN 'Submitted Editable'
               -- Standard vendor submission status cases
               WHEN M.StatusValue = 'AVS' THEN VS.SubmissionStatus
               WHEN M.StatusValue IN ('ALAMS', 'HSDQ', 'ASDQF') THEN 'BP Processing'
               WHEN M.StatusValue IN ('INIT', 'AEIA', 'ASMIA') THEN 'BP Processing - Initiating'
               WHEN M.StatusValue IN ('AOEVA', 'ALAMS', 'ADPR', 'ICORR', 'CORR') THEN 'BP Processing with OE'
               WHEN M.StatusValue IN ('ASAA', 'AVSA', 'ASMA') THEN 'BP Processing with SM'
               WHEN M.StatusValue IN ('AEBSP','ACOR','AESAA','AEFP','ASVPA','APCOR','ACANC', 'AEAP','CANCO', 'CANCS', 'AVPA') THEN 'BP Processing with EBS'
               WHEN M.StatusValue = 'ADIVA' THEN 'BP Processing with DivM'
               WHEN M.StatusValue IN ('ADMA', 'ADVMA', 'ADMSA') THEN 'BP Processing with DM EP'
               WHEN M.StatusValue IN ('ACC', 'ARIP', 'VDU', 'ODU', 'CLOSE', 'SUPER') AND M.AwardedVendor IS NOT NULL AND UV_Awarded.Attribute IS NULL THEN 'Not Awarded'
               WHEN M.StatusValue = 'ODU' THEN 'Date Update - BP Processing'
               WHEN M.StatusValue = 'VDU' THEN 'Vendor Date Update'
               WHEN M.StatusValue IN ('ACC', 'ARIP') AND M.AwardedVendor IS NOT NULL AND UV_Awarded.Attribute IS NOT NULL THEN 'Awarded'
               WHEN M.StatusValue = 'CLOSE' AND M.AwardedVendor IS NOT NULL AND UV_Awarded.Attribute IS NOT NULL THEN 'TOQ Closed'
               WHEN M.StatusValue = 'NOT' THEN 'TOQ Not Approved'
               WHEN M.StatusValue = 'SUPER' AND M.AwardedVendor IS NOT NULL AND UV_Awarded.Attribute IS NOT NULL THEN 'TOQ Revised'
               WHEN M.StatusValue = 'AVENA' THEN 'Awaiting Vendor Approval'
               WHEN M.StatusValue = 'REP' THEN 'Replaced'
			   WHEN M.TypeValue = 'EMERG' THEN M.Status
               ELSE 'No Status Available - Contact Admin'
           END,
		   StatusLabel.Label
       ) AS VendorStatus,
        -- Get vendor-specific TOQ number based on type.
       CASE
           WHEN M.TypeValue = 'EMERG' THEN ED.VendorTOQNumber
           ELSE V_TOQ.VendorTOQNumber -- Value comes from the OUTER APPLY below.
       END AS VendorTOQNumber
   FROM MainWithCounts AS M
    -- Join to get related data, avoiding correlated subqueries in the SELECT list.
   LEFT JOIN stng.VV_TOQ_ChildActionsPending AS CA ON CA.ParentTOQID = M.UniqueID
   LEFT JOIN stng.TOQ_EmergentDetail AS ED ON ED.UniqueID = M.UniqueID
   LEFT JOIN stng.VV_TOQ_VendorSubmission AS VS ON VS.TOQMainID = M.UniqueID
      AND EXISTS (SELECT 1 FROM UserVendors UV_Sub WHERE VS.Vendor = UV_Sub.Attribute)
   LEFT JOIN stng.Common_ValueLabel AS StatusLabel
       ON StatusLabel.Value = M.StatusValue
       AND StatusLabel.Field = 'Status'
       AND StatusLabel.[Group] = M.TypeValue
    -- Creates a flag to efficiently check if the TOQ was awarded to the user's vendor.
   LEFT JOIN UserVendors AS UV_Awarded ON M.AwardedVendor = UV_Awarded.Attribute
    -- Use APPLY to get the user's TOQ number without duplicating rows from a standard join.
   OUTER APPLY (
       SELECT TOP 1 V.TOQNumber AS VendorTOQNumber
       FROM stng.TOQ_VendorAssigned V
       JOIN stng.Common_ValueLabel CVL ON V.VendorID = CVL.UniqueID
       JOIN UserVendors UV ON CVL.Label = UV.Attribute
       WHERE V.TOQMainID = M.UniqueID
         AND CVL.Field = 'Vendor'
         AND CVL.Active = 1
   ) AS V_TOQ
   WHERE
        -- Primary filter to find TOQs related to the user's vendors using the original string split method.
       EXISTS (
           SELECT 1
           FROM STRING_SPLIT(M.AllVendors, ',') v
           WHERE TRIM(v.value) IN (SELECT Attribute FROM UserVendors)
       )
       -- Business visibility rules based on status and total vendor count.
       AND (
           (COALESCE(M.VendorTotal, 0) <= 1 AND M.StatusValue <> 'NTAPP') OR
           (COALESCE(M.VendorTotal, 0) > 1 AND M.StatusValue NOT IN ('INIT', 'ASMIA', 'AEIA', 'NTAPP'))
       )
	   -- Don't show Emergent rows to vendor if has not been approved by DM
	   --AND (
	   --	M.TypeValue != 'EMERG'
	   --	OR (M.TypeValue = 'EMERG' AND M.StatusValue NOT IN ('INIT', 'ADMA', 'REDDMEP'))
	   --)
);