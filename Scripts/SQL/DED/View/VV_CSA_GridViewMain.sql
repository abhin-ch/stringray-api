ALTER VIEW [stng].[VV_CSA_GridViewMain]
AS
SELECT DISTINCT 
                         a.CSAID, a.Item, a.INID, a.VERID, a.APPID, a.RAD, a.RAB, a.LUD, a.LUB, 
                         a.Permit, a.AR, a.AMOT, a.EC, a.RootItem, a.CSAStatus
						 ,f.[Status] as CSAStatusC
						 ,a.ItemDesc, { fn CONCAT('B-CSA-', a.Item) } AS CSANum,a.CurrentCSARevision
						 ,a.BOMUpdateRequired, a.Manufacturer, a.Model, 
                         a.CritCat, a.SPV,
						 b.EmpName as Initiator, c.EmpName as Verifier, d.EmpName as Approver
FROM            stng.CSA_Main AS a 
		LEFT OUTER JOIN [stng].[VV_Admin_UserView] AS b ON b.EmployeeID = a.INID
		LEFT OUTER JOIN [stng].[VV_Admin_UserView] AS c ON c.EmployeeID = a.VERID 
		LEFT OUTER JOIN [stng].[VV_Admin_UserView] AS d ON d.EmployeeID = a.APPID
		LEFT OUTER JOIN [stngetl].[General_LatestIssuedCSA] AS e ON { fn CONCAT('B-CSA-', a.Item) } = e.CSANum
		LEFT OUTER JOIN [stng].[CSA_Status] as f on a.CSAStatus = f.StatusShort
GO


