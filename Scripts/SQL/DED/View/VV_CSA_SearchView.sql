CREATE view [stng].[VV_CSA_SearchView] as
SELECT a.ParentItem, a.Item, a.LOCATION,  a.MANUFACTURER_CODE,  a.MODEL_NUMBER,  a.CSANum,  a.CSARev,  a.csaissued, 
 a.USI,  a.CRIT_CAT,  a.SPV,  a.STRATEGY_OWNER,  a.RSE,  a.RDE,  a.ept,  a.ITEMDESC,  a.Identifier, a.Identifier as CSAMessage
  --,a.totcriticalends,  a.mincritcat,  a.maxspv
FROM stngetl.CSA_ETLCore as a
left join stng.CSA_MgmtMain as b on a.Item = b.Item
where b.ScopeStatus <> 'Descoped'  or b.ScopeStatus is null 
or b.TemporaryOverride is null or b.TemporaryOverride = 1
union
SELECT a.Item as ParentCATID, a.Item as catalog_id, 
b.LOCATION, d.MANUFACTURER as MANUFACTURER_CODE, d.MODEL as MODEL_NUMBER, c.CSANum, c.CSARevision as CSARev, 
case when c.CSANum is not null then 'Y' else 'N' end as csaissued, b.USI, b.CRIT_CAT, b.SPV, 
b.STRATEGY_OWNER, b.RSE, b.RDE, b.ept, d.ITEMDESC, 
'Manually Added Scope' as Identifier, 'Manually Added Scope' as CSAMessage
--,case when d.totcriticalends is null then 0 else d.totcriticalends end as totcriticalends, d.mincritcat, d.maxspv
from stng.CSA_MgmtMain as a
left join stng.VV_IQT_MEL as b on a.Item = b.Item
left join stngetl.General_LatestIssuedCSA as c on a.Item = c.AssocItem
left join stngetl.General_Item as d on a.Item = d.ITEM
where a.AddedScope = 1 and a.ScopeStatus = 'In-Scope' 
union
SELECT a.RepItem as ParentCATID, a.Item as catalog_id, 
b.LOCATION, d.MANUFACTURER as MANUFACTURER_CODE, d.MODEL as MODEL_NUMBER, c.CSANum, c.CSARevision as CSARev, 
case when c.CSANum is not null then 'Y' else 'N' end as csaissued, b.USI, b.CRIT_CAT, b.SPV, 
b.STRATEGY_OWNER, b.RSE, b.RDE, b.ept, d.ITEMDESC, 
'Parent' as Identifier, 'CATIDs replaced by below Parent' as CSAMessage
--,case when d.totcriticalends is null then 0 else d.totcriticalends end as totcriticalends, d.mincritcat, d.maxspv
from stng.CSA_MgmtMain as a
left join stng.VV_IQT_MEL as b on a.RepItem = b.Item
left join stngetl.General_LatestIssuedCSA as c on a.RepItem = c.AssocItem
left join stngetl.General_Item as d on a.RepItem = d.ITEM
where isnull(a.RepItem,'') <> '' and a.ScopeStatus = 'Descoped' 
and a.TemporaryOverride = 0
GO


