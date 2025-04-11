param (
    [string]$ori_pvc_name,
    [string]$ori_pvc_status,
    [string]$ori_pvc_namespace,
    [string]$deleteyamlpath
)



#Clear the comma and space because the bug of Micorsoft
$a1=$ori_pvc_name.Trim(",").replace(","," ").replace("  "," ").Trim()
Write-Output $a1

#Clear the comma and space because the bug of Micorsoft
$a2=$ori_pvc_status.Trim(",").replace(","," ").replace("  "," ").Trim()
Write-Output $a2

#Clear the comma and space because the bug of Micorsoft
$a5=$ori_pvc_namespace.Trim(",").replace(","," ").replace("  "," ").Trim()
Write-Output $a5

#Split the values by space to be the arry
$a3=$a1 -split " "

#Split the values by space to be the arry
$a4=$a2 -split " "

#Split the values by space to be the arry
$a6=$a5 -split " "
Write-Output $a3
Write-Output $a4
Write-Output $a6

#Create a new hash for storaging the values
$index = @()

#Put the name and status into the hash
for ($k=0; $k -le ($a4.length-1); $k +=1){
    if ($a4[$k] -ne "Bound"){
        $index = $index+$k
    }
}
Write-Output $index

#Create a new arry to storge the unhealthy pvc name
$names=@()
$namespaces=@()
#Filter the pvcs that the status are not "Bound"
foreach ($n1 in $index){
    $names=$names+$a3[$n1]
    $namespaces=$namespaces+$a6[$n1]
}
Write-Output $names
Write-Output $namespaces

$pvc_yaml = ""
for ($n=0; $n -le ($names.length-1); $n +=1){
    $pvcname = $names[$n]
    $pvcnamespace = $namespaces[$n]
    $template = "---"+"`n"+"kind: PersistentVolumeClaim"+"`n"+"apiVersion: v1"+"`n"+"metadata:"+"`n"+"  name: ${pvcname}"+"`n"+"  namespace: ${pvcnamespace}"+"`n"
    $pvc_yaml+=$template
}
Write-Output $pvc_yaml
write-output $pvc_yaml | out-file -filepath $deleteyamlpath
Write-Host "##vso[task.setvariable variable=unhealtheypvcnames;isOutput=true]$pvc_yaml"


