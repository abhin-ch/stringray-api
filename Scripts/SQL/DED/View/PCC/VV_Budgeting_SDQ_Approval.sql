CREATE OR ALTER view [stng].[VV_Budgeting_SDQ_Approval] as
WITH initialquery AS
(
    SELECT 
        c.SDQUID, 
        b.SDQApprovalSetID, 
        a.SDQApprovalID, 
        d.SDQApprovalType, 
        a.SDQApprovalTypeID, 
        a.PersonGroup, 
        a.Approved, 
        a.ApprovalDate, 
        c.Verifier, 
        a.Comment,
		a.ApprovedBy,
		u.EmpName ApprovedByC
    FROM stng.Budgeting_SDQ_Approval AS a
    INNER JOIN stng.Budgeting_SDQ_Approval_Mapping AS b ON a.SDQApprovalID = b.SDQApprovalID
    INNER JOIN stng.Budgeting_SDQMain AS c ON b.SDQApprovalSetID = c.SDQApprovalSetID
    INNER JOIN stng.Budgeting_SDQ_Approval_Type AS d ON a.SDQApprovalTypeID = d.SDQApprovalTypeID 
	LEFT JOIN stng.VV_Admin_UserView U ON U.EmployeeID = A.ApprovedBy
),
leadplanners AS
(
    SELECT STRING_AGG(EmployeeID, ';') AS leadplanners
    FROM stng.VV_Budgeting_SpecialPersonnel
    WHERE SpecialPersonnalType = 'LeadPlanner'
),
p6hours AS
(
    SELECT SDQUID, PersonGroup, LabourRemainingUnits
    FROM stngetl.VV_Budgeting_SDQ_P6_Discipline
),
secondquery AS
(
    -- Verifiers
    SELECT 
        a.SDQUID, 
        a.SDQApprovalSetID, 
        a.SDQApprovalID, 
        NULL AS PersonGroup, 
        NULL AS PersonGroupHours, 
        NULL AS PersonGroupC, 
        a.SDQApprovalType, 
        a.SDQApprovalTypeID, 
        a.Approved, 
        a.ApprovalDate, 
        a.Verifier AS Approver, 
		a.ApprovedBy,
		a.ApprovedByC,
        a.Comment
    FROM initialquery AS a
    WHERE a.SDQApprovalType = 'Verifier'
    UNION ALL
    -- Lead Planners
    SELECT 
        a.SDQUID, 
        a.SDQApprovalSetID, 
        a.SDQApprovalID, 
        NULL AS PersonGroup, 
        NULL AS PersonGroupHours, 
        NULL AS PersonGroupC, 
        a.SDQApprovalType, 
        a.SDQApprovalTypeID, 
        a.Approved, 
        a.ApprovalDate, 
        b.leadplanners AS Approver, 
		a.ApprovedBy,
		a.ApprovedByC,
        a.Comment
    FROM initialquery AS a
    CROSS JOIN leadplanners AS b
    WHERE a.SDQApprovalType = 'LeadPlanner'
    UNION ALL
    -- Section Managers
    SELECT 
        x.SDQUID, 
        x.SDQApprovalSetID, 
        x.SDQApprovalID, 
        x.PersonGroup, 
        y.LabourRemainingUnits AS PersonGroupHours, 
        x.PersonGroupC, 
        x.SDQApprovalType, 
        x.SDQApprovalTypeID, 
        x.Approved, 
        x.ApprovalDate, 
        x.Approver,
		x.ApprovedBy,
		x.ApprovedByC,
        x.Comment
    FROM
    (
        SELECT 
            a.SDQUID, 
            a.SDQApprovalSetID, 
            a.SDQApprovalID, 
            a.PersonGroup, 
            b.[Description] AS PersonGroupC, 
            a.SDQApprovalType, 
            a.SDQApprovalTypeID, 
            a.Approved, 
            a.ApprovalDate, 
            b.Supervisor AS Approver, 
			a.ApprovedBy,
			a.ApprovedByC,
            a.Comment
        FROM initialquery AS a
        INNER JOIN stng.General_Organization AS b ON a.PersonGroup = b.PersonGroup
        WHERE a.SDQApprovalType = 'SectionManager'
    ) AS x
    INNER JOIN p6hours AS y 
        ON x.SDQUID = y.SDQUID 
        AND x.PersonGroup = y.PersonGroup
)
SELECT DISTINCT 
    a.*,
    CASE 
        WHEN a.Approved = 1 THEN 'Approved' 
        ELSE 'Pending Approval' 
    END AS ApprovalLabel,
    CONCAT(b.FirstName, ' ', b.LastName) AS ApproverC
FROM secondquery AS a
LEFT JOIN stng.Admin_User AS b ON a.Approver = b.EmployeeID
--OPTION (HASH JOIN); -- Optimize join performance
GO


