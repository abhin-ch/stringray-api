ALTER view [stng].[VV_ER_Section] as


SELECT b.UniqueID, a.UniqueID as SECID, a.Section, d.DPID, e.Department, a.DED, a.ProjectRequired, b.SM as SMEmployeeID, c.EmpName as SM, b.[Primary]
FROM [stng].[ER_Section] as a
left join [stng].[ER_SectionManager] as b on a.UniqueID = b.Section and b.Deleted = 0
left join [stng].[VV_Admin_UserView] as c on b.SM = c.EmployeeID 
left join [stng].[ER_SectionToDepartment] as d on a.UniqueID = d.SECID
left join [stng].[ER_Department] as e on d.DPID = e.UniqueID
where a.Deleted = 0 

GO


