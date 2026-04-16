CREATE OR ALTER VIEW [stng].[VV_MPL_PMC]
AS
select 
		ProjectDepartment = 'PMC',mpl.INTERNALID as INTERNALID
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
	from [stng].[MPL] as mpl
	where ProjectID not like '%ENG%' and ProjectID not like '%CS%' and PROJECTTYPE not like 'MCR%'
GO


