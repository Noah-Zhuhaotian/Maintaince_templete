param (
    [string]$User,
    [string]$pass,
    [string]$Computer,
    [string]$resourceName,
    [string]$env,
    [string]$backupPath,
    [string]$updatePackagePath,
    [string]$appPath
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


# ############################
# # Start Updating
# ############################

# Back up package
for ($k=0; $k -le ($n.length-1);$k++) {
    # Back up package
    try {
        Invoke-Command -ComputerName $n[$k] -credential $cred -ScriptBlock {Compress-Archive -Path $Using:appPath -DestinationPath $Using:backupPath -Force}
    }
    catch {
        "The process cannot access the file 'E:\Website\envreporting\api\Autofac.dll' because it is being used by another process."
    }
    # Invoke-Command -ComputerName $n[$k] -credential $cred -ScriptBlock {Compress-Archive -Path $Using:appPath -DestinationPath $Using:backupPath -Force}
    "the old packeage on "+$n[$k]+" has been backed up"
    # Update application
    Invoke-Command -ComputerName $n[$k] -credential $cred -ScriptBlock {Expand-Archive -LiteralPath $Using:updatePackagePath -DestinationPath $Using:appPath -Force}
    "the new packeage on "+$n[$k]+" has been unziped"
    # Move app setting.json
    Invoke-Command -ComputerName $n[$k] -credential $cred -ScriptBlock {Move-Item -Path "E:\Website\envreporting\api\appsettings.$Using:env.json" -Destination "E:\Website\envreporting\api\appsettings.json" -Force}
    "the appsettings.json on "+$n[$k]+" has been replaced"
    # Delete update package
    Invoke-Command -ComputerName $n[$k] -credential $cred -ScriptBlock {Remove-Item -Path $Using:updatePackagePath -Force}
    "the new packeage on "+$n[$k]+" has been cleared"
}



#########################
## Start Service
#########################

# Check if the API appPool is "Stopped"
# If true, try to start it
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


# Done