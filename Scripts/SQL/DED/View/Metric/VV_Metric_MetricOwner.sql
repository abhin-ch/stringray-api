/****** Object:  View [stng].[VV_Metric_MetricOwner]    Script Date: 9/9/2024 4:28:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [stng].[VV_Metric_MetricOwner] AS
SELECT 
    a.UniqueID AS MeasureInfoID,
    a.MetricID,
    a.MetricOwner,
    d.OwnershipType AS OwnershipTypeC,
    a.RAB,
	a.RAD,
    a.Deleted,
	b.EmpName as MetricOwnerC,
    c.EmpName AS AssignedByC
FROM stng.Metric_MetricOwner AS a
LEFT JOIN stng.VV_Admin_UserView AS b ON a.MetricOwner = b.EmployeeID
LEFT JOIN stng.VV_Admin_UserView AS c ON a.RAB = c.EmployeeID
INNER JOIN stng.Metric_OwnershipType AS d ON a.OwnershipType = d.UniqueID
WHERE 
    a.Deleted = 0;
GO


