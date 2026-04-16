#Daily scheduled update script for Stingray Backing Data in ENG_STG

#Set error preference
$erroractionpreference = "Stop"

#Start Stopwatch
$stopwatch = [system.diagnostics.stopwatch]::startnew()

try 
{	

    $ETL_starttime = [DateTime]::Now | Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"

    $conn = new-object system.data.sqlclient.sqlconnection
	$connectionstring = "Server=LSN_BE_D,1569;Database=ENG_STG;Integrated Security=true"
	$conn.connectionstring = $connectionstring
	$conn.open()
	
	$cmd = new-object system.data.sqlclient.sqlcommand
	$cmd.commandtimeout = 2000
	$cmd.connection = $conn
    
    $machineid = $env:ComputerName

	#Populate ETL Log
	$sql = "UPDATE stng.ETLLog SET LUD = GETDATE(), LUB = '$machineid', ETLMethod = 'Powershell on BP Network Machine' WHERE ETLName = 'P6Project'"
    $cmd.commandtext = $sql 
	$cmd.executenonquery()
    
	#Migrate to MSSQL
	$path = "$psscriptroot\API\SQLtoSQL.ps1"

    #Projects to update
    $projects = $args[0]
    
    ## Get P6_Task
    $sql = "SELECT DISTINCT T.PROJ_ID
                ,P.PROJ_SHORT_NAME
                ,T.TASK_CODE
                ,T.TASK_ID
                ,T.TASK_NAME
                ,T.WBS_ID
                ,C.SHORT_NAME AS ACTIVITYCODEVALUE
                ,T.TARGET_START_DATE
                ,T.TARGET_END_DATE_D
                ,T.REEND_DATE
                ,T.ACTUAL_START_DATE
                ,T.ACTUAL_END_DATE               
                ,CASE WHEN T.STATUS_CODE = 'TK_Complete' THEN 'Actualized'
                    WHEN T.STATUS_CODE = 'TK_Active' THEN 'Active'
                    WHEN T.STATUS_CODE = 'TK_NotStart' THEN 'NotStart'
                    ELSE T.STATUS_CODE
                    END AS 'STATUS_CODE'               
                ,T.REMAIN_WORK_QTY
                ,T.TARGET_WORK_QTY
	            INTO #TempActivity
            FROM [P6_DV].[dbo].[P6_Task] T 
			INNER JOIN [P6_DV].[dbo].[P6_TaskActv] B ON T.TASK_ID = B.TASK_ID AND B.ACTV_CODE_TYPE_ID = 427380 AND T.[CURRENT] = 'Y' AND B.[CURRENT] = 'Y' AND T.SNAPSHOT_CHANGE != 'Removed'
			INNER JOIN [P6_DV].[dbo].[P6_Actvcode] C ON B.ACTV_CODE_TYPE_ID = C.ACTV_CODE_TYPE_ID AND C.[CURRENT] = 'Y' AND C.ACTV_CODE_ID = B.ACTV_CODE_ID
			INNER JOIN [P6_DV].[dbo].[P6_Project] P ON T.PROJ_ID = P.PROJ_ID AND P.[CURRENT] = 'Y'
            INNER JOIN [P6_DV].[dbo].[P6_ProjWbs] W ON T.WBS_ID = W.WBS_ID AND W.[CURRENT] = 'Y' AND W.SNAPSHOT_CHANGE != 'Removed'
            WHERE P.PROJ_SHORT_NAME IN ($projects)

            SELECT T.PROJ_ID AS ProjID
                ,T.PROJ_SHORT_NAME AS ProjShortName
                ,T.TASK_CODE AS ActivityID
                ,T.TASK_NAME AS ActivityName
                ,T.WBS_ID AS FragnetID
                ,T.ACTIVITYCODEVALUE AS [N/CSQ]
                ,T.TARGET_START_DATE AS StartDate
                ,T.TARGET_END_DATE_D AS EndDate
                ,T.REEND_DATE AS ReendDate
                ,T.ACTUAL_START_DATE AS ActualStartDate
                ,T.ACTUAL_END_DATE AS ActualEndDate
                ,IIF(T.STATUS_CODE = 'Actualized',1,0) AS [Actualized]
                ,NULL AS [Resource]
                ,T.COMMITMENT_OWNER AS CommitmentOwner
                ,T.STATUS_CODE AS Status
                ,T.REMAIN_WORK_QTY AS 'RemainingHours'
                ,T.TARGET_WORK_QTY AS 'BudgetedHours'
                ,NULL AS [Duration]
            FROM #TempActivity AS T
            UNION
            SELECT DISTINCT T.PROJ_ID
                ,P.PROJ_SHORT_NAME
                ,T.TASK_CODE
                ,T.TASK_NAME
                ,T.WBS_ID
                ,NULL -- Acitivity CODE
                ,T.TARGET_START_DATE
                ,T.TARGET_END_DATE_D
                ,T.REEND_DATE
                ,T.ACTUAL_START_DATE
                ,T.ACTUAL_END_DATE
                ,IIF(T.STATUS_CODE = 'TK_Complete',1,0)
                ,R.RSRC_NAME                
                ,CASE WHEN T.STATUS_CODE = 'TK_Complete' THEN 'Actualized'
                    WHEN T.STATUS_CODE = 'TK_Active' THEN 'Active'
                    WHEN T.STATUS_CODE = 'TK_NotStart' THEN 'NotStart'
                    ELSE T.STATUS_CODE
                    END AS 'Status'
                ,T.REMAIN_WORK_QTY
                ,T.TARGET_WORK_QTY
                ,RX.PLANNEDDURATION
            FROM [P6_DV].[dbo].[P6_Task] T
            INNER JOIN [P6_DV].[dbo].[V_P6.P6_TaskRsrc_Daily_Current] TR ON TR.TASK_ID = T.TASK_ID AND T.[CURRENT] = 'Y' AND T.SNAPSHOT_CHANGE != 'Removed'
            INNER JOIN [P6_DV].[dbo].[V_P6.P6_Rsrc_Daily_Current] R ON R.RSRC_ID = TR.RSRC_ID
            INNER JOIN [P6_DV].[dbo].[P6_Project] P ON T.PROJ_ID = P.PROJ_ID AND P.[CURRENT] = 'Y'
            LEFT JOIN [P6_DV].[dbo].[P6_TaskRsrcX] RX ON RX.TASKRSRC_ID = TR.TASKRSRC_ID AND RX.ACTIVITYID = T.TASK_CODE AND RX.[CURRENT] = 'Y'
            --WHERE T.WBS_ID IN (SELECT A.WBS_ID FROM #TempActivity A)
            WHERE P.PROJ_SHORT_NAME IN ($projects)
            ORDER BY T.TASK_CODE ASC"

    $starttime = $stopwatch.elapsed.totalminutes
	& "$path" -fromservername "LSN_PSTG001,1572" -fromdbname "P6_DV" -destservername "LSN_BE_D,1569" -destdbname "ENG_STG" -destschemaname "temp" -desttblname "FragnetActivity" -destwinauthentication -fromwinauthentication -execsql $sql

    $sql = "UPDATE stng.FragnetActivity SET 
                [ActivityName] = A.ActivityName
                ,[StartDate] = A.StartDate
                ,[EndDate] = A.EndDate
                ,[ReendDate] = A.ReendDate
                ,[ActualStartDate] = A.ActualStartDate
                ,[ActualEndDate] = A.ActualEndDate
                ,[Actualized] = A.Actualized
                ,[Status] = A.[Status]
            FROM temp.FragnetActivity A
            WHERE stng.FragnetActivity.ActivityID = A.ActivityID;
            
            UPDATE stng.MPL SET LastUpdated = GETDATE()
            FROM temp.FragnetActivity A 
            WHERE stng.MPL.[Project ID] = A.ProjShortName
            
            DROP TABLE temp.FragnetActivity"

    $cmd.commandtext = $sql 
	$cmd.executenonquery()
    $totaltime = $stopwatch.elapsed.totalminutes - $starttime

    $sql = "INSERT INTO stng.ActionLog(Action,ObjectName,StartTime,EndTime,ExecutionMessage)
            VALUES ('ETL','P6 Migration - Project Update','$ETL_starttime',GETDATE(),'Success')"

    $cmd.commandtext = $sql 
	$cmd.executenonquery()

	$conn.close()

    write-host "Process Complete."
}

catch 
{
	$date = get-date -format "yyyy-MM-dd"
	write-host "Exception thrown. Script did not execute correctly. Please check error log in Errors Folder"
	
	#Delete old error file if it exists
	switch (get-childitem -path "$psscriptroot\Errors") 
	{

		{$_.name -match "$date-StingrayETLErrors"} {

			remove-item -path $_.fullname -force

		}

	}

    $errorstr = $error|out-string

    $sql = "INSERT INTO stng.ActionLog(Action,ObjectName,StartTime,EndTime,ExecutionMessage)
            VALUES ('ETL','Stingray_P6Project_QA.ps1','$ETL_starttime',GETDATE(),'Failed: $errorstr')"

    $cmd.commandtext = $sql 
	$cmd.executenonquery()
    $conn.close()

	[void](new-item -path "$psscriptroot\Errors" -name "$date-P6MigrationProjectErrors.txt" -value $errorstr -itemtype "file")


}


