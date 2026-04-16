CREATE view [stng].[VV_General_BOMHierarchy] as
with printcodem as
(
	select *
	from stngetl.General_ItemSpec
	where CRITERION = 'PRINT CODE M' and trim(CRITERIONVALUE) is not null
)

select distinct a.PARENTITEM, a.TOPITEM, a.ITEMNUM, a.ITEMLEVEL, a.ITEMPATH, c.[STATUS], c.ITEMDESC as Description, b.CRITICAL_CODE,
b.STOCK, cast(c.PROCUREMENTCLASS as int) as q_level,
a.QUANTITY, a.REF,
case when b.AUTO_REORDER_IND is null then 0 else b.AUTO_REORDER_IND end as ROP, 
case when b.TARGET_MAXIMUM is null then 0 else b.TARGET_MAXIMUM end as TMAX, 
case when b.SAFETY_STOCK is null then 0 else b.SAFETY_STOCK end as safetystock, 
case when b.AVG_UNIT_PRICE is null then 0 else b.AVG_UNIT_PRICE end as AUP,
case when d.itemnum is not null then 'Y' else 'N' end as HasPrintCodeM
from stngetl.General_ItemHierarchy as a
left join stngetl.General_CatalogMain as b on a.ITEMNUM = b.ITEM
left join stngetl.General_Item as c on a.ITEMNUM = c.ITEM 
left join printcodem as d on a.ITEMNUM = d.ITEMNUM


