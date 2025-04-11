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

$apiAppPoolState =$(@(for ($k=0; $k -le ($n.length-1);$k++) {
    Invoke-Command -ComputerName $n[$k] -credential $cred -ScriptBlock {
        Get-IISAppPool -Name $Using:resourceName }
}))
$curState =$(@($apiAppPoolState.state))
for ($k=0; $k -le ($n.length-1);$k++) {
    if ($curState[$k] -eq "Stopped"){ 
        Invoke-Command -ComputerName $n[$k] -credential $cred -ScriptBlock {
            Start-WebAppPool -Name $Using:resourceName } }
            "The api AppPool of "+ $n[$k]+" has been started"
        }

# Check if the Web AppPool is "Stopped"
# If true, try to start it
$webAppPoolState =$(@(for ($k=0; $k -le ($n.length-1);$k++) {
    Invoke-Command -ComputerName $n[$k] -credential $cred -ScriptBlock {
        Get-IISAppPool -Name "svc-envreporting-web-$Using:env" }
}))
$curState =$(@($webAppPoolState.state))
for ($k=0; $k -le ($n.length-1);$k++) {
    if ($curState[$k] -eq "Stopped"){ 
        Invoke-Command -ComputerName $n[$k] -credential $cred -ScriptBlock {
            Start-WebAppPool -Name "svc-envreporting-web-$Using:env" } }
            "The web AppPool of "+ $n[$k]+" has been started"
        }

# Check if the API Website is "Stopped"
# If true, try to start it
$apiWebState =$(@(for ($k=0; $k -le ($n.length-1);$k++) {
    Invoke-Command -ComputerName $n[$k] -credential $cred -ScriptBlock {
        Get-Website -Name $Using:resourceName }
}))
$curState =$(@($apiWebState.state))
for ($k=0; $k -le ($n.length-1);$k++) {
    if ($curState[$k] -eq "Stopped"){ 
        Invoke-Command -ComputerName $n[$k] -credential $cred -ScriptBlock {
            Start-Website -Name $Using:resourceName } }
            "The api Website of "+ $n[$k]+" has been started"
        }

# Check if the Web WebSite is "Stopped"
# If true, try to start it
$webWebState =$(@(for ($k=0; $k -le ($n.length-1);$k++) {
    Invoke-Command -ComputerName $n[$k] -credential $cred -ScriptBlock {
        Get-Website -Name "svc-envreporting-web-$Using:env" }
}))
$curState =$(@($webWebState.state))
for ($k=0; $k -le ($n.length-1);$k++) {
    if ($curState[$k] -eq "Stopped"){ 
        Invoke-Command -ComputerName $n[$k] -credential $cred -ScriptBlock {
            Start-Website -Name "svc-envreporting-web-$Using:env" } }
            "The web Website of "+ $n[$k]+" has been started"
        }