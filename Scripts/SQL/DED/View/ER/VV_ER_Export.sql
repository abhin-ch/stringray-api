/****** Object:  View [stng].[VV_ER_Export]    Script Date: 2/3/2026 2:17:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE view [stng].[VV_ER_Export] as
SELECT
      [SiteID] as [Site ID]
      ,[ER]
      ,[ERType] as [ER Type]
      ,[ERTitle] as [ER Title]
      ,[TweekRender] as [WO Program]
      ,[TweekCalc] as [Min T-Week]
      ,[ERTCD] as [ER TCD]
      ,[ERDueDateActual] as [ER Milestone Due Date]
      ,[DateVariance] as [Date Variance]
      ,[CurrentStatus] as [Workflow Status]
      ,[SectionName] as [Section]
      ,[SMName] as [SM]
      ,[SMDueDate] as [SM Due Date]
      ,[AssignedIndividual] as [Assigned Individual]
      ,[Verifier]
      ,[AlternateAssessor] as [Alternate Assessor]
      ,[ScheduleBuilt] as [Schedule Built]
      ,[AllActiveOutages] as [All Active Outages]
      ,[AllCanceledWO] as [Canceled WO]
      ,[InventoryCategory] as [IC]
      ,[EmergentBacklog] as [Emer. Backlog]
      ,[InHouse] as [In House]
      ,[PMER] as [PM ER]
      ,[PHCFlag] as [PHC Flag]
      ,[Location]
      ,[LocationType] as [Location Type]
      ,[USI]
      ,[USIDesc] as [USI Desc.]
      ,[OnlineReporting] as [Online Reporting]
      ,[DueDateType] as [Due Date Type]
      ,[Outage] as [Earliest Outage]
	  ,[AllActiveWOTypes] as [All Active WO Types]
      ,[AllWOGroups] as [All WO Groups]
      ,[AllWOProj] as [All WO Projects]
      ,[AllWOHeader] as [Related WO Headers]
      ,[RelatedWOs] as [Related WOs]
      ,[EarliestWOAge] as [Earliest WO Age]
      ,[AllScheduleBacklog] as [All Scheduled Backlog]
      ,[AllScheduleGrade] as [All Scheduled Grade]
      ,[AllWOPCTR] as [All Active WO PCTR]
      ,[FinishDate] as [Finish Date]
	  ,NULL as [Missed Due Date?]
      ,[WOPriority] as [Highest WO Priority]
      ,[ProjectID] as [Project ID]
      ,[RSE]
      ,[RDE]
      ,[RCE]
      ,[MaximoStatus] as [Maximo Status]
      ,[MaximoTCD] as [Maximo TCD]
      ,[CritCat] as [Crit Cat]
      ,[AssignedTo] as [Assigned To]
      ,[AssignedGroup] as [Assigned Group]
      ,[Initiator]
      ,[InitiatedWorkGroup] as [Initiating Group]
      ,[OrigDate] as [Orig. Date]
      ,[RAD] as [DMS Add Date]
      ,[ERAge] as [ER Age (Days)]
      ,[MinExecDate] as [Min. Execution Date]
      ,[EstimatedHours] as [Estimated Hours]
      ,[Vendors]
      ,[Deliverables]
  FROM [stng].[VV_ER_Main]

GO


