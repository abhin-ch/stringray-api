/****** Object:  View [stng].[VV_Metric_DataInputs]    Script Date: 9/9/2024 4:26:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER view [stng].[VV_Metric_DataInputs] as
select a.UniqueID as DataInputsID
, a.MetricID
, a.JanuaryActual
, a.FebruaryActual
, a.MarchActual
, a.AprilActual
, a.MayActual
, a.JuneActual
, a.JulyActual
, a.AugustActual
, a.SeptemberActual
, a.OctoberActual
, a.NovemberActual
, a.DecemberActual
, a.Variance
, a.RAD
, a.RAB
, a.Deleted
, a.DeletedBy
, a.DeletedOn
, a.JanuaryTarget
, a.FebruaryTarget
, a.MarchTarget
, a.AprilTarget
, a.MayTarget
, a.JuneTarget
, a.JulyTarget
, a.AugustTarget
, a.SeptemberTarget
, a.OctoberTarget
, a.NovemberTarget
, a.DecemberTarget

from stng.Metric_DataInputs as a
inner join stng.Metric_Main as b on a.MetricID = b.UniqueID 
where a.Deleted = 0
GO


