#Daily scheduled update script for Stingray Backing Data in ENG_STG

try {      
       $error.Clear()

       #Start Stopwatch
       $stopwatch = [system.diagnostics.stopwatch]::startnew()
       $ETL_starttime = [DateTime]::Now | Get-Date  -Format "yyyy-MM-dd HH:mm:ss"

       $conn = new-object system.data.sqlclient.sqlconnection
       $connectionstring = "Server=LSN_BE_D,1569;Database=ENG_STG;Integrated Security=true"
       $conn.connectionstring = $connectionstring

       $cmd = new-object system.data.sqlclient.sqlcommand
       $cmd.commandtimeout = 2000
       $cmd.connection = $conn

       $conn.open()
    
       #Migrate to MSSQL
       write-host "Beginning ETL... "
       $path = "$psscriptroot\API\SQLtoSQL.ps1"

       write-host "P6 to Stingray"
    
       ## Get P6_ProjWBS (Fragnets & Sub-Fragnets)
       $sql = "SELECT P.PROJ_SHORT_NAME INTO #TempProjects
            FROM [P6_DV].[dbo].[P6_Project] P
            WHERE P.PROJ_SHORT_NAME LIKE 'CS-%'
            AND P.PROJ_SHORT_NAME NOT LIKE 'CS%B[1-9]'
            AND P.PROJ_SHORT_NAME NOT LIKE 'CS%B[1-9][0-9]'
            AND P.PROJ_SHORT_NAME NOT LIKE 'CS-[0-9][0-9][0-9][0-9][0-9]V'
            AND P.[CURRENT] = 'Y'
               GROUP BY P.PROJ_SHORT_NAME

            SELECT W.WBS_ID
                   ,W.WBS_NAME
                   ,W.PROJ_ID
                   ,W.PARENT_WBS_ID INTO #TempSubFragnets
            FROM [P6_DV].[dbo].[P6_ProjWbs] W 
            WHERE W.WBS_ID IN 
            (
                   SELECT DISTINCT A.WBS_ID
                   FROM [P6_DV].[dbo].[P6_Task] A          
                   INNER JOIN [P6_DV].[dbo].[P6_ProjWbs] W2 ON W2.WBS_ID = A.WBS_ID AND W2.[CURRENT] = 'Y' AND W2.SNAPSHOT_CHANGE != 'Removed'
                   INNER JOIN [P6_DV].[dbo].P6_Project P ON A.PROJ_ID = P.PROJ_ID AND P.[CURRENT] = 'Y'
                   WHERE P.PROJ_SHORT_NAME IN (SELECT P.PROJ_SHORT_NAME FROM #TempProjects P) AND A.[CURRENT] = 'Y'
            ) AND W.[CURRENT] = 'Y'

            SELECT DISTINCT S.WBS_ID AS FragnetID
                ,S.WBS_NAME AS FragnetName
                ,S.PROJ_ID AS ProjID
                ,S.PARENT_WBS_ID AS ParentID
            FROM #TempSubFragnets S
            UNION
            SELECT W.WBS_ID
                ,W.WBS_NAME 
                ,W.PROJ_ID
                ,NULL
                FROM [P6_DV].[dbo].[P6_ProjWbs] W 
            WHERE W.WBS_ID IN (SELECT S.PARENT_WBS_ID FROM #TempSubFragnets S) 
            AND W.WBS_ID NOT IN (SELECT S.WBS_ID FROM #TempSubFragnets S)
            AND W.[CURRENT] = 'Y'"       

       $starttime = $stopwatch.elapsed.totalminutes
       & "$path" -fromservername "LSN_PSTG001,1572" -fromdbname "P6_DV" -destservername "LSN_BE_D,1569" -destdbname "ENG_STG" -destschemaname "stng" -desttblname "Fragnet" -destwinauthentication -fromwinauthentication -execsql $sql
       
       $sql = "ALTER TABLE [ENG_STG].[stng].[Fragnet] ALTER COLUMN FragnetID NUMERIC(10,0)
            ALTER TABLE [ENG_STG].[stng].[Fragnet] ALTER COLUMN ProjID NUMERIC(10,0)
            ALTER TABLE [ENG_STG].[stng].[Fragnet] ALTER COLUMN ParentID NUMERIC(10,0)

            CREATE CLUSTERED INDEX [IX_Fragnet_CLUSTERED] ON [stng].[Fragnet]
            (
                   [ProjID] ASC,
                [ParentID] ASC
            );
            
            CREATE NONCLUSTERED INDEX [IX_Fragnet_FragnetID] ON [stng].[Fragnet]
            (
                   [FragnetID] ASC             
            )
    
            DROP TABLE stngQA.Fragnet
            SELECT * INTO stngQA.Fragnet FROM stng.Fragnet

            ALTER TABLE [ENG_STG].[stngQA].[Fragnet] ALTER COLUMN FragnetID NUMERIC(10,0)
            ALTER TABLE [ENG_STG].[stngQA].[Fragnet] ALTER COLUMN ProjID NUMERIC(10,0)
            ALTER TABLE [ENG_STG].[stngQA].[Fragnet] ALTER COLUMN ParentID NUMERIC(10,0)

            CREATE CLUSTERED INDEX [IX_Fragnet_CLUSTERED] ON [stngQA].[Fragnet]
            (
                   [ProjID] ASC,
                [ParentID] ASC
            );
            
            CREATE NONCLUSTERED INDEX [IX_Fragnet_FragnetID] ON [stngQA].[Fragnet]
            (
                   [FragnetID] ASC             
            )"
    
       $cmd.commandtext = $sql 
       $cmd.executenonquery()
       $totaltime = $stopwatch.elapsed.totalminutes - $starttime

       write-host "[Time] CARLA_Fragnet: $totaltime minutes"

       ## Get P6_Task
       $sql = "SELECT P.PROJ_SHORT_NAME INTO #TempProjects
            FROM [P6_DV].[dbo].[P6_Project] P
            WHERE P.PROJ_SHORT_NAME LIKE 'CS-%'
            AND P.PROJ_SHORT_NAME NOT LIKE 'CS%B[1-9]'
            AND P.PROJ_SHORT_NAME NOT LIKE 'CS%B[1-9][0-9]'
            AND P.PROJ_SHORT_NAME NOT LIKE 'CS-[0-9][0-9][0-9][0-9][0-9]V'
            AND P.[CURRENT] = 'Y'
            GROUP BY P.PROJ_SHORT_NAME

            SELECT DISTINCT A.TASK_CODE,C.SHORT_NAME INTO #TempCOwner
            FROM [P6_DV].[dbo].[P6_Task] A 
            INNER JOIN [P6_DV].[dbo].[P6_TaskActv] B ON A.TASK_ID = B.TASK_ID AND B.ACTV_CODE_TYPE_ID = 427381 AND A.[CURRENT] = 'Y' AND B.[CURRENT] = 'Y' AND A.SNAPSHOT_CHANGE != 'Removed'
            INNER JOIN [P6_DV].[dbo].[P6_Actvcode] C ON B.ACTV_CODE_TYPE_ID = C.ACTV_CODE_TYPE_ID AND C.[CURRENT] = 'Y' AND C.ACTV_CODE_ID = B.ACTV_CODE_ID
            INNER JOIN [P6_DV].[dbo].[P6_ProjWbs] W2 ON W2.WBS_ID = A.WBS_ID AND W2.[CURRENT] = 'Y' AND W2.SNAPSHOT_CHANGE != 'Removed'
            INNER JOIN [P6_DV].[dbo].[P6_Project] P ON A.PROJ_ID = P.PROJ_ID AND P.[CURRENT] = 'Y'
            WHERE P.PROJ_SHORT_NAME IN (SELECT P.PROJ_SHORT_NAME FROM #TempProjects P)

            SELECT DISTINCT T.PROJ_ID
                   ,P.PROJ_SHORT_NAME
                   ,T.TASK_CODE
                   ,T.TASK_ID
                   ,T.TASK_NAME
                   ,T.WBS_ID
                   ,C.SHORT_NAME AS ACTIVITYCODEVALUE
                   ,T.TARGET_START_DATE
                   ,T.TARGET_START_DATE_D
                   ,T.TARGET_END_DATE
                   ,T.TARGET_END_DATE_D
                   ,T.REEND_DATE
                   ,T.ACTUAL_START_DATE
                   ,T.ACTUAL_END_DATE               
                   ,CASE WHEN T.STATUS_CODE = 'TK_Complete' THEN 'Actualized'
                          WHEN T.STATUS_CODE = 'TK_Active' THEN 'Active'
                          WHEN T.STATUS_CODE = 'TK_NotStart' THEN 'NotStart'
                          ELSE T.STATUS_CODE
                          END AS 'STATUS_CODE'
                  ,CASE WHEN D.SHORT_NAME = 'MMP' THEN 'CPB.MMP'
                          WHEN D.SHORT_NAME = 'SVC' THEN 'CPB.SVC'
                          WHEN D.SHORT_NAME = 'GEM' THEN 'CPB.GEM'
                          WHEN D.SHORT_NAME = 'CS' THEN 'CPP.CS'
                          WHEN D.SHORT_NAME = 'CA' THEN 'CPP.CA'
                          ELSE D.SHORT_NAME
                          END AS 'COMMITMENT_OWNER'
                   ,T.REMAIN_WORK_QTY
                   ,T.TARGET_WORK_QTY
                   INTO #TempActivity
            FROM [P6_DV].[dbo].[P6_Task] T 
            INNER JOIN [P6_DV].[dbo].[P6_TaskActv] B ON T.TASK_ID = B.TASK_ID AND B.ACTV_CODE_TYPE_ID = 427380 AND T.[CURRENT] = 'Y' AND B.[CURRENT] = 'Y' AND T.SNAPSHOT_CHANGE != 'Removed'
            INNER JOIN [P6_DV].[dbo].[P6_Actvcode] C ON B.ACTV_CODE_TYPE_ID = C.ACTV_CODE_TYPE_ID AND C.[CURRENT] = 'Y' AND C.ACTV_CODE_ID = B.ACTV_CODE_ID
            INNER JOIN [P6_DV].[dbo].[P6_Project] P ON T.PROJ_ID = P.PROJ_ID AND P.[CURRENT] = 'Y'
            INNER JOIN [P6_DV].[dbo].[P6_ProjWbs] W ON T.WBS_ID = W.WBS_ID AND W.[CURRENT] = 'Y' AND W.SNAPSHOT_CHANGE != 'Removed'
            LEFT JOIN #TempCOwner D ON D.TASK_CODE = T.TASK_CODE
            WHERE P.PROJ_SHORT_NAME IN (SELECT P.PROJ_SHORT_NAME FROM #TempProjects P) 

            --OR (P.PROJ_SHORT_NAME LIKE '[0-9][0-9][0-9][0-9][0-9]' AND P.[CURRENT] = 'Y')

            SELECT T.PROJ_ID AS ProjID
                   ,T.PROJ_SHORT_NAME AS ProjShortName
                   ,T.TASK_CODE AS ActivityID
                   ,T.TASK_NAME AS ActivityName
                   ,T.WBS_ID AS FragnetID
                   ,T.ACTIVITYCODEVALUE AS [N/CSQ]
                   ,T.TARGET_START_DATE AS StartDate
                   ,T.TARGET_START_DATE_D AS BLStartDate
                   ,T.TARGET_END_DATE_D AS EndDate
                   ,T.REEND_DATE AS ReendDate
                   ,T.ACTUAL_START_DATE AS ActualStartDate
                   ,T.ACTUAL_END_DATE AS ActualEndDate
                   ,IIF(T.STATUS_CODE = 'Actualized',1,0) AS [Actualized]
                   ,NULL AS [Resource]
                   ,T.COMMITMENT_OWNER AS CommitmentOwner
                   ,T.STATUS_CODE AS Status
                   ,T.REMAIN_WORK_QTY AS [RemainingHours]
                   ,T.TARGET_WORK_QTY AS [BudgetedHours]
                   ,NULL AS [Duration]
                   ,IIF(T.STATUS_CODE = 'Active',T.REEND_DATE,T.TARGET_END_DATE_D) AS [CommitmentDate]
            FROM #TempActivity AS T
            UNION
            SELECT DISTINCT T.PROJ_ID
                   ,P.PROJ_SHORT_NAME
                   ,T.TASK_CODE
                   ,T.TASK_NAME
                   ,T.WBS_ID
                   ,NULL
                   ,T.TARGET_START_DATE
                   ,T.TARGET_START_DATE_D
                   ,T.TARGET_END_DATE_D
                   ,T.REEND_DATE
                   ,T.ACTUAL_START_DATE
                   ,T.ACTUAL_END_DATE
                   ,IIF(T.STATUS_CODE = 'TK_Complete',1,0)
                   ,R.RSRC_NAME
                   ,CASE WHEN D.SHORT_NAME = 'MMP' THEN 'CPB.MMP'
                          WHEN D.SHORT_NAME = 'SVC' THEN 'CPB.SVC'
                          WHEN D.SHORT_NAME = 'GEM' THEN 'CPB.GEM'
                          WHEN D.SHORT_NAME = 'CS' THEN 'CPP.CS'
                          WHEN D.SHORT_NAME = 'CA' THEN 'CPP.CA'
                          ELSE D.SHORT_NAME
                          END AS 'CommitmentOwner'
                   ,CASE WHEN T.STATUS_CODE = 'TK_Complete' THEN 'Actualized'
                          WHEN T.STATUS_CODE = 'TK_Active' THEN 'Active'
                          WHEN T.STATUS_CODE = 'TK_NotStart' THEN 'NotStart'
                          ELSE T.STATUS_CODE
                          END AS 'Status'
                   ,T.REMAIN_WORK_QTY
                   ,T.TARGET_WORK_QTY
                   ,RX.PLANNEDDURATION
                   ,IIF(T.STATUS_CODE = 'TK_Active',T.REEND_DATE,T.TARGET_END_DATE_D)
            FROM [P6_DV].[dbo].[P6_Task] T
            INNER JOIN [P6_DV].[dbo].[P6_TaskRsrc] TR ON TR.TASK_ID = T.TASK_ID AND T.[CURRENT] = 'Y' AND T.SNAPSHOT_CHANGE != 'Removed' AND TR.[CURRENT] = 'Y'
            INNER JOIN [P6_DV].[dbo].[P6_Rsrc] R ON R.RSRC_ID = TR.RSRC_ID AND R.[CURRENT] = 'Y'
            INNER JOIN [P6_DV].[dbo].[P6_Project] P ON T.PROJ_ID = P.PROJ_ID AND P.[CURRENT] = 'Y'
            LEFT JOIN #TempCOwner D ON D.TASK_CODE = T.TASK_CODE
            LEFT JOIN [P6_DV].[dbo].[P6_TaskRsrcX] RX ON RX.TASKRSRC_ID = TR.TASKRSRC_ID AND RX.ACTIVITYID = T.TASK_CODE AND RX.[CURRENT] = 'Y'
            WHERE P.PROJ_SHORT_NAME IN (SELECT P.PROJ_SHORT_NAME FROM #TempProjects P)"

       $starttime = $stopwatch.elapsed.totalminutes
       & "$path" -fromservername "LSN_PSTG001,1572" -fromdbname "P6_DV" -destservername "LSN_BE_D,1569" -destdbname "ENG_STG" -destschemaname "stng" -desttblname "FragnetActivity" -destwinauthentication -fromwinauthentication -execsql $sql

       write-host "Creating indexes..."

       $sql = "ALTER TABLE [ENG_STG].[stng].[FragnetActivity] ALTER COLUMN ProjID NUMERIC(10,0);
            ALTER TABLE [ENG_STG].[stng].[FragnetActivity] ALTER COLUMN FragnetID NUMERIC(10,0);
            ALTER TABLE [ENG_STG].[stng].[FragnetActivity] ALTER COLUMN Actualized BIT;
            ALTER TABLE [ENG_STG].[stng].[FragnetActivity] ALTER COLUMN StartDate DATE;
            ALTER TABLE [ENG_STG].[stng].[FragnetActivity] ALTER COLUMN BLStartDate DATE;
            ALTER TABLE [ENG_STG].[stng].[FragnetActivity] ALTER COLUMN EndDate DATE;
            ALTER TABLE [ENG_STG].[stng].[FragnetActivity] ALTER COLUMN CommitmentDate DATE;
            ALTER TABLE [ENG_STG].[stng].[FragnetActivity] ALTER COLUMN ReendDate DATE;
            ALTER TABLE [ENG_STG].[stng].[FragnetActivity] ALTER COLUMN ActualStartDate DATE;
            ALTER TABLE [ENG_STG].[stng].[FragnetActivity] ALTER COLUMN ActualEndDate DATE;
            ALTER TABLE [ENG_STG].[stng].[FragnetActivity] ALTER COLUMN RemainingHours FLOAT;
            ALTER TABLE [ENG_STG].[stng].[FragnetActivity] ALTER COLUMN BudgetedHours FLOAT;
            ALTER TABLE [ENG_STG].[stng].[FragnetActivity] ALTER COLUMN Duration NUMERIC(10,0);
            
            CREATE NONCLUSTERED INDEX [IX_FragnetActivity_TaskID] ON [stng].[FragnetActivity]
            (
                   [ActivityID] ASC
            );
            
            CREATE CLUSTERED INDEX [IX_FragnetActivity_CLUSTERED] ON [stng].[FragnetActivity]
            (
                   [ProjID] ASC,
                   [FragnetID] ASC
            );

            CREATE NONCLUSTERED INDEX [IX_FragnetActivity_FragnetID] ON [stng].[FragnetActivity]
            (
                   [FragnetID] ASC,
                   [Actualized] ASC
            );

            CREATE NONCLUSTERED INDEX [IX_FragnetActivity_ProjShortName] ON [stng].[FragnetActivity]
            (
                   [ProjShortName] ASC
            );

            DROP TABLE [stngQA].[FragnetActivity];
            SELECT * INTO stngQA.FragnetActivity FROM stng.FragnetActivity;

            ALTER TABLE [ENG_STG].[stngQA].[FragnetActivity] ALTER COLUMN ProjID NUMERIC(10,0);
            ALTER TABLE [ENG_STG].[stngQA].[FragnetActivity] ALTER COLUMN FragnetID NUMERIC(10,0);
            ALTER TABLE [ENG_STG].[stngQA].[FragnetActivity] ALTER COLUMN Actualized BIT;
            ALTER TABLE [ENG_STG].[stngQA].[FragnetActivity] ALTER COLUMN StartDate DATE;
            ALTER TABLE [ENG_STG].[stngQA].[FragnetActivity] ALTER COLUMN BLStartDate DATE;
            ALTER TABLE [ENG_STG].[stngQA].[FragnetActivity] ALTER COLUMN EndDate DATE;
            ALTER TABLE [ENG_STG].[stngQA].[FragnetActivity] ALTER COLUMN CommitmentDate DATE;
            ALTER TABLE [ENG_STG].[stngQA].[FragnetActivity] ALTER COLUMN ReendDate DATE;
            ALTER TABLE [ENG_STG].[stngQA].[FragnetActivity] ALTER COLUMN ActualStartDate DATE;
            ALTER TABLE [ENG_STG].[stngQA].[FragnetActivity] ALTER COLUMN ActualEndDate DATE;
            ALTER TABLE [ENG_STG].[stngQA].[FragnetActivity] ALTER COLUMN RemainingHours FLOAT;
            ALTER TABLE [ENG_STG].[stngQA].[FragnetActivity] ALTER COLUMN BudgetedHours FLOAT;
            ALTER TABLE [ENG_STG].[stngQA].[FragnetActivity] ALTER COLUMN Duration NUMERIC(10,0);
            
            CREATE NONCLUSTERED INDEX [IX_FragnetActivity_TaskID] ON [stngQA].[FragnetActivity]
            (
                   [ActivityID] ASC
            )
            
            CREATE CLUSTERED INDEX [IX_FragnetActivity_CLUSTERED] ON [stngQA].[FragnetActivity]
            (
                   [ProjID] ASC,
                   [FragnetID] ASC
            );
            
            CREATE NONCLUSTERED INDEX [IX_FragnetActivity_FragnetID] ON [stngQA].[FragnetActivity]
            (
                   [FragnetID] ASC,
                   [Actualized] ASC
            );
            CREATE NONCLUSTERED INDEX [IX_FragnetActivity_ProjShortName] ON [stngQA].[FragnetActivity]
            (
                   [ProjShortName] ASC
            );
            "
    
       $cmd.commandtext = $sql 
       $cmd.executenonquery()
       $totaltime = $stopwatch.elapsed.totalminutes - $starttime

       write-host "[Time] FragnetActivity: $totaltime minutes"

       write-host "Getting Workdays..."
       $sql = "SELECT CAST(C.DAYDATE AS DATE) AS [Date], 
                     IIF(C.WORKDAYFLAG = 'Y',1,0) AS 'IsWorkday' 
              FROM [P6_DV].[dbo].[P6_CalendarX] C
              WHERE C.CLNDR_ID = '68735' AND C.[CURRENT] = 'Y'
              ORDER BY C.DAYDATE DESC"

       & "$path" -fromservername "LSN_PSTG001,1572" -fromdbname "P6_DV" -destservername "LSN_BE_D,1569" -destdbname "ENG_STG" -destschemaname "stng" -desttblname "WorkDate" -destwinauthentication -fromwinauthentication -execsql $sql
       
       #Import MPL
       & "$psscriptroot\StingrayImportMPL.ps1"

       #Run CARLA-Importer
       & 'H:\Commercial Scheduling\22. Stingray\StingrayDB\Worker\CARLA-Importer\CARLA-Importer.exe'

       #Run additional stored proc, required after MPL import
       $cmd.commandtext = "EXEC [stng].[SP_0024_PostCARLAImport] @Operation=1
                            EXEC [stngQA].[SP_0024_PostCARLAImport] @Operation=1
                            
                            ALTER TABLE [ENG_STG].[stng].[WorkDate] ALTER COLUMN [Date] DATE
                            ALTER TABLE [ENG_STG].[stng].[WorkDate] ALTER COLUMN IsWorkday BIT

                            INSERT INTO stng.ActionLog(Action,ObjectName,StartTime,EndTime,ExecutionMessage)
                            VALUES ('ETL','Stingray_P6CARLA.ps1','$ETL_starttime',GETDATE(),'Success')
              
                            UPDATE stng.ETLLog SET LUD = GETDATE(), LUB = '$env:ComputerName', ETLMethod = 'Powershell on BP Network Machine', Status = 'Complete'
                            WHERE ETLName = 'P6CARLA_Refresh'"
       $cmd.executenonquery()

       $conn.close()
       
       write-host "Process Complete."

       & "$psscriptroot\StingrayGanttChartETL.ps1"
}

catch {
       $date = get-date -format "yyyy-MM-dd"
       write-host "Exception thrown. Script did not execute correctly. Please check error log in Errors Folder"
       
       #Delete old error file if it exists
       switch (get-childitem -path "$psscriptroot\Errors") {

              { $_.name -match "$date-Stingray_P6CARLA" } {

                     remove-item -path $_.fullname -force

              }

       }

       $errorstr = $error | out-string

       [void](new-item -path "$psscriptroot\Errors" -name "$date-Stingray_P6CARLA.txt" -value $errorstr -itemtype "file")


       $sql = "INSERT INTO stng.ActionLog(Action,ObjectName,StartTime,EndTime,ExecutionMessage)
            VALUES ('ETL','Stingray_P6CARLA.ps1',@startTime,GETDATE(),'Failed: '+@errorstr)
            
            UPDATE stng.ETLLog SET LUD = GETDATE(), LUB = @machineId, ETLMethod = 'Powershell on BP Network Machine',Status = 'Error'
            WHERE ETLName = 'P6CARLA_Refresh'"

       $cmd.commandtext = $sql 

       $cmd.Parameters.Add("@startTime", $ETL_starttime);
       $cmd.Parameters.Add("@errorstr", $errorstr);
       $cmd.Parameters.Add("@machineId", $env:ComputerName);
       $cmd.executenonquery()

       $cmd.commandtext = "EXEC msdb.dbo.sp_send_dbmail  
                            @profile_name = 'BE_mail',  
                            @recipients = 'habib.shakibanejad@kinectrics.com',  
                            @copy_recipients = 'arvind.dhinakar@brucepower.com;arvind.dhinakar@kinectrics.com',

                            @subject = 'Stingrary ETL - CARLA Refresh Error Thrown',
                            @body = @errorstr,  
                            @body_format = 'HTML',
                            @importance = 'High';"
                                                
       $cmd.Parameters.Clear()
       $cmd.Parameters.Add("@errorstr", '<p>' + $errorstr + '<p>');
       [void]$cmd.ExecuteNonQuery()
      
       $conn.close()



}
