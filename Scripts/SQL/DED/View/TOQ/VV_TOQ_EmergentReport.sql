CREATE OR ALTER VIEW [stng].[VV_TOQ_EmergentReport] 
AS
SELECT ROW_NUMBER() OVER(ORDER BY a.BPTOQID ASC) as id
	  ,a.TMID
      ,a.[BPTOQID]
      ,i.FullName as RequestFrom
	  ,CASE WHEN d.ParentTOQID is null THEN 'Standalone' ELSE 'Child Emergent' END as EmergentType
	  ,e.BPTOQID as ParentTOQID
	  ,e.TMID as ParentTMID
	  ,e.Rev
	  ,m.Label as Vendor
	  ,c.Label as [Status]
	  ,j.Label as ParentStatus
      ,a.[StatusDate]
      ,e.StatusDate as ParentStatusDate
	  ,CASE WHEN e.StatusDate is not null THEN DATEDIFF(day,e.StatusDate,stng.GetDate()) ELSE null END  DaySinceParentStatus
      ,k.CreatedDate as AcceptedDate
	  ,CASE WHEN k.CreatedDate is not null THEN DATEDIFF(day,k.CreatedDate,stng.GetDate()) ELSE null END  DaySinceAccepted
	  ,CASE WHEN k.CreatedDate is not null and ParentTOQID is null THEN DATEDIFF(day,k.CreatedDate,stng.GetDate()) ELSE null END  OutstandingDays
	  ,f.Project
	  ,f.Title
	  ,f.RequestAmount
	  ,g.Value as FundingSource
	  ,h.FullName as SectionManager
	  ,f.VendorTOQNumber
	  ,f.ContractNumber
	  ,f.ScopeOfWork
     
  FROM [stng].[TOQ_Main] as a
  LEFT JOIN stng.Common_ValueLabel as b on b.UniqueID = a.TypeID
  LEFT JOIN stng.Common_ValueLabel as c on c.UniqueID = a.StatusID
  LEFT JOIN stng.TOQ_Child as d on d.ChildTOQID = a.UniqueID
  LEFT JOIN stng.TOQ_Main as e on e.UniqueID = d.ParentTOQID
  LEFT JOIN stng.VV_TOQ_EmergentDetail as f on f.UniqueID = a.UniqueID
  LEFT JOIN stng.Common_ValueLabel as g on g.UniqueID = f.FundingSource
  LEFT JOIN stng.Admin_User as  h on h.EmployeeID = f.SectionManager 
  LEFT JOIN stng.Admin_User as  i on i.EmployeeID = a.RequestFrom
  LEFT JOIN stng.Common_ValueLabel as j on j.UniqueID = e.StatusID
    LEFT JOIN (
	SELECT * FROM (
	SELECT TOQMainID,CreatedDate,
	ROW_NUMBER() OVER (PARTITION BY TOQMainID ORDER BY CreatedDate DESC) as rn
	FROM (
	SELECT TOQMainID,b.Value,a.CreatedDate FROM stng.TOQ_StatusLog as a
	LEFT JOIN stng.Common_ValueLabel as b on b.UniqueID = a.TOQStatusID
	WHERE b.[Value] = 'ACC') as a
	) as a WHERE a.rn = 1) as k on k.TOQMainID = a.UniqueID 
  LEFT JOIN stng.TOQ_VendorAssigned as l on l.TOQMainID = a.UniqueID and l.DeleteRecord = 0
  LEFT JOIN stng.Common_ValueLabel as m on m.UniqueID = l.VendorID
  WHERE b.Value = 'EMERG'
GO