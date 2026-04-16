  CREATE OR ALTER VIEW stng.VV_Budgeting_ProjectType
  AS 
  SELECT UniqueID ProjectTypeID
  ,[Group]
  ,Label ProjectTypeLong
  ,Value1 ProjectType
  FROM stng.VV_Common_ValueLabel A 
  WHERE A.Module = 'PCC' AND A.Field = 'ProjectType' 
