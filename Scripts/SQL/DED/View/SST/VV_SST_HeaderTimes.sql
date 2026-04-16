/****** Object:  View [stng].[VV_SST_HeaderTimes]    Script Date: 10/29/2025 12:00:10 PM ******/
SET ANSI_NULLS ON
GO

CREATE OR ALTER VIEW [stng].[VV_SST_HeaderTimes]
AS
(
	SELECT m.UniqueID as SSTID, hc.ImpairmentCount, hc.ImpairmentUnit, hc.ImpairmentNA, hc.ChannelRejectionCount, hc.ChannelRejectionUnit, hc.ChannelRejectionNA
	FROM stng.SST_Main m
	LEFT JOIN stng.SST_HeaderTimes hc on hc.SSTID = m.UniqueID
)
GO


