/****** Object:  View [stng].[VV_ER_WeeklyExport]    Script Date: 12/1/2025 11:58:53 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO










ALTER view [stng].[VV_ER_WeeklyExport] as

	
	select distinct
	er.snap_dt, 
	er.wonum, 
    er.WOHeader,
	ER.ERWO,
	lu.kpi_id, 
	isnull(er.SectionName,'Unassigned') as ERSection, 
	isnull(er.DepartmentName,'Unassigned') as ERDepartment, 
	case when 
	(dem.SectionName	is null and dem.ERType in ('ENCD','ENGD','MJT','EQ','ENGS'))
	or
	s.DED = 1 then
		'Y'
	else
		'N'
	end as [Design ER],
	CASE
		WHEN dem.ERType in ('ENCD','ENGD','MJT','EQ','ENGS') then 'DED'
		WHEN dem.ERType in ('ENGP', 'ENGC' ,'EVD') then 'Station Engineering' 
	END as MilestoneOwner,
	er.WMCriteria WMCombined,
	dem.ERID, dem.ER, dem.MaximoLink, dem.ERTitle, dem.MaximoStatus, dem.ERType, dem.CurrentStatusShort, dem.CurrentStatus, dem.AssignedIndividual, dem.Verifier, 
	dem.AlternateAssessor, dem.ERTCD, dem.WOPriority, dem.MinExecDate, dem.SiteID, dem.Outage, dem.ProjectID, dem.ERAge, dem.MaximoComments, dem.Tweek, dem.SectionName, dem.SMName,
	dem.DepartmentName, dem.AllScheduleBacklog, dem.AllScheduleGrade, dem.EPT, dem.AllActiveOutages, dem.OnlineReporting, dem.AllWOPCTR, dem.AllWOHeader, dem.SMDueDate, 
	dem.ERDueDate, dem.DateVariance, dem.Location, dem.USI, dem.DueDateType, dem.AllActiveWOTypes, dem.TweekCalc, dem.EarliestWOAge
	from stngetl.ER_WeeklyERSnapshot er
	inner join 
	(
		select max(snap_dt) snap_dt 
		from stngetl.ER_WeeklyERSnapshot 
	) asd on asd.snap_dt = er.snap_dt
	left join [stng].[ER_MetricsKPI] lu on lu.KPI_ID = er.KPI_ID
	left join stng.VV_ER_Main  dem on dem.ERID = er.ERID and dem.ERType in ('ENCD', 'ENGC', 'ENGD', 'EQ', 'ENGP', 'ENGS', 'EP', 'EVD', 'MJT', 'RS', 'WLD')
	left join stng.VV_ER_Section s on dem.Section = s.SECID
	left join stngetl.ER_SupportingWOInfo wo on wo.ER = er.ER and wo.WONUM = er.WONUM

GO


