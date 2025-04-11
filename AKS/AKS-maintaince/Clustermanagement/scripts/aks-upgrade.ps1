param (
    [string]$resourcegroup,
    [string]$cluster,
    [string]$forupgradeversion
    )

# Create a function to sort the versions of upgrade
function sortUpgradesArray {
    param (
        $inputUpgrades
    )

    for ($i = 0; $i -le $inputUpgrades.length - 1; $i++){
        for ($j = $i + 1; $j -le $inputUpgrades.length - 1; $j++){
            $ai1 = $inputUpgrades[$i] -split "\."
            $aj1 = $inputUpgrades[$j] -split "\."
            if(($ai1[0] -eq $aj1[0]) -and ($ai1[1] -eq $aj1[1]) -and ($ai1[2] -gt $aj1[2])){
                $s = $inputUpgrades[$i]
                $inputUpgrades[$i] = $inputUpgrades[$j]
                $inputUpgrades[$j] = $s
            }
            elseif (($ai1[0] -eq $aj1[0]) -and ($ai1[1] -gt $aj1[1])) {
                $s = $inputUpgrades[$i]
                $inputUpgrades[$i] = $inputUpgrades[$j]
                $inputUpgrades[$j] = $s
            }
            elseif (($ai1[0] -gt $aj1[0])) {
                $s = $inputUpgrades[$i]
                $inputUpgrades[$i] = $inputUpgrades[$j]
                $inputUpgrades[$j] = $s
            }
            $ai1=@()
            $aj1=@()
        }
    }
    return $inputUpgrades
}

# Init the version 
$isNotContainUpgradeVersion = $true
$upgrades=$(az aks get-upgrades --resource-group $resourcegroup --name $cluster --query "controlPlaneProfile.upgrades[].kubernetesVersion" --output tsv)
$sortUpgrades = sortUpgradesArray -inputUpgrades $upgrades
Write-Output $sortUpgrades

# Upgrade the version untill the controlPlaneProfile contains the forupgradeversion
while($isNotContainUpgradeVersion){
    if($sortUpgrades -contains $forupgradeversion){
        $isNotContainUpgradeVersion = $false
    }else{
        for ($a = 0; $a -le $sortUpgrades.length - 1; $a += 1){
            az aks upgrade --resource-group $resourcegroup --name $cluster --control-plane-only --no-wait --kubernetes-version $sortUpgrades[$a] -y
            $num = 1
            do {
                $status=$(az aks show --name $cluster --resource-group $resourcegroup --query "provisioningState" --output tsv)
                $num+= 1
                Write-Output "Awaiting for upgrading $num..."
                $k=$sortUpgrades[$a]
            }
            until($status -eq "Succeeded")
            Write-Output "The $k has been upgraded successfully!"
        }
        $upgrades=$(az aks get-upgrades --resource-group $resourcegroup --name $cluster --query "controlPlaneProfile.upgrades[].kubernetesVersion" --output tsv)
        $sortUpgrades = sortUpgradesArray -inputUpgrades $upgrades
    }
}

# Get the index of version
Write-Output $sortUpgrades
for ($a = 0; $a -le ($sortUpgrades.length - 1); $a += 1){
    if ($sortUpgrades[$a] -eq $forupgradeversion){
        $element=$a
        Write-Output $element
    }
}

# Upgrade the version untill the control Plane is upgraded to forupgradeversion
for ($a = 0; $a -le $element; $a += 1){
    az aks upgrade --resource-group $resourcegroup --name $cluster --control-plane-only --no-wait --kubernetes-version $sortUpgrades[$a] -y
    $num = 1
    do {
        $status=$(az aks show --name $cluster --resource-group $resourcegroup --query "provisioningState" --output tsv)
        $num+= 1
        Write-Output "Awaiting for upgrading $num..."
        $k=$sortUpgrades[$a]
    }
    until($status -eq "Succeeded")
    Write-Output "The $k has been upgraded successfully!"
}