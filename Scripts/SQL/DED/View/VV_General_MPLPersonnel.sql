/****** Object:  View [stng].[VV_General_MPLPersonnel]    Script Date: 11/26/2024 11:49:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER   view [stng].[VV_General_MPLPersonnel] as
select distinct a.SharedProjectID as ProjectID,
b.EmpName as PCS, b.EmployeeID as PCSID,
c.EmpName as OE, c.EmployeeID as OEID,
d.EmpName as Planner, d.EmployeeID as PlannerID,
e.EmpName as ProjM, e.EmployeeID as ProjMID,
f.EmpName as ProgM, f.EmployeeID as ProgMID,
h.Supervisor SupervisorID, h.SupervisorName Supervisor,
h.SM SMID,h.SMName SM,
h.DM DMID, h.DMName DM,
h.DivM DivMID,h.DivMName DivM,
h.VP VIPID, h.VPName VP,
h.ExecVP ExecVPID, h.ExecVPName ExecVP
from stng.VV_MPL_ENG as a
left join stng.VV_Admin_UserView as b on a.PCSLANID = b.LANID and b.Active = 1
left join stng.VV_Admin_UserView as c on a.OwnersEngineerLANID = c.LANID and c.Active = 1
left join stng.VV_Admin_UserView as d on a.ProjectPlannerLANID = d.LANID and d.Active = 1
left join stng.VV_Admin_UserView as e on a.ProjectManagerLANID = e.LANID and e.Active = 1
left join stng.VV_Admin_UserView as f on a.ProgramManagerLANID = f.LANID and f.Active = 1
left join stng.VV_General_OrganizationView h ON h.MPLDiscipline = a.Discipline
GO


