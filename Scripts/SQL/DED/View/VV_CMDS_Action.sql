CREATE VIEW [stng].[VV_CMDS_Action]
AS
SELECT DISTINCT a.*, b.EmpName as ActionAssignedToC, c.[Status] as StatusC
FROM stng.CMDS_Action AS a 
left join stng.VV_Admin_UserView as b on a.ActionAssignedTo = b.EmployeeID
left join stng.CMDS_ActionStatus as c on a.ActionStatus = c.UniqueID
GO