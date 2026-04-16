CREATE OR ALTER view [stng].[VV_SST_SOEReference] as
select ROW_NUMBER() over (order by a.REFDESCRIPTION) as UniqueID, b.UniqueID as SSTID, a.REFDESCRIPTION as SOERef
from stngetl.SST_PMReferences as a
inner join stng.SST_Main as b on a.PMNUM = b.PM
where a.REFTYPE = 'SOE'
GO


