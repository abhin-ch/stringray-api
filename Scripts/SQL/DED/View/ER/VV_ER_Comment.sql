CREATE view [stng].[VV_ER_Comment] as
select a.UniqueID, a.ERID, a.Comment,
case when a.RAB <> 'SYSTEM' then concat(b.FirstName, ' ',b.LastName) else a.RAB end as Commenter,
a.RAD as CommentDate
from stng.ER_Comment as a
inner join stng.Admin_User as b on a.RAB = b.EmployeeID
where a.Deleted = 0;