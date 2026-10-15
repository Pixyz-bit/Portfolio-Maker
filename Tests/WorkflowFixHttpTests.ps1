param([string]$BaseUrl='http://localhost:51904')
. (Join-Path $PSScriptRoot 'PriorityFixHttpTests.ps1') -BaseUrl $BaseUrl
$ErrorActionPreference='Stop'
SignIn-Fix
$adminPage=Request-Audit '/Frontend/Admin/Dashboard.aspx'
Assert-Audit ([regex]::Matches($adminPage.Content,'class="user-data-row"').Count -eq 12 -and $adminPage.Content -match 'Page 1 of') 'admin directory renders only its first SQL page'
$fields=Get-AuditFields $adminPage.Content; $fields.btnNextUsers='Next'
$second=Request-Audit '/Frontend/Admin/Dashboard.aspx' $fields
Assert-Audit ([regex]::Matches($second.Content,'class="user-data-row"').Count -eq 12 -and $second.Content -match 'Page 2 of') 'admin Next changes the rendered page'
$fields=Get-AuditFields $second.Content; $fields.txtSearch='owner@example.test'; $fields.btnSearchUsers='Search'
$matching=Request-Audit '/Frontend/Admin/Dashboard.aspx' $fields
Assert-Audit ([regex]::Matches($matching.Content,'class="user-data-row"').Count -eq 1 -and $matching.Content -match 'owner@example.test') 'admin search finds accounts outside the previous page'
$fields=Get-AuditFields $matching.Content; $fields.btnResetFilter='Reset Filters'
$reset=Request-Audit '/Frontend/Admin/Dashboard.aspx' $fields
Assert-Audit ([regex]::Matches($reset.Content,'class="user-data-row"').Count -eq 12 -and $reset.Content -match 'Page 1 of') 'reset restores first page and clears server filters'
$fields=Get-AuditFields $reset.Content
$fields.txtAddFirstName=''; $fields.txtAddLastName='Retained Family'; $fields.txtAddEmail='invalid-form@example.test'; $fields.txtAddPassword='Example-password'; $fields.btnSaveNewUser='Create User'; $fields.ddlAddRole='User'; $fields.chkAddIsActive='on'
$invalid=Request-Audit '/Frontend/Admin/Dashboard.aspx' $fields
Assert-Audit ($invalid.Content -match 'id="pnlAddError"' -and $invalid.Content.Contains("getElementById('addModal').classList.add('active')") -and (Get-AuditFields $invalid.Content).txtAddLastName -eq 'Retained Family') 'invalid Add User preserves values and reopens its inline error'
$fields=Get-AuditFields $invalid.Content; $fields.txtAddFirstName=('N'*51); $fields.txtAddPassword='Example-password'; $fields.btnSaveNewUser='Create User'; $fields.ddlAddRole='User'; $fields.chkAddIsActive='on'
$longName=Request-Audit '/Frontend/Admin/Dashboard.aspx' $fields
Assert-Audit ($longName.Content -match '50 characters or fewer' -and (Query-Audit "SELECT COUNT(*) FROM dbo.Users WHERE Email=N'invalid-form@example.test'") -eq 0) 'forged overlong admin input is rejected without creating an account'
$signup=Get-AuditFields (Request-Audit '/Frontend/Login/Signup.aspx').Content
$signup.txtFirstName='Mira'; $signup.txtLastName='Reyes'; $signup.txtEmail='owner@example.test'; $signup.txtPassword='Example-password'; $signup.txtConfirmPassword='Example-password'; $signup.btnRegister='Create Account'
$duplicate=Request-Audit '/Frontend/Login/Signup.aspx' $signup
Assert-Audit ($duplicate.StatusCode -eq 200 -and $duplicate.Content -match 'already exists' -and $duplicate.Content -notmatch 'database operation could not') 'duplicate signup gives an actionable account message'
$fields=Get-AuditFields (Request-Audit '/Frontend/User/Onboarding.aspx').Content
$fields.txtDescription='<b>Hello</b> & literal text <script>alert(1)</script>'
$fields.btnSaveStep1='Save & Exit'
$biography=Request-Audit '/Frontend/User/Onboarding.aspx' $fields
Assert-Audit ($biography.StatusCode -eq 200 -and $biography.Content -match 'Portfolio saved successfully') 'HTML-like biography saves as plain text without HTTP 500'
$portfolio=Request-Audit '/Frontend/User/Portfolio.aspx'
Assert-Audit ($portfolio.Content -match '&lt;b&gt;Hello&lt;/b&gt;' -and $portfolio.Content -notmatch '<script>alert\(1\)</script>') 'saved biography remains encoded and cannot execute scripts'
$directory=Guest-Fix '/Frontend/User/PublicDashboard.aspx?q=NoMatchingPortfolioForAudit'
Assert-Audit ($directory.Content -match 'No matching public portfolios' -and $directory.Content -notmatch 'No portfolios are currently') 'empty directory search describes no matches instead of no public content'

