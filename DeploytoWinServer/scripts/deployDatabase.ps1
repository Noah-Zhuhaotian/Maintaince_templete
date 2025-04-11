Param(
    [string]$isScriptOnWindows = "false",
	[string]$token = $env:SqlAccessToken
)
	
$sqlServerName = "$env:sqlServerName"
$sqlDatabaseName = "$env:sqlDatabaseName"
$sqlFile = "$env:System_DefaultWorkingDirectory/$env:serviceName/migration.sql"

function RunSql([string] $accessToken)
{
    Try {
        $scriptContent = [IO.File]::ReadAllText($sqlFile)
        $lineSplit = "\n"
        if ($isScriptOnWindows -eq "true") {
            $lineSplit = "\r\n"
        }

        $delim = "GO" + $lineSplit
        $scripts = $scriptContent -split $delim

        $conn = New-Object System.Data.SqlClient.SQLConnection
        $conn.ConnectionString = "Server=tcp:$sqlServerName.database.windows.net,1433;Initial Catalog=$sqlDatabaseName;Persist Security Info=True;Connect Timeout=30"
        $conn.AccessToken = $accessToken
        Try {
            $conn.Open()
        }
        Catch [System.SystemException] {
            Start-Sleep -s 10
            # try second time to connect
            $conn.Open()
        }
        
        for ($i=0; $i -lt $scripts.Count; $i++)
        {
            $script = $scripts[$i]
            $script = $script -replace $delim, ""
            $execute = ($script -ne "") -and ($script -ne $lineSplit)

            if ($execute)
            {
                $command = $conn.CreateCommand()
                $command.CommandTimeout = 0
                $command.CommandText = $script
                $rowsAffected = $command.ExecuteNonQuery()
                Write-Host ("Rows Affected: [{0}]" -f $rowsAffected)
                $command = $null
            }
        }

        $conn.Close() 
    }
    Catch [System.SystemException] {
        Write-Error -Message $PSItem.ToString()
        throw
    }
}

if ('' -ne $sqlServerName -And $null -ne $sqlServerName) {
    RunSql -accessToken $token
}




