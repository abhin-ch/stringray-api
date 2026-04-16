Create or ALTER VIEW [stng].[VV_MPL_ENG]
AS
select 
		ProjectDepartment = 'ENG',mpl.INTERNALID as INTERNALID
		,mpl.PROJECTID as ProjectID
		,mpl.PROJECTIDNUM as SharedProjectID
		,mpl.PROJECTNAME as ProjectName
		,mpl.BUSINESSDRIVER as BusinessDriver
		,mpl.BUYERANALYST as BuyerAnalyst, mpl.BUYERANALYSTSHORT as BuyerAnalystLANID
		,mpl.PROJECTCATEGORYSHORT as Category
		,mpl.CONTRACTADMIN as ContractAdmin, mpl.CONTRACTADMINSHORT as ContractAdminLANID
		,mpl.CONTRACTTYPE as ContractType
		,mpl.PROJECTCOSTANALYST as CostAnalyst, mpl.PROJECTCOSTANALYSTSHORT as CostAnalystLANID
		,mpl.CSFLM as CSFLM, mpl.CSFLMSHORT as CSFLMLANID
		,mpl.PCS as PCS, mpl.PCSSHORT as PCSLANID 
		,user1.FullName as SM
		,user1.LANID as SMLANID
		,user2.FullName as DM
		,user2.LANID as DMLANID
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
		,mpl.PROJECTTYPE as ProjectType
		,mpl.INVOICE as ENGInvoice
		,cast( c.blprojecttotalcost as int) as blprojecttotalcost
		,cast( c.actualtotalcost as int) as actualtotalcost
		,cast(c.Released - c.actualtotalcost as Int) as AvailableBudget
		,cast(c.Released as int) as Released
	

	from  mpl
	left join [stng].[General_Organization] as orgDisc on mpl.DISCIPLINE = orgDisc.[Description]
	left join [stng].[Admin_User] as user1 on orgDisc.Supervisor = user1.EmployeeID
	left join (select * 	from [stng].[General_Organization] where code is not null) as org on mpl.DEPARTMENTSHORT2 = org.code
	  	left join [stng].[Admin_User] as user2 on org.Supervisor = user2.EmployeeID
	left join stngetl.MPL_Cost as c on mpl.PROJECTID = c.projectid
	where mpl.PROJECTID like '%ENG%'
GO


