/****** Object:  View [stng].[VV_Admin_Delegation_AllUserPermission]    Script Date: 10/21/2024 12:41:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




/****** Script for SelectTopNRows command from SSMS  ******/

CREATE view [stng].[VV_Admin_Delegation_AllUserPermission] AS

WITH DelegateRolePermission AS (
SELECT 
      [Delegatee] as EmployeeID
	  ,b.RoleUID as RoleID
	  ,e.[Role]
	  ,c.PermissionID
	  ,f.Permission
	  ,'Role, Direct Permission' as Origin
	  ,f.PermissionDescription
  FROM [stng].[VV_Admin_Delegation] as a
  LEFT JOIN stng.Admin_DelegateRole as b on b.DelegateUID = a.UniqueID
  LEFT JOIN stng.Admin_RolePermission as c on c.RoleID = b.RoleUID
  INNER JOIN stng.Admin_DelegatePermission as d on d.DelegateUID = b.DelegateUID and d.PermissionUID = c.PermissionID
  LEFT JOIN stng.Admin_Role as e on e.UniqueID = b.RoleUID
  LEFT JOIN stng.Admin_Permission as f on f.UniqueID = d.PermissionUID
  WHERE b.[Enabled] = 1 and d.[Enabled] = 1 and a.[Status] = 'Active'
  ),

  DelegateRolePermissionInherited AS (
	SELECT DISTINCT a.EmployeeID, a.RoleID, a.[Role], b.PermissionID, b.Permission, 'Role, Inherited Permission' as Origin, b.PermissionDescription
	FROM DelegateRolePermission as a
	inner join stng.VV_Admin_AllPermission as b on a.PermissionID = b.ParentPermissionID
  ),

  DelegateDirectPermission AS (
  SELECT 
      [Delegatee] as EmployeeID
  
     
	  ,null as RoleID
	  ,null as Role
	  ,b.PermissionUID as PermissionID
	  ,d.Permission
	  ,'Direct Permission' as Origin
	  ,d.PermissionDescription
  FROM [stng].[VV_Admin_Delegation] as a
  LEFT JOIN stng.Admin_DelegatePermission as b on b.DelegateUID = a.UniqueID
  LEFT JOIN stng.Admin_RolePermission as c on c.PermissionID = b.PermissionUID
  LEFT JOIN stng.Admin_Permission as d on d.UniqueID = b.PermissionUID
  WHERE c.PermissionID is null and a.Status = 'Active' and b.[Enabled] = 1
  ),

  DelegateDirectPermissionInherited as 
  (
	SELECT DISTINCT a.EmployeeID, null as RoleID, null as [Role], b.PermissionID, b.Permission, 'Inherited Permission' as Origin, b.PermissionDescription
	FROM DelegateDirectPermission as a
	inner join stng.VV_Admin_AllPermission as b on a.PermissionID = b.[ParentPermissionID] and b.ParentPermissionID <> b.PermissionID
  ),

UNIONED as
(
	SELECT EmployeeID, RoleID, [Role], PermissionID, Permission, Origin, PermissionDescription
	FROM DelegateDirectPermission
	UNION
	SELECT EmployeeID, RoleID, [Role], PermissionID, Permission, Origin, PermissionDescription
	FROM DelegateDirectPermissionInherited
	UNION
	SELECT EmployeeID, RoleID, [Role], PermissionID, Permission, Origin, PermissionDescription
	FROM DelegateRolePermission
	UNION
	SELECT EmployeeID, RoleID, [Role], PermissionID, Permission, Origin, PermissionDescription
	FROM DelegateRolePermissionInherited
)

  SELECT EmployeeID, RoleID, [Role], PermissionID, Permission, Origin, PermissionDescription FROM UNIONED
 
GO


