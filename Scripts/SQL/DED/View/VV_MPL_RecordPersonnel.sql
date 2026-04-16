CREATE OR ALTER VIEW [stng].[VV_MPL_RecordPersonnel]
AS 
	SELECT
		-- Fields with priority given to VV_General_MPLPersonnel (G) first if there is match Project, otherwise use MPL_Override (O)
		COALESCE(G.RecordType, O.RecordType) AS RecordType,
		COALESCE(G.RecordUniqueID, O.RecordUniqueID) AS RecordUniqueID,
		COALESCE(G.ActualProjectID, O.Project) AS Project,
		COALESCE(G.DMID, O.DMID) AS DMID,
		COALESCE(G.DM, O.DM) AS DM,
		COALESCE(G.PCSID, O.PCSID) AS PCSID,
		COALESCE(G.PCS, O.PCS) AS PCS,
		COALESCE(G.DMEPID, O.DMEPID) AS DMEPID,
		COALESCE(G.DMEP, O.DMEP) AS DMEP,
		COALESCE(G.SMID, O.SMID) AS SMID,
		COALESCE(G.SM, O.SM) AS SM,
		COALESCE(G.OEID, O.OEID) AS OEID,
		COALESCE(G.OE, O.OE) AS OE,
		COALESCE(G.ProgMID, O.ProgMID) AS ProgMID,
		COALESCE(G.ProgM, O.ProgM) AS ProgM,
		COALESCE(G.ProjMID, O.ProjMID) AS ProjMID,
		COALESCE(G.ProjM, O.ProjM) AS ProjM,
		COALESCE(G.ProjMContractor, O.ProjMContractor) AS ProjMContractor,
		COALESCE(G.PlannerID, O.PlannerID) AS PlannerID,
		COALESCE(G.Planner, O.Planner) AS Planner,
		COALESCE(G.DMESID, O.DMESID) AS DMESID,
		COALESCE(G.DMES, O.DMES) AS DMES,
		COALESCE(G.DivMID, O.DivMID) AS DivMID,
		COALESCE(G.DivM, O.DivM) AS DivM
	FROM 
		-- Data from MPL_Override with all required LEFT JOINs
		(SELECT
			A.RecordType,
			A.RecordUniqueID,
			A.Project,
			B.EmployeeID AS DMID,
			B.EmpName AS DM,
			C.EmployeeID AS PCSID,
			C.EmpName AS PCS,
			D.EmployeeID AS DMEPID,
			D.EmpName AS DMEP,
			E.EmployeeID AS SMID,
			E.EmpName AS SM,
			F.EmployeeID AS OEID,
			F.EmpName AS OE,
			G.EmployeeID AS ProgMID,
			G.EmpName AS ProgM,
			H.EmployeeID AS ProjMID,
			H.EmpName AS ProjM,
			H.Contractor AS ProjMContractor,
			I.EmployeeID AS PlannerID,
			I.EmpName AS Planner,
			J.EmployeeID AS DMESID,
			J.EmpName AS DMES,
			K.EmployeeID AS DivMID,
			K.EmpName AS DivM
		FROM stng.MPL_Override A
		LEFT JOIN stng.VV_Admin_UserView B ON B.EmployeeID = A.DM
		LEFT JOIN stng.VV_Admin_UserView C ON C.EmployeeID = A.PCS
		LEFT JOIN stng.VV_Admin_UserView D ON D.EmployeeID = A.DMEP
		LEFT JOIN stng.VV_Admin_UserView E ON E.EmployeeID = A.SM
		LEFT JOIN stng.VV_Admin_UserView F ON F.EmployeeID = A.OE
		LEFT JOIN stng.VV_Admin_UserView G ON G.EmployeeID = A.ProgM
		LEFT JOIN stng.VV_Admin_UserView H ON H.EmployeeID = A.ProjM
		LEFT JOIN stng.VV_Admin_UserView I ON I.EmployeeID = A.Planner
		LEFT JOIN stng.VV_Admin_UserView J ON J.EmployeeID = A.DMES
		LEFT JOIN stng.VV_Admin_UserView K ON K.EmployeeID = A.DivM
		) O
	LEFT JOIN 
		-- Data from VV_General_MPLPersonnel
		(SELECT 
			ActualProjectID,
			ProjectID,
			PCS,
			PCSID,
			OE,
			OEID,
			Planner,
			PlannerID,
			ProjM,
			ProjMID,
			ProgM,
			ProgMID,
			SupervisorID,
			Supervisor,
			SMID,
			SM,
			DMID,
			DM,
			DivMID,
			DivM,
			NULL AS RecordType,
			NULL AS RecordUniqueID,
			NULL AS ProjMContractor,
			NULL AS DMEPID,
			NULL AS DMEP,
			NULL AS DMESID,
			NULL AS DMES
		FROM stng.VV_General_MPLPersonnel
		) G 
	ON O.Project = G.ActualProjectID;
GO


