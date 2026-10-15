$ErrorActionPreference = 'Stop'
$state = Join-Path $PSScriptRoot 'Temp/web-database.txt'
if (!(Test-Path -LiteralPath $state)) { return }
$fixtureDatabase = (Get-Content -LiteralPath $state -Raw).Trim()
if ($fixtureDatabase -notmatch '^PortfolioAudit_[a-f0-9]{32}$') { throw 'Refusing to remove a database outside the fixture naming convention.' }
$connection = [Data.SqlClient.SqlConnection]::new('Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=master;Integrated Security=True;')
try {
    $connection.Open()
    $command = $connection.CreateCommand()
    $command.CommandText = "IF DB_ID(N'$fixtureDatabase') IS NOT NULL BEGIN ALTER DATABASE [$fixtureDatabase] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [$fixtureDatabase]; END"
    $null = $command.ExecuteNonQuery()
    Remove-Item -LiteralPath $state
    Write-Output 'Disposable web fixture database removed.'
} finally { $connection.Dispose() }
