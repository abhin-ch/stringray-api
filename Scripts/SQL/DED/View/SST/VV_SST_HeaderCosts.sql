CREATE OR ALTER VIEW [stng].[VV_SST_HeaderCosts]
AS
(
	SELECT m.UniqueID as SSTID, hc.PreDoseCost, hc.Dose, hc.DoseMREM, hc.SingleExecutionCost
	FROM stng.SST_Main m
	LEFT JOIN stng.SST_HeaderCosts hc on hc.SSTID = m.UniqueID
)
GO


