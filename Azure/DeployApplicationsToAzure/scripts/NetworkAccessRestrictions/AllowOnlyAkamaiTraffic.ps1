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
$rules = @()
$rules = $rules + (Create-AppServiceAccessRestrictionRuleObjects `
    -FilePath "$scriptDir\AvailabilityTestAgentIpAddresses.txt" `
    -RuleNamePrefix "Azure Av Test: " `
    -RulePriority 100)

$rules = $rules + (Create-AppServiceAccessRestrictionRuleObjects `
    -FilePath "$scriptDir\YourWAFaddress.txt" `
    -RuleNamePrefix "Replace-your-waf-name: " `  #Replace your waf name here
    -RulePriority 200)

Set-AppServiceAccessRestrictionRules `
    -ResourceGroupName $ResourceGroupName `
    -AppServiceName $AppServiceName `
    -AccessRestrictionRules $rules
