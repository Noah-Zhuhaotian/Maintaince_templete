Param(
    [string]$repositoryProjectName,
    [string]$RepositoryName,
    [string]$ServiceName,
    [string]$appName,
    [string]$BuildID,
    [string]$SYSTEM_ACCESSTOKEN,
    [string]$repositoryCallbackUrl,
    [string]$portalClientId,
    [string]$portalClientKey
)

Write-Host "Getting Scan Results..."
#get the log url
$proj = "$env:repositoryProjectName" -replace " ", "%20"
$Headers = @{Authorization="Bearer $SYSTEM_ACCESSTOKEN"}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
$res = ConvertFrom-Json ( Invoke-WebRequest -Uri "https://your/DevOps/URL/$proj/_apis/build/builds/$BuildID/logs?api-version=6.0" -UseBasicParsing -Headers $Headers).Content # Replace your DevOps URL with the actual URL
$url = $res.value[-1].url
Write-Host $url

# get content of log
$log_res = Invoke-WebRequest -Uri "$url" -UseBasicParsing -Headers $Headers
$scanned =0

#search for checkmax results
if ($log_res -like "*Checkmarx Scan Results*"){

    $log_res.Content > temp.txt
    $scan_res = Select-String -Path .\temp.txt -Pattern ".*severity results: (.*)\w+"
    $scanned =1
    $scan_results = $scan_res.Matches.Value
    $scan_string = $scan_results -join ","

    # $scan_res0 = Select-String -Path .\temp.txt -Pattern ".*High severity results([\s\S]).*"
    # $scan_res1 = Select-String -Path .\temp.txt -Pattern ".*Medium severity results([\s\S]).*"
    # $scan_res2 = Select-String -Path .\temp.txt -Pattern ".*Low severity results([\s\S]).*"
    # $scan_res3 = Select-String -Path .\temp.txt -Pattern ".*Info severity results([\s\S]).*"
    # $scan_strings = $scan_res0.Matches.Value +' ' + $scan_res1.Matches.Value+' ' + $scan_res2.Matches.Value+' ' + $scan_res3.Matches.Value

}

if ($scanned -eq 0){

    $high = -999
    $medium = -999
    $low = -999
    $info = -999
    $scan_string = "null"
}
else {
    $high = $scan_results[0].Split()[4]
    $medium = $scan_results[1].Split()[4]
    $low = $scan_results[2].Split()[4]
    $info = $scan_results[3].Split()[4]
}

Write-Host "$scanned"
write-Host "$high $medium $low $info"
# Write-Host "##vso[task.setvariable variable=scanned]$scanned"
# write-Host "##vso[task.setvariable variable=high]$high"
# write-Host "##vso[task.setvariable variable=medium]$medium"
# write-Host "##vso[task.setvariable variable=low]$low"
# write-Host "##vso[task.setvariable variable=info]$info"

Write-Host "Write to Database"
# write back to cosmos db

#get token
$tennantId = 'c3e32f53-cb7f-4809-968d-1cc4ccc785fe'
$tokenEndpoint = {https://login.windows.net/{0}/oauth2/token} -f $tennantId 

$tokenBody = @{
    'resource'= $portalClientId
    'client_id' = $portalClientId
    'grant_type' = 'client_credentials'
    'client_secret' = $portalClientKey
}

$tokenParams = @{
    ContentType = 'application/x-www-form-urlencoded'
    Headers = @{'accept'='application/json'}
    Body = $tokenBody
    Method = 'Post'
    URI = $tokenEndpoint
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
$token = Invoke-RestMethod @tokenParams
$scanCallbackUrl = $repositoryCallbackUrl + '/checkmarx-scan'
#post data to database
$headers = @{   
    'Content-Type' = 'application/json'
    'Authorization' = 'Bearer ' + $token.access_token
}  

$scanBodyContent = @{
    id = $BuildId
    appName = $appName
    ServiceName = $ServiceName
    RepositoryName = $RepositoryName
    BuildId = $BuildId
    CheckmarxScanned = $scanned
    CheckmarxHigh = $high
    CheckmarxMedium = $medium
    CheckmarxLow = $low
    CheckmarxInfo = $info
    CheckmarxResult = $scan_string
}
$Body = $scanBodyContent | ConvertTo-Json
Write-Host $Body
# call the API   
Invoke-RestMethod -Uri $scanCallbackUrl -Method POST -Headers $headers -Body $Body