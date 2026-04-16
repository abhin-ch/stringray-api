CREATE OR ALTER VIEW [stng].[VV_Budgeting_SDQ_PendingApprovals] AS 
	WITH LeadPlanners AS (
		-- Calculate the LeadPlanner string only ONCE
		SELECT STRING_AGG(EmployeeID, ';') AS PlannerString
		FROM stng.VV_Budgeting_SpecialPersonnel
		WHERE SpecialPersonnalType = 'LeadPlanner'
	),
	P6Data AS (
		-- Pre-calculate all valid (SDQUID, PersonGroup) pairs from P6 data (Legacy + New)

		-- Legacy path
		SELECT DISTINCT a.SDQUID, e.PersonGroup
		FROM stng.VV_Budgeting_SDQ_P6_Legacy_HourByDisciplines AS a 
		INNER JOIN stng.Budgeting_SDQP6Link AS b ON a.SDQUID = b.SDQUID AND b.Active = 1
		INNER JOIN stngetl.Budgeting_SDQ_Run AS rn ON b.RunID = rn.RunID AND rn.Legacy = 1
		INNER JOIN temp.TT_0154_Section AS ts ON a.SECID = ts.SECID
		INNER JOIN stng.General_Organization AS e ON ts.PersonGroup = e.PersonGroup

		UNION 

		-- New
		SELECT DISTINCT b.SDQUID, e.PersonGroup
		FROM stngetl.Budgeting_SDQ_P6 AS a
		INNER JOIN stng.Budgeting_SDQP6Link AS b ON a.RunID = b.RunID AND b.Active = 1
		INNER JOIN stngetl.Budgeting_SDQ_P6_ActivityResource AS ar ON a.task_id = ar.task_id AND a.RunID = ar.runid
		INNER JOIN stng.General_Organization_P6RoleMapping AS d ON ar.RoleName = d.P6RoleName
		INNER JOIN stng.General_Organization AS e ON d.PersonGroup = e.PersonGroup
	),
	ApprovalCalculation AS (
		-- Calculate the potential approver for each relevant row BEFORE filtering/aggregation
		SELECT
			c.SDQUID,
			a.SDQApprovalID, 
			CASE
				WHEN d.SDQApprovalType = 'Verifier' THEN c.Verifier
				WHEN d.SDQApprovalType = 'LeadPlanner' THEN lp.PlannerString 
				WHEN d.SDQApprovalType = 'SectionManager' AND p6d.SDQUID IS NOT NULL THEN go.Supervisor
				ELSE NULL
			END AS Approver
		FROM stng.Budgeting_SDQ_Approval AS a
		INNER JOIN stng.Budgeting_SDQ_Approval_Mapping AS b ON a.SDQApprovalID = b.SDQApprovalID
		INNER JOIN stng.Budgeting_SDQMain AS c ON b.SDQApprovalSetID = c.SDQApprovalSetID
		INNER JOIN stng.Budgeting_SDQ_Approval_Type AS d ON a.SDQApprovalTypeID = d.SDQApprovalTypeID
		LEFT JOIN stng.General_Organization AS go ON a.PersonGroup = go.PersonGroup
		CROSS JOIN LeadPlanners lp
		LEFT JOIN P6Data p6d ON d.SDQApprovalType = 'SectionManager'AND p6d.SDQUID = c.SDQUID AND p6d.PersonGroup = a.PersonGroup 
		WHERE a.Approved = 0
	)
	-- Final Aggregation
	SELECT
		ac.SDQUID,
		STRING_AGG(ac.Approver, ', ') WITHIN GROUP (ORDER BY ac.Approver) AS Approvers
	FROM ApprovalCalculation ac
	WHERE ac.Approver IS NOT NULL 
	GROUP BY ac.SDQUID;

GO
