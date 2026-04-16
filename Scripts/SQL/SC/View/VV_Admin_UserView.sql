CREATE OR ALTER view [stng].[VV_Admin_UserView] as
select a.*
,concat(a.FirstName,' ', a.LastName) as EmpName
,c.NameShort RoleShort
from stng.Admin_User as a
left join stng.Admin_UserRole b on b.UserID = a.UserID and b.[Default] = 1
left join stng.Admin_Role c on c.RoleID = b.RoleID