#Script for updating all dotnet packages in Stingray-API

$erroractionpreference = "Stop"

$apipath = "C:\Users\612497\Documents\Stingray-API"

$exemptions = @("EPPlus")
$specificVersions = @{"Microsoft.AspNetCore.Authentication.JwtBearer"="6.0.29";"Microsoft.AspNetCore.Authentication.OpenIdConnect"="6.0.29"}

cd $apipath
$packageRaw = dotnet list package --outdated

$regexProj = [system.text.regularexpressions.regex]::new('(?<=(Project\s\`))([^\`]+)(?=\`)')

$projects = $regexProj.matches($packageRaw)

$projCount = $projects.count
for($i = 0; $i -lt $projCount; $i++)
{
	$project = $projects[$i]
	$startIndex = $project.index

	$project.value

	if($i -eq ($projCount - 1))
	{
		$stopIndex = $packageRaw.tochararray().length
	}

	else
	{
		$stopIndex = $projects[$i + 1].index
	}
	
	#Go to project folder
	cd ("./" + $project)

	#Get packages
	$regexPackage = [system.text.regularexpressions.regex]::new("([^\s]+)((\s)+)([0-9\.]+)((\s)+)([0-9\.]+)((\s)+)([0-9\.]+)")

	$packages = $regexPackage.matches($packageRaw, $startIndex)

	#Update packages
	foreach($package in $packages)
	{
		if($package.index -ge $stopIndex)
		{
			break
		}

		$packageName = [system.text.regularexpressions.regex]::match($package,"^[^\s]+(?=\s)").value
		$packageName
	
		if(!$exemptions.contains($packageName))
		{
			if($specificVersions.containskey($packageName))
			{
				$update = dotnet add package $packageName -v $specificVersions[$packageName]
			}

			else
			{
				$update = dotnet add package $packageName 		
			}

			if($lastexitcode -ne 0)
			{
				write-host "Error occurred during executing of package update"
				$update
			}
		}

		else
		{
			write-host "Exempted"
		}
	}

	#Go back to root dir
	cd ../

}