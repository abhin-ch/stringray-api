CREATE view [stng].[VV_Metric_YTDTargets] as
with RunningTotals as (
	Select	
	MetricID,
	[Year],
	[Month],
	ISNULL([Value], 0) as [Value],
	ROW_NUMBER() OVER (Partition by MetricID, [Year] ORDER BY [Month]) as MonthOrder, 
	SUM(ISNULL([Value], 0)) OVER (Partition by MetricID, [Year] order by [Month]) as CumulativeValue,
	COUNT([Value]) over (Partition by MetricID, [Year] Order by [Month]) as CumulativeCount
	from stng.Metric_Targets
	where Deleted = 0
)

select
MetricID,
[Year],
[Month],
CumulativeValue,
CumulativeCount,
CumulativeValue/NULLIF(Cast(CumulativeCount as FLOAT), 0) as AverageValue
from RunningTotals

GO
