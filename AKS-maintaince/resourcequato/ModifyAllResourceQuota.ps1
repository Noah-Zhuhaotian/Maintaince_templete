param (
    [string]$ori_resourcequato_name,
    [string]$ori_namespace,
    [string]$defaultresourcequota_cpu_limit,
    [string]$defaultresourcequota_mem_limit,
    [string]$mediumresourcequota_cpu_limit,
    [string]$mediumresourcequota_mem_limit,
    [string]$largeresourcequota_cpu_limit,
    [string]$largeresourcequota_mem_limit
)


# Delete the comma due to the bug of "Kubernetes@1"
$a1 = $ori_resourcequato_name.Trim(",").replace(","," ").replace("  "," ").Trim()
$a2 = $ori_namespace.Trim(",").replace(","," ").replace("  "," ").Trim()
$inputStringArraya1 = $a1.split(" ")
$inputStringArraya2 = $a2.split(" ")

# Put all the scripts together.
$comman_part_yaml1 = "---" + "`n" + "apiVersion: v1" + "`n" + "kind: ResourceQuota" + "`n" + "metadata:" + "`n" + "  name: "
$comman_default_yaml = "spec:" + "`n" + "  hard:" + "`n" + "    limits.cpu: " + $defaultresourcequota_cpu_limit + "`n" + "    limits.memory: " + $defaultresourcequota_mem_limit + "`n"
$comman_medium_yaml = "spec:" + "`n" + "  hard:" + "`n" + "    limits.cpu: " + $mediumresourcequota_cpu_limit + "`n" + "    limits.memory: " + $mediumresourcequota_mem_limit + "`n"
$comman_large_yaml = "spec:" + "`n" + "  hard:" + "`n" + "    limits.cpu: " + $largeresourcequota_cpu_limit + "`n" + "    limits.memory: " + $largeresourcequota_mem_limit + "`n"

# Crate 3 empty arrays to store all the scripts
$defaultresourcequota_yaml = @()
$mediumresourcequota_yaml = @()
$largeresourcequota_yaml = @()
for ($i = 0; $i -le $inputStringArraya1.Length; $i++){
    if($inputStringArraya1[$i] -eq "defaultresourcequota"){
        $defaultresourcequota_yaml += $comman_part_yaml1 + $inputStringArraya1[$i] + "`n" + "  namespace: " + $inputStringArraya2[$i] + "`n" + $comman_default_yaml
        $defaultresourcequota_yaml_ori += $comman_part_yaml1 + $inputStringArraya1[$i] + "`n" + "  namespace: " + $inputStringArraya2[$i] + "`n"
    }elseif($inputStringArraya1[$i] -eq "mediumresourcequota"){
        $mediumresourcequota_yaml += $comman_part_yaml1 + $inputStringArraya1[$i] + "`n" + "  namespace: " + $inputStringArraya2[$i] + "`n" + $comman_medium_yaml
        $mediumresourcequota_yaml_ori += $comman_part_yaml1 + $inputStringArraya1[$i] + "`n" + "  namespace: " + $inputStringArraya2[$i] + "`n"
    }elseif($inputStringArraya1[$i] -eq "largeresourcequota"){
        $largeresourcequota_yaml += $comman_part_yaml1 + $inputStringArraya1[$i] + "`n" + "  namespace: " + $inputStringArraya2[$i] + "`n" + $comman_large_yaml
        $largeresourcequota_yaml_ori += $comman_part_yaml1 + $inputStringArraya1[$i] + "`n" + "  namespace: " + $inputStringArraya2[$i] + "`n"
    }
}

# To splice all the scripts and extra them as yaml
$all_yaml_Array = $defaultresourcequota_yaml + $mediumresourcequota_yaml + $largeresourcequota_yaml
$all_yaml_ori_Array = $defaultresourcequota_yaml_ori + $mediumresourcequota_yaml_ori + $largeresourcequota_yaml_ori
$all_yaml = $all_yaml_Array -join "`n"
$all_yaml_ori = $all_yaml_ori_Array -join "`n"
Write-Output $all_yaml
Write-Output $all_yaml_ori
write-output $all_yaml | out-file -filepath 'resourcequato/all_yaml.yaml' -Force
write-output $all_yaml_ori | out-file -filepath 'resourcequato/all_yaml_ori.yaml' -Force
