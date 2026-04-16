CREATE OR ALTER VIEW [stng].[VV_Admin_ModuleOwners]
AS


select uv.EmpName, uv.EmployeeID, uv.Username, ur.Role, ra.Attribute as Module, ra.AttributeID as ModuleID
from stng.VV_Admin_UserRole ur
join stng.VV_Admin_UserView uv on uv.EmployeeID = ur.EmployeeID
left join stng.VV_Admin_RoleAttribute ra on ra.RoleID = ur.RoleID and ra.AttributeType = 'Module'
where ur.Role like '%admin%' and not exists (
	SELECT 1 FROM stng.VV_Admin_ActualUserPermission up
	where up.Permission = 'SysAdmin'
	AND up.EmployeeID = uv.EmployeeID
	)
GO


