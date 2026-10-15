$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($env:SQLCONNSTR_DefaultConnection)) {
    throw 'Set SQLCONNSTR_DefaultConnection to the intended existing database before running migrations.'
}
$migrationSettings = [Data.SqlClient.SqlConnectionStringBuilder]::new($env:SQLCONNSTR_DefaultConnection)
if ([string]::IsNullOrWhiteSpace($migrationSettings.InitialCatalog) -or $migrationSettings.InitialCatalog -in @('master','model','msdb','tempdb')) {
    throw 'Select an explicit application database; system databases are not allowed.'
}
$migrationFolder = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../241611JalopPersonalWebsite/Backend/Database/Migration'))
$migrationConnection = [Data.SqlClient.SqlConnection]::new($migrationSettings.ConnectionString)
try {
    $migrationConnection.Open()
    $migrationTransaction = $migrationConnection.BeginTransaction()
    try {
        foreach ($migrationName in Get-Content -LiteralPath (Join-Path $migrationFolder 'manifest.txt')) {
            if ($migrationName -notmatch '^\d{2}_[A-Za-z_]+\.sql$') { throw 'Invalid migration manifest entry.' }
            $migrationSql = Get-Content -LiteralPath (Join-Path $migrationFolder $migrationName) -Raw
            if ($migrationSql -match '(?im)^\s*(USE|CREATE\s+DATABASE)\b') { throw 'Migrations must use the selected database without switching targets.' }
            foreach ($migrationBatch in [regex]::Split($migrationSql, '(?im)^\s*GO\s*\r?$')) {
                if ([string]::IsNullOrWhiteSpace($migrationBatch)) { continue }
                $migrationCommand = $migrationConnection.CreateCommand()
                try {
                    $migrationCommand.Transaction = $migrationTransaction
                    $migrationCommand.CommandText = $migrationBatch
                    $migrationCommand.CommandTimeout = 120
                    $null = $migrationCommand.ExecuteNonQuery()
                } finally { $migrationCommand.Dispose() }
            }
            Write-Output "Applied $migrationName"
        }
        $migrationTransaction.Commit()
        Write-Output 'Database initialization completed. Existing account and portfolio data were preserved.'
    } catch {
        try { $migrationTransaction.Rollback() } catch { }
        throw
    } finally { $migrationTransaction.Dispose() }
} finally { $migrationConnection.Dispose() }
