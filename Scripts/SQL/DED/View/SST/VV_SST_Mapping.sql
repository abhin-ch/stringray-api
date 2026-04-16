CREATE OR ALTER view [stng].[VV_SST_Mapping] as
select a.UniqueID, a.SSTID, a.SSTNo, a.SSTChannel,
concat(a.SSTNo,a.SSTChannel) as SSTLabel
from stng.SST_Mapping as a
where a.Deleted = 0
GO


