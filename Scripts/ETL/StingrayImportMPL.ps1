#Daily scheduled update script for Stingray Backing Data in ENG_STG

#Set error preference
$erroractionpreference = "Stop"

#Start Stopwatch
$stopwatch = [system.diagnostics.stopwatch]::startnew()

#Add assemblies
[void][system.reflection.assembly]::loadwithpartialname('microsoft.office.interop.excel')	

#Declare Excel .NET class
$excel = new-object microsoft.office.interop.excel.applicationclass
$excel.visible = $false

try 
{	


	

    write-host "Importing MPL... "
    #Import MPL to MSSQL before ImportCARLA proc
	[hashtable]$mappingMPL = @{"Project ID"="nvarchar(255) null";"Project Name"="nvarchar(255) null";"Portfolio"="nvarchar(255) null";"Funding"="nvarchar(255) null";"Status"="nvarchar(255) null";"CS-PCS"="nvarchar(255) null";"OE"="nvarchar(255) null";"Project Manager"="nvarchar(255) null";"Project Planner"="nvarchar(255) null";"Program Manager"="nvarchar(255) null";"Material Buyer"="nvarchar(255) null";"Contract Admin"="nvarchar(255) null";"Service Buyer"="nvarchar(255) null";"Buyer Analyst"="nvarchar(255) null";"CS FLM"="nvarchar(255) null";"ContractSpecialist"="nvarchar(255) null";"CostAnalyst"="nvarchar(255) null";"FastTrack"="nvarchar(255) null"}
    [hashtable]$namemappingMPL = @{"Owner's Engineer"="OE";"Contract Spec / RFI Support"="ContractSpecialist";"Cost Analyst"="CostAnalyst";"Fast Track"="FastTrack"}

    $xlsxpathMPL = "\\corp.brucepower.com\common`$\Commercial Scheduling\9. Reports\MPL\"
    $latestfileMPL = $xlsxpathMPL + (gci -path $xlsxpathMPL | where-object {$_.name -match "CS\-MPL" -and $_.name -match "\.xlsm"} | sort-object creationtime | select-object -last 1).name
    
    & "$psscriptroot\API\ExceltoSQL.ps1" -filepath $latestfileMPL -shtname "MPL" -destservername "LSN_BE_D,1569" -destdbname "ENG_STG" -destschemaname "stng" -desttblname "MPL" -destwinauthentication -manualmappingtbl $mappingMPL -namemappingtbl $namemappingMPL


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
}


