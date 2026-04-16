#Daily scheduled script to generate Gantt Chart File for Planners

#Set error preference
$erroractionpreference = "Stop"

#Add assemblies
[void][system.reflection.assembly]::loadwithpartialname('microsoft.office.interop.excel')

## - Create an Excel Application instance:
write-host "Create an Excel Application instance"
$xlsObj = New-Object -ComObject Excel.Application;
$ETL_starttime = [DateTime]::Now | Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
$SaveDate = [DateTime]::Now | Get-Date -Format "dd-MMM-yy HH.mm.ss"

try
{
    ## ---------- Working with SQL Server ---------- ##

    ## - Get SQL Server Table data:
    write-host "Get SQL Server Table data:"
    $SQLServer = 'LSN_BE_D,1569';
    $Database = 'ENG_STG';
    $SqlQuery = "SELECT M.[Project Name],
                    M.[CS-PCS],
                       V.ActivityID, 
                       V.ActivityName,
                       V.SubFragnetName,
                       V.FragnetName,
                       V.ActualStartDate,
                       V.AnticipatedStartDate,
                       V.ActualFinishDate,
                       V.AnticipatedFinishDate,
                       C.Comments 
                FROM stngQA.VV_0027_P6UpdateRequired V 
                INNER JOIN stng.MPL M on M.[Project ID] = V.ProjectID
                LEFT JOIN (
                       SELECT ActivityID, 
                       STRING_AGG((DetailName + '# ' + DetailValue), ', ') AS Comments 
                       FROM stngQA.FragnetActivityDetail GROUP BY ActivityID
                ) C ON C.ActivityID = V.ActivityID 
                ORDER BY V.ProjectID,  V.ActivityID, V.FragnetName, V.SubFragnetName";

    ## - Connect to SQL Server using non-SMO class 'System.Data
    write-host "Connect to SQL Server...'"
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection;
    $SqlConnection.ConnectionString = "Server = $SQLServer; Database = $Database; Integrated Security = True";
    $SqlConnection.open()

    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand;
    $SqlCmd.commandtext = $SqlQuery;
    $SqlCmd.Connection = $SqlConnection;

    ## - Extract and build the SQL data object '$DataSetTable':
    write-host "Filling Data Table..."
    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter;
    $SqlAdapter.SelectCommand = $SqlCmd;
    $DataSet = New-Object System.Data.DataSet;
    $SqlAdapter.Fill($DataSet);
    $DataSetTable = $DataSet.Tables["Table"];

    ## ---------- Working with Excel ---------- ##

    $FilePath = "H:\EMPC\ENGETL\ForImport\GanttChartGeneratorTemplate.xltm"


    $xlsObj.DisplayAlerts = $false;

    ## - Create new Workbook and Sheet (Visible = 1 / 0 not visible)
    write-host "Create new Workbook and Sheet"
    $xlsObj.Visible = 0;
    $WorkBook = $xlsObj.Workbooks.Open($FilePath);

    ## - Copy entire table to the clipboard as tab delimited CSV
    write-host "Copy and Paste table to Excel"
    $DataSetTable | ConvertTo-Csv -NoType -Del "`t" | Clip;

    ## - Paste table to Excel
    $xlsObj.ActiveCell.PasteSpecial() | Out-Null;

    ## - Set columns to auto-fit width
    $xlsObj.ActiveSheet.UsedRange.Columns|%{$_.AutoFit()|Out-Null};

    ## - Run Excel Macro within Template File to generate Gantt Chart
    write-host "Run Excel Macro within Template File to generate Gantt Chart"
    $app = $xlsObj.Application
    $app.run("GanttChartBuilder", $SqlQuery)

    ## - Create Timestamp and Save a copy of File to destination and close original template file unsaved
    write-host "Saving File..."
    $ext=".xlsx";
    $path="H:\Commercial Scheduling\22. Stingray\StingrayQA\QAGanttChart\Gantt Chart Updates - $SaveDate$ext";
    $xlsObj.DisplayAlerts = $false;
    $WorkBook.SaveAs($path);
    $WorkBook.Close;
    $xlsObj.Quit();

    write-host "Adding Entry into the ActionLog SQL Table to show work's been completed"
    $sql = "INSERT INTO stng.ActionLog(Action,ObjectName,StartTime,EndTime,ExecutionMessage)
            VALUES ('ETL','StingrayGanttChartETL.ps1','$ETL_starttime',GETDATE(), 'Success');"

    $SqlCmd.commandtext = $sql 
    $SqlCmd.executenonquery()
    write-host "Process Complete."
}

catch 
{
    $xlsObj.Quit();
    $date = get-date -format "yyyy-MM-dd";
    write-host "Exception thrown. Script did not execute correctly. Please check error log in Errors Folder";

    #Delete old error file if it exists
    switch (get-childitem -path "$psscriptroot\Errors") 
    {

            {$_.name -match "$date-StingrayGanttChartErrors"} {

                    remove-item -path $_.fullname -force

            }

    };
       
    $errorstr = $error|out-string;
    [void](new-item -path "$psscriptroot\Errors" -name "$date-StingrayGanttChartErrors.txt" -value $errorstr -itemtype "file");
   
    $sql = "INSERT INTO stng.ActionLog(Action,ObjectName,StartTime,EndTime,ExecutionMessage)
            VALUES ('ETL','StingrayGanttChartETL.ps1','$ETL_starttime',GETDATE(), 'Failed: See ETL Error Logs');"

    $SqlCmd.commandtext = $sql 
    $SqlCmd.executenonquery()
} 
