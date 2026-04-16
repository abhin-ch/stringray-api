ALTER VIEW [stng].[VV_MPL_ENG]
AS
select distinct
		ProjectDepartment = 'ENG'
		,mpl.PROJECTID as ProjectID
		,mpl.INTERNALID as InternalID
		,mpl.PROJECTIDNUM as SharedProjectID
		,mpl.PROJECTNAME as ProjectName
		,mpl.BUSINESSDRIVER as BusinessDriver
		,mpl.BUYERANALYST as BuyerAnalyst, mpl.BUYERANALYSTSHORT as BuyerAnalystLANID
		,mpl.PROJECTCATEGORYSHORT as Category
		,mpl.CONTRACTADMIN as ContractAdmin, mpl.CONTRACTADMINSHORT as ContractAdminLANID
		,mpl.CONTRACTTYPE as ContractType
		,mpl.PROJECTCOSTANALYST as CostAnalyst, mpl.PROJECTCOSTANALYSTSHORT as CostAnalystLANID
		,mpl.CSFLM as CSFLM, mpl.CSFLMSHORT as CSFLMLANID
		,mpl.PCS as PCS, mpl.PCSSHORT as PCSLANID, pcs.EmployeeID as PCSID
		,mpl.DEPARTMENT as Department
		,mpl.DISCIPLINE as Discipline
		,mpl.FASTTRACK as FastTrack
		,mpl.FUNDINGSOURCE as FundingSource
		,mpl.MATERIALBUYER as MaterialBuyer, mpl.MATERIALBUYERSHORT as MaterialBuyerLANID
		,mpl.MULTIDISC as MultiDisc
		,mpl.OWNERSENGINEER as OwnersEngineer, mpl.OWNERSENGINEERSHORT as OwnersEngineerLANID
		,mpl.PORTFOLIO as Portfolio
		,mpl.PHASE as Phase
		,mpl.PROGRAM as Program
		,mpl.PROGRAMMANAGER as ProgramManager, mpl.PROGRAMMANAGERSHORT as ProgramManagerLANID
		,mpl.PROJECTENGINEER as ProjectEngineer, mpl.PROJECTENGINEERSHORT as ProjectEngineerLANID
		,mpl.PROJECTMANAGER as ProjectManager, mpl.PROJECTMANAGERSHORT as ProjectManagerLANID
		,mpl.PROJECTPLANNER as ProjectPlanner, mpl.PROJECTPLANNERSHORT as ProjectPlannerLANID
		,mpl.PROJECTPLANNERALTERNATE as ProjectPlannerAlternate, mpl.PROJECTPLANNERALTERNATESHORT as ProjectPlannerAlternateLANID
		,mpl.SENIORPROGRAMMANAGER as SeniorProgramManager, mpl.SENIORPROGRAMMANAGERSHORT as SeniorProgramManagerLANID
		,mpl.SERVICEBUYER as ServiceBuyer, mpl.SERVICEBUYERSHORT as ServiceBuyerLANID
		,mpl.[STATUS] as [Status]
		,mpl.SUBPORTFOLIO as SubPortfolio
		,c.blprojecttotalcost
		,c.actualtotalcost
		,c.blprojecttotalcost - c.actualtotalcost as AvailableBudget
		,mpl.PROJECTTYPE ProjectType
		,mpl.PROJECTTYPESHORT ProjectTypeShort
	from [stng].[MPL] as mpl
	left join stngetl.MPL_Cost as c on mpl.PROJECTID = c.projectid
	left join stng.Admin_User as pcs on mpl.PCSSHORT = pcs.LANID
	where mpl.ProjectID like '%ENG%'
GO