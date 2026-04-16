CREATE OR ALTER VIEW [stng].[VV_TOQ_CostSummary]
AS
	SELECT
		C.UniqueID,
		C.VendorAssignedID,
		V.TOQMainID,
		C.DeliverableCode,
		D.EngineeringDeliverable,
		[DeliverableTitle],
		[TotalHour],
		C.TotalCost,
		C.DeliverableStartDate,
		C.DeliverableEndDate,
		C.DateExtension_NewStartDate,
		C.DateExtension_NewEndDate,
		C.DateExtension_NewStartDate_Static,
		C.DateExtension_NewEndDate_Static,
		C.DateExtension_NewCommitmentDate_Static,
		DATEDIFF(DAY, C.DeliverableStartDate, C.DeliverableEndDate) AS [DurationDays],
		[NewTOQCommitmentDate], 
		[CurrentTOQCommitmentDate],
		[PriorTOQCommitmentDate],
		[OriginalTOQCommitmentDate],
		[DeliverableAccount],
		C.[CreatedDate],
		C.[CreatedBy],
		C.[UpdateDate],
		C.[UpdatedBy],
		D.BrucePowerCommitment, 
		CASE 
			WHEN C.PartialOverride IS NOT NULL AND DistributedPartialsOverrided = 1 THEN C.PartialOverride
			ELSE P.DistributedPartial
		END AS DistributedPartial,
		C.PartialOverride,
		V.DistributedPartialsOverrided,
		V.TOQEndDate,
		C.IsFromRevision,
		V.Awarded
	FROM
		[stng].[TOQ_CostSummary] as C
		left join [stng].TOQ_CostSummary_Deliverables as D on C.DeliverableCode = D.DeliverableCode
		left join [stng].TOQ_VendorAssigned as V on C.VendorAssignedID = V.UniqueID
		left join [stng].VV_TOQ_DistributedPartials as P on P.UniqueID = C.UniqueID

GO