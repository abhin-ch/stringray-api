CREATE VIEW [stng].[VV_CSA_Main]
AS
SELECT DISTINCT 
	a.CSAID, a.Item, a.CSAStatus, a.INID, a.VERID, a.APPID, a.RAD, a.RAB, a.LUD, a.LUB, 
	a.Permit, a.AR, a.AMOT, a.EC, a.RootItem, a.ItemDesc, { fn CONCAT('B-CSA-', a.Item) } AS CSANum,a.CurrentCSARevision, a.BOMUpdateRequired, a.Manufacturer, a.Model, 
	a.CritCat, a.SPV,
	b.EmpName as Initiator, c.EmpName as Verifier, d.EmpName as Approver
	FROM            stng.CSA_Main AS a 
	left join stng.VV_Admin_UserView as b on a.INID = b.EmployeeID
	left join stng.VV_Admin_UserView as c on a.VERID = c.EmployeeID
	left join stng.VV_Admin_UserView as d on a.APPID = d.EmployeeID
GO


