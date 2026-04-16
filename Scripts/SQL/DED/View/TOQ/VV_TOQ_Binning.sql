SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [stng].[VV_TOQ_Binning]
AS
(
	SELECT b.UniqueID BinningUniqueID, b.TOQMainID, tm.BPTOQID, bt.Bin, b.Comment, b.CreatedBy, b.CreatedDate, bt.Sort FROM stng.TOQ_Binning b
	JOIN stng.TOQ_BinningType bt ON bt.UniqueID = b.BinningTypeID
	JOIN stng.TOQ_Main tm ON tm.UniqueID = b.TOQMainID
	WHERE b.Deleted = 0
)
GO