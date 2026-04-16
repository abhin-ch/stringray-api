CREATE OR ALTER view [stng].[VV_SST_OSR] as
select b.UniqueID as SSTID, a.name, a.Status, a.StatusDate, a.Title, a.URLNAME
from stngetl.SST_OSR as a
inner join stng.SST_Main as b on a.PMNUM = b.PM
GO


