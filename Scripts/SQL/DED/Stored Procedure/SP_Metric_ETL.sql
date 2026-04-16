/****** Object:  StoredProcedure [stngetl].[SP_Metric_ETL]    Script Date: 1/13/2026 9:55:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER   PROCEDURE [stngetl].[SP_Metric_ETL]
AS
BEGIN

	--Declare @CurrentDate datetime = '2025-12-01'
	Declare @CurrentDate datetime = stng.GetBPTime(getdate())

	Declare @StatusUniqueID uniqueidentifier;
	Declare @EditingYear int;
	Declare @EditingMonth int;
	
	set @EditingYear = YEAR(DATEADD(MONTH, -1, @CurrentDate))
	set @EditingMonth = MONTH(DATEADD(MONTH, -1, @CurrentDate))


--if month === 1 meaning its a new year
--then add new year to metric_year table
--also create new target and actual row for every metric for the new year

	
	if not exists(
		select [Year] 
		from stng.Metric_Year
		where [Year] = year(@CurrentDate)
	)
		begin
			Insert into stng.Metric_Year
			([Year], YearString)
			values
			(year(@CurrentDate), cast(year(@CurrentDate) as varchar(20)))
		end


	SELECT @StatusUniqueID = UniqueID
	FROM [stng].[Metric_Status]
	WHERE [Status] = 'Awaiting Input'

	-- Add new Awiating Input status for this month
	INSERT into stng.Metric_StatusLog
	(MetricID, [Year], [Month], [Status], RAB, RAD)
	SELECT UniqueID, @EditingYear, @EditingMonth, @StatusUniqueID, 'SYSTEM', @CurrentDate
	FROM stng.Metric_Main
	WHERE UniqueID not in (
		Select MetricID
		From stng.Metric_StatusLog
		Where [Year] = @EditingYear and [Month] = @EditingMonth
	)



END
