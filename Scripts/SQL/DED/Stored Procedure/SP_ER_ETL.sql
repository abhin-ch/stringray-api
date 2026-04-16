/****** Object:  StoredProcedure [stngetl].[SP_ER_ETL]    Script Date: 11/24/2025 9:45:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [stngetl].[SP_ER_ETL]
AS
begin

	--For Tweek calculation
	declare @ThisSunday date
	select @ThisSunday = case when DATEPART(dw,GETDATE()) > 1 then DATEADD(day,-(DATEPART(dw,GETDATE())-1),GETDATE()) else GETDATE() end;

			IF OBJECT_ID('temp.ER_SupportInfo','U') is not null
				begin
					drop table temp.ER_SupportInfo
				end
				
			IF OBJECT_ID('temp.ER_SupportingWOInfo','U') is not null
				begin
					drop table temp.ER_SupportingWOInfo
				end
				
			IF OBJECT_ID('temp.RELATEDWOS','U') is not null
				begin
					drop table temp.RELATEDWOS
				end;

			with scores as
			(
				select wonum, task, 
				case when SCHEDULEBACKLOG in ('5R','H2') then 1
				when SCHEDULEBACKLOG in ('JJ') then 2
				else 0 end as Score
				from stngetl.General_AllWOTask
			),
			scorecalcs as 
			(
				select x1.WONUM, min(x1.schedulebacklog) as minbpschedulebacklog, min(x1.schedstart) as minschedstart, max(x1.schedfinish) as maxschedfinish, min(x1.wopriority) as minwopriority
				from stngetl.General_AllWOTask x1
				inner join 
				(
					select y1.WONUM, y1.TASK
					from scores y1
					inner join
					(
						select WONUM, min(score) as minscore
						from scores
						group by WONUM
					) y2 on y1.wonum = y2.WONUM and y1.score = y2.minscore
				) x2 on x1.wonum = x2.wonum and x1.TASK = x2.TASK
				where x1.TASKSTATUS not in ('COMP','CAN','CLOSE')
				group by x1.WONUM
			),
			mintasks as 
			(
				select p.WONUM, p.schedulebacklog, p.schedstart, p.schedfinish, p.wopriority
				from stngetl.General_AllWOTask as p
				inner join
				(
					select x.wonum, min(task) as WOTask
					from stngetl.General_AllWOTask x  
					inner join 
					(
						select wonum, min(schedstart) as minschedstart
						from stngetl.General_AllWOTask
						where taskstatus not in ('COMP','CAN','CLOSE')
						group by wonum
					) y on x.WONUM = y.WONUM and x.schedstart = y.minschedstart
					where x.WOSTATUS not in ('COMP','CAN','CLOSE')
					group by x.WONUM
				) z on p.WONUM = z.WONUM and p.TASK = z.wotask
			),
			wocspv as
			(
				select distinct a.WOHEADER, a.wonum, a.facility, a.eq_component_tag,
				case when b.CSPV is null then 0 else b.CSPV end as CSPV
				from stngetl.General_WOByEndUse as a
				left join stngetl.IQT_MEL as b on a.EQ_COMPONENT_TAG = b.LOCATION and a.FACILITY = b.SITEID
				where a.EQ_COMPONENT_TAG is not null
			),
			maxcspv as
			(
				select WOHeader, facility, max(CSPV) as CSPV
				from wocspv
				group by WOHEADER, FACILITY
			)

			select *
			into temp.RELATEDWOS
			from
			(
				select distinct a.ER, a.WONUM, a.WOSITEID as siteid, b.WONUM as WOHeader, b.SCHEDULEBACKLOG as bpschedulebacklog, b.BPSCHEDGRADE, b.SCHEDSTART, b.SCHEDFINISH, b.WORKTYPE,
				b.TASKTITLE as description, b.BPPLANNINGCTR, e.BPPLANNINGCTR as WOHeaderPCTR, b.BPWOGROUP as WOGroup, b.WOPRIORITY, b.REPORTDATE, b.TASKSTATUS as status, b.LOCATION,
				b.OUTAGE as plusoutagecode,
				b.PLUSWORKCAT, b.PROJECTID, c.REPORTDATE as permitreportdate, a.CLASSSTRUCTUREID, b.HASFLSPEC, b.haswaspec,
				case when d.cspv is null then 0 else d.CSPV end as CSPV
				from stngetl.ER_RelatedWO as a
				inner join stngetl.General_AllWOTask as b on a.WONUM = b.TASK
				inner join stngetl.ER_Import as c on a.ER = c.TICKETID
				left join wocspv as d on a.wonum = d.wonum and a.wositeid = d.FACILITY
				left join stngetl.General_AllWO as e on b.WONUM = e.WONUM
				where a.WOTYPE = 'Task'
				union
				select distinct a.ER, a.WONUM, a.WOSITEID as siteid, a.WONUM as WOHeader, 
				case when b.minbpschedulebacklog is not null then b.minbpschedulebacklog else c.schedulebacklog end as bpschedulebacklog, 
				d.BPSCHEDGRADE,
				case when b.minschedstart is not null then b.minschedstart else c.schedstart end as schedstart,
				case when b.maxschedfinish is not null then b.maxschedfinish  else c.schedfinish end as schedfinish, 
				d.wotype as worktype, d.WODESC as description, d.BPPLANNINGCTR, d.BPPLANNINGCTR as WOHeaderPCTR, d.bpwogroup as WOGroup,
				d.wopriority,
				d.reportdate, d.WOSTATUS as status, d.location, 
				d.OUTAGE as plusoutagecode, 
				d.plusworkcat, d.projectid, e.reportdate as permitreportdate, a.classstructureid,
				case when a.wotype = 'Header' then d.HasFLSpec else g.HASFLSPEC end as HasFLSpec, 
				d.haswaspec,
				case when f.cspv is null then 0 else f.CSPV end as CSPV
				from stngetl.ER_RelatedWO as a
				inner join stngetl.General_AllWO as d on a.WONUM = d.WONUM
				inner join stngetl.ER_Import as e on a.ER = e.TICKETID
				left join scorecalcs as b on a.WONUM = b.WONUM
				left join mintasks c on a.WONUM = c.WONUM
				left join maxcspv as f on a.wonum = f.woheader and a.wositeid = f.FACILITY
				left join stngetl.General_AllWOTask as g on a.wonum = g.TASK
				where a.WOTYPE = 'Header'
			) as x;

			--Drop temp schema ER_SupportInfo and ER_SupportWO if they exist
			IF OBJECT_ID('temp.ER_SupportInfo','U') is not null
				drop table temp.ER_SupportInfo;

			IF OBJECT_ID('temp.ER_SupportingWOInfo','U') is not null
				drop table temp.ER_SupportingWOInfo;

			--Insert new ERs into General_AllER
			insert into stngetl.General_AllER
			(ER)
			select distinct a.TicketID
			from stngetl.ER_Import as a
			inner join stngetl.ER_TicketSpec as b on a.TICKETID = b.TICKETID
			where a.TICKETID not in
			(
				select distinct ER 
				from stngetl.General_AllER
			)
			union
			select x1.TICKETID
			from stngetl.ER_Import as x1
			where x1.classstructureid in ('1532','1533','1252') and x1.TICKETID not in (select distinct ER from stngetl.General_AllER);

			--Update stngetl.ER_OutageMilestones with stngetl.Milestone
			insert into stngetl.ER_OutageMilestones
			(Outage,OutageMilestone,MilestoneTCD)
			select distinct Outage, OutageMilestone, MilestoneTCD
			from stngetl.ER_Milestone
			where concat(Outage,'-',OutageMilestone) not in (select distinct CONCAT(Outage,'-',OutageMilestone) from stngetl.ER_OutageMilestones);

			update a
			set MilestoneTCD = b.MilestoneTCD
			from stngetl.ER_OutageMilestones as a
			inner join (
				SELECT  [OUTAGE]
				  ,[OUTAGEMILESTONE]
				  ,max([MILESTONETCD]) as MILESTONETCD
			  FROM [stngetl].[ER_Milestone]
			  group by [OUTAGE] ,[OUTAGEMILESTONE]
			 ) as b on CONCAT(a.outage,'-',a.outagemilestone) = CONCAT(b.outage,'-',b.outagemilestone);

			--update stngetl.ER_OutageMilestones
			--set MilestoneTCD = b.MilestoneTCD
			--from stngetl.ER_OutageMilestones as a
			--inner join stngetl.ER_Milestone as b on CONCAT(a.outage,'-',a.outagemilestone) = concat(b.outage,'-',b.outagemilestone);

			--Create temp ER_SupportingWOInfo			
			select distinct WOs_2.ER, WOs_2.WONUM, WOs_2.WOHeader, WOs_2.ExecDate, WOs_2.PMER, WOs_2.WOType, WOs_2.WOTitle, WOs_2.WOGroup, WOs_2.PCTR, WOs_2.WOHeaderPCTR, WOs_2.ScheduleBacklog, WOs_2.ScheduleGrade, WOs_2.WOStatus, WOs_2.OnlineReporting,
			WOs_2.Tweek, WOs_2.OperatorChallenge, WOs_2.WOOriginDate, WOs_2.WOAge, WOs_2.WOPRIORITY, WOs_2.Outage, WOs_2.OutageStart, WOs_2.OutageEnd, WOs_2.HighPriority, 
			WOs_2.LowPriority, WOs_2.OutageRank, WOs_2.CNOPriority,
			case when WOs_2.HighPriority = 1 then 'H' when WOs_2.LowPriority = 1 then 'L' else 'N' end as EmergentBacklog, 
			case when WOs_2.CNOPriority = 1 then 'CNO' when WOs_2.HighPriority = 1 then 'H' when WOs_2.LowPriority = 1 then 'L' else 'N' end as EmergentBacklogRender,
			WOs_2.PHCFlag, WOs_2.Projectid,
			case when WOs_2.WOStatus not in ('COMP','CAN','CLOSE') and WOs_2.Outage is not null and M05.MilestoneTCD is not null then M05.MilestoneTCD end as M05TCD,
			case when WOs_2.WOStatus not in ('COMP','CAN','CLOSE') and WOs_2.Outage is not null and M16.MilestoneTCD is not null then M16.MilestoneTCD end as M16TCD,
			cast(case when WOs_2.WONUM in ('02019068') and WOs_2.classstructureid = '1255' then 1 else 0 end as bit) as InventoryWO,
			case 
				--when WOs_2.CriticalSpareProject = 1 then 1 
				when MCR6.MCROutage is not null then 2 
				when MCR3.MCROutage is not null then 3
				when MCR4.MCROutage is not null then 4
				when permitproj.ProjectRank is not null then permitproj.ProjectRank
				else 13
			end as ProjectRank,
			case when WOs_2.WOStatus in ('CAN','WCANCEL') then 1 else 0 end as CanceledWO
			,case when 
				WOs_2.OnlineReporting = 1 
				and WOs_2.PCTR in ('OPA', 'OPB', 'PLN', 'PRJ', 'VBO') --not FHA, FHB
				and WOs_2.WOHeaderPCTR in ('OPA', 'OPB', 'PLN', 'PRJ', 'VBO') --not FHA, FHB
				and WOs_2.ScheduleBacklog in ('CY', 'ME', 'PP', 'EX') 
				and WOs_2.ScheduleGrade in ('A', 'B', 'C') 
					then 1 
					else 0 
			end as WorkManagement
			into temp.ER_SupportingWOInfo
			from
				(select distinct WOs_1.*,
				case when @ThisSunday > WOs_1.ExecWeekStart then null else DATEDIFF(week,@ThisSunday, WOs_1.ExecWeekStart) end as Tweek,
				cast(
					case when 
							(WOs_1.WorkCategory not in ('MAJEVOL','PROJECT') or WOs_1.WorkCategory is null) 
							and WOs_1.WOStatus not in ('COMP','CAN','CLOSE') 
							and WOs_1.PCTR in ('FHA','FHB','OPA','OPB') 
							and WOs_1.ScheduleBacklog in ('5R','H2')
							and (WOs_1.OperatorChallenge = 1 or WOs_1.WOPriority in ('1','2') or WOs_1.WOType in('DC','CC','CN','DN') or WOs_1.hasflspec = 1) 
						then 1 
						else 0 
					end 
				as smallint) as HighPriority,

				--Check if 5R/H2 Schedule Backlog logic from HighPriority above is relevant for CNOPriority
				cast(
					case when 
							(WOs_1.WorkCategory not in ('MAJEVOL','PROJECT') or WOs_1.WorkCategory is null) 
							and WOs_1.WOStatus not in ('COMP','CAN','CLOSE') 
							and WOs_1.PCTR in ('FHA','FHB','OPA','OPB') 
							and WOs_1.outage is null 
							and
							(WOs_1.WOType in ('DC','CC')							
							or WOs_1.HasWASpec = 1)
						then 1 
						else 0 
					end 	
				as smallint) as CNOPriority,
				cast(0 as smallint) as LowPriority
				from
					(select distinct a.ER, b.classstructureid,
					b.DESCRIPTION as WOTitle, b.WOPRIORITY, b.WONUM, b.WOHeader, b.WOHeaderPCTR, b.SiteID, b.BPPLANNINGCTR as PCTR, b.WOGroup, b.WORKTYPE as WOType, b.STATUS as WOStatus, b.SCHEDSTART as ExecDate, 
					b.BPSCHEDULEBACKLOG as ScheduleBacklog, b.bpschedgrade as ScheduleGrade, b.Reportdate as WOOriginDate, h.OutageRank, b.plusoutagecode as Outage, h.bpstartdate as OutageStart, h.bpenddate as OutageEnd,
					cast(case when b.WORKTYPE in ('PM','SUR') then 1 else 0 end as smallint) as PMER, b.plusworkcat as WorkCategory,
					case when b.bpschedulebacklog in ('EX','CY','PP','ME') and b.siteid in ('BA','BB') and b.BPPLANNINGCTR in ('FHA','FHB', 'OPA','OPB', 'PLN', 'SCO', 'VBO') then 1 else 0 end as OnlineReporting, --might PRJ as planning center if we find discrepencies
					DATEDIFF(day,b.REPORTDATE, GETDATE()) as WOAge,
					b.hasflspec, b.haswaspec, b.cspv,
					cast(case when e.wonum is not null then 1 else 0 end as smallint) as OperatorChallenge,
					cast(case when j.wonum is not null then 1 else 0 end as smallint) as PHCFlag,
					case when DATEPART(dw,b.SCHEDSTART) > 1 then DATEADD(day,-(DATEPART(dw,b.SCHEDSTART)-1),b.SCHEDSTART) else b.SCHEDSTART end as ExecWeekStart,
					b.projectid
					from 
						stngetl.General_AllER as a
						left join temp.RELATEDWOS as b on a.ER = b.ER
						left join stngetl.ER_OperatorChallenge as e on b.WONUM = e.wonum
						left join stngetl.ER_PHCWO as j on b.wonum = j.wonum
						left join stngetl.General_Outage as h on h.bpoutagecode = b.PLUSOUTAGECODE
					--where a.Passport is null or a.Passport = 0
					) as WOs_1
				) as WOs_2
				left join stng.ER_MCROutages as MCR3 on MCR3.MCROutage = WOs_2.Outage and MCR3.MCRCategory = 'MCR3'
				left join stng.ER_MCROutages as MCR6 on MCR6.MCROutage = WOs_2.Outage and MCR6.MCRCategory = 'MCR6'
				left join stng.ER_MCROutages as MCR4 on MCR4.MCROutage = WOs_2.Outage and MCR4.MCRCategory = 'MCR4'
				left join stngetl.ER_Projects as permitproj on WOs_2.Outage = permitproj.PriorityDesc
				left join stngetl.ER_OutageMilestones as M16 on WOs_2.Outage = M16.Outage and M16.OutageMilestone = '16'
				left join stngetl.ER_OutageMilestones as M05 on WOs_2.Outage = M05.Outage and M05.OutageMilestone = '05';

				--Tweek calculations
				if OBJECT_ID('temp.ERTweekCalcs','U') is not null drop table temp.ERTweekCalcs;

				with scoremapping as
				(
					select *
					from
					(
						values
						(0,'Regular'),
						(1,'FIN/Corr'),
						(2,'JJ')
					) as x(Score,Def)
				),
				initialquery as
				(
					select ER, Tweek,
					case when WOStatus in ('CAN','COMP','CLOSE') or ScheduleBacklog in ('JJ','5R','H2') then 1 else 0 end as ExemptinNumeric,
					case when WOStatus not in ('CAN') then
						case when ScheduleBacklog in ('5R','H2') then 1
						when ScheduleBacklog in ('JJ') then 2
						else 0 
						end
					end as Score
					from temp.ER_SupportingWOInfo
					where wonum is not null
				),
				minscores as 
				(
					select ER, min(Score) as minscore
					from initialquery
					group by ER	
				),
				mintweeks as 
				(
					select a.ER, min(Tweek) as TweekCalc
					from initialquery as a
					inner join minscores as b on a.ER = b.ER and a.Score = b.minscore
					where a.ExemptinNumeric = 0
					group by a.ER
				),
				secondquery as 
				(
					select distinct a.ER, d.TweekCalc,
					c.Def as TweekRender
					from initialquery as a
					left join minscores as b on a.ER = b.ER
					left join scoremapping as c on b.minscore = c.Score
					left join mintweeks as d on a.ER = d.ER
				)

				select *
				into temp.ERTweekCalcs
				from secondquery;

				--Aggregate temp TT_0009; join to PERMITIMPORT and union with historical PP info to get temp TT_0008 (Without CPID)
				with WODueDateTypes as
				(
					select distinct WO.ER, WO.WONUM, 
					case 
						when WO.Outage is not null and WO.ExecDate is not null and outage.BPSTARTDATE > wo.ExecDate then 'PREREQ'
						when WO.Outage is not null then 'Outage'
						else 'Online'
					end as WODueDateType
					from temp.ER_SupportingWOInfo as WO
					left join stngetl.General_Outage as outage on wo.outage = outage.bpoutagecode
					where wo.WOStatus not in ('COMP','CAN','CLOSE')
				),
				WOCounts as
				(
					select distinct a.ER, b.countwo as CountOutage, c.countwo as CountOnline, d.countwo as CountPREREQ
					from WODueDateTypes as a
					left join
					(
						select ER, count(WONUM) as countwo
						from WODueDateTypes
						where WODueDateType = 'Outage'
						group by ER
					) as b on a.ER = b.ER
					left join
					(
						select ER, count(WONUM) as countwo
						from WODueDateTypes
						where WODueDateType = 'Online'
						group by ER
					) as c on a.ER = c.ER
					left join
					(
						select ER, count(WONUM) as countwo
						from WODueDateTypes
						where WODueDateType = 'PREREQ'
						group by ER
					) as d on a.ER = d.ER
				),
				Permits_1 as 
				(
					select ER, min(WOPriority) as WOPriority, max(PMER) as PMER, min(ExecDate) as MinExecDate, min(Tweek) as Tweek, min(OutageRank) as OutageRank, max(OnlineReporting) as OnlineReporting,
					max(CNOPriority) as CNOPriority,
					max(HighPriority) as HighPriority, case when max(HighPriority) = 0 then max(LowPriority) else 0 end as LowPriority, min(ProjectRank) as ProjectRank, max(PHCFlag) as PHCFlag,
					min(WOAge) as EarliestWOAge, max(cast(InventoryWO as tinyint)) as InventoryWO, max(cast(CanceledWO as tinyint)) as CanceledWO
					from
						temp.ER_SupportingWOInfo
					--where WOStatus not in ('COMP','CAN','CANCELED','CLOSE')
					group by ER
				)
				
				select distinct ER, ERTitle, AssignedTo, Facility, RSE, RDE, EPT, RCE, Location, USI, SYSTEMDESC, EQUIPMENTTYPE, FinishDate, itemnum,
				ERType
				, AssignedGroup
				, ERStatus, StatusDate as ERStatusDate, WOPriority, OnlineReporting, ProjectID, PMER, MinExecDate, Tweek, TweekCalc, TweekRender, ERDueDate,
				InventoryWO, cast(CanceledWO as bit) as AllCanceledWO, projectrank,
				case when DueDateType <> 'Outage' then EmergentBacklog else 'N' end as EmergentBacklog,
				EmergentBacklogRender,
				OutageStart, CritCat, MaximoTCD, OrigDate,
				ERAge, Outage, DueDateType, Initiator
				, InitiatedWorkGroup
				, ERComments, PHCFlag, EarliestWOAge
				into temp.ER_SupportInfo
				from
					(select distinct Permits_1.ER, P.Description as ERTitle, P.REPORTEDBY as AssignedTo, P.SITEID as Facility, P.itemnum,
					P.Location, MEL.rse, mel.RDE, MEL.ept, MEL.RCE, MEL.USI, USI.USIDESC as SYSTEMDESC, MEL.EQUIPMENTTYPE, cast(Permits_1.InventoryWO as bit) as InventoryWO,
					P.finishdate, p.statusdate, permits_1.projectrank,
					case when T.ALNVALUE is null then C.CLASSIFICATIONID else T.ALNVALUE end as ERType, 
					PER2.WorkGroup as AssignedGroup, 
					P.STATUS as ERStatus, Permits_1.WOPriority, 
					cast(case when Permits_1.OnlineReporting = 1 and P.SITEID in ('BA','BB') and c.CLASSSTRUCTUREID in ('1255') and (T.ALNVALUE is null or T.ALNVALUE not in ('WLD')) then 1 else 0 end as bit) as OnlineReporting, 
					--case when P.STATUS in ('COMP','CLOSED','CANCEL','CANCELED') and year(P.STATUSDATE) = 2020 and ProjObsol.ProjectID is not null 
						--then ProjObsol.ProjectID 
					--when Proj.ProjectID = '10960' and P.STATUS in ('COMP','CLOSED','CANCEL','CANCELED') and P.finishdate < DATEFROMPARTS(2022,12,1) 
						--then 'POTG-MAINT-10910'
					--else 
						Proj.ProjectID,
					--end as ProjectID, 
					Permits_1.PMER, Permits_1.MinExecDate, Permits_1.Tweek, tw.TweekCalc, tw.TweekRender,
					case
						when Permits_1.OnlineReporting = 1 and d.NewMinExecDate is not null then
							case 
								when DATEDIFF(WEEK, @ThisSunday, d.NewMinExecDate) >= 40 and t.ALNVALUE in ('ENCD','ENGD','ENGS','MJT','EQ') then DATEADD(WEEK, -36, d.NewMinExecDate)  -- ENCD/ENGD/ENGS/MJT/EQ
								when DATEDIFF(WEEK, @ThisSunday, d.NewMinExecDate) >= 40 and t.ALNVALUE in ('ENGP','ENGC','EVD') then DATEADD(WEEK, -34, d.NewMinExecDate)  -- ENGP/ENGC/EVD
								when DATEDIFF(WEEK, @ThisSunday, d.NewMinExecDate) < 40 then  DATEADD(WEEK, -14, d.NewMinExecDate)  -- All types
								--when Permits_1.PMER = 1 and tw.TweekCalc >= 26 then DATEADD(day,6 + (tw.TweekCalc - 26)*7,@ThisSunday)
								--else DATEADD(day,6 + (tw.TweekCalc - 14)*7,@ThisSunday) 
							end
						when Permits_1.OnlineReporting = 1 then e.ERDueDate
						when P.reportdate > M05.MilestoneTCD and P.reportdate > dateadd(w,-6,M16.MilestoneTCD) then O.BPSTARTDATE
						when P.reportdate > m05.MilestoneTCD and P.reportdate <= dateadd(w,-6,m16.MilestoneTCD) then M16.MilestoneTCD 	
						when P.reportdate <= M05.MilestoneTCD then DATEADD(m,-2,m16.MilestoneTCD)
						when tw.TweekCalc is not null then
						case 
							when Permits_1.PMER = 1 and tw.TweekCalc >= 26 then DATEADD(day,6 + (tw.TweekCalc - 26)*7,@ThisSunday)
							else DATEADD(day,6 + (tw.TweekCalc - 14)*7,@ThisSunday) 
						end
					end as ERDueDate,			
					Permits_1.PHCFlag, Permits_1.EarliestWOAge, Permits_1.CanceledWO,
					case when Permits_1.HighPriority = 1 then 'H' when Permits_1.LowPriority = 1 then 'L' else 'N' end as EmergentBacklog, 
					case when Permits_1.CNOPriority = 1 then 'CNO' when Permits_1.HighPriority = 1 then 'H' when Permits_1.LowPriority = 1 then 'L' else 'N' end as EmergentBacklogRender, 
					O.bpstartdate as OutageStart, P.bpcritcat as CritCat, P.targetfinish as MaximoTCD, P.REPORTDATE as OrigDate, DATEDIFF(day, P.REPORTDATE, GETDATE()) as ERAge, O.BPOUTAGECODE as Outage,
					case 
						when counts.CountOnline > 0 and counts.CountOutage > 0 and counts.CountPREREQ > 0 then 'Outage/Online/PREREQ' 
						when counts.CountOnline > 0 and counts.CountOutage > 0 and (counts.CountPREREQ = 0 or counts.CountPREREQ is null) then 'Outage/Online'
						when (counts.CountOnline = 0 or counts.CountOnline is null) and counts.CountOutage > 0  and (counts.CountPREREQ = 0 or counts.CountPREREQ is null) then 'Outage'
						when (counts.CountOnline = 0 or counts.CountOnline is null) and (counts.CountOutage = 0 or counts.CountOutage is null) and counts.CountPREREQ > 0  then 'PREREQ'
						when counts.CountOnline > 0 and (counts.CountOutage = 0 or counts.CountOutage is null) and counts.CountPREREQ > 0  then 'Online/PREREQ'
						when (counts.CountOnline = 0 or counts.CountOnline is null) and counts.CountOutage > 0 and counts.CountPREREQ > 0  then 'Outage/PREREQ'
						when Permits_1.WOPriority is not null then 'Online'
					end as DueDateType, 
					P.REPORTEDBY as Initiator
					, PER.WorkGroup as InitiatedWorkGroup
					,P.ldtext as ERComments
					from Permits_1
					left join wocounts as counts on Permits_1.ER = counts.ER
					left join temp.ERTweekCalcs as tw on Permits_1.ER = tw.ER
					left join stngetl.ER_Projects as Proj on Permits_1.ProjectRank = Proj.ProjectRank
					left join stngetl.ER_Import as P on Permits_1.ER = P.TICKETID
					left join stng.VV_Admin_UserView as PER on P.REPORTEDBY = PER.EmployeeID
					left join stng.VV_Admin_UserView as PER2 on P.[OWNER] = PER2.EmployeeID
					left join stngetl.ER_TicketSpec as T on Permits_1.ER = t.TICKETID
					left join stngetl.General_Outage as O on Permits_1.OutageRank = O.OutageRank
					left join stngetl.General_ClassStructure as C on P.Classstructureid = C.CLASSSTRUCTUREID
					left join stngetl.ER_PRMEL as MEL on P.Location = MEL.EQ_COMPONENT_TAG and P.SITEID = MEL.FACILITY
					left join stngetl.General_AllUSI as USI on MEL.USI = USI.USI
					left join stngetl.ER_OutageMilestones as M16 on O.BPOUTAGECODE = M16.Outage and M16.OutageMilestone = '16'
					left join stngetl.ER_OutageMilestones as M05 on O.BPOUTAGECODE = M05.Outage and M05.OutageMilestone = '05'
					left join (
						SELECT a.ER, a.MinExecDate as NewMinExecDate, b.MinExecDate as PrevMinExecDate
						FROM Permits_1 as a
						left join stngetl.ER_SupportInfo as b on a.ER = b.ER
						where a.MinExecDate <> b.MinExecDate or b.ERDueDate is null
					) as d on Permits_1.ER = d.ER
					left join stngetl.ER_SupportInfo as e on Permits_1.ER = e.ER
				) as FINAL;

			--Working new ER table
			declare @NewERs as table
			(
				ER varchar(50) not null
			);

			insert into @NewERs
			(ER)
			select distinct a.ER
			from stngetl.General_AllER as a
			left join stng.ER_Main as b on a.ER = b.ER
			where b.ER is null;

			--insert New ER into ER_Main
			INSERT INTO stng.ER_Main
			(ER,CurrentStatus,RAD,RAB,LUB,LUD)
			SELECT a.ER, b.UniqueID, GETDATE(), 'SYSTEM' , 'SYSTEM', GETDATE()
			from @NewERs as a
			left join stng.ER_Status as b on b.StatusShort = 'AA';

			----Add new ER AA Due Dates
			--insert into ENG_IM.dems.TT_0858_CPAADueDates
			--(CPID, AADueDate, RAD, RAB)
			--select b.CPID, DATEADD(day,2,cast(getdate() as date)), GETDATE(), 'SYSTEM'
			--from @NewERs as a
			--inner join stng.ER_Main as b on a.ER = b.ER
			--inner join stngetl.ER_SupportInfo as c on a.ER = c.ER
			--left join PBI.ERMetricsAutomation_PO18 as d on c.Outage = d.Outage
			--where 
			--(
			--	(c.DueDateType not like '%Outage%' and c.TweekCalc <= 52 and c.TweekCalc >= 0 and c.PermitType in ('ENCD','ENGD','MJT','EVD','ENGC','ENGP','EQ','ENGS'))
			--	or
			--	(c.DueDateType like '%Outage%' and cast(getdate() as date) >= cast(d.PO18 as date) and c.PermitType in ('ENCD','ENGD','MJT','EQ','ENGS'))
			--);
		
			--Add index to temp SupportingWOs
			create nonclustered index temp_ER_SupportingWOInfoWONUM on temp.ER_SupportingWOInfo (WONUM);

			--Track changes to select ER/WO fields
			
			--ER Emergent Backlog
			insert into stng.ER_FieldChangeLog
			(ERID, FieldName, ChangedFromStr, ChangedToStr, RAD, RAB)
			select distinct a.UniqueID, 'Emergent Backlog', c.EmergentBacklog, b.EmergentBacklog, GETDATE(), 'SYSTEM'
			from stng.ER_Main as a 
			inner join temp.ER_SupportInfo as b on a.ER = b.ER
			left join stngetl.ER_SupportInfo as c on b.ER = c.ER
			where c.EmergentBacklog <> b.EmergentBacklog or (c.emergentbacklog is null and b.EmergentBacklog is not null) or (b.emergentbacklog is null and c.EmergentBacklog is not null);

			----ER Status
			insert into stng.[ER_FieldChangeLog]
			(ERID, FieldName, ChangedFromStr, ChangedToStr, RAD, RAB)
			select distinct a.UniqueID, 'ER Status', c.ERStatus, b.ERStatus, GETDATE(), 'SYSTEM'
			from stng.ER_Main as a 
			inner join temp.ER_SupportInfo as b on a.ER = b.ER
			left join stngetl.ER_SupportInfo as c on b.ER = c.ER
			where c.ERStatus <> b.ERStatus or (c.ERStatus is null and b.ERStatus is not null) or (b.ERStatus is null and c.ERStatus is not null);

			----ER AssignedTo
			insert into stng.[ER_FieldChangeLog]
			(ERID, FieldName, ChangedFromStr, ChangedToStr, RAD, RAB)
			select distinct a.UniqueID, 'Assigned To', c.AssignedTo, b.AssignedTo, GETDATE(), 'SYSTEM'
			from stng.ER_Main as a 
			inner join temp.ER_SupportInfo as b on a.ER = b.ER
			left join stngetl.ER_SupportInfo as c on b.ER = c.ER
			where c.assignedto <> b.assignedto or (c.assignedto is null and b.assignedto is not null) or (b.assignedto is null and c.assignedto is not null);

			--ER AssignedGroup
			insert into stng.[ER_FieldChangeLog]
			(ERID, FieldName, ChangedFromStr, ChangedToStr, RAD, RAB)
			select distinct a.UniqueID, 'Assigned Group', c.AssignedGroup, b.AssignedGroup, GETDATE(), 'SYSTEM'
			from stng.ER_Main as a 
			inner join temp.ER_SupportInfo as b on a.ER = b.ER
			left join stngetl.ER_SupportInfo as c on b.ER = c.ER
			where c.assignedgroup <> b.assignedgroup or (c.assignedgroup is null and b.assignedgroup is not null) or (b.assignedgroup is null and c.assignedgroup is not null);

			--ER Type
			insert into stng.[ER_FieldChangeLog]
			(ERID, FieldName, ChangedFromStr, ChangedToStr, RAD, RAB)
			select distinct a.UniqueID, 'ER Type', c.ERType, b.ERType, GETDATE(), 'SYSTEM'
			from stng.ER_Main as a 
			inner join temp.ER_SupportInfo as b on a.ER = b.ER
			left join stngetl.ER_SupportInfo as c on b.ER = c.ER
			where c.ERType <> b.ERType or (c.ERType is null and b.ERType is not null) or (b.ERType is null and c.ERType is not null);

			----ER Tweek
			insert into stng.[ER_FieldChangeLog]
			(ERID, FieldName, ChangedFromStr, ChangedToStr, RAD, RAB)
			select distinct a.UniqueID, 'Tweek', c.TweekCalc, b.TweekCalc, GETDATE(), 'SYSTEM'
			from stng.ER_Main as a 
			inner join temp.ER_SupportInfo as b on a.ER = b.ER
			left join stngetl.ER_SupportInfo as c on b.ER = c.ER
			where c.TweekCalc <> b.TweekCalc or (c.TweekCalc is null and b.TweekCalc is not null) or (b.TweekCalc is null and c.TweekCalc is not null);

			--WO Outage
			insert into stngetl.ER_WOFieldChanges
			(WONum, FieldName, ChangedFrom, ChangedTo, RAD, RAB)
			select distinct a.WONum, 'Outage', b.Outage, a.Outage, GETDATE(), 'SYSTEM'
			from temp.ER_SupportingWOInfo as a
			left join stngetl.ER_SupportingWOInfo as b on a.WONUM = b.wonum
			where a.outage <> b.outage or (a.outage is null and b.outage is not null) or (b.outage is null and a.outage is not null) and a.wonum is not null;

			----WO Priority
			insert into stngetl.ER_WOFieldChanges
			(WONum, FieldName, ChangedFrom, ChangedTo, RAD, RAB)
			select distinct a.WONum, 'WO Priority', b.wopriority, a.WOPriority, GETDATE(), 'SYSTEM'
			from temp.ER_SupportingWOInfo as a
			left join stngetl.ER_SupportingWOInfo as b on a.WONUM = b.wonum
			where a.wopriority <> b.wopriority or (a.wopriority is null and b.wopriority is not null) or (b.wopriority is null and a.wopriority is not null) and a.wonum is not null;

			----WO Type
			insert into stngetl.ER_WOFieldChanges
			(WONum, FieldName, ChangedFrom, ChangedTo, RAD, RAB)
			select distinct a.WONum, 'WO Type', b.wotype, a.WOtype, GETDATE(), 'SYSTEM'
			from temp.ER_SupportingWOInfo as a
			left join stngetl.ER_SupportingWOInfo as b on a.WONUM = b.wonum
			where a.wotype <> b.wotype or (a.wotype is null and b.wotype is not null) or (b.wotype is null and a.wotype is not null) and a.wonum is not null;

			----WO Emergent Backlog
			insert into stngetl.ER_WOFieldChanges
			(WONum, FieldName, ChangedFrom, ChangedTo, RAD, RAB)
			select distinct a.WONum, 'Emergent Backlog', b.EmergentBacklog, a.EmergentBacklog, GETDATE(), 'SYSTEM'
			from temp.ER_SupportingWOInfo as a
			left join stngetl.ER_SupportingWOInfo as b on a.WONUM = b.wonum
			where a.emergentbacklog <> b.emergentbacklog or (a.emergentbacklog is null and b.emergentbacklog is not null) or (b.emergentbacklog is null and a.emergentbacklog is not null) and a.wonum is not null;

			----WO ExecDate
			insert into stngetl.ER_WOFieldChanges
			(WONum, FieldName, ChangedFrom, ChangedTo, RAD, RAB)
			select distinct a.WONum, 'Exec Date',convert(varchar, b.execdate, 106) , convert(varchar, a.execdate, 106) , GETDATE(), 'SYSTEM'
			from temp.ER_SupportingWOInfo as a
			left join stngetl.ER_SupportingWOInfo as b on a.WONUM = b.wonum
			where a.execdate <> b.execdate or (a.execdate is null and b.execdate is not null) or (b.execdate is null and a.execdate is not null) and a.wonum is not null;
			
			----Linkage Snaps

			----WO Linkage Date/Tweek
			with newwos as
			(
				select distinct a.ER, a.wonum, a.Tweek
				from temp.ER_SupportingWOInfo as a
				left join stngetl.ER_SupportingWOInfo as b on a.ER = b.ER and a.wonum = b.WONUM
				where b.ER is null and a.WONUM is not null
			)

			insert into stngetl.ER_WOLinkageChanges
			(ERID, WONUM, LinkageItem, NumValueER, NumValueWO, RAD)
			select a.UniqueID, b.wonum, N'WO Linkage to ER Tweek', c.Tweek, b.Tweek, GETDATE()
			from stng.ER_Main as a
			inner join newwos as b on a.ER = b.ER
			inner join temp.ER_SupportInfo as c on b.ER = c.ER;

			--ERs on Parent WOs
			insert into stng.ER_Snaps
			(SnapName, ERID, SnapDate)
			select distinct N'ERs on Parent WOs', b.UniqueID, getdate()
			from temp.ER_SupportingWOInfo as a
			inner join stng.ER_Main as b on a.ER = b.ER
			where a.WONUM = a.WOHeader;

			--ERs on Cancelled WOs
			insert into stng.ER_Snaps
			(SnapName, ERID, SnapDate)
			select distinct N'ERs on Canceled WOs', b.UniqueID, getdate()
			from temp.ER_SupportingWOInfo as a
			inner join stng.ER_Main as b on a.ER = b.ER
			where a.WOStatus = 'CAN';

			--ERs at Draft Status
			insert into stng.ER_Snaps
			(SnapName, ERID, SnapDate)
			select distinct N'ERs at DRAFT Status', b.UniqueID, getdate()
			from temp.ER_SupportInfo as a
			inner join stng.ER_Main as b on a.ER = b.ER
			where a.ERStatus = 'DRAFT';

			--ERs at Assessment with a TCD
			insert into stng.ER_Snaps
			(SnapName, ERID, SnapDate)
			select distinct N'ERs at Assessment with TCD', ERID, getdate()
			from stng.VV_ER_Main 
			where CurrentStatusShort in ('AA','ASA') and ERTCD is not null;

			--Drop ER_SupportInfo and ER_SupportWO
			IF OBJECT_ID('stngetl.ER_SupportInfo','U') is not null
				drop table stngetl.ER_SupportInfo;

			IF OBJECT_ID('stngetl.ER_SupportingWOInfo','U') is not null
				drop table stngetl.ER_SupportingWOInfo;

			--insert all records from temp TT_0008 and CPID from TT_0152 in ENG_IM into final TT_0008
			with activewos as
			(
				select *
				from temp.ER_SupportingWOInfo
				where WOStatus not in ('COMP','CAN','CLOSE')
			)

			select b.UniqueID, a.*, c.RelatedWOs, d.AllScheduleBacklog, k.AllScheduleGrade, e.AllActiveOutages, f.AllActiveWOTypes, g.AllWOGroups, h.AllWOProj, i.AllWOPCTR, j.AllWOHeader
			into stngetl.ER_SupportInfo
			from temp.ER_SupportInfo as a 
			left join stng.ER_Main as b on a.ER = b.ER
			left join
			(
				select x.ER, case when len(x.WOs) = 0 then null else left(x.wos,len(x.wos)-1) end as RelatedWOs
				from
					(
						select distinct st2.ER,
						(select st1.wonum + '; ' as [text()]
						from temp.ER_SupportingWOInfo as st1
						where st1.ER = st2.ER
						for xml path ('')
						) WOs
						from temp.ER_SupportingWOInfo as st2
					) as x			
			) as c on b.ER = c.ER
			left join
			(
				select x1.ER, case when len(x1.ScheduleBacklog) = 0 then null else left(x1.ScheduleBacklog,len(x1.ScheduleBacklog)-1) end as AllScheduleBacklog
				from
					(
						select distinct st4.ER,
						(select distinct st3.ScheduleBacklog + '; ' as [text()]
						from temp.ER_SupportingWOInfo as st3
						where st3.ER = st4.ER
						for xml path ('')
						) ScheduleBacklog
						from temp.ER_SupportingWOInfo as st4
					) as x1
			) as d on b.ER = d.ER
			left join
			(
				select x2.ER, case when len(x2.Outage) = 0 then null else left(x2.outage,len(x2.outage)-1) end as AllActiveOutages
				from
					(
						select distinct st6.ER,
						(select distinct st5.outage + '; ' as [text()]
						from activewos as st5
						where st5.ER = st6.ER
						for xml path ('')
						) Outage
						from activewos as st6
					) as x2
			) as e on b.ER = e.ER
			left join
			(
				select x3.ER, case when len(x3.WOType) = 0 then null else left(x3.WOType,len(x3.WOType)-1) end as AllActiveWOTypes
				from
					(
						select distinct st8.ER,
						(select distinct st7.wotype + '; ' as [text()]
						from activewos as st7
						where st7.ER = st8.ER
						for xml path ('')
						) WOType
						from activewos as st8
					) as x3
			) as f on b.ER = f.ER
			left join
			(
				select x4.ER, case when len(x4.WOGroup) = 0 then null else left(x4.WOGroup,len(x4.WOGroup)-1) end as AllWOGroups
				from
					(
						select distinct st10.ER,
						(select distinct st9.wogroup + '; ' as [text()]
						from temp.ER_SupportingWOInfo as st9
						where st9.ER = st10.ER
						for xml path ('')
						) WOGroup
						from temp.ER_SupportingWOInfo as st10
					) as x4
			) as g on b.ER = g.ER
			left join
			(
				select x6.ER, case when len(x6.WOProj) = 0 then null else left(x6.WOProj,len(x6.WOProj)-1) end as AllWOProj
				from
					(
						select distinct st12.ER,
						(select distinct st11.projectid + '; ' as [text()]
						from temp.ER_SupportingWOInfo as st11
						where st11.ER = st12.ER
						for xml path ('')
						) WOProj
						from temp.ER_SupportingWOInfo as st12
					) as x6
			) as h on b.ER = h.ER
			left join
			(
				select x7.ER, case when len(x7.PCTR) = 0 then null else left(x7.PCTR,len(x7.PCTR)-1) end as AllWOPCTR
				from
					(
						select distinct st14.ER,
						(select distinct st13.PCTR + '; ' as [text()]
						from activewos as st13
						where st13.ER = st14.ER
						for xml path ('')
						) PCTR
						from activewos as st14
					) as x7
			) as i on b.ER = i.ER
			left join
			(
				select ER, string_agg(cast(WOHeader as nvarchar(max)), '; ') as AllWOHeader
				from activewos
				group by ER
			) as j on b.ER = j.ER
			left join
			(
				select x8.ER, case when len(x8.ScheduleGrade) = 0 then null else left(x8.ScheduleGrade,len(x8.ScheduleGrade)-1) end as AllScheduleGrade
				from
					(
						select distinct st16.ER,
						(select distinct st15.ScheduleGrade + '; ' as [text()]
						from temp.ER_SupportingWOInfo as st15
						where st15.ER = st16.ER
						for xml path ('')
						) ScheduleGrade
						from temp.ER_SupportingWOInfo as st16
					) as x8
			) as k on b.ER = k.ER
			where a.ERType in ('ENCD', 'ENGC', 'ENGD', 'EQ', 'ENGP', 'ENGS', 'EP', 'EVD', 'MJT', 'RS', 'WLD');

			--insert all records from temp TT_0009 and CPID from TT_0152 in ENG_IM into final TT_0009
			select b.UniqueID as ERID, a.*
			into stngetl.ER_SupportingWOInfo
			from temp.ER_SupportingWOInfo as a 
			inner join stng.ER_Main as b on a.ER = b.ER;

			--Add indexes to TT_0009 and _0008
			create nonclustered index IX_ER_SupportingWOInfo_WONUM on stngetl.ER_SupportingWOInfo (WONUM);
			create nonclustered index IX_ER_SupportingWOInfo_ERID on stngetl.ER_SupportingWOInfo (ERID);
			create clustered index IX_ER_SupportInfo_UniqueID on stngetl.ER_SupportInfo(UniqueID);
			create nonclustered index IX_ER_SupportInfo_ER on stngetl.ER_SupportInfo(ER);
			create nonclustered index IX_ER_SupportInfo_Facility on stngetl.ER_SupportInfo(Facility);
			create nonclustered index IX_ER_SupportInfo_ERType on stngetl.ER_SupportInfo(ERType);

			--update stng.ER_Main based on Status
			--UNCOMMENT WHEN MIGRATION IS FINISHED for the COMP values 
			update stng.ER_Main
			set CurrentStatus = '1ACC3E70-3A60-47BC-8175-69782E13D252' -- COM
			,CompDate = b.FinishDate 
			from stng.ER_Main as a 
			inner join stngetl.ER_SupportInfo as b on a.ER = b.ER 
			where b.ERStatus in ('COMP','CLOSED','RELEASED','READY') 
			and a.ER not in (select ER from stng.VV_ER_Main where CurrentStatusShort = 'COM');

			update stng.ER_Main
			set CurrentStatus = 'FC5712E4-BEFD-46C3-9A14-CFA42B8FE964' -- CAN
			,CompDate = b.FinishDate
			from stng.ER_Main as a 
			inner join stngetl.ER_SupportInfo as b on a.ER = b.ER 
			where b.ERStatus in ('CANCEL','CANCELED') 
			and a.ER not in (select ER from stng.VV_ER_Main where CurrentStatusShort = 'CAN');

			----insert new EPDE/AA status entries for new permits into ER_StatusLog
			INSERT INTO stng.ER_StatusLog(ERID,StatusID,Comment,RAD,RAB)
			select a.ERID, a.CurrentStatusID, 'From Automatic System Update',GETDATE(),'SYSTEM'
			from stng.VV_ER_Main as a
			where a.CurrentStatusShort in ('AA') and a.ERID not in (select ERID from stng.VV_ER_StatusLog where StatusShort in ('AA'));

			INSERT INTO stng.ER_StatusLog(ERID,StatusID,Comment,RAD,RAB)
			select a.ERID, a.CurrentStatusID, 'From Automatic System Update',a.CompDate,'SYSTEM'
			from stng.VV_ER_Main as a
			where a.CurrentStatusShort in ('COM') and a.ERID not in (select ERID from stng.VV_ER_StatusLog where StatusShort in ('COM'));

			INSERT INTO stng.ER_StatusLog(ERID,StatusID,Comment,RAD,RAB)
			select a.ERID, a.CurrentStatusID,'From Automatic System Update',a.CompDate,'SYSTEM'
			from stng.VV_ER_Main as a
			where a.CurrentStatusShort in ('CAN') and a.ERID not in (select ERID from stng.VV_ER_StatusLog where StatusShort in ('CAN'));

			----Reversion of ER COM status
			select a.ERID 
			into temp.RevertedPermits
			from stng.VV_ER_Main as a
			inner join stngetl.ER_SupportInfo as b on a.ER = b.ER 
			where b.ERStatus not in ('COMP','CLOSED','CANCEL','CANCELED','RELEASED','READY') and a.CurrentStatusShort in ('COM','CAN');
			
			update stng.ER_Main
			set CurrentStatus = '30CB0E3C-E48B-4D6F-B8B0-26F79CD8C3A4', --AA
			CompDate = null
			from stng.ER_Main as a 
			inner join temp.RevertedPermits as b on a.UniqueID = b.ERID;

			delete a 
			from stng.ER_StatusLog as a
			inner join stng.ER_Status as b on a.StatusID = b.UniqueID
			inner join temp.RevertedPermits as c on a.ERID = c.ERID
			where b.StatusShort in ('COM','CAN');
			
			insert into stng.ER_StatusLog
			(ERID, StatusID, Comment, RAD, RAB)
			select ERID, '30CB0E3C-E48B-4D6F-B8B0-26F79CD8C3A4', 'Reverted from COMP/CANCEL/CANCELED/CLOSED in Maximo', GETDATE(),'SYSTEM' --StatusID is AA
			from temp.RevertedPermits;

			IF OBJECT_ID('temp.RevertedPermits','U') is not null
				drop table temp.RevertedPermits;

			--Insert new misses for non-complete, deliverable-related ERs
			insert into stngetl.ER_DueDateMisses
			(ERID, DueDate, DueDateType, RAD, RAB)
			select distinct a.ERID, a.ERDueDate, a.DueDateType, GETDATE(), 'SYSTEM'
			from (
				select x.ERID, x.CurrentStatusShort, y.ERDueDate, y.DueDateType
				from stng.VV_ER_Main as x
				inner join stngetl.ER_SupportInfo as y on x.ER = y.ER
			) as a
			left join (
				select * 
				from stng.VV_ER_StatusLog 
				where [StatusShort] in ('COM','CAN')
			) as b on a.ERID = b.ERID
			left join stngetl.ER_DueDateMisses as c on a.ERID = c.ERID and a.ERDueDate = c.DueDate 
			where a.ERDueDate is not null and a.ERDueDate < cast(GETDATE() as date) and (b.[StatusDate] is null or cast(b.[StatusDate] as date) > a.ERDueDate) and c.ERID is null and a.CurrentStatusShort <> 'NOD';

			--Update miss id in ER_Main
			update stng.ER_Main
			set DateMissedID = b.MaxUniqueID
			from stng.ER_Main as a
			inner join (
				select distinct ERID, max(UniqueID) as MaxUniqueID 
				from stngetl.ER_DueDateMisses 
				group by ERID
			) as b on a.UniqueID = b.ERID;

			--Update TCDPermit with TargetCompDate if ERType = WLD
			if OBJECT_ID('temp.ER_TCDChanges','U') is not null drop table temp.ER_TCDChanges;

			with tcdchanges as
			(
				select a.ERID, a.ERTCD as OriginalDate, b.MaximoTCD as NewDate
				from stng.VV_ER_Main as a
				inner join stngetl.ER_SupportInfo as b on a.ERID = b.UniqueID
				where b.ERType = 'WLD' and b.MaximoTCD is not null 
				and
				(
					a.ERTCD is null
					or
					cast(a.ERTCD as date) <> cast(b.MaximoTCD as date)
				)			
			)

			select *
			into temp.ER_TCDChanges
			from tcdchanges;

			insert into stng.ER_DateChangeLog
			(ERID, DateValues, ChangedTo, LUB, LUD)
			select ERID, N'ER TCD', NewDate, 'SYSTEM', GETDATE()
			from temp.ER_TCDChanges;

			update stng.ER_Main
			set ERTCD = b.NewDate
			from stng.ER_Main as a
			inner join temp.ER_TCDChanges as b on a.UniqueID = b.ERID;

			if OBJECT_ID('temp.ER_TCDChanges','U') is not null drop table temp.ER_TCDChanges;

			update a
			set ERTCD = b.MaximoTCD
			from stng.ER_Main as a
			inner join stngetl.ER_SupportInfo as b on a.UniqueID = b.UniqueID
			where b.ERType = 'WLD' and b.MaximoTCD is not null;

			--Drop temp tables

			IF OBJECT_ID('temp.ER_SupportInfo','U') is not null
				begin
					drop table temp.ER_SupportInfo;
				end
				
			IF OBJECT_ID('temp.ER_SupportingWOInfo','U') is not null
				begin
					drop table temp.ER_SupportingWOInfo;
				end
				
			IF OBJECT_ID('temp.RELATEDWOS','U') is not null
				begin
					drop table temp.RELATEDWOS;
				end

end

