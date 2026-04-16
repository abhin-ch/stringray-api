CREATE view [stng].[VV_EQDB_IndexEQEBOM] as
select distinct a.[LOCATION]
      ,a.[FACILITY]
      ,a.[AMLITEM]
      ,a.[AMLITEMVERIFIED]
      ,a.[AMLITEMSTATUS]
      ,a.[AMLITEMQL]
      ,a.[AMLITEMACTIVE]
      ,a.[AMLITEMEQ]
      ,a.[AMLITEMLVL1]
      ,a.[EQEBOM]
      ,a.[AMLINSTALLED]
	  , b.MANUFACTURER
	  , b.MODEL
from stngetl.EQDB_IndexEQEBOM as a
left join stngetl.[General_Item] as b on a.AMLITEM = b.[ITEM]
GO


