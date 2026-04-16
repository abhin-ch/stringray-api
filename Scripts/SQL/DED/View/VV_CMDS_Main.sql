with crumQuery as (
	select a.UniqueID
	,case when max(case when c.Category = 'CRUM' then 1 else 0 end) = 1 then 'Yes' else 'No' end as CRUM
	from stng.CMDS_Goal as a 
	left join stng.CMDS_Category_Map as b on a.UniqueID = b.CMDSID
	left join stng.CMDS_Category as c on b.Category = c.UniqueID
	group by a.UniqueID
),
actionsStr as (
	select CMDSID, STRING_AGG(Action, ' ') as Actions
	from stng.CMDS_Action
	where Deleted = 0
	group by CMDSID
),
commentsStr as (
	select CMDSID, STRING_AGG(Comment, ' ') as Comments
	from stng.CMDS_Comment
	where Deleted = 0
	group by CMDSID
)



SELECT DISTINCT a.[UniqueID]
      ,a.[Title]
      ,a.[Description]
      ,a.[Section]
      ,a.[WorkProgram]
      ,a.[GoalLevel]
      ,a.[Owner]
      ,a.[Status]
      ,a.[TCD]
      ,a.[RAD]
      ,a.[RAB]
      ,a.[CompletionNotes]
      ,a.[Year]
      ,a.[Quarter]
	  , CAST(a.TCD as DATE) as TCDC
	  , b.EmpName as OwnerC
	  , c.Status as StatusC
	  , d.GoalLevel as GoalLevelC
	  , e.WorkProgram as WorkProgramC
	  , f.AssignedSection as AssignedSectionC
	  , g.[Value] as YearC
	  , h.[Value] as QuarterC
	  , CONCAT(g.[Value],' ', h.[Value]) as YearQuarter
	  , i.CRUM
	  , j.Actions
	  , k.Comments
FROM stng.CMDS_Goal AS a 
left join stng.VV_Admin_UserView as b on a.Owner = b.EmployeeID
left join stng.CMDS_Status as c on a.Status = c.UniqueID
left join stng.CMDS_GoalLevel as d on a.GoalLevel = d.UniqueID
left join stng.CMDS_WorkProgram as e on a.WorkProgram = e.UniqueID
left join stng.CMDS_AssignedSection as f on a.Section = f.UniqueID
left join stng.CMDS_Date as g on a.[Year] = g.UniqueID
left join stng.CMDS_Date as h on a.[Quarter] = h.UniqueID
left join crumQuery as i on a.UniqueID = i.UniqueID
left join actionsStr as j on a.UniqueID = j.CMDSID
left join commentsStr as k on a.UniqueID = k.CMDSID
where a.Deleted = 0