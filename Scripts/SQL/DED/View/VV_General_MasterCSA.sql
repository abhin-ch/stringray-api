CREATE VIEW [stng].[VV_General_MasterCSA] AS
WITH allitems AS 
(
	SELECT a.ParentItem, a.item
	FROM stngetl.CSA_ETLCore as a
	LEFT JOIN stng.CSA_MgmtMain as b on a.item = b.Item
	WHERE b.ScopeStatus <> 'Descoped'  or b.ScopeStatus is null
	UNION
	SELECT a.Item as ParentItem, a.Item
	FROM stng.CSA_MgmtMain as a
	WHERE a.AddedScope = 1 and a.ScopeStatus = 'In-Scope' 
	UNION
	SELECT a.RepItem as ParentItem, a.Item
	FROM stng.CSA_MgmtMain as a
	WHERE isnull(a.RepItem,'') <> '' and a.ScopeStatus = 'Descoped' 
),
dmscsa AS
(
       SELECT DISTINCT a.ParentItem, a.item, concat('B-CSA-',a.ParentItem) as CSANum, b.CurrentCSARevision as Revision, c.StatusDate
       FROM  allitems as a
	   INNER JOIN stng.CSA_Main as b on a.ParentItem = b.Item and b.CSAStatus <> 'CA'
       LEFT JOIN stngetl.General_LatestIssuedCSA as c on b.Item = c.AssocItem and b.CurrentCSARevision = c.CSARevision
),
legacycsa AS
(
       SELECT DISTINCT a.ParentItem, a.item, b.CSANum, b.CSARevision as Revision, b.StatusDate 
       FROM allitems as a
       INNER JOIN stngetl.General_LatestIssuedCSA as b on a.ParentItem = b.AssocItem
       LEFT JOIN dmscsa as c on b.CSANum = c.CSANum and b.CSARevision = c.Revision 
       WHERE c.CSANum is null
),
tbdcsa AS
(
	   SELECT DISTINCT a.ParentItem, a.item, null as CSANum, null as Revision, null as StatusDate 
       FROM allitems as a
	   LEFT JOIN dmscsa as b on a.item = b.item
	   LEFT JOIN legacycsa as c on a.item = c.item
       WHERE b.item is null and c.item is null and (trim(a.item) is not null and trim(a.item) <> '')
),
unionquery AS
(
       SELECT *, 1 as InDMS, 0 as Legacy
       FROM dmscsa 
       UNION
       SELECT *, 0 as InDMS, 1 as Legacy 
       FROM legacycsa
	   UNION
	   SELECT *, 0 as InDMS, 0 as Legacy
	   FROM tbdcsa
),
csurl AS
(
	SELECT DISTINCT a.*, 
	case when b.dataid is not null then 'ISSUED' when InDMS = 1 then 'INPROG' else 'To Be Completed' end as Status,
	case when b.dataid is not null then  
	stng.FN_General_CSLink(b.FileType, b.DATAID) end as CSURL
	FROM unionquery as a
	LEFT JOIN stngetl.General_ControlledDoc as b on a.CSANum = b.NAME and a.Revision = b.Revision
)

SELECT * 
FROM csurl


