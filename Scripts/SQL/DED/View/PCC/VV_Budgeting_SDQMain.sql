CREATE OR ALTER VIEW [stng].[VV_Budgeting_SDQMain] AS 
WITH lateststatuses AS
(
    SELECT SDQUID, max(CreatedDate) AS CurrentSDQStatusDate
    FROM stng.VV_Budgeting_SDQStatusLog
    GROUP BY SDQUID
),
dptepsupervisor AS
(
    SELECT top 1 A.DM AS DPTEPDM, A.DMName AS DPTEPDMName
    FROM stng.VV_General_OrganizationView AS A
    WHERE A.PersonGroup = 'DPTEP'
),
dmapproval as
(
    SELECT [SDQUID], max(CreatedDate) as maxStatusDate
    FROM stng.VV_Budgeting_SDQStatusLog
    WHERE [Status] = 'Awaiting Customer (PM) Approval'
    group by [SDQUID]
),
approved as
(
    SELECT S.[SDQUID], max(S.CreatedDate) as maxStatusDate,A.ProjectNo
    FROM stng.VV_Budgeting_SDQStatusLog S
	INNER JOIN stng.Budgeting_SDQMain A ON A.SDQUID = S.SDQUID
	WHERE [Status] IN ('Approved, Partial Release','Approved, Full Release')
    group by S.[SDQUID],A.ProjectNo
),
revisionRanks AS (
    SELECT 
        A.SDQUID,
        A.ProjectNo,
        J.Phase,
        A.Revision,
        ROW_NUMBER() OVER(PARTITION BY A.ProjectNo ORDER BY J.Phase DESC, A.Revision DESC) as RankDesc,
        ROW_NUMBER() OVER(PARTITION BY A.ProjectNo ORDER BY J.Phase ASC, A.Revision ASC) as RankAsc
    FROM stng.Budgeting_SDQMain AS A
    INNER JOIN stng.Budgeting_SDQ_Phase J on J.SDQPhaseID = A.Phase
    WHERE A.DeleteRecord = 0
),
initialquery as
(
    SELECT DISTINCT 'SDQ' AS [Type]
        ,concat('SDQ','-',A.SDQUID) UniqueID
        ,A.SDQUID RecordTypeUniqueID
        ,A.SDQID as RecordID
        ,concat(J.Phase,'.', A.Revision) as Revision
        ,A.Revision as SubRevision
        ,CASE WHEN RR.RankDesc = 1 THEN 1 ELSE 0 END as LatestRevision
        ,CASE WHEN RR.RankAsc = 1 THEN 1 ELSE 0 END as FirstRevision
        ,A.Phase PhaseID
        ,J.Phase
        ,J.PhaseDesc as PhaseDescription
        ,A.ProjectNo
        ,C.PROJECTNAME ProjectTitle
        ,C.[STATUS] AS ProjectStatus
        ,A.TargetDMApprovalDate
        ,A.PMAnticipatedApprovalDate
		,A.AnticipatedProgMApprovalDate
        ,A.TargetExecutionWindow
        ,A.StatusID
        ,H.SDQStatusLong [Status]
        ,H.SDQStatus StatusValue
        ,B.CurrentSDQStatusDate CurrentStatusDate
        ,A.RAD RequestDate
        ,F.EmpName RequestFROM
        ,A.RAB RequestFROMID
        ,coalesce(I.PCSID, K.PCSID) as PCSID
        ,coalesce(I.PCS, K.PCS) as PCS
        ,coalesce(I.OEID, K.OEID) as OEID
        ,coalesce(I.OE, K.OE) as OE
        ,coalesce(I.PlannerID, K.PlannerID) as PlannerID
        ,coalesce(I.Planner, K.Planner) as Planner
        ,coalesce(I.ProjMID, K.ProjMID) as ProjMID
        ,coalesce(I.ProjM, K.ProjM) as ProjM
        ,coalesce(I.ProgMID, K.ProgMID) as ProgMID
        ,coalesce(I.ProgM, K.ProgM) as ProgM
        ,0 as ProjMContractor --Fix 
        ,D.Section
        ,coalesce(D.SM, K.SMID) as SMID
        ,coalesce(D.SMName, K.SM) as SM
        ,coalesce(D.DM, K.DMID) as DMID
        ,coalesce(D.DMName, K.DM) as DM
        ,coalesce(D.DivM, K.DivMID) as DivMID
        ,coalesce(D.DivMName, K.DivM) as DivM
        ,A.FundingSource FundingSourceID
        ,G.[Label] as FundingSource
        ,A.ProblemStatement, A.ProblemStatementLong
        ,A.CurrentScopeDefinition, A.CurrentScopeDefinitionLong
        ,A.Risk, A.RiskLong
        ,A.Assumption, A.AssumptionLong
        ,C.BusinessDriver
		,CONCAT(C.ProjectTypeShort, ' - ',C.ProjectType) ProjectType
        ,C.Discipline PrimaryDiscipline
        ,A.Complexity ComplexityID
        ,Q.Label Complexity
        ,PreviouslyApproved
        ,RequestedScope
        ,VarianceComment
        ,A.RAB CreatedBy
        ,A.Verifier VerifierID
        ,L.EmpName Verifier
        ,A.SDQApprovalSetID
        ,R.Approvers as PendingApprovers
        ,A.Legacy
        ,A.LAMP3
        ,case when v.RunID is not null then 1 else 0 end as HasP6
        ,CASE WHEN lamp4.LAMP4 = 1 THEN 'Y' ELSE NULL END LAMP4
        ,CASE WHEN a.LAMP4Baseline = 1 THEN 'Y' ELSE NULL END LAMP4Baseline
        ,dmapproval.maxStatusDate as DMApprovalDate
        ,NoTOQFunding
        ,RevisionHeader
		,CASE when APP.ProjectNo IS NOT NULL then 1 else 0 end as HasApprovedSDQ
    FROM stng.Budgeting_SDQMain AS A
    LEFT JOIN lateststatuses AS B on A.SDQUID = B.SDQUID
    LEFT JOIN stng.VV_MPL_ENG AS C on A.ProjectNo = C.ProjectID
    LEFT JOIN stng.VV_General_OrganizationView AS D on C.DISCIPLINE = D.MPLDiscipline
    LEFT JOIN stng.VV_Admin_UserView AS F on A.RAB = F.EmployeeID
    LEFT JOIN stng.Budgeting_SDQ_Status AS H on A.StatusID = H.SDQStatusID
    LEFT JOIN stng.VV_General_MPLPersonnel I on A.ProjectNo = I.ActualProjectID
    LEFT JOIN stng.VV_MPL_Override K on A.SDQUID = K.RecordUniqueID and K.RecordType = 'SDQ'
    LEFT JOIN stng.Budgeting_SDQ_Phase J on J.SDQPhaseID = A.Phase
    LEFT JOIN stng.VV_Admin_UserView AS L on L.EmployeeID = A.Verifier
    LEFT JOIN stng.VV_Budgeting_SDQCommon Q ON Q.UniqueID = A.Complexity
    LEFT JOIN stng.VV_Budgeting_SDQ_PendingApprovals as R on R.SDQUID = A.SDQUID
    LEFT JOIN revisionRanks as RR on A.SDQUID = RR.SDQUID
    LEFT JOIN stng.Budgeting_SDQP6Link as v on A.SDQUID = v.SDQUID and v.Active = 1
    LEFT JOIN stng.Common_ValueLabel AS G on A.FundingSource = G.UniqueID
    LEFT JOIN stng.VV_Budgeting_SDQ_LAMP4 as lamp4 on A.SDQUID = lamp4.SDQUID
    LEFT JOIN dmapproval on A.SDQUID = dmapproval.SDQUID
	LEFT JOIN approved APP ON APP.ProjectNo = A.ProjectNo
    WHERE a.DeleteRecord = 0
)

-- Final query with join to allSMs after main processing is complete
SELECT a.*, 
    b.DPTEPDM as DMEPID, 
    b.DPTEPDMName as DMEP
FROM initialquery as a
CROSS JOIN dptepsupervisor AS b

GO