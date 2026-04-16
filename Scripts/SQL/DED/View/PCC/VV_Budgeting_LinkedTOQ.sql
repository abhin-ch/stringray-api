CREATE or ALTER VIEW [stng].[VV_Budgeting_LinkedTOQ] as 
SELECT 
	a.[UniqueID],
	a.[SDQUID],
	b.[TMID],
	a.[TOQID],
	a.[AllocatedFunding],
	a.[RAB],
	a.[RAD],
	b.[BPTOQID],
	b.[Rev],
	b.[Status],
	b.[AwardedTotalCost],
    b.[AwardedVendor],
    b.[AwardedVendorTOQNumber],
	b.[TDSNo],
	b.[AwardedStartDate],
    b.[AwardedEndDate]
FROM [stng].[Budgeting_LinkedTOQ_Mapping] as a
inner join [stng].[VV_TOQ_Main] as b on a.TOQID = b.UniqueID and a.Deleted = 0
inner join stng.Budgeting_SDQMain as c on a.sdquid = c.sdquid and c.NoTOQFunding = 0
GO


