CREATE OR ALTER VIEW [stng].[VV_TWP_Main]
AS
WITH ActivityC AS (SELECT DISTINCT t.TASK_ID, COALESCE (mp.c, 0) AS ActivityCount
                                         FROM            stngetl.TWP_Task AS t LEFT OUTER JOIN
                                                                       (SELECT        PARENTTASK, COUNT(*) AS c
                                                                         FROM            stngetl.TWP_TaskChild AS tc
                                                                         GROUP BY PARENTTASK) AS mp ON mp.PARENTTASK = t.TASK_ID), FlaggedT AS
    (SELECT DISTINCT t.TASK_ID, COALESCE (mp_1.c, 0) AS FlaggedCount
      FROM            stngetl.TWP_Task AS t LEFT OUTER JOIN
                                    (SELECT        PARENTTASK, COUNT(CASE WHEN Flagged = 1 THEN 1 END) AS c
                                      FROM            stngetl.TWP_TaskChildFlags AS tc
                                      GROUP BY PARENTTASK) AS mp_1 ON mp_1.PARENTTASK = t.TASK_ID), CompCountT AS
    (SELECT DISTINCT t.TASK_ID, COALESCE (mp_2.c, 0) AS NotCompletedCount
      FROM            stngetl.TWP_Task AS t LEFT OUTER JOIN
                                    (SELECT        PARENTTASK, COUNT(CASE WHEN COMPLETED = 0 THEN 1 END) AS c
                                      FROM            stngetl.TWP_TaskChild AS tc
                                      GROUP BY PARENTTASK) AS mp_2 ON mp_2.PARENTTASK = t.TASK_ID)
    SELECT        t.PROJECT, t.TASK_ID, t.ACTIVITYID, t.ACTIVITYNAME, t.ACTSTARTDATE, t.ACTENDDATE, t.TARGETSTARTDATE, t.TARGETENDDATE, t.UniqueID, comp.NotCompletedCount, f.FlaggedCount, a.ActivityCount, p.ProjectDepartment, 
                              p.ProjectID, p.SharedProjectID, p.ProjectName, p.BusinessDriver, p.BuyerAnalyst, p.BuyerAnalystLANID, p.Category, p.ContractAdmin, p.ContractAdminLANID, p.ContractType, p.CostAnalyst, p.CostAnalystLANID, p.CSFLM, 
                              p.CSFLMLANID, p.PCS, p.PCSLANID, p.Department, p.Discipline, p.FastTrack, p.FundingSource, p.MaterialBuyer, p.MaterialBuyerLANID, p.MultiDisc, p.OwnersEngineer, p.OwnersEngineerLANID, p.Portfolio, p.Phase, 
                              p.Program, p.ProgramManager, p.ProgramManagerLANID, p.ProjectEngineer, p.ProjectEngineerLANID, p.ProjectManager, p.ProjectManagerLANID, p.ProjectPlanner, p.ProjectPlannerLANID, p.ProjectPlannerAlternate, 
                              p.ProjectPlannerAlternateLANID, p.SeniorProgramManager, p.SeniorProgramManagerLANID, p.ServiceBuyer, p.ServiceBuyerLANID, p.Status, p.SubPortfolio, p.ProjectType, t.COMPLETED, t.OUTAGE, t.MAJORGROUP
     FROM            stngetl.TWP_Task AS t LEFT OUTER JOIN
                              FlaggedT AS f ON f.TASK_ID = t.TASK_ID LEFT OUTER JOIN
                              stng.VV_MPL_PMC AS p ON t.PROJECT = p.ProjectID LEFT OUTER JOIN
                              ActivityC AS a ON a.TASK_ID = t.TASK_ID LEFT OUTER JOIN
                              CompCountT AS comp ON comp.TASK_ID = t.TASK_ID
GO


