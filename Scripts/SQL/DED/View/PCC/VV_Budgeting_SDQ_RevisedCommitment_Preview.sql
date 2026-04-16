CREATE OR ALTER view [stng].[VV_Budgeting_SDQ_RevisedCommitment_Preview] as
	WITH LatestDates AS (
	  SELECT 
	   c.SDQUID,
	   -- Calculate the latest date between AnticipatedProgMApprovalDate and PMAnticipatedApprovalDate
	   CASE 
		WHEN c.AnticipatedProgMApprovalDate IS NOT NULL AND c.AnticipatedProgMApprovalDate > c.PMAnticipatedApprovalDate 
		THEN c.AnticipatedProgMApprovalDate 
		ELSE c.PMAnticipatedApprovalDate 
	   END AS LatestApprovalDate
	  FROM 
	   stng.Budgeting_SDQMain AS c
	)
	SELECT 
	  a.SDQUID, 
	  a.RunID, 
	  a.activityid, 
	  a.activityname, 
	  a.BPDQCommitment, 
	  a.RevisedCommitment AS PriorCommitment,
	  ld.LatestApprovalDate as PMAnticipatedApprovalDate,
	  -- Use the latest date in the DateDelta calculation
	  stng.FN_General_WorkDateDelta(ld.LatestApprovalDate, NULL) AS DateDelta,
	  -- Check ScopeTrend and return NULL if 'Not Required', otherwise calculate MaximumRevisedCommitmentDate
	  CASE
		WHEN a.ScopeTrend = 'Not Required' THEN NULL
		ELSE stng.FN_General_NextWorkDate(
		  a.RevisedCommitment,
		  stng.FN_General_WorkDateDelta(ld.LatestApprovalDate, NULL)
		)
	  END AS MaximumRevisedCommitmentDate,
	  a.ScopeTrend
	FROM stngetl.VV_Budgeting_SDQ_P6_DeliverablesSummary AS a
	INNER JOIN stng.Budgeting_SDQMain AS c ON a.SDQUID = c.SDQUID
	INNER JOIN LatestDates AS ld ON c.SDQUID = ld.SDQUID
	WHERE a.EndActualized = 0
GO