/*
Author: Raman Molla
Description: Get all users that have access to a Module
CreatedDate: 12 Sept 2023
*/
ALTER FUNCTION [stng].[FN_Admin_GetUsersForModule] (@ModuleName nvarchar(255))
RETURNS TABLE
AS
RETURN (
    SELECT DISTINCT
		   a.UAID,
		   a.RoleID,
           a.[Description]
          ,a.[Module]
          ,a.[Name]
          ,a.[Type]
          ,b.UserID
          ,b.EmployeeID
          ,c.FirstName + ' ' + c.LastName as FullName
      FROM [stng].[VV_Admin_UserAccess] as a
      INNER JOIN [stng].[VV_Admin_UserRole] as b ON a.RoleID = b.RoleID 
      INNER JOIN [stng].[Admin_User] as c on b.EmployeeID = c.EmployeeID
      where (a.Type = 'Module' OR a.Type = 'System') AND (a.Module = @ModuleName OR a.Name = 'SysAdmin')
)
GO