CREATE or ALTER VIEW [stng].[VV_Budgeting_LinkedTOQ_Funding] as 
 
	SELECT SDQUID, sum(ApprovalAmount) as ApprovalAmount, sum(RemainingApprove) as RemainingApprove
	FROM [stng].[VV_Budgeting_SDQ_CustomerApproval]
	group by SDQUID

GO


