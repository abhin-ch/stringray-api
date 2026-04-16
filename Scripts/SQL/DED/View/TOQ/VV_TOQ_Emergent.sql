CREATE OR ALTER VIEW [stng].[VV_TOQ_Emergent]
AS
	SELECT DISTINCT
		T.*
		,S.Label Status
		,S.Value StatusValue
		,WT.Value VendorWorkType
		,'Emergent' Type
		,'EMERG' TypeValue
		,COALESCE(M.SM,D.SMName) SM
		,COALESCE(M.SMID,D.SM) SMID
		--,M.DivM DivMID
		--,d.DivMName DivM
		,L.EmergentParentID
		,L.TOQ_MainID
	FROM stng.TOQ_Emergent T
	LEFT JOIN stng.VV_TOQ_Status S ON S.StatusID = T.StatusID
	LEFT JOIN stng.Common_ValueLabel WT ON WT.UniqueID = T.VendorWorkTypeID-- AND W.ModuleID = M.UniqueID AND W.[Group] = 'Header' AND W.[Field] = 'WorkType'
	LEFT JOIN stng.TOQ_EmergentLink L ON L.TOQ_EmergentID = T.UniqueID 
	LEFT JOIN stng.VV_MPL_ENG AS C on T.Project = C.SharedProjectID
	LEFT JOIN stng.VV_General_OrganizationView AS D on C.DISCIPLINE = D.MPLDiscipline
	LEFT JOIN stng.VV_General_MPLPersonnel I on T.Project = I.ProjectID
	LEFT JOIN stng.VV_MPL_RecordPersonnel M ON M.RecordUniqueID = T.UniqueID AND M.RecordType = 'TOQEmergent'