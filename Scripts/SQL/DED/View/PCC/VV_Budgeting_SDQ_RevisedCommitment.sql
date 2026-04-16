CREATE OR ALTER view [stng].[VV_Budgeting_SDQ_RevisedCommitment] as
	select 
		c.SDQUID, 
		a.RunID, 
		a.activityid, 
		-- use coalesce to grab data regarding whether it's a legacy or not
		COALESCE(b.wbs_name, leg.WBSName) as wbs_name, 
		COALESCE(b.activityname, leg.ActivityName) as activityname, 
		COALESCE(b.BPDQCommitment, leg.BPDQCommitment) as BPDQCommitment, 
		a.PriorCommitment,
		a.MaximumRevisedCommitmentDate, 
		a.RevisedCommitmentDate as RevisedCommitment
	from stng.Budgeting_SDQ_RevisedCommitment as a
	inner join stng.Budgeting_SDQP6Link as c on a.RunID = c.RunID and c.Active = 1
	left join stngetl.Budgeting_SDQ_P6 as b on a.RunID = b.RunID and a.ActivityID = b.activityid
	left join stng.VV_Budgeting_SDQ_P6_Legacy_DeliverableSummary as leg on c.SDQUID = leg.SDID and a.ActivityID = leg.ActivityID
	inner join stngetl.Budgeting_SDQ_Run as r on a.RunID = r.RunID
GO