CREATE OR ALTER view [stng].[VV_SST_HistoricalInfo] as
select SSTID, SSTNo, SSTChannel, Result, DocName, SSTDate, dataid, MaximoLink from stng.SST_HistoricalInfo_Mapped
GO


