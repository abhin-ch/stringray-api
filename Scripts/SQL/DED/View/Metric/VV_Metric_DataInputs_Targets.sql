/****** Object:  View [stng].[VV_Metric_DataInputs_Targets]    Script Date: 12/3/2024 8:15:14 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







ALTER view [stng].[VV_Metric_DataInputs_Targets] as
select a.UniqueID as MeasureInfoID
, a.MetricID
, a.[Year]
, a.[JanuaryTarget]
, a.[FebruaryTarget]
, a.[MarchTarget]
, a.[AprilTarget]
, a.[MayTarget]
, a.[JuneTarget]
, a.[JulyTarget]
, a.[AugustTarget]
, a.[SeptemberTarget]
, a.[OctoberTarget]
, a.[NovemberTarget]
, a.[DecemberTarget]
, a.RAD
, a.RAB
, b.EmpName as RABc
, a.Deleted
, a.DeletedBy
, a.DeletedOn
from stng.Metric_DataInputs_Targets as a
LEFT JOIN stng.VV_Admin_UserView AS b ON a.RAB = b.EmployeeID
where a.Deleted = 0
GO


