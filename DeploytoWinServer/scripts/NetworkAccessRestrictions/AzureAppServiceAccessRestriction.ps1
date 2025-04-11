function Get-AppServiceAccessRestrictionRules
{
    Param
    (       
        # Name of the resource group that contains the App Service.
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ResourceGroupName, 
 
        # Name of your Web or API App.
        [Parameter(Mandatory=$true, Position=1)]
        [string]$AppServiceName
    )

    Write-Host ("================================================================================")
    Write-Host ("Get-AppServiceAccessRestrictionRules")
    Write-Host ("    ResourceGroupName: [{0}]" -f $ResourceGroupName)
    Write-Host ("    AppServiceName:    [{0}]" -f $AppServiceName)
    Write-Host ("================================================================================")

    #$ApiVersion = Get-AzureRmResourceProvider -ProviderNamespace Microsoft.Web `
    $ApiVersion = Get-AzResourceProvider -ProviderNamespace Microsoft.Web `
        | Select-Object -ExpandProperty ResourceTypes `
        | Where-Object ResourceTypeName -eq 'sites' `
        | Select-Object -ExpandProperty ApiVersions `
        | Select -First 1
 
    #$WebAppConfig = Get-AzureRmResource `
    $WebAppConfig = Get-AzResource `
        -ResourceType 'Microsoft.Web/sites/config' `
        -ResourceName $AppServiceName `
        -ResourceGroupName $ResourceGroupName `
        -ApiVersion $ApiVersion

    return $WebAppConfig.Properties.ipSecurityRestrictions
}

function Set-AppServiceAccessRestrictionRules
{
    [CmdletBinding()]
    Param
    (
        # Name of the resource group that contains the App Service.
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ResourceGroupName, 
 
        # Name of your Web or API App.
        [Parameter(Mandatory=$true, Position=1)]
        [string]$AppServiceName, 
 
        [Parameter(Mandatory=$false, Position=2)]
        [object[]]$AccessRestrictionRules = @()
    )
 
    Write-Host ("================================================================================")
    Write-Host ("Set-AppServiceAccessRestrictionRules")
    Write-Host ("    ResourceGroupName:       [{0}]" -f $ResourceGroupName)
    Write-Host ("    AppServiceName:          [{0}]" -f $AppServiceName)
    Write-Host ("    AccessRestrictionRules:  [{0}]" -f $AccessRestrictionRules.Count)
    Write-Host ("================================================================================")

    $ApiVersion = Get-AzResourceProvider -ProviderNamespace Microsoft.Web `
        | Select-Object -ExpandProperty ResourceTypes `
        | Where-Object ResourceTypeName -eq 'sites' `
        | Select-Object -ExpandProperty ApiVersions `
        | Select -First 1
 
    $WebAppConfig = Get-AzResource `
        -ResourceType 'Microsoft.Web/sites/config' `
        -ResourceName $AppServiceName `
        -ResourceGroupName $ResourceGroupName `
        -ApiVersion $ApiVersion

    Write-Host ("================================================================================")
    Write-Host ("Current Rules")
    Write-Host ("================================================================================")
    $WebAppConfig.Properties.ipSecurityRestrictions | ft *

    Write-Host ("================================================================================")
    Write-Host ("Desired Rules")
    Write-Host ("================================================================================")
    $AccessRestrictionRules | ft *

    # Save rules
    $WebAppConfig.Properties.ipSecurityRestrictions = $AccessRestrictionRules
    $WebAppConfig = Set-AzResource `
        -ResourceId $WebAppConfig.ResourceId `
        -Properties $WebAppConfig.Properties `
        -ApiVersion $ApiVersion -Force 

    Write-Host ("================================================================================")
    Write-Host ("New Rules")
    Write-Host ("================================================================================")
    $WebAppConfig.Properties.ipSecurityRestrictions | ft *
}

function Create-AppServiceAccessRestrictionRuleObjects
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$FilePath,

        [Parameter(Mandatory=$false, Position=1)]
        [string]$RuleNamePrefix = $null,

        [Parameter(Mandatory=$false, Position=2)]
        [int32]$RulePriority = 100
    )

    Write-Host ("================================================================================")
    Write-Host ("Create-AppServiceAccessRestrictionRuleObjects")
    Write-Host ("    FilePath:       [{0}]" -f $FilePath)
    Write-Host ("    RuleNamePrefix: [{0}]" -f $RuleNamePrefix)
    Write-Host ("    RulePriority:   [{0}]" -f $RulePriority)
    Write-Host ("================================================================================")

    $file = Get-Content $FilePath
    $lines = $file.Split([Environment]::NewLine)

    $isHeader = $true
    $currentGroup = $null;

    $rules = @();
    ForEach($line in $lines)
    {
        if($isHeader)
        {
            $currentGroup = $line;
            $isHeader = $false
            continue
        }

        if([System.String]::IsNullOrEmpty($Line))
        {
            $isHeader = $True #next line will be header
            continue
        }

        $ip = $null
        if($line.Contains("/"))
        {
            $ip = $line;
        }
        else
        {
            $ip = "$line/32";
        }

        $ruleName = $currentGroup
        if ($RuleNamePrefix -ne $null)
        {
            $ruleName = $RuleNamePrefix + $currentGroup
        }

        $rule = [PSCustomObject]@{
            ipAddress = $ip
            action = "Allow"
            priority = $RulePriority + $rules.Count + 1;
            name = $ruleName
            description = ""
            tag = "Default"
        }
        $rules = $rules + $rule
    }

    #$rules | ft *

    return $rules
}