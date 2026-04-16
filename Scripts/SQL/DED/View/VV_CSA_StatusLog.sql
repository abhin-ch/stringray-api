CREATE VIEW [stng].[VV_CSA_StatusLog]
AS
SELECT DISTINCT 
a.CSASID
, a.CSAID
, c.Status as CSAStatus
, a.Comment
, a.RAD
, b.EmpName		 
FROM stng.CSA_StatusLog AS a 
left join stng.VV_Admin_UserView AS b ON b.EmployeeID = a.RAB
left join stng.CSA_Status as c on a.CSAStatus = c.StatusShort
GO


