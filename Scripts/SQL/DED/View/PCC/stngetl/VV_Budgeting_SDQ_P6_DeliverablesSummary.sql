CREATE OR ALTER VIEW [stngetl].[VV_Budgeting_SDQ_P6_DeliverablesSummary] AS
WITH LateStartStatusCheck AS (
    -- Used for late start process to check if OE Revised Commitments (AOERC) have been approved
	SELECT 
    logAfterStatus.RecordTypeUID,
    CASE 
        WHEN MAX(CASE WHEN statusAfterStatus.SDQStatus IN ('AFRE', 'AOEFR') THEN logAfterStatus.CreatedDate END) 
             > MAX(CASE WHEN statusAOERC.SDQStatus = 'AOERC' THEN logAOERC.CreatedDate END) 
        THEN 1 ELSE 0
    END AS OEHasApprovedRevised
	FROM 
		[stng].[Budgeting_Statuslog] logAfterStatus 
		INNER JOIN [stng].[Budgeting_SDQ_Status] statusAfterStatus ON logAfterStatus.StatusID = statusAfterStatus.SDQStatusID 
		INNER JOIN [stng].[Budgeting_Statuslog] logAOERC ON logAfterStatus.RecordTypeUID = logAOERC.RecordTypeUID
		INNER JOIN [stng].[Budgeting_SDQ_Status] statusAOERC ON logAOERC.StatusID = statusAOERC.SDQStatusID
	WHERE 
		statusAfterStatus.SDQStatus IN ('AFRE', 'AOEFR') AND statusAOERC.SDQStatus = 'AOERC'
	GROUP BY 
		logAfterStatus.RecordTypeUID
),
nonlegacy AS (
    SELECT 
        b.SDQUID, 
        a.RunID, 
        a.wbs_name, 
        a.activityid, 
        a.activityname, 
        a.BPDQCommitment, 
        a.G4008BPDeliverableType,
        a.G4009BPResponsibleDiscipline, 
        a.G4017ActivityType, 
        a.InterProjectIntegration,
        CASE 
            WHEN e.Value = 'Not required' THEN NULL 
            WHEN e.Value = 'No Change' AND c.RevisedCommitmentDate IS NULL THEN NULL
            WHEN g.RevisedCommitmentDate IS NOT NULL 
                AND sc.OEHasApprovedRevised = 1 THEN g.RevisedCommitmentDate
            WHEN c.RevisedCommitmentDate IS NULL THEN a.CurrentEnd 
            ELSE c.RevisedCommitmentDate 
        END AS RevisedCommitment,
        a.EndActualized,
        a.BaselineEnd AS PriorCommitment,
        CASE 
            WHEN e.Value IS NOT NULL THEN e.Value
            WHEN a.BaselineEnd IS NULL THEN 'Scope'
            ELSE 'N/A' 
        END AS ScopeTrend,
        CASE 
            WHEN e.UniqueID IS NOT NULL THEN e.UniqueID
            WHEN a.BaselineEnd IS NULL THEN '3AB7D176-6FCD-4E42-92DB-0CFF157427F3'
            ELSE '03DF8DBD-F2B6-412A-8897-3283C44C3F2F'--N/A code
        END AS ScopeOrTrendID,
        g.RevisedCommitmentDate AS LateStartCommitment
    FROM 
    stngetl.Budgeting_SDQ_P6 AS a 
	INNER JOIN stng.Budgeting_SDQP6Link AS b ON a.RunID = b.RunID AND b.Active = 1 
	INNER JOIN stngetl.Budgeting_SDQ_Run AS f ON b.RunID = f.RunID AND f.Legacy = 0
	LEFT JOIN stng.Budgeting_SDQ_P6_DeliverableRevisedCommitment AS c ON a.RunID = c.RunID AND a.activityid = c.activityid
	LEFT JOIN stng.Budgeting_SDQ_ScopeTrend d ON a.RunID = d.RunID AND a.activityid = d.ActivityID LEFT JOIN stng.Budgeting_SDQ_ScopeOrTrendID e ON e.UniqueID = d.ScopeOrTrendID
	LEFT JOIN stng.Budgeting_SDQ_RevisedCommitment AS g ON a.RunID = g.RunID AND a.activityid = g.ActivityID
	LEFT JOIN LateStartStatusCheck sc ON b.SDQUID = sc.RecordTypeUID
    WHERE a.BPDQCommitment IS NOT NULL
),
legacy AS (
    SELECT 
        x.SDQUID, 
        x.RunID, 
        x.wbs_name, 
        x.activityid, 
        x.activityname,
        x.G4017ActivityType, 
        x.BPDQCommitment, 
        x.G4008BPDeliverableType, 
        x.G4009BPResponsibleDiscipline, 
        x.InterProjectIntegration,
        CASE 
            WHEN e.Value = 'Not required' THEN NULL
            WHEN e.Value = 'No Change' AND c.RevisedCommitmentDate IS NULL THEN NULL
            WHEN g.RevisedCommitmentDate IS NOT NULL 
                AND sc.OEHasApprovedRevised = 1 THEN g.RevisedCommitmentDate
            WHEN c.RevisedCommitmentDate IS NULL THEN x.RevisedCommitment 
            ELSE c.RevisedCommitmentDate 
        END AS RevisedCommitment,
        x.EndActualized,
        CASE 
            WHEN e.Value IS NOT NULL THEN e.Value
            WHEN x.ScopeTrend IS NOT NULL THEN x.ScopeTrend
            WHEN x.PriorCommitment IS NULL THEN 'Scope'
            ELSE 'N/A' 
        END AS ScopeTrend,
        CASE 
            WHEN e.UniqueID IS NOT NULL THEN e.UniqueID
            WHEN x.ScopeTrend IS NOT NULL AND EXISTS(
                (SELECT TOP(1) UniqueID 
                 FROM stng.Budgeting_SDQ_ScopeOrTrendID 
                 WHERE [Value] = x.ScopeTrend)
            ) THEN (SELECT TOP(1) UniqueID 
                   FROM stng.Budgeting_SDQ_ScopeOrTrendID 
                   WHERE [Value] = x.ScopeTrend)
            WHEN x.PriorCommitment IS NULL THEN '3AB7D176-6FCD-4E42-92DB-0CFF157427F3'
            ELSE '03DF8DBD-F2B6-412A-8897-3283C44C3F2F'--N/A code 
        END AS ScopeOrTrendID,
        x.PriorCommitment,
        g.RevisedCommitmentDate AS LateStartCommitment
    FROM (
        SELECT 
            a.SDQUID, 
            b.RunID, 
            WBSName AS wbs_name, 
            a.ActivityID AS activityid, 
            a.ActivityName AS activityname,
            a.G4017ActivityType, 
            a.BPDQCommitment, 
            a.G4008BPDeliverableType, 
            a.G4009BPResponsibleDiscipline, 
            a.InterProjectIntegrations AS InterProjectIntegration,
            CASE 
                WHEN a.FinishC = 'Not Req' THEN NULL 
                WHEN a.FinishC = 'No Change' THEN a.BLProjectFinish 
                ELSE TRY_CONVERT(DATETIME, 
                    CASE 
                        WHEN a.Finish LIKE '%A' THEN LEFT(a.Finish, LEN(a.Finish) - 2)   
                        ELSE REPLACE(a.Finish, '*', '') 
                    END
                ) 
            END AS RevisedCommitment,
            CASE WHEN a.Finish LIKE '%A' THEN 1 ELSE 0 END AS EndActualized,
            TRY_CONVERT(DATETIME, a.BLProjectFinish) AS PriorCommitment,
            CASE 
                WHEN a.FinishC = 'Not Req' THEN 'Not required' 
                WHEN a.FinishC = 'No Change' THEN 'No Change' 
                ELSE a.ScopeTrend 
            END AS ScopeTrend
        FROM 
        stng.VV_Budgeting_SDQ_P6_Legacy_DeliverableSummary AS a 
		INNER JOIN stng.Budgeting_SDQP6Link AS b  ON a.SDID = b.SDQUID AND b.Active = 1
        INNER JOIN stngetl.Budgeting_SDQ_Run AS f ON b.RunID = f.RunID AND f.Legacy = 1
    ) AS x
    LEFT JOIN stng.Budgeting_SDQ_P6_DeliverableRevisedCommitment AS c ON x.RunID = c.RunID AND x.activityid = c.activityid
    LEFT JOIN stng.Budgeting_SDQ_ScopeTrend d ON x.RunID = d.RunID AND x.activityid = d.ActivityID
    LEFT JOIN stng.Budgeting_SDQ_ScopeOrTrendID e ON e.UniqueID = d.ScopeOrTrendID
    LEFT JOIN stng.Budgeting_SDQ_RevisedCommitment AS g ON x.RunID = g.RunID AND x.activityid = g.ActivityID
    LEFT JOIN LateStartStatusCheck sc ON x.SDQUID = sc.RecordTypeUID
),
unioned AS (
    SELECT 
        SDQUID, 
        RunID, 
        0 AS Legacy, 
        wbs_name, 
        a.activityid, 
        a.activityname, 
        a.BPDQCommitment, 
        a.G4008BPDeliverableType, 
        a.G4009BPResponsibleDiscipline, 
        a.G4017ActivityType, 
        a.InterProjectIntegration, 
        a.RevisedCommitment, 
        a.EndActualized, 
        a.PriorCommitment, 
        a.ScopeTrend, 
        a.ScopeOrTrendID, 
        a.LateStartCommitment
    FROM 
        nonlegacy AS a

    UNION

    SELECT 
        SDQUID, 
        RunID, 
        1 AS Legacy, 
        wbs_name, 
        a.activityid, 
        a.activityname, 
        a.BPDQCommitment, 
        a.G4008BPDeliverableType, 
        a.G4009BPResponsibleDiscipline, 
        a.G4017ActivityType, 
        a.InterProjectIntegration, 
        a.RevisedCommitment, 
        a.EndActualized, 
        a.PriorCommitment, 
        a.ScopeTrend, 
        a.ScopeOrTrendID, 
        a.LateStartCommitment
    FROM 
        legacy AS a
)
SELECT *
FROM unioned
GO


