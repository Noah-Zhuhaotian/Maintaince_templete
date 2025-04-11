param (
    [string]$cluster,
    [string]$resourcegroup,
    [int]$appmaxcount,
    [int]$appmincount,
    [int]$appnodecount,
    [int]$apposdisksize,
    [string]$apposdisktype,
    [string]$appvmsize,
    [int]$inframaxcount,
    [int]$inframincount,
    [int]$infranodecount,
    [int]$infraosdisksize,
    [string]$infraosdisktype,
    [string]$infravmsize,
    [int]$systemmaxcount,
    [int]$systemmincount,
    [int]$systemnodecount,
    [int]$systemosdisksize,
    [string]$systemosdisktype,
    [string]$systemvmsize,
    [int]$maxpods,
    [string]$Isaddapppool,
    [string]$Isaddinfrapool,
    [string]$Isaddsystempool
    )


$apppoolname=$(az aks nodepool list --cluster-name $cluster --resource-group $resourcegroup --query "[].[name]" --output tsv | findstr "apppool")
$apppoolname1=$($apppoolname -split " ")
$apppoolnamearry=@($apppoolname1)
$infrapoolname=$(az aks nodepool list --cluster-name $cluster --resource-group $resourcegroup --query "[].[name]" --output tsv | findstr "infrapool")
$infrapoolname1=$($infrapoolname -split " ")
$infrapoolnamearry=@($infrapoolname1)
$systempoolname=$(az aks nodepool list --cluster-name $cluster --resource-group $resourcegroup --query "[].[name]" --output tsv | findstr "systempool")
$systempoolname1=$($systempoolname -split " ")
$systempoolnamearry=@($systempoolname1)

$maxnum1 = $apppoolnamearry.length-1
$maxnum2 = $infrapoolnamearry.length-1
$maxnum3 = $systempoolnamearry.length-1

$apppoolnamemax=$apppoolnamearry[$maxnum1]
$infrapoolnamemax=$infrapoolnamearry[$maxnum2]
$systempoolnamemax=$systempoolnamearry[$maxnum3]

$oldapppoolname=$apppoolnamearry[0]
$oldinfrapoolname=$infrapoolnamearry[0]
$oldsystempoolname=$systempoolnamearry[0]

$oldapppoolVersion=$(az aks nodepool list --cluster-name $cluster --resource-group $resourcegroup --query "[?name=='$oldapppoolname'].orchestratorVersion" --output tsv)
$oldinfrapoolVersion=$(az aks nodepool list --cluster-name $cluster --resource-group $resourcegroup --query "[?name=='$oldinfrapoolname'].orchestratorVersion" --output tsv)
$oldsystempoolVersion=$(az aks nodepool list --cluster-name $cluster --resource-group $resourcegroup --query "[?name=='$oldsystempoolname'].orchestratorVersion" --output tsv)

$oldapppoolCount=$(az aks nodepool list --cluster-name $cluster --resource-group $resourcegroup --query "[?name=='$oldapppoolname'].count" --output tsv)
$oldinfrapoolCount=$(az aks nodepool list --cluster-name $cluster --resource-group $resourcegroup --query "[?name=='$oldinfrapoolname'].count" --output tsv)
$oldsystempoolCount=$(az aks nodepool list --cluster-name $cluster --resource-group $resourcegroup --query "[?name=='$oldsystempoolname'].count" --output tsv)

$apppoolnum = $($apppoolnamemax -split "l")
$infrapoolnum = $($infrapoolnamemax -split "l")
$systempoolnum = $($systempoolnamemax -split "l")

$num1 = $($apppoolnum -match '[0-9][0-9]')
$num2 = $($infrapoolnum -match '[0-9][0-9]')
$num3 = $($systempoolnum -match '[0-9][0-9]')

$result1 = [int]$num1+1
$result2 = [int]$num2+1
$result3 = [int]$num3+1

