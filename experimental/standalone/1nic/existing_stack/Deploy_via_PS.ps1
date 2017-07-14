## Script parameters being asked for below match to parameters in the azuredeploy.json file, otherwise pointing to the ##
## azuredeploy.parameters.json file for values to use.  Some options below are mandatory, some(such as region) can     ##
## be supplied inline when running this script but if they aren't then the default will be used as specificed below.   ##
## Example Command: .\Deploy_via_PS.ps1 -licenseType PAYG -licensedBandwidth 200m -adminUsername azureuser -adminPassword <value> -dnsLabel <value> -instanceName f5vm01 -instanceType Standard_DS2_v2 -imageName Good -bigIpVersion 13.0.021 -vnetName <value> -vnetResourceGroupName <value> -mgmtSubnetName <value> -mgmtIpAddress <value> -ntpServer 0.pool.ntp.org -timeZone UTC -restrictedSrcAddress "*" -resourceGroupName <value>

param(

  [Parameter(Mandatory=$True)]
  [string]
  $licenseType,

  [string]
  $licensedBandwidth = $(if($licenseType -eq "PAYG") { Read-Host -prompt "licensedBandwidth"}),

  [string]
  $licenseKey1 = $(if($licenseType -eq "BYOL") { Read-Host -prompt "licenseKey1"}),

  [string]
  $bigIqLicenseHost = $(if($licenseType -eq "BIGIQ") { Read-Host -prompt "bigIqLicenseHost"}),

  [string]
  $bigIqLicenseUsername = $(if($licenseType -eq "BIGIQ") { Read-Host -prompt "bigIqLicenseUsername"}),

  [string]
  $bigIqLicensePassword = $(if($licenseType -eq "BIGIQ") { Read-Host -prompt "bigIqLicensePassword"}),

  [string]
  $bigIqLicensePool = $(if($licenseType -eq "BIGIQ") { Read-Host -prompt "bigIqLicensePool"}),

  [Parameter(Mandatory=$True)]
  [string]
  $adminUsername,

  [Parameter(Mandatory=$True)]
  [string]
  $adminPassword,

  [Parameter(Mandatory=$True)]
  [string]
  $dnsLabel,

  [Parameter(Mandatory=$True)]
  [string]
  $instanceName,

  [Parameter(Mandatory=$True)]
  [string]
  $instanceType,

  [Parameter(Mandatory=$True)]
  [string]
  $imageName,

  [Parameter(Mandatory=$True)]
  [string]
  $bigIpVersion,

  [Parameter(Mandatory=$True)]
  [string]
  $vnetName,

  [Parameter(Mandatory=$True)]
  [string]
  $vnetResourceGroupName,

  [Parameter(Mandatory=$True)]
  [string]
  $mgmtSubnetName,

  [Parameter(Mandatory=$True)]
  [string]
  $mgmtIpAddress,

  [Parameter(Mandatory=$True)]
  [string]
  $ntpServer,

  [Parameter(Mandatory=$True)]
  [string]
  $timeZone,

  [string]
  $restrictedSrcAddress = "*",

  [Parameter(Mandatory=$True)]
  [string]
  $resourceGroupName,

  [string]
  $region = "West US",

  [string]
  $templateFilePath = "azuredeploy.json",

  [string]
  $parametersFilePath = "azuredeploy.parameters.json"
)

Write-Host "Disclaimer: Scripting to Deploy F5 Solution templates into Cloud Environments are provided as examples. They will be treated as best effort for issues that occur, feedback is encouraged." -foregroundcolor green
Start-Sleep -s 3

# Connect to Azure, right now it is only interactive login
try {
    Write-Host "Checking if already logged in!"
    Get-AzureRmSubscription | Out-Null
    Write-Host "Already logged in, continuing..."
    }
    Catch {
    Write-Host "Not logged in, please login..."
    Login-AzureRmAccount
    }

# Create Resource Group for ARM Deployment
New-AzureRmResourceGroup -Name $resourceGroupName -Location "$region"

# Create Arm Deployment
$pwd = ConvertTo-SecureString -String $adminPassword -AsPlainText -Force
if ($licenseType -eq "BYOL") {
  if ($templateFilePath -eq "azuredeploy.json") { $templateFilePath = ".\BYOL\azuredeploy.json"; $parametersFilePath = ".\BYOL\azuredeploy.parameters.json" }
  $deployment = New-AzureRmResourceGroupDeployment -Name $resourceGroupName -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath -Verbose -adminUsername "$adminUsername" -adminPassword $pwd -dnsLabel "$dnsLabel" -instanceName "$instanceName" -instanceType "$instanceType" -imageName "$imageName" -bigIpVersion "$bigIpVersion" -vnetName "$vnetName" -vnetResourceGroupName "$vnetResourceGroupName" -mgmtSubnetName "$mgmtSubnetName" -mgmtIpAddress "$mgmtIpAddress" -ntpServer "$ntpServer" -timeZone "$timeZone" -restrictedSrcAddress "$restrictedSrcAddress"  -licenseKey1 "$licenseKey1"
} elseif ($licenseType -eq "PAYG") {
  if ($templateFilePath -eq "azuredeploy.json") { $templateFilePath = ".\PAYG\azuredeploy.json"; $parametersFilePath = ".\PAYG\azuredeploy.parameters.json" }
  $deployment = New-AzureRmResourceGroupDeployment -Name $resourceGroupName -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath -Verbose -adminUsername "$adminUsername" -adminPassword $pwd -dnsLabel "$dnsLabel" -instanceName "$instanceName" -instanceType "$instanceType" -imageName "$imageName" -bigIpVersion "$bigIpVersion" -vnetName "$vnetName" -vnetResourceGroupName "$vnetResourceGroupName" -mgmtSubnetName "$mgmtSubnetName" -mgmtIpAddress "$mgmtIpAddress" -ntpServer "$ntpServer" -timeZone "$timeZone" -restrictedSrcAddress "$restrictedSrcAddress"  -licensedBandwidth "$licensedBandwidth"
} elseif ($licenseType -eq "BIGIQ") {
  if ($templateFilePath -eq "azuredeploy.json") { $templateFilePath = ".\BIGIQ\azuredeploy.json"; $parametersFilePath = ".\BIGIQ\azuredeploy.parameters.json" }
  $bigiq_pwd = ConvertTo-SecureString -String $bigIqLicensePassword -AsPlainText -Force
  $deployment = New-AzureRmResourceGroupDeployment -Name $resourceGroupName -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath -Verbose -adminUsername "$adminUsername" -adminPassword $pwd -dnsLabel "$dnsLabel" -instanceName "$instanceName" -instanceType "$instanceType" -imageName "$imageName" -bigIpVersion "$bigIpVersion" -vnetName "$vnetName" -vnetResourceGroupName "$vnetResourceGroupName" -mgmtSubnetName "$mgmtSubnetName" -mgmtIpAddress "$mgmtIpAddress" -ntpServer "$ntpServer" -timeZone "$timeZone" -restrictedSrcAddress "$restrictedSrcAddress"  -bigIqLicenseHost "$bigIqLicenseHost" -bigIqLicenseUsername "$bigIqLicenseUsername" -bigIqLicensePassword $bigiq_pwd -bigIqLicensePool "$bigIqLicensePool"
} else {
  Write-Error -Message "Please select a valid license type of PAYG, BYOL or BIGIQ."
}

# Print Output of Deployment to Console
$deployment