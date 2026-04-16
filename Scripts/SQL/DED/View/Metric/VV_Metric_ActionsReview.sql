CREATE view [stng].[VV_Metric_ActionsReview] as
select a.UniqueID as ActionsReviewID
, a.MetricID
, a.Action
, a.Responsibility
, c.EmpName as ResponsibilityC
, a.DueDate
, a.[StatusID]
, a.RAD
, a.RAB
, b.ActionStatus as ActionStatusC
, a.ReportingYear
, e.YearString as ReportingYearC
, d.ParentMeasure
, d.SectionC
from stng.Metric_ActionsReview as a
left join stng.Metric_ActionStatus as b on a.StatusID = b.UniqueID 
left join stng.VV_Admin_UserView as c on a.Responsibility = c.EmployeeID
left join stng.VV_Metric_Main as d on a.MetricID = d.UniqueID
left join stng.Metric_Year as e on a.ReportingYear = e.UniqueID
where a.Deleted = 0
GO