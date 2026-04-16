CREATE OR ALTER FUNCTION [stng].[FN_Budgeting_SDQ_P6_Validation]
(	
	@RunID uniqueidentifier,
	@SDQUID bigint
)
RETURNS @ReturnTbl table
(
	RunID uniqueidentifier,
	ActivityID varchar(50),
	WBSCode varchar(50), 
	Error varchar(250),
	General bit
)
AS
BEGIN

	--Inactive Project Status
	insert into @ReturnTbl
	(RunID, ActivityID, WBSCode, Error, General)
	select distinct RunID, activityid, wbs_code, 'WBS Needs to be at Inactive Project Status', 0
	from stngetl.Budgeting_SDQ_P6
	where RunID = @RunID
	and
	CV = 1 and wbs_status <> 'Inactive' and activityid is not null;

	--In Development Code
	insert into @ReturnTbl
	(RunID, ActivityID, WBSCode, Error, General)
	select distinct RunID, activityid, wbs_code, 'Activity needs G4004-In-Development code', 0
	from stngetl.Budgeting_SDQ_P6
	where RunID = @RunID
	and
	CV = 0 and wbs_status = 'Inactive' and activityid is not null;

	--Successor Tasks
	insert into @ReturnTbl
	(RunID, ActivityID, WBSCode, Error, General)
	select distinct RunID, activityid, wbs_code, 'Incomplete VDR.TOQ activity needs Successor', 0
	from stngetl.Budgeting_SDQ_P6
	where RunID = @RunID
	and
	G4008BPDeliverableType = 'VDR.TOQ' and EndActualized = 0 and HasSuccessor = 0 and activityid is not null;

	--Next Phase DQ
	--if not exists
	--(
	--	select RunID, activityid
	--	from stngetl.Budgeting_SDQ_P6
	--	where RunID = @RunID
	--	and G4008BPDeliverableType like '%DQ%' and EndActualized = 0
	--) and exists
	--(
	--	select *
	--	from stng.Budgeting_SDQMain as a
	--	inner join stng.Budgeting_SDQ_Phase as b on a.Phase = b.SDQPhaseID
	--	where SDQUID = @SDQUID and b.Phase < 4
	--)
	--	begin

	--		insert into @ReturnTbl
	--		(RunID, ActivityID, WBSCode, Error, General)
	--		values
	--		(@RunID, null, null, 'Next Phase DQ Missing', 1);

	--	end

	--Activity Type code
	insert into @ReturnTbl
	(RunID, ActivityID, WBSCode, Error, General)
	select RunID, activityid, wbs_code, 'Activity requires G4017-Activity-Type code', 0
	from
	(
		select distinct b.RunID, b.activityid, b.wbs_code, a.Baseline, a.RemainingCost, a.SunkCost
		from stngetl.Budgeting_SDQ_P6_ActivityResource_Materialized as a 
		inner join stngetl.Budgeting_SDQ_P6 as b on a.RunID = b.RunID and a.TASK_ID = b.task_id
		where a.RunID = @RunID and b.G4017ActivityType is null and a.Baseline = 0 and (a.RemainingCost <> 0 or a.SunkCost <> 0) 
	) as x;

	--RespOrg code
	with relevantact as
	(
		select distinct b.RunID, b.activityid, b.wbs_code
		from stngetl.Budgeting_SDQ_P6_ActivityResource_Materialized as a 
		inner join stngetl.Budgeting_SDQ_P6 as b on a.RunID = b.RunID and a.TASK_ID = b.task_id
		where a.RunID = @RunID and b.RespOrg is null and a.Baseline = 0 and (a.RemainingCost <> 0 or a.SunkCost <> 0) 
	)

	insert into @ReturnTbl
	(RunID, ActivityID, WBSCode, Error, General)
	select RunID, activityid, wbs_code, 'Activity requires Responsible Organization code', 0
	from relevantact;

	--Deliverable Type code
	insert into @ReturnTbl
	(RunID, ActivityID, WBSCode, Error, General)
	select RunID, activityid, wbs_code, 'Commitment requires G4008-BP-Deliverable-Type code', 0
	from stngetl.Budgeting_SDQ_P6
	where RunID = @RunID
	and BPDQCommitment is not null and EndActualized = 0 and G4008BPDeliverableType is null and activityid is not null;

	--Responsible Discipline code
	insert into @ReturnTbl
	(RunID, ActivityID, WBSCode, Error, General)
	select distinct RunID, activityid, wbs_code, 'Commitment requires G4009-BP-Responsible-Discipline code', 0
	from stngetl.Budgeting_SDQ_P6
	where RunID = @RunID
	and BPDQCommitment is not null and EndActualized = 0 and G4009BPResponsibleDiscipline is null and activityid is not null;

	--Multiple Vendor code 
	with relevantact as
	(
		select distinct b.RunID, b.activityid, b.wbs_code
		from stngetl.Budgeting_SDQ_P6_ActivityResource_Materialized as a 
		inner join stngetl.Budgeting_SDQ_P6 as b on a.RunID = b.RunID
		where a.RunID = @RunID and b.RespOrg like '%PMPC%' and b.MultipleVendor is null and a.Baseline = 0 and (a.RemainingCost <> 0 or a.SunkCost <> 0) 
	)

	insert into @ReturnTbl
	(RunID, ActivityID, WBSCode, Error, General)
	select RunID, activityid, wbs_code, 'Activity requires Multiple-Vendor code', 0
	from relevantact;

	--Unit Code
	insert into @ReturnTbl
	(RunID, ActivityID, WBSCode, Error, General)
	select distinct RunID, null, wbs_code, 'Deliverable requires a Unit code', 0
	from stngetl.Budgeting_SDQ_P6
	where RunID = @RunID
	and wbs_lvl = 6 and Unit is null;

	--Deliverable Type code
	insert into @ReturnTbl
	(RunID, ActivityID, WBSCode, Error, General)
	select distinct RunID, null, wbs_code, 'Deliverable requires a Deliverable Type code', 0
	from stngetl.Budgeting_SDQ_P6
	where RunID = @RunID
	and wbs_lvl = 6 and DeliverableType is null;

	--Unit Specific
	insert into @ReturnTbl
	(RunID, ActivityID, WBSCode, Error, General)
	select distinct a.RunID, null, a.wbs_code, 'Deliverable must be Unit specific', 0
	from stngetl.Budgeting_SDQ_P6 as a
	CROSS APPLY (SELECT * FROM stng.FN_Budgeting_SDQ_StandardDeliverable(@SDQUID) f WHERE a.DeliverableType = f.DeliverableID AND f.Direct = 1) as b
	where a.RunID = @RunID
	and PhaseCode in (4,5,6) and (Unit = 'N/A' or Unit like '%,%');

	--Deliverable Type does not exist
	insert into @ReturnTbl
	(RunID, ActivityID, WBSCode, Error, General)
	select distinct a.RunID, null, a.wbs_code, 'Deliverable Type does not exist', 0
	from stngetl.Budgeting_SDQ_P6 as a
	CROSS APPLY (SELECT * FROM stng.FN_Budgeting_SDQ_StandardDeliverable(@SDQUID) f WHERE a.DeliverableType = f.DeliverableID) as b
	where a.RunID = @RunID and wbs_lvl = 6 and a.DeliverableType is not null and b.DeliverableID is null;

	--DQ Commitment
	with relevantwbs as
	(
		select distinct wbslvl6
		from stngetl.Budgeting_SDQ_P6
		where RunID = @RunID and wbs_lvl >= 6 and DeliverableType in (4, 10, 12, 13, 14, 15, 19, 62) and EndActualized = 0
		AND activityid IS NOT NULL
	),
	relevantwbsdq as
	(
		select distinct wbslvl6
		from stngetl.Budgeting_SDQ_P6
		where RunID = @RunID  and wbs_lvl >= 6 and (BPDQCommitment = 'DQ' OR BPDQCommitment = 'DQ-PPA')
		AND activityid IS NOT NULL		
	)

	insert into @ReturnTbl
	(RunID, ActivityID, WBSCode, Error, General)
	select distinct @RunID, null, a.wbslvl6, 'Deliverable needs a DQ commitment', 0
	from relevantwbs as a
	left join relevantwbsdq as b on a.wbslvl6 = b.wbslvl6
	where b.wbslvl6 is null;

	--NDQ Commitment
	with relevantwbs as
	(
		select distinct wbslvl6
		from stngetl.Budgeting_SDQ_P6
		where RunID = @RunID and wbs_lvl >= 6 
		and DeliverableType in (71, 72, 73, 1, 7, 9, 11, 17, 18, 20, 21, 40, 44, 48, 50, 53, 56, 61, 79) and EndActualized = 0
		AND activityid IS NOT NULL
	),
	relevantwbsdq as
	(
		select distinct wbslvl6
		from stngetl.Budgeting_SDQ_P6
		where RunID = @RunID and wbs_lvl >= 6 and  (BPDQCommitment = 'NDQ' OR BPDQCommitment = 'NDQ-PPA')
		AND activityid IS NOT NULL
	)
	insert into @ReturnTbl
	(RunID, ActivityID, WBSCode, Error, General)
	select distinct @RunID, null, a.wbslvl6, 'Deliverable needs a NDQ commitment', 0
	from relevantwbs as a
	left join relevantwbsdq as b on a.wbslvl6 = b.wbslvl6
	where b.wbslvl6 is null;

	return;

END
