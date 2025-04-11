Param(
    [string]$sqlAccount,
    [string]$sqlKey,
    [switch]$isScriptOnWindows = $false
)

$sqlServerName = "$env:sqlServerName"
$sqlDatabaseName = "$env:sqlDatabaseName"
$sqlFile = "$env:System_DefaultWorkingDirectory/$env:serviceName/migration.sql"

function RunSqlQuery()
{
    Try {
        $scriptContent = [IO.File]::ReadAllText($sqlFile)
        $lineSplit = "\n"
        if ($isScriptOnWindows -eq $true) {
            $lineSplit = "\r\n"
        }

        $delim = "GO" + $lineSplit
        $scripts = $scriptContent -split $delim

        $conn = New-Object System.Data.SqlClient.SQLConnection
        $conn.ConnectionString = "Server=tcp:$sqlServerName.database.windows.net,1433;Initial Catalog=$sqlDatabaseName;Persist Security Info=True;User ID=$sqlAccount;Password=$sqlKey;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30"
        $conn.Open()
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
    RunSqlQuery 
}