CREATE OR ALTER VIEW [stng].[VV_MPL_UsersDepartments]
AS
select 
a.FullName as [user]
,a.LANID
,a.EmployeeID
, case when c.Department is not null then c.Department else d.Department end as Department
from [stng].[Admin_User] as a
left join [stng].[Admin_UserRole] as b on a.UserID = b.UserID and b.[Default] = 1
left join [stng].[Admin_Role] as c on b.RoleID = c.RoleID
left join (
SELECT Department = 'pmc', [user], [lanid]
FROM (
  SELECT ProjectEngineer, ProjectEngineerLANID
  FROM stng.VV_MPL_PMC
  UNION
  SELECT ProjectManager, ProjectManagerLANID
  FROM stng.VV_MPL_PMC
  UNION
  SELECT ProgramManager, ProgramManagerLANID
  FROM stng.VV_MPL_PMC
  UNION
  SELECT SeniorProgramManager, SeniorProgramManagerLANID
  FROM stng.VV_MPL_PMC
  UNION
  SELECT ProjectPlanner, ProjectPlannerLANID
  FROM stng.VV_MPL_PMC
  UNION
  SELECT CostAnalyst, CostAnalystLANID
  FROM stng.VV_MPL_PMC
) AS PMCUsers ([user], [lanid])
WHERE [user] IS NOT NULL

union 

SELECT Department = 'sc', [user], [lanid]
FROM (
  SELECT PCS, PCSLANID
  FROM stng.VV_MPL_SC
  UNION
  SELECT ProjectPlannerAlternate, ProjectPlannerAlternateLANID
  FROM stng.VV_MPL_SC
  UNION
  SELECT BuyerAnalyst, BuyerAnalystLANID
  FROM stng.VV_MPL_SC
  UNION
  SELECT MaterialBuyer, MaterialBuyerLANID
  FROM stng.VV_MPL_SC
  UNION
  SELECT ServiceBuyer, ServiceBuyerLANID
  FROM stng.VV_MPL_SC
  UNION
  SELECT ContractAdmin, ContractAdminLANID
  FROM stng.VV_MPL_SC
  UNION
  SELECT CSFLM, CSFLMLANID
  FROM stng.VV_MPL_SC
) AS SCUsers ([user], [lanid])
WHERE [user] IS NOT NULL

union

SELECT Department = 'ded', [user], [lanid]
FROM (
  SELECT PCS, PCSLANID
  FROM stng.VV_MPL_ENG
  UNION
  SELECT OwnersEngineer, OwnersEngineerLANID
  FROM stng.VV_MPL_ENG
  UNION
  SELECT ProjectPlanner, ProjectPlannerLANID
  FROM stng.VV_MPL_ENG
  UNION
  SELECT SeniorProgramManager, SeniorProgramManagerLANID
  FROM stng.VV_MPL_ENG
) AS DEDUsers ([user], [lanid])
WHERE [user] IS NOT NULL) as d on a.LANID = d.lanid

GO


