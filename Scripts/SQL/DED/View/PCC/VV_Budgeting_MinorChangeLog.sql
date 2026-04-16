CREATE   VIEW [stng].[VV_Budgeting_MinorChangeLog]
AS
	SELECT a.[UniqueID]
      ,a.[SDQUID]
      ,a.[ChangeTypeID]
	  ,b.[Type]
      ,a.[Comment]
      ,c.EmpName as RAB
      ,a.[RAD]
  FROM [stng].[Budgeting_MinorChangeLog] as a
  LEFT JOIN [stng].[Budgeting_MinorChangeType] as b on a.ChangeTypeID = b.UniqueID
  LEFT JOIN [stng].[VV_Admin_UserView] as c on a.RAB = c.EmployeeID
  WHERE a.Deleted = 0
GO