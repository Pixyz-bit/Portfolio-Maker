# Regression checks

Run from the repository root with Visual Studio MSBuild and SQL Server LocalDB installed:

```powershell
& 'C:/Program Files/Microsoft Visual Studio/2022/Community/MSBuild/Current/Bin/MSBuild.exe' Tests/RegressionTests.csproj /t:Build /p:Configuration=Release /verbosity:minimal
& './Tests/bin/PortfolioRegressionTests.exe' (Get-Location).Path
```

The suite creates a unique `PortfolioAudit_<guid>` database on `(localdb)\MSSQLLocalDB`, loads the existing migrations into that database, runs database/security/image regressions, and drops only that database in `finally`. It sets a connection override inside its own process; it does not use the application's real database credentials. Windows WIC WebP codec support is needed for the WebP assertion.

For HTTP/browser testing, pass `--prepare-web` to the executable, then run `node Tests/prepare-web.cjs`. That mode retains its fixture database, records its name in `Tests/Temp/web-database.txt`, and prepares a site copy under `Tests/Temp/Site`. Use a Windows path with backslashes when starting IIS Express:

```powershell
$site = Join-Path (Get-Location) 'Tests\Temp\Site'
& 'C:/Program Files/IIS Express/iisexpress.exe' "/path:$site" /port:51904 /systray:false
```

Run `Tests/HttpRegressionTests.ps1` from a second terminal. HTTP tests intentionally change only synthetic accounts and portfolios in the fixture database. Recreate the fixture before rerunning because the successful-save test changes the deliberately unsafe stored-content fixture.

Afterward, stop that IIS Express instance and run `Tests/CleanupWebFixture.ps1` to remove the retained database. All fixture files live beneath the ignored `Tests/Temp` directory.

## Final audit probes

The final audit scripts are diagnostic probes: some deliberately demonstrate remaining bugs and report observations rather than failing assertions. Use a fresh disposable fixture for each audit run, never a production connection or site. `FinalAuditHttp.ps1` runs the baseline HTTP suite itself, so do not run the baseline separately first on the same fixture.

With the prepared localhost site running, run in this order:

```powershell
& './Tests/FinalAuditHttp.ps1'
& 'C:/Program Files/Microsoft Visual Studio/2022/Community/MSBuild/Current/Bin/MSBuild.exe' Tests/FinalAuditBackend.csproj /t:Build /p:Configuration=Release /verbosity:minimal
& './Tests/bin/FinalAuditBackend.exe' (Get-Location).Path
& './Tests/FinalAuditUploads.ps1'
node Tests/final-inventory.cjs
```

These probes intentionally change synthetic account fields, status, passwords, section contents and avatar files. The backend probe restricts its database to the fixture naming convention; HTTP scripts restrict requests to localhost. Results are written under `Tests/Temp`. Preserve only nonsecret evidence before cleanup. The report and retained results from 14 October are in `Documentation/10_Final_Audit_2026-10-14.md` and `Documentation/Final_Audit_Evidence`.
