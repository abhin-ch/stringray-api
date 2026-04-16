CREATE view [stng].[VV_ECRA_PerceptionComment] as
select 
a.UniqueID
, a.EC
, a.Comment
,b.empname as Commenter
,a.RAD as CommentDate
from stng.ECRA_PerceptionComment as a
inner join stng.VV_Admin_UserView as b on a.RAB = b.EmployeeID
where a.Deleted = 0;
GO