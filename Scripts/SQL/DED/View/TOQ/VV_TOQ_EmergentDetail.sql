CREATE OR ALTER VIEW [stng].[VV_TOQ_EmergentDetail] 
AS
SELECT [UniqueID]
      ,[Project]
      ,[Title]
      ,[RequestAmount]
      ,a.[FundingSource]
      ,[SectionManager] as ManualSM
	  ,b.SMID as MPLSM
	  ,CASE WHEN b.SMID is null THEN a.SectionManager ELSE b.SMID END AS [SectionManager]
	  ,CASE WHEN b.PCSID is null THEN a.PCS ELSE b.PCSID END AS PCS
      ,[VendorTOQNumber]
      ,[ContractNumber]
      ,[ScopeOfWork]
      ,[DeleteDate]
      ,[DeleteRecord]
      ,[DeleteBy]
      ,[CreatedDate]
      ,[CreatedBy]
  FROM [stng].[TOQ_EmergentDetail] as a
  LEFT JOIN [stng].VV_General_MPLPersonnel as b on b.ProjectID = a.Project
GO