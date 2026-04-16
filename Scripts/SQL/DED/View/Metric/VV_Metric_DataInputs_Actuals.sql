/****** Object:  View [stng].[VV_Metric_DataInputs_Actuals]    Script Date: 12/3/2024 8:15:00 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







ALTER view [stng].[VV_Metric_DataInputs_Actuals] as
select a.UniqueID as MeasureInfoID
, a.MetricID
, a.[Year]
, a.[JanuaryActual]
, a.[FebruaryActual]
, a.[MarchActual]
, a.[AprilActual]
, a.[MayActual]
, a.[JuneActual]
, a.[JulyActual]
, a.[AugustActual]
, a.[SeptemberActual]
, a.[OctoberActual]
, a.[NovemberActual]
, a.[DecemberActual]
, a.RAD
, a.RAB
, b.EmpName as RABc
, a.Deleted
, a.DeletedBy
, a.DeletedOn
from stng.Metric_DataInputs_Actuals as a
LEFT JOIN stng.VV_Admin_UserView AS b ON a.RAB = b.EmployeeID
where a.Deleted = 0
GO


