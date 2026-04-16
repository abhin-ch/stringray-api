CREATE VIEW [stng].[VV_CMDS_StatusLog]
AS
SELECT a.*, b.[Status] StatusC, c.EmpName 
FROM [stng].[CMDS_StatusLog] as a
left join [stng].[CMDS_Status] as b on a.[StatusID] = b.UniqueID
left join [stng].[VV_Admin_UserView] as c on a.RAB = c.EmployeeID
GO