# Simulate one section read failing; restore the disposable table immediately.
$summaryFields=Get-AuditFields (Request-Audit '/Frontend/Admin/Dashboard.aspx').Content
$summaryFields.__EVENTTARGET='rptUsers$ctl01$btnUserClick'
$null=Query-Audit "EXEC sp_rename N'dbo.Affiliations',N'AuditMissingAffiliations'"
try {
    $failedSummary=Request-Audit '/Frontend/Admin/Dashboard.aspx' $summaryFields
    Assert-Audit ($failedSummary.StatusCode -eq 200 -and $failedSummary.Content -match 'account summary could not be loaded' -and $failedSummary.Content -notmatch 'id="pnlUserSummaryModal"') 'summary read failure shows recovery error rather than empty sections'
} finally { $null=Query-Audit "EXEC sp_rename N'dbo.AuditMissingAffiliations',N'Affiliations'" }
$ownerView=Request-Audit "/Frontend/User/Portfolio.aspx?userId=$ownerId"
$ownerToken=[regex]::Match($ownerView.Content,'data-share-url="[^"]*\?u=([^"]+)"').Groups[1].Value
if (!$ownerToken) {throw 'Fixture owner share token missing.'}
SignIn-Fix 'backup-admin@example.test'
$nonowner=Request-Audit "/Frontend/User/Portfolio.aspx?u=$ownerToken"
Assert-Audit ($nonowner.StatusCode -eq 200 -and $nonowner.Content -notmatch 'id="ucUserMenu_btnToggleVisibility"|id="menuVisibilityCard"') 'nonowner does not receive unavailable privacy controls'
SignIn-Fix
$deleteImage=Join-Path $PSScriptRoot 'Temp/Site/App_Data/ProfileImages/workflow-delete.jpg'
Copy-Item -LiteralPath (Join-Path $PSScriptRoot '../241611JalopPersonalWebsite/Uploads/Profiles/user_2_cb5bb71a.jpg') -Destination $deleteImage
$deleteId=[int](Query-Audit "INSERT dbo.Users(Email,PasswordHash) VALUES(N'workflow-delete@example.test',N'hash'); SELECT SCOPE_IDENTITY();")
$null=Query-Audit "INSERT dbo.UserProfiles(UserID,FirstName,LastName,ProfileImagePath) VALUES($deleteId,N'Deletion',N'Fixture',N'~/App_Data/ProfileImages/workflow-delete.jpg')"
$fields=Get-AuditFields (Request-Audit '/Frontend/Admin/Dashboard.aspx').Content; $fields.hfDeleteUserId="$deleteId"; $fields.btnConfirmDeleteUser='Delete'
$deleted=Request-Audit '/Frontend/Admin/Dashboard.aspx' $fields
Assert-Audit ($deleted.StatusCode -eq 200 -and (Query-Audit "SELECT COUNT(*) FROM dbo.Users WHERE UserID=$deleteId") -eq 0 -and !(Test-Path -LiteralPath $deleteImage)) 'admin deletion removes both account and physical avatar'

# Valid maximum-length names, placed first for responsive browser checks.
$null=Query-Audit "INSERT dbo.Users(Email,PasswordHash) SELECT N'long-name-ui@example.test',PasswordHash FROM dbo.Users WHERE Email=N'backup-admin@example.test'; DECLARE @ID int=SCOPE_IDENTITY(); INSERT dbo.UserProfiles(UserID,FirstName,LastName) VALUES(@ID,REPLICATE(N'N',50),REPLICATE(N'L',50))"
Write-Output "PASS: $auditPassed baseline, priority and workflow HTTP assertions."
