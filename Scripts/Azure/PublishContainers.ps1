#Define Classes and Enums
enum ContainerType{
	API = 1
	FE = 2

}

enum EnvType{
	Development = 1
	QA = 2
	Production = 3
}

class Container{
	[ContainerType]$containerType
	[string]$imageName
	[string]$appServiceName
	
	Container([ContainerType]$containerType, [string]$imageName, [string]$appServiceName){
	
		$this.containerType = $containerType
		$this.imageName = $imageName
		$this.appServiceName = $appServiceName
	
	}

}

class DeployEnv{
	[string]$subscription
	[string]$resourceGroup
	[string]$registry
	[Container]$api
	[Container]$fe
	[EnvType] $envType
	
	DeployEnv([string]$subscription, [string]$resourceGroup, [string]$registry, [Container]$api, [Container]$fe, [EnvType]$envType){
		
		$this.subscription = $subscription
		$this.resourceGroup = $resourceGroup
		$this.registry = $registry
		$this.envType = $envType
		
		if($api.containerType -ne [ContainerType]::API)
		{
			throw "api argument to DeployEnv is not of ContainerType API"
		}
		
		$this.api = $api
		
		if($fe.containerType -ne [ContainerType]::FE)
		{
			throw "fe argument to DeployEnv is not of ContainerType FE"
		}
		
		$this.fe = $fe
	
	}

}

#Paths to api and fe root code directories
$apipath = "C:\Users\612497\Documents\Stingray-API"
$fepath = "C:\Users\612497\Documents\Stingray-FE"

#Login to Azure
write-host "Performing Azure login ... "
az login

#Instantiate Containers
write-host "Instantiating Container objects ... "
#DEV
$devapi = [Container]::new([ContainerType]::API,"stingraydevapi/test","stingraydevapi")
$devfe = [Container]::new([ContainerType]::FE,"stingraydevfe/test","stingraydevfe")

#QA
$qaapi = [Container]::new([ContainerType]::API,"stingrayqaapi/test","stingrayqaapi")
$qafe = [Container]::new([ContainerType]::FE,"stingrayqafe/test","stingrayqafe")

#PROD
$prodapi = [Container]::new([ContainerType]::API,"stingrayprodapi/test","stingrayprodapi")
$prodfe = [Container]::new([ContainerType]::FE,"stingrayprodfe/test","stingrayprodfe")

#Instantiate DeployEnvs
write-host "Instantiating DeployEnv objects"
$deployEnvs = @(
<#
	#DEV
	[DeployEnv]::new(
		"04117318-1568-44be-92fd-c64815fb9ed0",
		"RG-Stingray-DEV_1.0_PaaS_DevQA-01",
		"acrccstingraydev",
		$devapi,
		$devfe,
		[EnvType]::Development
	)
	#>,
	#QA
	[DeployEnv]::new(
		"04117318-1568-44be-92fd-c64815fb9ed0",
		"RG-Stingray-QA_1.0_PaaS_DevQA-01",
		"acrccstingrayqa",
		$qaapi,
		$qafe,
		[EnvType]::QA
	)
	<#
	,
	#PROD
	[DeployEnv]::new(
		"84141255-e6df-440c-8db8-ec33f16d1013",
		"RG-Stingray-PROD_1.0_Paas_Prod-01",
		"acrccstingrayprod",
		$prodapi,
		$prodfe,
		[EnvType]::Production
	)
	#>
)

$attempts = 3

foreach($deployEnv in $deployEnvs)
{
	write-host "Operations for DeployEnv" $deployEnv.envType.toString()

	#Set subscription
	$currentattempt = 1
	
	while($currentattempt -le $attempts)
	{
		az account set --subscription $deployEnv.subscription
		
		if($lastexitcode -eq 0)
		{
			break
		}
		
		$currentattempt++
	}
	
	if($lastexitcode -ne 0)
	{
		throw "Error setting subscription for " + $deployEnv.envType.toString()
	}
	
	#API
	write-host "API"
	cd $apipath
	
	#Alter Dockerfile
	(get-content -path "$apipath\Dockerfile") -replace "(?<=(ENV\sASPNETCORE_ENVIRONMENT\s)).+$", $deployEnv.envType.toString() | set-content -path "$apipath\Dockerfile"
		
	#Write to Azure and restart AAS
	$currentattempt = 1
	
	while($currentattempt -le $attempts)
	{
		az acr build -g $deployEnv.resourceGroup -r $deployEnv.registry -t $deployEnv.api.imageName .

		if($lastexitcode -eq 0)
		{
			break
		}
		
		$currentattempt++
	}
	
	if($lastexitcode -ne 0)
	{
		throw "Error building container for " + $deployEnv.envType.toString() + " API"
	}
	
	$currentattempt = 1
	
	while($currentattempt -le $attempts)
	{
		az webapp restart -n $deployEnv.api.appServiceName -g $deployEnv.resourceGroup
	
		if($lastexitcode -eq 0)
		{
			break
		}
		
		$currentattempt++
	}
		
	if($lastexitcode -ne 0)
	{
		throw "Error restarting AAS for " + $deployEnv.envType.toString() + " API"
	}
	
	#FE
	write-host "FE"
	cd $fepath
	
	#Alter env file
	set-content -path "$fepath\.env" -value ("REACT_APP_ENV=" + $deployEnv.envType.toString())
		
	#Write to Azure and restart AAS
	
	$currentattempt = 1
	
	while($currentattempt -le $attempts)
	{
		az acr build -g $deployEnv.resourceGroup -r $deployEnv.registry -t $deployEnv.fe.imageName .

		if($lastexitcode -eq 0)
		{
			break
		}
		
		$currentattempt++		
	}
		
	if($lastexitcode -ne 0)
	{
		throw "Error building container for " + $deployEnv.envType.toString() + " FE"
	}
	
	$currentattempt = 1
	
	while($currentattempt -le $attempts)
	{
		az webapp restart -n $deployEnv.fe.appServiceName -g $deployEnv.resourceGroup

		if($lastexitcode -eq 0)
		{
			break
		}
		
		$currentattempt++
		
	}
	
	if($lastexitcode -ne 0)
	{
		throw "Error restarting AAS for " + $deployEnv.envType.toString() + " FE"
	}

}