param (
    [string]$ori_rolebinding_name,
    [string]$ori_namespace,
    [string]$ori_sa_name,
    [string]$matchPattern,
    [string]$backup_yaml_path
)

function stringToArray {

    param (
        $inputString,
        $matchPattern=$null
    )
    $inputString = $inputString.Trim(",").replace(","," ").replace("  "," ").Trim()
    $inputStringArray = $inputString.split(" ")
    $returnArray = $null
    if($null -ne $matchPattern){
        $returnArray=$($inputStringArray -match "$matchPattern")
    }else{
        $returnArray=$inputStringArray
    }
    return $returnArray
}

$rolebindingnameArray = stringToArray -inputString $ori_rolebinding_name -matchPattern $matchPattern
# echo $rolebindingnameArray.Length

$namespaceArray = stringToArray -inputString $ori_namespace
# echo $namespaceArray.Length

$saNameArray = stringToArray -inputString $ori_sa_name
# echo $saNameArray.Length

$backup_yaml = ""
for ($i = 0; $i -lt $saNameArray.Length; $i++) {
    $cur_rolebinding_name = $rolebindingnameArray[$i]
    $cur_namespace = $namespaceArray[$i]
    $cur_roleRef_name = $cur_rolebinding_name -replace "-rolebinding",""
    $cur_sa_name = $rolebindingnameArray[$i]

    $template = "apiVersion: rbac.authorization.k8s.io/v1`nkind: RoleBinding`nmetadata:`n  name: ${cur_rolebinding_name}`n  namespace: ${cur_namespace}`nroleRef:`n  apiGroup: rbac.authorization.k8s.io`n  kind: Role`n  name: ${cur_roleRef_name}`nsubjects:`n- apiGroup: rbac.authorization.k8s.io`n  kind: Group`n  name: ${cur_sa_name}`n  namespace: ${cur_namespace}`n---`n"

    $backup_yaml+=$template
}

write-output $backup_yaml | out-file -filepath $backup_yaml_path