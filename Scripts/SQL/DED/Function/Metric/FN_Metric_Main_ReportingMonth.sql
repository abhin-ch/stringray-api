/****** Object:  UserDefinedFunction [stng].[FN_Metric_Main_ReportingMonth]    Script Date: 1/27/2026 1:32:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER FUNCTION [stng].[FN_Metric_Main_ReportingMonth]
(	
	@Year int,
	@Month int,
	@CurrentUser varchar(20)
)
RETURNS @ResultTable Table (
			UniqueID uniqueidentifier
			,MeasureName varchar(max)
			,[Department] varchar(40)
			,[DepartmentC] varchar(20)
			,[Section] varchar(40)
			,[SectionC] varchar(20)
			,MonthlyVarianceText varchar(max)
			,KPICategorization uniqueidentifier
			,KPICategorizationC varchar(200)
			,MeasureType uniqueidentifier
			,Frequency uniqueidentifier
			,Unit uniqueidentifier
			,UnitC varchar(20)
			,MeasureCategory uniqueidentifier
			,DataOwner varchar(10)
			,DataOwnerC varchar(100)
			,MetricOwner varchar(10)
			,MetricOwnerC varchar(100)
			,MeasureCategoryC varchar(max)
			,[Objective] varchar(max)
			,[Definition] varchar(max)
			,[Driver] varchar(max)
			,[DataSource] varchar(max)
			,[RedRecoveryDate] datetime
			,[RedCriteriaC] nvarchar(200)
			,[YellowCriteriaC] nvarchar(200)
			,[GreenCriteriaC] nvarchar(200)
			,[WhiteCriteriaC] nvarchar(200)
			,StatusShort varchar(20)
			,[RAD] datetime
			,[RAB] varchar(20)
			,CurrentMonth decimal(18,2)
			,PreviousMonth decimal(18,2)
			,MonthlyTarget decimal(18,2)
			,OversightAreas varchar(max)
			,ParentMeasure uniqueidentifier
			,ParentMeasureName varchar(max)
			,YTDTarget float
			,CurrentYTD float
			,IsDataOwner bit
			,IsMetricOwner bit
			,[Status] uniqueidentifier
			,[StatusC] varchar(200)
			,[ActiveStatus] uniqueidentifier
			,[ActiveStatusC] varchar(200)
			,[Archived] bit
)
AS
BEGIN 


	Declare @CurrentYear int;
	Declare @CurrentMonth int;

	--Get the current editable year and month, so todays date minus one month
	set @CurrentYear = YEAR(DATEADD(MONTH, -1, GETDATE()))
	set @CurrentMonth = MONTH(DATEADD(MONTH, -1, GETDATE()))

	INSERT INTO @ResultTable
	SELECT 
			a.[UniqueID],
			a.[MeasureName],
			a.[Department],
			a.[DepartmentC],
			a.[Section],
			a.[SectionC],
			MonthyVariance.MonthlyVariance as MonthlyVarianceText,
			a.KPICategorization,
			a.KPICategorizationC,
			a.MeasureType,
			a.Frequency,
			a.Unit,
			a.UnitC,
			a.MeasureCategory,
			a.DataOwner,
			a.DataOwnerC,
			a.MetricOwner,
			a.MetricOwnerC,
			a.MeasureCategoryC,
			a.[Objective],
			a.[Definition],
			a.[Driver],
			a.[DataSource],
			a.[RedRecoveryDate]
			,a.[RedCriteriaC]
			,a.[YellowCriteriaC]
			,a.[GreenCriteriaC]
			,a.[WhiteCriteriaC]
			, MonthlyStatus.StatusShort
			,a.[RAD]
			,a.[RAB]
			--,b.[Value] as CurrentMonth
			--,c.[Value] as PreviousMonth
			,case
				when UnitC = 'Percentage' then
					case
						when d.[Value] = 0 or d.[Value] is null then null
						else isNull((b.[Value]/nullif(d.[Value], 0))*100, 0)
					end
				else b.[Value]
			end as CurrentMonth
			,case
				when UnitC = 'Percentage' then
					case 
						when g.[Value] = 0 or g.[Value] is null then null
						else isNull((c.[Value]/nullif(g.[Value], 0))*100, 0)
					end
				else c.[Value]
			end as PreviousMonth
			--,d.[Value] as MonthlyTarget
			,case
				when UnitC = 'Percentage' then Round(a.TargetPercent, 2)
				else d.[Value]
			end as MonthlyTarget
			,a.OversightAreas
			,a.ParentMeasure
			,a.ParentMeasureName
			,case 
				when UnitC = 'Number' or UnitC = 'Dollar' then Round(e.[CumulativeValue], 2)
				--when UnitC = 'Percentage' then Round(e.[AverageValue], 2)
				when UnitC = 'Percentage' then  Round(a.YTDTargetPercent, 2)
				else null
			end as YTDTarget
			,case 
				when UnitC = 'Number' or UnitC = 'Dollar' then Round(f.[CumulativeValue], 2)
				--when UnitC = 'Percentage' then Round(f.[AverageValue], 2)
				when UnitC = 'Percentage' then case
					when (f.[CumulativeValue] is null) and (e.[CumulativeValue] = 0 or e.[CumulativeValue] is null) then null
					else Round((f.[CumulativeValue]/nullif(e.[CumulativeValue], 0)) * 100, 2) end
				else null
			end as CurrentYTD
			,case when dataOwner.DataOwner is not null then 1 else 0 end as IsDataOwner
			,case when metricOwner.MetricOwner is not null then 1 else 0 end as IsMetricOwner
			, MonthlyStatus.[Status] as [Status]
			, MonthlyStatus.StatusC as [StatusC]
			,a.ActiveStatus
			,a.ActiveStatusC
			,a.Archived
		FROM [stng].[VV_Metric_Main] a
		LEFT JOIN [stng].[Metric_Actuals] b ON a.UniqueID = b.MetricID and b.[Year] = @Year and b.[Month] = @Month and b.Deleted =0
		LEFT JOIN [stng].[Metric_Actuals] c ON a.UniqueID = c.MetricID --Get the previous months actual
			and c.[Year] = case when @Month - 1 < 1 then @Year - 1 else @Year end --Handle when the previous month is the previous year
			and c.[Month] = case when @Month - 1 < 1 then 12 else @Month - 1 end --Handle when the previous month is the previous year
			and c.Deleted =0
		LEFT JOIN [stng].[Metric_Targets] d ON a.UniqueID = d.MetricID and d.[Year] = @Year and d.[Month] = @Month and d.Deleted =0
		LEFT JOIN [stng].[Metric_Targets] g ON a.UniqueID = g.MetricID --Get the previous months actual
			and g.[Year] = case when @Month - 1 < 1 then @Year - 1 else @Year end --Handle when the previous month is the previous year
			and g.[Month] = case when @Month - 1 < 1 then 12 else @Month - 1 end --Handle when the previous month is the previous year
			and g.Deleted =0
		LEFT JOIN [stng].[VV_Metric_YTDTargets] e ON a.UniqueID = e.MetricID and e.[Year] = @Year and e.[Month] = @Month 
		LEFT JOIN [stng].[VV_Metric_YTDActuals] f ON a.UniqueID = f.MetricID and f.[Year] = @Year and f.[Month] = @Month 
		LEFT JOIN (
			select distinct MetricID, DataOwner
			from stng.VV_Metric_DataOwner 
			where DataOwner = @CurrentUser
		) as dataOwner on a.UniqueID = dataowner.MetricID
		LEFT JOIN (
			select distinct MetricID, MetricOwner
			from stng.VV_Metric_MetricOwner 
			where MetricOwner = @CurrentUser
		) as metricOwner on a.UniqueID = metricOwner.MetricID
		LEFT JOIN (
			Select MetricID, [Year], [Month], a.[Status], b.[Status] as StatusC, b.[StatusShort]
			From (
				Select
				MetricID, [Year], [Month], [Status], RAD
				,Row_Number() OVER (
					PARTITION BY MetricID, [Year], [Month]
					Order by RAD DESC
				) as RowNum
				From [stng].[Metric_StatusLog]
				where Deleted = 0
			) as a
			Left Join stng.Metric_Status as b on a.[Status] = b.UniqueID
			Where a.RowNum = 1
		) as MonthlyStatus on a.UniqueID = MonthlyStatus.MetricID and MonthlyStatus.[Year] = @Year and MonthlyStatus.[Month] = @Month 
		LEFT JOIN (
			Select MetricID, [Year], [Month], a.MonthlyVariance
			From (
				Select
				MetricID, [Year], [Month], MonthlyVariance, RAD
				,Row_Number() OVER (
					PARTITION BY MetricID, [Year], [Month]
					Order by RAD DESC
				) as RowNum
				From [stng].[Metric_MonthlyVarianceLog]
				where Deleted = 0
			) as a
			Where a.RowNum = 1
		) as MonthyVariance on a.UniqueID = MonthyVariance.MetricID and MonthyVariance.[Year] = @Year and MonthyVariance.[Month] = @Month 
		ORDER BY a.MeasureName desc

		RETURN;
END
