CREATE OR ALTER view [stng].[VV_Budgeting_SDQ_CustomerApproval_2] as
with initialquery as 
(
	select  b.SDQUID,
	b.Active,
	a.CustomerApprovalID,
	a.ApprovalAmount,
	a.Approved,
	a.ApprovalDate,
	a.ApprovedBy as ApprovedID,
	c.EmpName as Approver,
	a.Comment,
	a.SunkCost,
	a.RemainingCII,
	a.SunkCost + a.RemainingCII as RequestedCost,
	a.FutureCV, 
	a.SunkCost + a.RemainingCII + a.FutureCV as EAC,
	d.PreviouslyApproved,
	a.SunkCost + a.RemainingCII - isnull(a.PriorPartialApproval,0)- d.PreviouslyApproved as CurrentRequest,
	isnull(a.PriorPartialApproval,0) as PriorPartialApproval,	
	case when f.sdqstatus in ('AOEFR','APCSC','AFRE','AOERC','APRE') 
		 then Round(isnull(a.PriorPartialApproval,0)+isnull(a.ApprovalAmount,0),0) 
		 else Round(isnull(a.PriorPartialApproval,0),0)  end  as TotalPartialApproval,
	isnull(a.PriorPartialApproval,0)+d.PreviouslyApproved + isnull(a.ApprovalAmount,0) as TotalApproved,
	Round(Round(a.SunkCost + a.RemainingCII,0) - d.PreviouslyApproved - isnull(a.ApprovalAmount,0)- isnull(a.PriorPartialApproval,0),0) as RemainingApproved,
	case when Round(Round(a.SunkCost + a.RemainingCII,0)- d.PreviouslyApproved - isnull(a.PriorPartialApproval,0)- isnull(a.ApprovalAmount,0),0) in (0,1,-1) 
		then 0 else 1 end as IsPartial,
	d.RequestedScope,
	Round(a.SunkCost + a.RemainingCII,0) - d.PreviouslyApproved - isnull(d.RequestedScope,0) - isnull(a.PriorPartialApproval,0)	as RequestedTrend,
	e.EcoSysEAC, 
	f.[SDQStatus]	
	from stng.Budgeting_SDQ_CustomerApproval_2 as a
	inner join stng.Budgeting_SDQ_CustomerApproval_Mapping as b on a.CustomerApprovalID = b.CustomerApprovalID and b.Active = 1
	inner join stng.Budgeting_SDQMain as d on b.SDQUID = d.SDQUID
	left join stng.VV_Admin_UserView as c on a.ApprovedBy = c.EmployeeID
	left join stng.VV_Budgeting_SDQ_EcoSysEAC as e on b.SDQUID = e.SDQUID
	left join [stng].[Budgeting_SDQ_Status] f on d.statusid=f.sdqstatusid
	
)

select *
from initialquery
GO

