CREATE view [stng].[VV_CSA_MELReview] as
select [CSAMID]
      ,[CSAID]
      ,[SiteID]
      ,[Location]
      ,[Equipment_Name]
      ,[MANUFACTURER]
      ,[Model_Number]
      ,[ParentItem]
      ,[Crit_Cat]
      ,[SPV]
      ,[Repair_Strat]
      ,[Verified]
      ,[Approved] from stng.CSA_MELReview
GO


