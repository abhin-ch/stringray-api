CREATE VIEW [stng].[VV_Metric_MonthYear] AS
SELECT concat(a.[Year], '-', b.[Month]) as UniqueID
, a.[Year]
, b.[Month]
, concat(b.MonthString, ' ', a.YearString) as [label]
FROM [stng].[Metric_Year] as a
CROSS JOIN [stng].[Metric_Month] as b 
WHERE a.[Year] < Year(GETDATE())
	OR (a.[Year] = Year(GETDATE()) AND b.[Month] < Month(GETDATE()))
GO