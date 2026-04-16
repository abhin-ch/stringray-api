/****** Object:  StoredProcedure [stngetl].[SP_ER_Weekly_Snapshot_V2]    Script Date: 12/1/2025 11:54:26 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER   procedure [stngetl].[SP_ER_Weekly_Snapshot_V2]  as
begin

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM 
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '1' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BA' AND b.WorkManagement = 1 and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ')  AND b.Tweek = 14 
	--AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') AND b.PCTR IN ('OPA','OPB','PLN','PRJ','VBO') AND b.ScheduleGrade in ('A','B','C') AND B.OnlineReporting = 1
	--(AllScheduleGrade LIKE '%A%' OR AllScheduleGrade LIKE '%B%' OR AllScheduleGrade LIKE '%C%')

 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)


(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '2' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BA' AND b.WorkManagement = 1 and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ')  AND b.Tweek = 14  
	-- AND b.PCTR IN ('OPA','OPB','PLN','PRJ','VBO')  AND  b.ScheduleGrade in ('A','B','C') AND B.OnlineReporting = 1 AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME')
	-- (AllScheduleGrade LIKE '%A%' OR AllScheduleGrade LIKE '%B%' OR AllScheduleGrade LIKE '%C%')
	and a.CurrentStatusShort in ('COM','CAN')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '3' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BB' AND b.WorkManagement = 1 and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ')  AND b.Tweek = 14  
	-- AND b.PCTR IN ('OPA','OPB','PLN','PRJ','VBO')  AND  b.ScheduleGrade in ('A','B','C') AND B.OnlineReporting = 1 AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME')
	-- (AllScheduleGrade LIKE '%A%' OR AllScheduleGrade LIKE '%B%' OR AllScheduleGrade LIKE '%C%')

 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '4' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BB' AND b.WorkManagement = 1 and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ')  AND b.Tweek = 14  
	-- AND b.PCTR IN ('OPA','OPB','PLN','PRJ','VBO')  AND  b.ScheduleGrade in ('A','B','C') AND B.OnlineReporting = 1 AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME')
	-- (AllScheduleGrade LIKE '%A%' OR AllScheduleGrade LIKE '%B%' OR AllScheduleGrade LIKE '%C%')
	and a.CurrentStatusShort in ('COM','CAN')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '5' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BA' AND B.WorkManagement = 1 and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ') AND b.Tweek = 36
	-- AND b.PCTR IN ('OPA','OPB','PLN','PRJ','VBO')  AND  b.ScheduleGrade in ('A','B','C') AND B.OnlineReporting = 1   AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') 
	-- (AllScheduleGrade LIKE '%A%' OR AllScheduleGrade LIKE '%B%' OR AllScheduleGrade LIKE '%C%')

 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '6' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BA' AND B.WorkManagement = 1 and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ') AND b.Tweek = 36
	-- AND b.PCTR IN ('OPA','OPB','PLN','PRJ','VBO')  AND  b.ScheduleGrade in ('A','B','C') AND B.OnlineReporting = 1   AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') 
	-- (AllScheduleGrade LIKE '%A%' OR AllScheduleGrade LIKE '%B%' OR AllScheduleGrade LIKE '%C%')
	and a.CurrentStatusShort in ('COM','CAN')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '7' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BB' AND B.WorkManagement = 1 and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ') AND b.Tweek = 36
	-- AND b.PCTR IN ('OPA','OPB','PLN','PRJ','VBO')  AND  b.ScheduleGrade in ('A','B','C') AND B.OnlineReporting = 1   AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') 
	-- (AllScheduleGrade LIKE '%A%' OR AllScheduleGrade LIKE '%B%' OR AllScheduleGrade LIKE '%C%')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '8' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BB' AND B.WorkManagement = 1 and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ') AND b.Tweek = 36
	-- AND b.PCTR IN ('OPA','OPB','PLN','PRJ','VBO')  AND  b.ScheduleGrade in ('A','B','C') AND B.OnlineReporting = 1   AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') 
	-- (AllScheduleGrade LIKE '%A%' OR AllScheduleGrade LIKE '%B%' OR AllScheduleGrade LIKE '%C%')
	and a.CurrentStatusShort in ('COM','CAN')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '9' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BA' AND ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ') AND b.EmergentBacklog in ('CNO', 'H')  and 
	(ERTCD >= DATEADD(Day, 2 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS date)) and ERTCD < DATEADD(DAY, 1, CAST(DATEADD(DAY, (7-DATEPART(WEEKDAY, GETDATE())), GETDATE()) AS date))) 
	--(ERTCD >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and ERTCD < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))

 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '10' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BA' AND ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ') AND b.EmergentBacklog in ('CNO', 'H')  and 
	(ERTCD >= DATEADD(Day, 2 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS date)) and ERTCD < DATEADD(DAY, 1, CAST(DATEADD(DAY, (7-DATEPART(WEEKDAY, GETDATE())), GETDATE()) AS date))) --(ERTCD >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and ERTCD < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
	and a.CurrentStatusShort in ('COM','CAN')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '11' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BB' AND ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ') AND b.EmergentBacklog in ('CNO', 'H')  and 
	(ERTCD >= DATEADD(Day, 2 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS date)) and ERTCD < DATEADD(DAY, 1, CAST(DATEADD(DAY, (7-DATEPART(WEEKDAY, GETDATE())), GETDATE()) AS date))) --(ERTCD >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and ERTCD < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '12' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BB' AND ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ') AND b.EmergentBacklog in ('CNO', 'H')  and 
	(ERTCD >= DATEADD(Day, 2 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS date)) and ERTCD < DATEADD(DAY, 1, CAST(DATEADD(DAY, (7-DATEPART(WEEKDAY, GETDATE())), GETDATE()) AS date))) --(ERTCD >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and ERTCD < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
	and a.CurrentStatusShort in ('COM','CAN')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '13' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE b.WorkManagement = 1 and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ')  and 
	(a.SMDueDate >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and a.SMDueDate < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
 
)


insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '14' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE b.WorkManagement = 1 and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ') and 
	(a.SMDueDate >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and a.SMDueDate < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
    and a.CurrentStatusShort in ('COM','CAN', 'EXE')
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '15' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	join stng.VV_ER_StatusLog C on a.ERID = c.ERID and c.StatusShort = 'AA' and (c.StatusDate >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and c.StatusDate < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0)) 
	WHERE b.WorkManagement = 1 and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ')  
)


insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(
	SELECT DISTINCT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '16' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	join stng.VV_ER_StatusLog C_AA on a.ERID = C_AA.ERID and C_AA.StatusShort = 'AA'  and (C_AA.StatusDate >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and C_AA.StatusDate < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
	join stng.VV_ER_StatusLog C_ASA on a.ERID = C_ASA.ERID and C_ASA.StatusShort = 'ASA' AND (C_ASA.StatusDate > C_AA.StatusDate)  AND (DATEDIFF(DAY, C_AA.StatusDate, C_ASA.StatusDate) - 2 * (DATEDIFF(WEEK, C_AA.StatusDate, C_ASA.StatusDate))) <=2
	WHERE b.WorkManagement = 1 and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ')    
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '1' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BA' AND b.WorkManagement = 0 and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ') AND B.OnlineReporting = 1  AND b.Tweek = 14 AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') 
	AND  B.PCTR IN ('OPA', 'OPB', 'PLN', 'PRJ', 'VBO', 'FHA', 'FHB')  
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '2' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BA' AND b.WorkManagement = 0 and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ') AND B.OnlineReporting = 1  AND b.Tweek = 14 AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') 
	AND  B.PCTR IN ('OPA', 'OPB', 'PLN', 'PRJ', 'VBO', 'FHA', 'FHB')  
    and a.CurrentStatusShort in ('COM','CAN')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '3' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BB' AND b.WorkManagement = 0 and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ') AND B.OnlineReporting = 1  AND b.Tweek = 14 AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') 
	AND  B.PCTR IN ('OPA', 'OPB', 'PLN', 'PRJ', 'VBO', 'FHA', 'FHB')  
 
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM 
	,WOHeader 
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '4' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BB' AND b.WorkManagement = 0 and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ') AND B.OnlineReporting = 1  AND b.Tweek = 14 AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') 
	AND  B.PCTR IN ('OPA', 'OPB', 'PLN', 'PRJ', 'VBO', 'FHA', 'FHB')  
    and a.CurrentStatusShort in ('COM','CAN')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '5' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BA' AND b.WorkManagement = 0 and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ') AND B.OnlineReporting = 1  AND b.Tweek = 36 AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') 
	AND  B.PCTR IN ('OPA', 'OPB', 'PLN', 'PRJ', 'VBO', 'FHA', 'FHB')  

 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM 
	,WOHeader 
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '6' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BA' AND b.WorkManagement = 0 and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ') AND B.OnlineReporting = 1  AND b.Tweek = 36 AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') 
	AND  B.PCTR IN ('OPA', 'OPB', 'PLN', 'PRJ', 'VBO', 'FHA', 'FHB')  
   and a.CurrentStatusShort in ('COM','CAN')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '7' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BB' AND b.WorkManagement = 0 and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ') AND B.OnlineReporting = 1  AND b.Tweek = 36 AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') 
	AND  B.PCTR IN ('OPA', 'OPB', 'PLN', 'PRJ', 'VBO', 'FHA', 'FHB')  

 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '8' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BB' AND b.WorkManagement = 0 and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ') AND B.OnlineReporting = 1  AND b.Tweek = 36 AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') 
	AND  B.PCTR IN ('OPA', 'OPB', 'PLN', 'PRJ', 'VBO', 'FHA', 'FHB')  
    and a.CurrentStatusShort in ('COM','CAN')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '9' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BA' and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ')  AND b.EmergentBacklog in ('CNO', 'H')  and 
	(ERTCD >= DATEADD(Day, 2 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS date)) and ERTCD < DATEADD(DAY, 1, CAST(DATEADD(DAY, (7-DATEPART(WEEKDAY, GETDATE())), GETDATE()) AS date))) --(ERTCD >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and ERTCD < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '10' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BA' AND ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ') AND b.EmergentBacklog in ('CNO', 'H')  and 
	(ERTCD >= DATEADD(Day, 2 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS date)) and ERTCD < DATEADD(DAY, 1, CAST(DATEADD(DAY, (7-DATEPART(WEEKDAY, GETDATE())), GETDATE()) AS date))) --(ERTCD >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and ERTCD < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
	and a.CurrentStatusShort in ('COM','CAN')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '11' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BB' AND ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ') AND b.EmergentBacklog in ('CNO', 'H')  and 
	(ERTCD >= DATEADD(Day, 2 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS date)) and ERTCD < DATEADD(DAY, 1, CAST(DATEADD(DAY, (7-DATEPART(WEEKDAY, GETDATE())), GETDATE()) AS date))) --(ERTCD >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and ERTCD < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM
	,WOHeader  
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '12' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BB' AND ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ') AND b.EmergentBacklog in ('CNO', 'H')  and 
	(ERTCD >= DATEADD(Day, 2 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS date)) and ERTCD < DATEADD(DAY, 1, CAST(DATEADD(DAY, (7-DATEPART(WEEKDAY, GETDATE())), GETDATE()) AS date))) --(ERTCD >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and ERTCD < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
	and a.CurrentStatusShort in ('COM','CAN')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '13' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE b.WorkManagement = 0 and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ') AND B.OnlineReporting = 1  and 
	(a.SMDueDate >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and a.SMDueDate < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
 
)


insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '14' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE b.WorkManagement = 0 and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ') AND B.OnlineReporting = 1  and 
	(a.SMDueDate >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and a.SMDueDate < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
    and a.CurrentStatusShort in ('COM','CAN', 'EXE')
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '15' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	join stng.VV_ER_StatusLog C on a.ERID = c.ERID and c.StatusShort = 'AA' and (c.StatusDate >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and c.StatusDate < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0)) 
	WHERE b.WorkManagement = 0 and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ') AND B.OnlineReporting = 1  
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT DISTINCT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '16' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'DED' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	join stng.VV_ER_StatusLog C_AA on a.ERID = C_AA.ERID and C_AA.StatusShort = 'AA'  and (C_AA.StatusDate >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and C_AA.StatusDate < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
	join stng.VV_ER_StatusLog C_ASA on a.ERID = C_ASA.ERID and C_ASA.StatusShort = 'ASA' AND (C_ASA.StatusDate > C_AA.StatusDate)  AND (DATEDIFF(DAY, C_AA.StatusDate, C_ASA.StatusDate) - 2 * (DATEDIFF(WEEK, C_AA.StatusDate, C_ASA.StatusDate))) <=2
	WHERE b.WorkManagement = 0 and ERType IN ('ENGD', 'ENCD', 'ENGS', 'MJT', 'EQ') AND B.OnlineReporting = 1   
 
)










insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '1' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BA' AND b.WorkManagement = 1 and ERType IN ('ENGP', 'ENGC' ,'EVD') AND b.Tweek = 14
	-- AND b.PCTR IN ('OPA','OPB','PLN','PRJ','VBO')  AND  b.ScheduleGrade in ('A','B','C') AND B.OnlineReporting = 1   AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') 
	-- (AllScheduleGrade LIKE '%A%' OR AllScheduleGrade LIKE '%B%' OR AllScheduleGrade LIKE '%C%')

 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)


(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '2' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BA' AND b.WorkManagement = 1 and ERType IN ('ENGP', 'ENGC' ,'EVD') AND b.Tweek = 14
	-- AND b.PCTR IN ('OPA','OPB','PLN','PRJ','VBO')  AND  b.ScheduleGrade in ('A','B','C') AND B.OnlineReporting = 1   AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') 
	-- (AllScheduleGrade LIKE '%A%' OR AllScheduleGrade LIKE '%B%' OR AllScheduleGrade LIKE '%C%')
	and a.CurrentStatusShort in ('COM','CAN')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM 
	,WOHeader 
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '3' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BB' AND b.WorkManagement = 1 and ERType IN ('ENGP', 'ENGC' ,'EVD') AND b.Tweek = 14
	-- AND b.PCTR IN ('OPA','OPB','PLN','PRJ','VBO')  AND  b.ScheduleGrade in ('A','B','C') AND B.OnlineReporting = 1   AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') 
	-- (AllScheduleGrade LIKE '%A%' OR AllScheduleGrade LIKE '%B%' OR AllScheduleGrade LIKE '%C%')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '4' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BB' AND b.WorkManagement = 1 and ERType IN ('ENGP', 'ENGC' ,'EVD') AND b.Tweek = 14
	-- AND b.PCTR IN ('OPA','OPB','PLN','PRJ','VBO')  AND  b.ScheduleGrade in ('A','B','C') AND B.OnlineReporting = 1   AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') 
	-- (AllScheduleGrade LIKE '%A%' OR AllScheduleGrade LIKE '%B%' OR AllScheduleGrade LIKE '%C%')
	and a.CurrentStatusShort in ('COM','CAN')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '5' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BA' AND b.WorkManagement = 1 and ERType IN ('ENGP', 'ENGC' ,'EVD')  AND b.Tweek = 34
	-- AND b.PCTR IN ('OPA','OPB','PLN','PRJ','VBO')  AND  b.ScheduleGrade in ('A','B','C')  AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME')  AND B.OnlineReporting = 1
	-- (AllScheduleGrade LIKE '%A%' OR AllScheduleGrade LIKE '%B%' OR AllScheduleGrade LIKE '%C%') 

 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '6' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BA' AND b.WorkManagement = 1 and ERType IN ('ENGP', 'ENGC' ,'EVD')  AND b.Tweek = 34
	-- AND b.PCTR IN ('OPA','OPB','PLN','PRJ','VBO')  AND  b.ScheduleGrade in ('A','B','C')  AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME')  AND B.OnlineReporting = 1
	-- (AllScheduleGrade LIKE '%A%' OR AllScheduleGrade LIKE '%B%' OR AllScheduleGrade LIKE '%C%') 
	and a.CurrentStatusShort in ('COM','CAN')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '7' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BB' AND b.WorkManagement = 1 and ERType IN ('ENGP', 'ENGC' ,'EVD')  AND b.Tweek = 34
	-- AND b.PCTR IN ('OPA','OPB','PLN','PRJ','VBO')  AND  b.ScheduleGrade in ('A','B','C')  AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME')  AND B.OnlineReporting = 1
	-- (AllScheduleGrade LIKE '%A%' OR AllScheduleGrade LIKE '%B%' OR AllScheduleGrade LIKE '%C%') 

 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '8' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BB' AND b.WorkManagement = 1 and ERType IN ('ENGP', 'ENGC' ,'EVD')  AND b.Tweek = 34
	-- AND b.PCTR IN ('OPA','OPB','PLN','PRJ','VBO')  AND  b.ScheduleGrade in ('A','B','C')  AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME')  AND B.OnlineReporting = 1
	-- (AllScheduleGrade LIKE '%A%' OR AllScheduleGrade LIKE '%B%' OR AllScheduleGrade LIKE '%C%') 
	and a.CurrentStatusShort in ('COM','CAN')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '9' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BA' AND ERType IN ('ENGP', 'ENGC' ,'EVD') AND b.EmergentBacklog in ('CNO', 'H')  and 
	(ERTCD >= DATEADD(Day, 2 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS date)) and ERTCD < DATEADD(DAY, 1, CAST(DATEADD(DAY, (7-DATEPART(WEEKDAY, GETDATE())), GETDATE()) AS date))) --(ERTCD >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and ERTCD < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
	
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '10' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BA' AND ERType IN ('ENGP', 'ENGC' ,'EVD') AND b.EmergentBacklog in ('CNO', 'H')  and 
	(ERTCD >= DATEADD(Day, 2 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS date)) and ERTCD < DATEADD(DAY, 1, CAST(DATEADD(DAY, (7-DATEPART(WEEKDAY, GETDATE())), GETDATE()) AS date))) --(ERTCD >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and ERTCD < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
	and a.CurrentStatusShort in ('COM','CAN')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '11' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BB' AND ERType IN ('ENGP', 'ENGC' ,'EVD') AND b.EmergentBacklog in ('CNO', 'H')  and 
	(ERTCD >= DATEADD(Day, 2 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS date)) and ERTCD < DATEADD(DAY, 1, CAST(DATEADD(DAY, (7-DATEPART(WEEKDAY, GETDATE())), GETDATE()) AS date))) --(ERTCD >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and ERTCD < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '12' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BB' AND ERType IN ('ENGP', 'ENGC' ,'EVD') AND b.EmergentBacklog in ('CNO', 'H')  and 
	(ERTCD >= DATEADD(Day, 2 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS date)) and ERTCD < DATEADD(DAY, 1, CAST(DATEADD(DAY, (7-DATEPART(WEEKDAY, GETDATE())), GETDATE()) AS date))) --(ERTCD >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and ERTCD < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
	and a.CurrentStatusShort in ('COM','CAN')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '13' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE b.WorkManagement = 1 and ERType IN ('ENGP', 'ENGC' ,'EVD')	
	AND (a.SMDueDate >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and a.SMDueDate < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
 
)


insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '14' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE b.WorkManagement = 1 and ERType IN ('ENGP', 'ENGC' ,'EVD') and 
	(a.SMDueDate >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and a.SMDueDate < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
    and a.CurrentStatusShort in ('COM','CAN', 'EXE')
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '15' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	join stng.VV_ER_StatusLog C on a.ERID = c.ERID and c.StatusShort = 'AA' and (c.StatusDate >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and c.StatusDate < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0)) 
	WHERE b.WorkManagement = 1 and ERType IN ('ENGP', 'ENGC' ,'EVD')
)


insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(
	SELECT DISTINCT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '16' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'Y' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	join stng.VV_ER_StatusLog C_AA on a.ERID = C_AA.ERID and C_AA.StatusShort = 'AA'  and (C_AA.StatusDate >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and C_AA.StatusDate < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
	join stng.VV_ER_StatusLog C_ASA on a.ERID = C_ASA.ERID and C_ASA.StatusShort = 'ASA' AND (C_ASA.StatusDate > C_AA.StatusDate)  AND (DATEDIFF(DAY, C_AA.StatusDate, C_ASA.StatusDate) - 2 * (DATEDIFF(WEEK, C_AA.StatusDate, C_ASA.StatusDate))) <=2
	WHERE b.WorkManagement = 1 and ERType IN ('ENGP', 'ENGC' ,'EVD') 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '1' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BA' AND b.WorkManagement = 0 and ERType IN ('ENGP', 'ENGC' ,'EVD') AND B.OnlineReporting = 1  AND b.Tweek = 14 AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') 
	AND  B.PCTR IN ('OPA', 'OPB', 'PLN', 'PRJ', 'VBO', 'FHA', 'FHB')  
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '2' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BA' AND b.WorkManagement = 0 and ERType IN ('ENGP', 'ENGC' ,'EVD') AND B.OnlineReporting = 1  AND b.Tweek = 14 AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') 
	AND  B.PCTR IN ('OPA', 'OPB', 'PLN', 'PRJ', 'VBO', 'FHA', 'FHB')  
	and a.CurrentStatusShort in ('COM','CAN')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '3' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BB' AND b.WorkManagement = 0 and ERType IN ('ENGP', 'ENGC' ,'EVD') AND B.OnlineReporting = 1  AND b.Tweek = 14 AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') 
	AND  B.PCTR IN ('OPA', 'OPB', 'PLN', 'PRJ', 'VBO', 'FHA', 'FHB')  
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '4' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BB' AND b.WorkManagement = 0 and ERType IN ('ENGP', 'ENGC' ,'EVD') AND B.OnlineReporting = 1  AND b.Tweek = 14 AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') 
	AND  B.PCTR IN ('OPA', 'OPB', 'PLN', 'PRJ', 'VBO', 'FHA', 'FHB')  
	and a.CurrentStatusShort in ('COM','CAN')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '5' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BA' AND b.WorkManagement = 0 and ERType IN ('ENGP', 'ENGC' ,'EVD') AND B.OnlineReporting = 1  AND b.Tweek = 34 AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') 
	AND  B.PCTR IN ('OPA', 'OPB', 'PLN', 'PRJ', 'VBO', 'FHA', 'FHB')  

 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '6' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BA' AND b.WorkManagement = 0 and ERType IN ('ENGP', 'ENGC' ,'EVD') AND B.OnlineReporting = 1  AND b.Tweek = 34 AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') 
	AND  B.PCTR IN ('OPA', 'OPB', 'PLN', 'PRJ', 'VBO', 'FHA', 'FHB')  
	and a.CurrentStatusShort in ('COM','CAN')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '7' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BB' AND b.WorkManagement = 0 and ERType IN ('ENGP', 'ENGC' ,'EVD') AND B.OnlineReporting = 1  AND b.Tweek = 34 AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') 
	AND  B.PCTR IN ('OPA', 'OPB', 'PLN', 'PRJ', 'VBO', 'FHA', 'FHB')   

 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '8' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BB' AND b.WorkManagement = 0 and ERType IN ('ENGP', 'ENGC' ,'EVD') AND B.OnlineReporting = 1  AND b.Tweek = 34 AND B.ScheduleBacklog IN ('CY', 'PP', 'EX', 'ME') 
	AND B.PCTR IN ('OPA', 'OPB', 'PLN', 'PRJ', 'VBO', 'FHA', 'FHB') 
	and a.CurrentStatusShort in ('COM','CAN')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '9' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BA' AND b.WorkManagement = 0 and ERType IN ('ENGP', 'ENGC' ,'EVD') AND B.OnlineReporting = 1  AND b.EmergentBacklog in ('CNO', 'H')  and 
	(ERTCD >= DATEADD(Day, 2 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS date)) and ERTCD < DATEADD(DAY, 1, CAST(DATEADD(DAY, (7-DATEPART(WEEKDAY, GETDATE())), GETDATE()) AS date))) --(ERTCD >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and ERTCD < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '10' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BA' AND b.WorkManagement = 0 and ERType IN ('ENGP', 'ENGC' ,'EVD') AND B.OnlineReporting = 1  AND b.EmergentBacklog in ('CNO', 'H')  and 
	(ERTCD >= DATEADD(Day, 2 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS date)) and ERTCD < DATEADD(DAY, 1, CAST(DATEADD(DAY, (7-DATEPART(WEEKDAY, GETDATE())), GETDATE()) AS date))) --(ERTCD >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and ERTCD < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
	and a.CurrentStatusShort in ('COM','CAN')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '11' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BB' AND b.WorkManagement = 0 and ERType IN ('ENGP', 'ENGC' ,'EVD') AND B.OnlineReporting = 1  AND b.EmergentBacklog in ('CNO', 'H')  and 
	(ERTCD >= DATEADD(Day, 2 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS date)) and ERTCD < DATEADD(DAY, 1, CAST(DATEADD(DAY, (7-DATEPART(WEEKDAY, GETDATE())), GETDATE()) AS date))) --(ERTCD >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and ERTCD < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '12' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE SiteID = 'BB' AND b.WorkManagement = 0 and ERType IN ('ENGP', 'ENGC' ,'EVD') AND B.OnlineReporting = 1  AND b.EmergentBacklog in ('CNO', 'H')  and 
	(ERTCD >= DATEADD(Day, 2 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS date)) and ERTCD < DATEADD(DAY, 1, CAST(DATEADD(DAY, (7-DATEPART(WEEKDAY, GETDATE())), GETDATE()) AS date))) --(ERTCD >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and ERTCD < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
	and a.CurrentStatusShort in ('COM','CAN')
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '13' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE b.WorkManagement = 0 and ERType IN ('ENGP', 'ENGC' ,'EVD') AND B.OnlineReporting = 1  and 
	(a.SMDueDate >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and a.SMDueDate < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
 
)


insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '14' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b 
	on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	WHERE b.WorkManagement = 0 and ERType IN ('ENGP', 'ENGC' ,'EVD') AND B.OnlineReporting = 1  and 
	(a.SMDueDate >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and a.SMDueDate < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
    and a.CurrentStatusShort in ('COM','CAN', 'EXE')
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)

(

	SELECT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '15' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	join stng.VV_ER_StatusLog C on a.ERID = c.ERID and c.StatusShort = 'AA' and (c.StatusDate >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and c.StatusDate < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0)) 
	WHERE b.WorkManagement = 0 and ERType IN ('ENGP', 'ENGC' ,'EVD') AND B.OnlineReporting = 1 
 
)

insert into stngetl.ER_WeeklyERSnapshot
(
	[snap_dt] 
    ,[ER]
    ,[ERID]  
    ,[SectionName]  
    ,[DepartmentName]  
	,WONUM  
	,WOHeader
    ,[KPI_ID]
	,[ERWO]
	,[MilestoneOwner]
	,[WMCriteria]
)



(

	SELECT DISTINCT cast (stng.GetBPTime(getdate()) as date) as snap_dt, A.ER, A.ERID, a.SectionName, a.DepartmentName, B.WONUM, b.WOHeader, '16' as KPI_ID, CONCAT(A.ER, '-', B.WONUM) AS ERWO, 'Station Engineering' AS MilestoneOwner, 'N' AS WMCriteria
	FROM STNG.VV_ER_Main A
	left join stngetl.ER_SupportingWOInfo b on a.ER = b.ER and b.woStatus not in ('CAN', 'COMP', 'CLOSE')
	join stng.VV_ER_StatusLog C_AA on a.ERID = C_AA.ERID and C_AA.StatusShort = 'AA'  and (C_AA.StatusDate >= DATEADD(WEEK, DATEDIFF(Week, 0, getdate()) -1, 0) and C_AA.StatusDate < DATEADD(WEEK, DATEDIFF(Week, 0, getdate()), 0))
	join stng.VV_ER_StatusLog C_ASA on a.ERID = C_ASA.ERID and C_ASA.StatusShort = 'ASA' AND (C_ASA.StatusDate > C_AA.StatusDate)  AND (DATEDIFF(DAY, C_AA.StatusDate, C_ASA.StatusDate) - 2 * (DATEDIFF(WEEK, C_AA.StatusDate, C_ASA.StatusDate))) <=2
	WHERE b.WorkManagement = 0 and ERType IN ('ENGP', 'ENGC' ,'EVD') AND B.OnlineReporting = 1 
 
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID, AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 1,
	'BA Short Range ER Milestone Adherence',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 1 AND MilestoneOwner = 'DED' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 2 AND MilestoneOwner = 'DED' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 1 AND MilestoneOwner = 'DED' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'Y',
	'DED'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 2,
	'BB Short Range ER Milestone Adherence',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 3 AND MilestoneOwner = 'DED' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 4 AND MilestoneOwner = 'DED' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 3 AND MilestoneOwner = 'DED' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'Y',
	'DED'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 3,
	'BA Long Range ER Milestone Adherence',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 5 AND MilestoneOwner = 'DED' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 6 AND MilestoneOwner = 'DED' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 5 AND MilestoneOwner = 'DED' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'Y',
	'DED'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 4,
	'BB Long Range ER Milestone Adherence',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 7 AND MilestoneOwner = 'DED' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 8 AND MilestoneOwner = 'DED' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 7 AND MilestoneOwner = 'DED' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'Y',
	'DED'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 5,
	'BA High Priority ER Execution',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 9 AND MilestoneOwner = 'DED' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 10 AND MilestoneOwner = 'DED' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 9 AND MilestoneOwner = 'DED' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'Y',
	'DED'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 6,
	'BB High Priority ER Execution',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 11 AND MilestoneOwner = 'DED' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 12 AND MilestoneOwner = 'DED' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 11 AND MilestoneOwner = 'DED' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'Y',
	'DED'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 7,
	'SM Assessment Timeliness',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 13 AND MilestoneOwner = 'DED' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 14 AND MilestoneOwner = 'DED' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 13 AND MilestoneOwner = 'DED' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'Y',
	'DED'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 8,
	'ER SPOC Assessment Timeliness',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 15 AND MilestoneOwner = 'DED' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 16 AND MilestoneOwner = 'DED' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 15 AND MilestoneOwner = 'DED' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'Y',
	'DED'
	FROM stngetl.ER_WeeklyERSnapshot
)


INSERT INTO stngetl.ER_AdherenceLog (AdherenceID, AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 1,
	'BA Short Range ER Milestone Adherence',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 1 AND MilestoneOwner = 'DED' AND WMCriteria = 'N' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 2 AND MilestoneOwner = 'DED' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 1 AND MilestoneOwner = 'DED' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'N',
	'DED'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 2,
	'BB Short Range ER Milestone Adherence',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 3 AND MilestoneOwner = 'DED' AND WMCriteria = 'N' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 4 AND MilestoneOwner = 'DED' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 3 AND MilestoneOwner = 'DED' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'N',
	'DED'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 3,
	'BA Long Range ER Milestone Adherence',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 5 AND MilestoneOwner = 'DED' AND WMCriteria = 'N' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 6 AND MilestoneOwner = 'DED' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 5 AND MilestoneOwner = 'DED' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'N',
	'DED'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 4,
	'BB Long Range ER Milestone Adherence',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 7 AND MilestoneOwner = 'DED' AND WMCriteria = 'N' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 8 AND MilestoneOwner = 'DED' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 7 AND MilestoneOwner = 'DED' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'N',
	'DED'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 5,
	'BA High Priority ER Execution',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 9 AND MilestoneOwner = 'DED' AND WMCriteria = 'N' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 10 AND MilestoneOwner = 'DED' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 9 AND MilestoneOwner = 'DED' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'N',
	'DED'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 6,
	'BB High Priority ER Execution',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 11 AND MilestoneOwner = 'DED' AND WMCriteria = 'N' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 12 AND MilestoneOwner = 'DED' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 11 AND MilestoneOwner = 'DED' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'N',
	'DED'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 7,
	'SM Assessment Timeliness',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 13 AND MilestoneOwner = 'DED' AND WMCriteria = 'N' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 14 AND MilestoneOwner = 'DED' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 13 AND MilestoneOwner = 'DED' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'N',
	'DED'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 8,
	'ER SPOC Assessment Timeliness',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 15 AND MilestoneOwner = 'DED' AND WMCriteria = 'N' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 16 AND MilestoneOwner = 'DED' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 15 AND MilestoneOwner = 'DED' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'N',
	'DED'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID, AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 1,
	'BA Short Range ER Milestone Adherence',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 1 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 2 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 1 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'Y',
	'Station Engineering'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 2,
	'BB Short Range ER Milestone Adherence',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 3 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 4 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 3 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'Y',
	'Station Engineering'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 3,
	'BA Long Range ER Milestone Adherence',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 5 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 6 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 5 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'Y',
	'Station Engineering'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 4,
	'BB Long Range ER Milestone Adherence',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 7 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 8 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 7 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'Y',
	'Station Engineering'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 5,
	'BA High Priority ER Execution',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 9 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 10 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 9 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'Y',
	'Station Engineering'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 6,
	'BB High Priority ER Execution',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 11 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 12 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 11 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'Y',
	'Station Engineering'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 7,
	'SM Assessment Timeliness',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 13 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 14 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 13 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'Y',
	'Station Engineering'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 8,
	'ER SPOC Assessment Timeliness',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 15 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 16 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 15 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'Y' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'Y',
	'Station Engineering'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID, AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 1,
	'BA Short Range ER Milestone Adherence',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 1 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'N' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 2 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 1 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'N',
	'Station Engineering'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 2,
	'BB Short Range ER Milestone Adherence',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 3 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'N' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 4 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 3 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'N',
	'Station Engineering'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 3,
	'BA Long Range ER Milestone Adherence',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 5 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'N' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 6 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 5 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'N',
	'Station Engineering'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 4,
	'BB Long Range ER Milestone Adherence',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 7 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'N' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 8 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 7 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'N',
	'Station Engineering'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 5,
	'BA High Priority ER Execution',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 9 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'N' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 10 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 9 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'N',
	'Station Engineering'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 6,
	'BB High Priority ER Execution',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 11 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'N' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 12 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 11 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'N',
	'Station Engineering'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 7,
	'SM Assessment Timeliness',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 13 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'N' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 14 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 13 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'N',
	'Station Engineering'
	FROM stngetl.ER_WeeklyERSnapshot
)

INSERT INTO stngetl.ER_AdherenceLog (AdherenceID,AdherenceName, AdherenceValue, RAD, WM, MilestoneOwner)

(
	SELECT 8,
	'ER SPOC Assessment Timeliness',
	CASE
		WHEN SUM(CASE WHEN KPI_ID = 15 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'N' THEN 1 ELSE 0 END) = 0 THEN 100
		ELSE 100.0*CAST(SUM(CASE WHEN KPI_ID = 16 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)/CAST(SUM(CASE WHEN KPI_ID = 15 AND MilestoneOwner = 'Station Engineering' AND WMCriteria = 'N' THEN 1 ELSE 0 END) AS float)
	END AS AdherenceValue,
	GETDATE(),
	'N',
	'Station Engineering'
	FROM stngetl.ER_WeeklyERSnapshot
)

end
GO


