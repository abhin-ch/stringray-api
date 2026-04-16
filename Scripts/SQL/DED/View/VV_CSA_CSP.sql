CREATE view [stng].[VV_CSA_CSP] as
with allcatids as 
(
	SELECT a.ParentItem, a.Item
	FROM stngetl.CSA_ETLCore as a
	left join stng.CSA_MgmtMain as b on a.Item = b.Item
	where b.ScopeStatus <> 'Descoped'  or b.ScopeStatus is null
	union
	SELECT a.Item as ParentCATID, a.Item as catalog_id
	from stng.CSA_MgmtMain as a
	where a.AddedScope = 1 and a.ScopeStatus = 'In-Scope' 
	union
	SELECT a.RepItem as ParentCATID, a.Item as catalog_id
	from stng.CSA_MgmtMain as a
	where isnull(a.RepItem,'') <> '' and a.ScopeStatus = 'Descoped' 
),
dmscsa as
(
       select distinct a.ParentItem, a.Item as ITEMNUM, b.CSANum, b.CurrentCSARevision as Revision, c.StatusDate
       from  allcatids as a
	   inner join [stng].[VV_CSA_Main] as b on a.ParentItem = b.Item and b.CSAStatus <> 'CA'
       left join [stngetl].[General_LatestIssuedCSA] as c on b.Item = c.AssocItem and b.CurrentCSARevision = c.CSARevision
),
legacycsa as
(
       SELECT distinct a.ParentItem, a.Item as ITEMNUM, b.CSANum, b.CSARevision as Revision, b.StatusDate 
       FROM allcatids as a
       inner join [stngetl].[General_LatestIssuedCSA] as b on a.ParentItem = b.AssocItem
       left join dmscsa as c on b.CSANum = c.CSANum and b.CSARevision = c.Revision 
       where c.CSANum is null
),
tbdcsa as
(
	   SELECT distinct a.ParentItem, a.Item as ITEMNUM, null as CSANum, null as Revision, null as StatusDate 
       FROM allcatids as a
	   left join dmscsa as b on a.Item = b.ITEMNUM
	   left join legacycsa as c on a.Item = c.ITEMNUM
       where b.ITEMNUM is null and c.ITEMNUM is null and (trim(a.Item) is not null and trim(a.Item) <> '')
),
unionquery as
(
       select *, 1 as InDMS, 0 as Legacy
       from dmscsa 
       union
       select *, 0 as InDMS, 1 as Legacy 
       from legacycsa
	   union
	   select *, 0 as InDMS, 0 as Legacy
	   from tbdcsa
),
csurl as
(
	select distinct concat(a.ParentItem,'-', a.itemnum,'-',case when a.Revision is null then 'N/A' else cast(a.Revision as varchar) end) as PK, a.*, 
	case when b.dataid is not null then 'ISSUED' when InDMS = 1 then 'INPROG' else 'To Be Completed' end as Status,
	case when b.dataid is not null then  
	CONCAT(N'https://ecm.corp.brucepower.com/OTCS/cs.exe?func=ll&objAction=open&objID=',b.DATAID) end as CSURL
	from unionquery as a
	left join [stngetl].[General_ControlledDoc] as b on a.CSANum = b.NAME and a.Revision = b.Revision
)

select * 
from csurl
GO