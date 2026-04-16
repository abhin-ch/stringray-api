CREATE view [stng].[VV_EQDB_IndexPredefined] as
select distinct a.[LOCATION]
      ,a.[FACILITY]
      ,a.[AMLITEM]
      ,a.[EQPM]
      ,a.[EQJP]
      ,a.[EQJPITEM]
      ,a.[eqebom]
      ,a.[JPAML]
      ,a.[Level]
      ,a.[TopItem]
      ,a.[OnAMLVerifiedBOM]
	  , b.STATUS
	  , cast(case when b.EQ is null then 0 else b.EQ end as bit) as EQ
from stngetl.EQDB_IndexPredefined as a
left join stngetl.[General_Item] as b on a.EQJPITEM = b.[ITEM]
GO


