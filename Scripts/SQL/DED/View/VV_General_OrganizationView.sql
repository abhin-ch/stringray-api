create or alter view stng.VV_General_OrganizationView as
with recurse(PersonGroup, ParentPersonGroup, [Type], [Description], Supervisor, Section, Department, Division, VPGroup, ExecVPGroup, SM, DM, DivM, VP, ExecVP) as
(
	select PersonGroup, ParentPersonGroup,[Type], Supervisor, [Description],
	cast(null as varchar(200)) as Section, 
	cast(null as varchar(200)) as Department, 
	cast(null as varchar(200)) as Division, 
	cast(null as varchar(200)) as VPGroup, 
	cast(null as varchar(200)) as ExecVPGroup,
	cast(null as varchar(200)) as SM,
	cast(null as varchar(200)) as DM,
	cast(null as varchar(200)) as DivM,
	cast(null as varchar(200)) as VP,
	cast(null as varchar(200)) as ExecVP
	from stng.General_Organization
	where ParentPersonGroup is null
	union all
	select a.PersonGroup, a.ParentPersonGroup, a.[Type], a.Supervisor, a.[Description],
	cast(case when a.[Type] = 'Section' then a.PersonGroup end as varchar(200)) as Section,
	cast(case when a.[Type] = 'Section' then a.ParentPersonGroup when a.[Type] = 'Department' then a.PersonGroup else b.Department end as varchar(200)) as Department,
	cast(case when a.[Type] = 'Department' then a.ParentPersonGroup when a.[Type] = 'Division' then a.PersonGroup else b.Division end as varchar(200)) as Division,
	cast(case when a.[Type] = 'Division' then a.ParentPersonGroup when a.[Type] = 'VP' then a.PersonGroup else b.VPGroup end as varchar(200)) as VPGroup,
	cast(case when a.[Type] = 'VP' then a.ParentPersonGroup when a.[Type] = 'ExecVP' then a.PersonGroup else b.ExecVPGroup end as varchar(200)) as ExecVPGroup,
	cast(case when a.[Type] = 'Section' then a.Supervisor end as varchar(200)) as SM,
	cast(case when a.[Type] = 'Section' then b.Supervisor when a.[Type] = 'Department' then a.Supervisor else b.DM end as varchar(200)) as DM,
	cast(case when a.[Type] = 'Department' then b.Supervisor when a.[Type] = 'Division' then a.Supervisor else b.DivM end as varchar(200)) as DivM,
	cast(case when a.[Type] = 'Division' then b.Supervisor when a.[Type] = 'VP' then a.Supervisor else b.VP end as varchar(200)) as VP,
	cast(case when a.[Type] = 'VP' then b.Supervisor when a.[Type] = 'ExecVP' then a.Supervisor else b.ExecVP end as varchar(200)) as ExecVP
	from stng.General_Organization as a
	inner join recurse as b on a.ParentPersonGroup = b.persongroup
)

select distinct b.UniqueID,a.*, b.MPLDiscipline,
c.EmpName as SupervisorName,
d.EmpName as SMName,
e.EmpName as DMName,
f.EmpName as DivMName,
g.EmpName as VPName,
h.EmpName as ExecVPName
from recurse as a
left join stng.General_MPLOrganizationMap as b on a.PersonGroup = b.PersonGroup
left join stng.VV_Admin_UserView as c on a.Supervisor = c.EmployeeID
left join stng.VV_Admin_UserView as d on a.SM = d.EmployeeID
left join stng.VV_Admin_UserView as e on a.DM = e.EmployeeID
left join stng.VV_Admin_UserView as f on a.DivM = f.EmployeeID
left join stng.VV_Admin_UserView as g on a.VP = g.EmployeeID
left join stng.VV_Admin_UserView as h on a.ExecVP = h.EmployeeID
--order by PersonGroup asc