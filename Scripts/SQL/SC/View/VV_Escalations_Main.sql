CREATE OR ALTER VIEW [stng].[VV_Escalations_Main]
AS 
SELECT 
	E.ESID,
	E.EscalationID,
	E.ProjectID,
	E.Title,
	E.StatusID,
	V.[Label],
	C.Body as LatestComment,
	E.Type,
	E.CreatedBy,
	M.ProjectName,
	M.CSFLM,
	M.PCS,
	M.BuyerAnalyst,
	M.MaterialBuyer,
	M.ServiceBuyer,
	M.CostAnalyst,
	M.ProgramManager,
	M.ContractAdmin,
	M.BusinessDriver,
	M.OwnersEngineer,
	M.ProjectManager,
	M.Status,
	M.SubPortfolio,
	E.ActionWith,
	E.ActionDue,
	E.Scheduled,
	E.PMCApproval,
	E.SCApproval,
	E.CreatedDate
FROM stng.Escalation E
LEFT JOIN stng.VV_MPL_SC AS M ON M.[ProjectID] = E.ProjectID
LEFT JOIN (
	SELECT C.ParentID, C.Body, ROW_NUMBER() OVER (PARTITION BY C.ParentID ORDER BY C.CreatedDate DESC) AS RN
	FROM stng.Common_Comment AS C
)  AS C ON C.ParentID = E.EscalationID AND C.RN = 1
LEFT JOIN stng.Common_ValueLabel V ON V.[Value] = E.StatusID AND V.Field = 'Status' AND V.[Group] = 'Main'
LEFT JOIN stng.Admin_Module MD ON MD.ModuleID = V.ModuleID AND MD.Name = 'Escalations'
GO