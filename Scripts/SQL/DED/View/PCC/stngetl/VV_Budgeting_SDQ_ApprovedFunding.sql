Create view [stngetl].[VV_Budgeting_FundingAllocation] as 
   select CII.[UniqueID]
      ,CII.[SDQUID]
      ,CII.[RunID]
      ,CII.[RespOrg]
      ,CII.[MultipleVendor]
      ,CII.[LabourRemainingUnits]
      ,CII.[LabourRemainingCost]
      ,CII.[NonLabourRemainingCost]
      ,CII.[RemainingCost]
      ,CII.[SunkCost]
      ,CII.[RequestCost]
      ,CII.[BLProjectTotalCost]
      ,CII.[CurrentRequest]
      ,CII.[Legacy]
  , case when AF.[AllocatedFunding] is null then 0 else AF.[AllocatedFunding] end as [AllocatedFunding]
  from stngetl.VV_Budgeting_SDQ_P6_CIIOrg CII

		 left join [stng].[Budgeting_ApprovedFunding] AF on 
				CII.SDQUID=AF.SDQUID and
				( CII.RespOrg=AF.RespOrg or ( CII.RespOrg is null and Af.RespOrg is null) )
			 and
				( CII.MultipleVendor=AF.MultipleVendor or ( CII.MultipleVendor is null and Af.MultipleVendor is null) )
			
GO