if ($Isaddapppool -eq "true"){
    if ($result1 -lt 10){
      az aks nodepool add --cluster-name $cluster --name apppool0$result1 --resource-group $resourcegroup --enable-cluster-autoscaler --kubernetes-version $oldapppoolVersion --max-count $appmaxcount --max-pods $maxpods --min-count $appmincount --mode User --node-count $oldapppoolCount --node-osdisk-size $apposdisksize --node-osdisk-type $apposdisktype --node-vm-size $appvmsize --os-sku Ubuntu --os-type Linux --max-surge 33%
      Write-Output "The apppool0$result1 has been created."
    }
    if ($result1 -ge 10){
        az aks nodepool add --cluster-name $cluster --name apppool$result1 --resource-group $resourcegroup --enable-cluster-autoscaler --kubernetes-version $oldapppoolVersion --max-count $appmaxcount --max-pods $maxpods --min-count $appmincount --mode User --node-count $oldapppoolCount --node-osdisk-size $apposdisksize --node-osdisk-type $apposdisktype --node-vm-size $appvmsize --os-sku Ubuntu --os-type Linux --max-surge 33%
        Write-Output "The apppool$result1 has been created."
    }
}

if ($Isaddinfrapool -eq "true"){   
    if ($result2 -lt 10){
      az aks nodepool add --cluster-name $cluster --name infrapool0$result2 --resource-group $resourcegroup --enable-cluster-autoscaler --kubernetes-version $oldinfrapoolVersion --max-count $inframaxcount --max-pods $maxpods --min-count $inframincount --mode User --node-count $oldinfrapoolCount --node-osdisk-size $infraosdisksize --node-osdisk-type $infraosdisktype --node-vm-size $infravmsize --os-sku Ubuntu --os-type Linux --max-surge 33% --node-taints infra=true:NoSchedule --labels nodepool=infrapool
      Write-Output "The infrapool0$result2 has been created."
    }
    if ($result2 -ge 10){
      az aks nodepool add --cluster-name $cluster --name infrapool$result2 --resource-group $resourcegroup --enable-cluster-autoscaler --kubernetes-version $oldinfrapoolVersion --max-count $inframaxcount --max-pods $maxpods --min-count $inframincount --mode User --node-count $oldinfrapoolCount --node-osdisk-size $infraosdisksize --node-osdisk-type $infraosdisktype --node-vm-size $infravmsize --os-sku Ubuntu --os-type Linux --max-surge 33% --node-taints infra=true:NoSchedule --labels nodepool=infrapool
      Write-Output "The infrapool$result2 has been created."
    }
}

if ($Isaddsystempool -eq "true"){
    if ($result3 -lt 10){
      az aks nodepool add --cluster-name $cluster --name systempool0$result3 --resource-group $resourcegroup --enable-cluster-autoscaler --kubernetes-version $oldsystempoolVersion --max-count $systemmaxcount --max-pods $maxpods --min-count $systemmincount --mode System --node-count $oldsystempoolCount --node-osdisk-size $systemosdisksize --node-osdisk-type $systemosdisktype --node-vm-size $systemvmsize --os-sku Ubuntu --os-type Linux --max-surge 33% --node-taints CriticalAddonsOnly=true:NoSchedule
      Write-Output "The systempool0$result3 has been created."
    }
    if ($result3 -ge 10){
      az aks nodepool add --cluster-name $cluster --name systempool$result3 --resource-group $resourcegroup --enable-cluster-autoscaler --kubernetes-version $oldsystempoolVersion --max-count $systemmaxcount --max-pods $maxpods --min-count $systemmincount --mode System --node-count $oldsystempoolCount --node-osdisk-size $systemosdisksize --node-osdisk-type $systemosdisktype --node-vm-size $systemvmsize --os-sku Ubuntu --os-type Linux --max-surge 33% --node-taints CriticalAddonsOnly=true:NoSchedule
      Write-Output "The systempool$result3 has been created."
    }
}
