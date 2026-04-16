CREATE OR ALTER VIEW [stng].[VV_Budgeting_PBRFMain] AS 
with lateststatuses AS
(
	SELECT PBRFUID, max(CreatedDate) AS CurrentPBRStatusDate
	FROM stng.VV_Budgeting_PBRFStatusLog
	GROUP BY PBRFUID
),
smapproval as
(
	select a.RecordTypeUID as PBRUID, max(a.CreatedDate) as maxStatusDate
	from stng.Budgeting_StatusLog as a
	inner join stng.Budgeting_PBRF_Status as b on a.StatusID = b.PBRFStatusID
	where [Type] ='PBRF' and b.PBRFStatus = 'ADMA'
	group by a.RecordTypeUID
),
dmapproval as
(
	select a.RecordTypeUID as PBRUID, max(a.CreatedDate) as maxStatusDate
	from stng.Budgeting_StatusLog as a
	inner join stng.Budgeting_PBRF_Status as b on a.StatusID = b.PBRFStatusID
	where [Type] ='PBRF' and b.PBRFStatus = 'AEBSP'
	group by a.RecordTypeUID
),
divmapproval as
(
	select a.RecordTypeUID as PBRUID, max(a.CreatedDate) as maxStatusDate
	from stng.Budgeting_StatusLog as a
	inner join stng.Budgeting_PBRF_Status as b on a.StatusID = b.PBRFStatusID
	where [Type] ='PBRF' and b.PBRFStatus = 'AAEBS'
	group by a.RecordTypeUID
),
requestdates AS
(
	SELECT DISTINCT x.PBRFUID, Y.CreatedDate AS RequestDate, Y.CreatedBy AS RequestFrom
	FROM
	(
		SELECT N.UniqueID maxUniqueID, N.PBRFUID FROM (
			SELECT UniqueID, PBRFUID, CreatedDate,            
			ROW_NUMBER() OVER (PARTITION BY PBRFUID ORDER BY CreatedDate DESC) AS RN     
		FROM stng.VV_Budgeting_PBRFStatusLog ) N
		WHERE RN = 1
	) AS x
	INNER JOIN stng.VV_Budgeting_PBRFStatusLog AS Y on x.PBRFUID = Y.PBRFUID and x.maxUniqueID = Y.UniqueID
	LEFT JOIN stng.VV_Admin_UserView AS Z on Y.CreatedBy = Z.EmployeeID
),
personnel AS
(
	SELECT distinct Description, Section, Department, Division, Supervisor, SM, SMName, DM, DMName, DivM, DivMName,Type
	FROM [stng].[VV_General_OrganizationView]
	where Type in ('Section','Division', 'Department')
)
SELECT distinct 'PBRF' AS [Type]
,CONCAT('PBRF','-',A.PBRUID) AS UniqueID
,A.PBRUID AS RecordTypeUniqueID
,A.ParentPBRUID
,CASE WHEN A.ProjectNo = 'TBD' THEN A.ProjectNo  when A.ProjectNo like 'Eng-%' then A.ProjectNo ELSE CONCAT('ENG-',A.ProjectNo) END ProjectNo
,CONCAT(A.PBRID, '-', A.Revision) AS RecordID
,A.Revision
,A.ProjectTitle
,A.StatusID
,H.PBRFStatusLong AS [Status]
,H.PBRFStatus StatusValue
,B.CurrentPBRStatusDate
,concat(c.FirstName, ' ', c.LastName) RequestFrom
,A.RAD RequestDate
,A.RAB RequestFromID
,D.Label AS RC
,A.RC AS RCID
,A.ProblemStatement
,A.Objective
,E.Label CustomerNeed
,A.CustomerNeedDate
,A.CustomerNeed AS CustomerNeedID
,G.Label FundingSource
,A.FundingSource AS FundingSourceID
,A.ProjectType as ProjectTypeID
,pt.ProjectTypeLong as ProjectType
, CASE  when F.Type = 'Division' then F.Division 
   WHEN F.Type = 'Department' THEN F.Department ELSE F.Section END Section
, CASE when F.Type = 'Division' then F.DivM 
WHEN F.Type = 'Department' THEN coalesce(F.dm, ov.DMID) else  coalesce(F.SM, ov.SMID) end as SMID
,CASE WHEN F.Type = 'Division' THEN F.DivMName
WHEN F.Type = 'Department' THEN coalesce(F.DMName, ov.DM) else  coalesce(F.SMName, ov.SM) end as SM
,CASE when F.Type = 'Division' then F.DivM else coalesce(F.dm, ov.DMID) end as DMID
,CASE WHEN F.Type = 'Division' THEN F.DivMName else coalesce(F.DMName, ov.DM) end as DM
,coalesce(F.DivM, ov.DivMID) as DivMID
,coalesce(F.DivMName, ov.DivM) as DivM
,A.Scope
,A.InformationReferences
,A.Station
,YR1.[Year] Year1
,YR1.Internal Internal1
,YR1.[External] External1
,YR2.[Year] Year2
,YR2.Internal Internal2
,YR2.[External] External2
,coalesce(YR1.Internal,0) + coalesce(YR1.[External],0) + coalesce(YR2.Internal,0) + coalesce(YR2.[External],0) as Total
,sm.maxStatusDate as SMApprovalDate
,dm.maxStatusDate as DMApprovalDate
,divm.maxStatusDate as DivMApprovalDate
FROM stng.Budgeting_PBRMain AS A
INNER JOIN lateststatuses AS B on A.PBRUID = B.PBRFUID
--LEFT JOIN requestdates AS C on A.PBRUID = C.PBRFUID
LEFT join stng.VV_Admin_UserView as C on A.RAB = C.EmployeeID
LEFT JOIN stng.Common_ValueLabel AS D on A.RC = D.UniqueID
LEFT JOIN stng.Common_ValueLabel AS E on A.CustomerNeed = E.UniqueID


LEFT JOIN personnel AS F on A.Section = CASE  WHEN F.Type ='Division' THEN F.Division  WHEN F.Type ='Department' THEN F.Department ELSE F.Section END
LEFT JOIN stng.VV_MPL_ENG AS Ca on Replace(A.ProjectNo,'ENG-','') = Ca.sharedProjectID
LEFT JOIN stng.VV_General_OrganizationView AS Da on Ca.DISCIPLINE = Da.MPLDiscipline

LEFT JOIN stng.Common_ValueLabel AS G on A.FundingSource = G.UniqueID
LEFT JOIN stng.Budgeting_PBRF_Status AS H on H.PBRFStatusID = A.StatusID
LEFT JOIN stng.Budgeting_PBRFCostEstimate YR1 ON YR1.PBRFUID = A.PBRUID AND YR1.Year1 = 1
LEFT JOIN stng.Budgeting_PBRFCostEstimate YR2 ON YR2.PBRFUID = A.PBRUID AND YR2.Year2 = 1
LEFT join stng.VV_Budgeting_ProjectType as pt on A.ProjectType = pt.ProjectTypeID
LEFT join smapproval as sm on a.PBRUID = sm.PBRUID
LEFT join dmapproval as dm on a.PBRUID = dm.PBRUID
LEFT join divmapproval as divm on a.PBRUID = divm.PBRUID
LEFT join stng.VV_MPL_Override as ov on A.PBRUID = ov.RecordUniqueID and ov.RecordType = 'PBRF'