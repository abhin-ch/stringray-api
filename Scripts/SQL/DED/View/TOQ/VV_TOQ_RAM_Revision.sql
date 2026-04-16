  CREATE OR ALTER VIEW stng.VV_TOQ_RAM_Revision
  AS
  	SELECT 
	  R.TOQMainID
	  ,'TOQ Revision' RAMReason
	  ,R.ReasonForRevision 
	  ,R.AdditionalInfoForRevision
	  ,R.ScopeDecision
	  ,R.TrendDecision
	  ,R.TOQRevisionAmount
	  ,T.ProjectTitle
	  ,T.SM
	  ,T.AwardedVendor
	  ,U.FirstName + ' ' + U.LastName as UpdatedBy
      ,R.UpdatedDate
	  ,COALESCE(V.CostSummary, 0) AS TOQCumulativeTotal
	FROM stng.TOQ_RAM_Revision R
	INNER JOIN stng.VV_TOQ_Main T ON T.UniqueID = R.TOQMainID
	INNER JOIN stng.VV_TOQ_VendorSubmission V ON V.TOQMainID = R.TOQMainID
	LEFT JOIN stng.Admin_User U ON U.EmployeeID = R.UpdatedBy