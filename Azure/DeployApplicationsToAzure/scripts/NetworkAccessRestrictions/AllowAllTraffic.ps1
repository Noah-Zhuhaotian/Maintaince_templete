[CmdletBinding()]
Param
(
    # Name of the resource group that contains the App Service.
    [Parameter(Mandatory=$true, Position=0)]
    [string]$ResourceGroupName, 
 
    # Name of your Web or API App.
    [Parameter(Mandatory=$true, Position=1)]
    [string]$AppServiceName
)

# Identify directory of running script
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

# Load supporting functions
. $scriptDir\AzureAppServiceAccessRestriction.ps1

# Set accessrules
Set-AppServiceAccessRestrictionRules `
    -ResourceGroupName $ResourceGroupName `
    -AppServiceName $AppServiceName
