param([string]$BaseUrl = 'http://localhost:51904')
$ErrorActionPreference = 'Stop'
if ($BaseUrl -notmatch '^http://localhost:\d+$') { throw 'Only a local test server is allowed.' }
$auditDatabase = (Get-Content -LiteralPath (Join-Path $PSScriptRoot 'Temp/web-database.txt') -Raw).Trim()
if ($auditDatabase -notmatch '^PortfolioAudit_[a-f0-9]{32}$') { throw 'Invalid test database.' }
$auditConnection = "Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=$auditDatabase;Integrated Security=True;"
$auditPassed = 0
function Assert-Audit($Condition, $Name) {
    if (!$Condition) { throw "FAIL: $Name" }
    $script:auditPassed++
    Write-Output "PASS: $Name"
}
function Query-Audit([string]$Sql) {
    $connection = [Data.SqlClient.SqlConnection]::new($auditConnection)
    try { $connection.Open(); $command = $connection.CreateCommand(); $command.CommandText = $Sql; $command.ExecuteScalar() }
    finally { $connection.Dispose() }
}
function Get-AuditFields([string]$Html) {
    $fields = @{}
    foreach ($match in [regex]::Matches($Html, '<input\b[^>]*>', 'IgnoreCase')) {
        $tag = $match.Value
        $name = [regex]::Match($tag, '\bname="([^"]*)"', 'IgnoreCase').Groups[1].Value
        $type = [regex]::Match($tag, '\btype="([^"]*)"', 'IgnoreCase').Groups[1].Value
        if (!$name -or $type -in @('submit','button','file')) { continue }
        if ($type -eq 'checkbox' -and $tag -notmatch '\bchecked\b') { continue }
        $valueMatch = [regex]::Match($tag, '\bvalue="([^"]*)"', 'IgnoreCase')
        $fields[$name] = if ($type -eq 'checkbox' -and !$valueMatch.Success) { 'on' } else { [Net.WebUtility]::HtmlDecode($valueMatch.Groups[1].Value) }
    }
    foreach ($match in [regex]::Matches($Html, '<textarea\b[^>]*name="([^"]*)"[^>]*>([\s\S]*?)</textarea>', 'IgnoreCase')) {
        $fields[$match.Groups[1].Value] = [Net.WebUtility]::HtmlDecode($match.Groups[2].Value)
    }
    return $fields
}
function Request-Audit([string]$Path, $Fields = $null) {
    $options = @{ Uri="$BaseUrl$Path"; WebSession=$script:auditSession; NoProxy=$true; SkipHttpErrorCheck=$true; TimeoutSec=45 }
    if ($null -ne $Fields) { $options.Method='Post'; $options.Body=$Fields }
    Invoke-WebRequest @options
}
$auditSession = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
# Restore only the synthetic fixture before each run, matching a browser's checked-checkbox submission.
$null = Query-Audit "UPDATE dbo.Users SET IsActive=1,Role=N'Admin' WHERE Email=N'audit-admin@example.test'; UPDATE dbo.Skills SET SkillName=N'<img src=x onerror=alert(1)>' WHERE UserID=(SELECT UserID FROM dbo.Users WHERE Email=N'audit-admin@example.test'); UPDATE dbo.UserProfiles SET IsPublic=0 WHERE UserID=(SELECT UserID FROM dbo.Users WHERE Email=N'audit-admin@example.test');"
$login = Request-Audit '/Frontend/Login/Login.aspx'
Assert-Audit ($login.StatusCode -eq 200 -and $login.Content -notmatch 'DATABASE STATUS') 'login page renders without database diagnostics'
$fields = Get-AuditFields $login.Content
$fields.txtEmail='audit-admin@example.test'; $fields.txtPassword='Example-password'; $fields.btnLogin='Sign In'
$signedIn = Request-Audit '/Frontend/Login/Login.aspx' $fields
Assert-Audit ($signedIn.StatusCode -eq 200 -and $signedIn.Content -match 'showLoginSuccessModal') 'local administrator login succeeds'
$admin = Request-Audit '/Frontend/Admin/Dashboard.aspx'
$accountEmail = (Get-AuditFields $admin.Content)['ucUserMenu$txtAccountEmail']
Assert-Audit ($accountEmail -eq 'audit-admin@example.test') 'account settings default to login email, not public contact email'
Assert-Audit ($admin.Content -match 'for="txtAddFirstName"') 'admin form renders associated label IDs'
$portfolio = Request-Audit '/Frontend/User/Portfolio.aspx'
Assert-Audit ($portfolio.StatusCode -eq 200 -and $portfolio.Content -match '&lt;img src=x onerror=alert\(1\)&gt;' -and $portfolio.Content -notmatch '<img src=x onerror') 'stored HTML is rendered as text'
$adminId = [int](Query-Audit "SELECT UserID FROM dbo.Users WHERE Email=N'audit-admin@example.test'")
$ownerId = [int](Query-Audit "SELECT UserID FROM dbo.Users WHERE Email=N'owner@example.test'")
$owner = Request-Audit "/Frontend/User/Portfolio.aspx?userId=$ownerId"
Assert-Audit ($owner.Content -match 'Public Portfolio' -and $owner.Content -notmatch 'dot-private') 'visibility menu reads target portfolio state instead of admin state'
$editor = Request-Audit '/Frontend/User/Onboarding.aspx'
$badFields = Get-AuditFields $editor.Content
$badFields.hfSkillsJson='{bad'; $badFields.btnSaveStep1='Save & Exit'
$save = Request-Audit '/Frontend/User/Onboarding.aspx' $badFields
Assert-Audit ($save.StatusCode -eq 200 -and $save.Content -match 'Skills data is invalid') 'malformed save reports validation error'
Assert-Audit ((Query-Audit "SELECT SkillName FROM dbo.Skills WHERE UserID=$adminId") -eq '<img src=x onerror=alert(1)>') 'malformed HTTP save preserves existing section rows'
$validFields = Get-AuditFields (Request-Audit '/Frontend/User/Onboarding.aspx').Content
$validFields.hfSkillsJson='[{"skillName":"C#","skillDescription":"Safe plain text"}]'; $validFields.btnSaveStep1='Save & Exit'
$validSave = Request-Audit '/Frontend/User/Onboarding.aspx' $validFields
Assert-Audit ($validSave.StatusCode -eq 200 -and $validSave.Content -match 'Portfolio saved successfully') 'valid HTTP portfolio save reports committed success'
Assert-Audit ((Query-Audit "SELECT SkillName FROM dbo.Skills WHERE UserID=$adminId") -eq 'C#' -and (Query-Audit "SELECT COUNT(*) FROM dbo.Educations WHERE UserID=$adminId") -eq 1) 'valid HTTP save persists replacements and retains other sections'
$accountFields = Get-AuditFields (Request-Audit '/Frontend/Admin/Dashboard.aspx').Content
$accountFields['ucUserMenu$btnSaveUserAccount']='Save Changes'
$accountFields['ucUserMenu$ddlAccountRole']='Admin'
$accountSaved = Request-Audit '/Frontend/Admin/Dashboard.aspx' $accountFields
Assert-Audit ($accountSaved.StatusCode -eq 200 -and (Query-Audit "SELECT Email FROM dbo.Users WHERE UserID=$adminId") -eq 'audit-admin@example.test') 'saving unrelated account settings preserves login email'
Assert-Audit ((Query-Audit "SELECT IsActive FROM dbo.Users WHERE UserID=$adminId") -eq $true) 'account settings test preserves the checked active-account state'
$invalid = Request-Audit '/Frontend/User/Portfolio.aspx?u=invalid'
Assert-Audit ($invalid.StatusCode -eq 404) 'invalid explicit portfolio token returns not found'
$noTarget = Request-Audit '/Frontend/User/Portfolio.aspx?userId=999999'
Assert-Audit ($noTarget.StatusCode -eq 404) 'nonexistent explicit user ID returns not found'
$public = Request-Audit '/Frontend/User/PublicDashboard.aspx'
Assert-Audit ([regex]::Matches($public.Content,'class="portfolio-card"').Count -eq 12 -and $public.Content -match 'btnNextPage') 'directory renders a bounded page with navigation'
$query = Request-Audit '/Frontend/User/PublicDashboard.aspx?q=UniqueSkill25'
Assert-Audit ([regex]::Matches($query.Content,'class="portfolio-card"').Count -eq 1) 'public search finds skills outside initial result page'
$replay = Get-AuditFields $portfolio.Content
$replay['__EVENTTARGET']='ucUserMenu$btnToggleVisibility'; $replay['__EVENTARGUMENT']=''
$before = Query-Audit "SELECT IsPublic FROM dbo.UserProfiles WHERE UserID=$adminId"
$null = Request-Audit '/Frontend/Login/Login.aspx?action=logout'
$blocked = Request-Audit '/Frontend/User/Portfolio.aspx' $replay
Assert-Audit ($blocked.StatusCode -ge 400 -and (Query-Audit "SELECT IsPublic FROM dbo.UserProfiles WHERE UserID=$adminId") -eq $before) 'logged-out postback replay cannot change visibility'
$guest = Request-Audit '/Frontend/Admin/Dashboard.aspx'
Assert-Audit ($guest.BaseResponse.RequestMessage.RequestUri.AbsolutePath -eq '/Frontend/Login/Login.aspx') 'guest administrator route redirects to login'
Write-Output "PASS: $auditPassed HTTP regression assertions."
