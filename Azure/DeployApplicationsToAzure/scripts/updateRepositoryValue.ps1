Param(
    [string]$repositoryCallbackUrl,
    [string]$clientId,
    [string]$clientKey
)

$tennantId = 'c3e32f53-cb7f-4809-968d-1cc4ccc785fe'
$tokenEndpoint = {https://login.windows.net/{0}/oauth2/token} -f $tennantId 
$tokenBody = @{
    'resource'= $clientId
    'client_id' = $clientId
    'grant_type' = 'client_credentials'
    'client_secret' = $clientKey
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


# construct headers, body
$insightId = $env:insightVar -replace '"',''
$headers = @{   
    'Content-Type' = 'application/json'
    'Authorization' = 'Bearer ' + $token.access_token
}  

$BodyContent = @{
    serviceName = $env:serviceName
    codeProjectName = $env:codeProjectName
    repositoryProjectName = $env:repositoryProjectName
    githubRepositoryProjectName = $env:githubRepositoryProjectName
    repositoryName = $env:repositoryName
    githubRepository = $env:githubRepository
    appFramework = $env:appFramework
    azureHost = $env:azureHost
    env = $env:env
    instrumentationKey = $insightId
    sqlServerName = $env:sqlServerName
    sqlDatabaseName = $env:sqlDatabaseName
    keyVaultName = $env:keyVaultName
    storageName = $env:storageName
    redisName = $env:redisName
    branch = $env:callbackBranch
}
$Body = $BodyContent | ConvertTo-Json
Write-Host $Body
# call the API   
Invoke-RestMethod -Uri $repositoryCallbackUrl -Method POST -Headers $headers -Body $Body   