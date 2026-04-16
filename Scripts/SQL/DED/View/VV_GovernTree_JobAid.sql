/****** Object:  View [stng].[VV_GovernTree_JobAid]    Script Date: 4/17/2024 8:18:58 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [stng].[VV_GovernTree_JobAid]
AS
SELECT DISTINCT 
    a.UniqueID AS JobAidID, 
    a.DocumentNoNum AS DocumentNo, 
    a.DocumentStatus AS jobaidstatusddl, 
    a.Revision, 
    a.DocumentTitle, 
    a.JobAidNum,
	a.StandardCount,
	a.FormCount,
	a.ReferenceCount,
	a.JobAidCount,
	a.DCRCount,
	a.RAD,
	a.UpdateDate,
	a.JobAidStatus,
	c.JAStatus as JobAidStatusC,

    CONCAT(a.DocumentNoNum, '-', REPLICATE('0', 3 - LEN(a.JobAidNum)), a.JobAidNum) AS FullDocumentNoName,
    CAST(
        CASE 
            WHEN b.filemetaID IS NOT NULL THEN 1
            ELSE 0
        END AS BIT
    ) AS DocumentAttached
FROM stng.GovernTree_JobAid AS a

LEFT JOIN [stng].[Common_FileMeta] AS b 
    ON CAST(a.UniqueID as varchar(50)) = b.ParentID 
    AND b.Deleted = 0
LEFT JOIN  [stng].[GovernTree_JobAidStatus] as c
  ON a.[JobAidStatus] = c.[UniqueID]
WHERE a.Deleted = 0



GO


