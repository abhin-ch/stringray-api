create or alter view stng.VV_Budgeting_SDQ_SMApproval_StatusLog as 
select b.SDQUID, a.SMApprovalSLID, a.SMApprovalID, a.ApprovalStatus as ApprovalStatusID, c.SMApprovalStatus as ApprovalStatus, a.Comment, a.RAD as StatusDate,
d.FullName as StatusBy
from stng.Budgeting_SDQ_SMApproval_StatusLog as a
inner join stng.VV_Budgeting_SDQ_SMApproval as b on a.SMApprovalID = b.SMApprovalID
inner join stng.Budgeting_SDQ_SMApproval_Status as c on a.ApprovalStatus = c.SMApprovalStatusID
inner join stng.Admin_User as d on a.RAB = d.EmployeeID