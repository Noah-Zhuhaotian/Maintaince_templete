param (
    [string]$User,
    [string]$pass,
    [string]$Computer,
    [string]$resourceName,
    [string]$env
    )
    
$PWord = ConvertTo-SecureString -String $pass -AsPlainText -Force
$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
$n = $Computer -split ","


######################
## Stop service
######################
# check if the api Website is "Started"
# if true, try to stop it
$apiWebState =$(@(for ($k=0; $k -le ($n.length-1);$k++) {
    $a=[string]($n[$k])
    Invoke-Command -ComputerName $a -credential $cred -ScriptBlock {
        Get-Website -Name $Using:resourceName }
}))
$curState =$(@($apiWebState.state))
for ($k=0; $k -le ($n.length-1);$k++) {
    if ($curState[$k] -eq "Started"){ 
        Invoke-Command -ComputerName $n[$k] -credential $cred -ScriptBlock {
            Stop-Website -Name $Using:resourceName } }
            "The api Website of "+ $n[$k]+" has been stopped"
        }

# check if the web Website is "Started"
# if true, try to stop it
$webWebState =$(@(for ($k=0; $k -le ($n.length-1);$k++) {
    Invoke-Command -ComputerName $n[$k] -credential $cred -ScriptBlock {
        Get-Website -Name "svc-envreporting-web-$Using:env" }
}))
$curState =$(@($webWebState.state))
for ($k=0; $k -le ($n.length-1);$k++) {
    if ($curState[$k] -eq "Started"){ 
        Invoke-Command -ComputerName $n[$k] -credential $cred -ScriptBlock {
            Stop-Website -Name "svc-envreporting-web-$Using:env" } }
            "The web Website of "+ $n[$k]+" has been stopped"
        }

# check if the api appPool is "Started"
# if true, try to stop it
$apiAppPoolState =$(@(for ($k=0; $k -le ($n.length-1);$k++) {
    Invoke-Command -ComputerName $n[$k] -credential $cred -ScriptBlock {
        Get-IISAppPool -Name $Using:resourceName }
}))
$curState =$(@($apiAppPoolState.state))
for ($k=0; $k -le ($n.length-1);$k++) {
    if ($curState[$k] -eq "Started"){ 
        Invoke-Command -ComputerName $n[$k] -credential $cred -ScriptBlock {
            Stop-WebAppPool -Name $Using:resourceName } }
            "The api AppPool of "+ $n[$k]+" has been stopped"
        }


# check if the web appPool is "Started"
# if true, try to stop it
$webAppPoolState =$(@(for ($k=0; $k -le ($n.length-1);$k++) {
    Invoke-Command -ComputerName $n[$k] -credential $cred -ScriptBlock {
        Get-IISAppPool -Name "svc-envreporting-web-$Using:env" }
}))
$curState =$(@($webAppPoolState.state))
for ($k=0; $k -le ($n.length-1);$k++) {
    if ($curState[$k] -eq "Started"){ 
        Invoke-Command -ComputerName $n[$k] -credential $cred -ScriptBlock {
            Stop-WebAppPool -Name "svc-envreporting-web-$Using:env" } }
            "The web AppPool of "+ $n[$k]+" has been stopped"
        }
