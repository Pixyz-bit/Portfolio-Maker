param([string]$BaseUrl='http://localhost:51904')
. (Join-Path $PSScriptRoot 'HttpRegressionTests.ps1') -BaseUrl $BaseUrl
$ErrorActionPreference='Stop'
function SignIn-Fix([string]$Email='audit-admin@example.test') {
    $script:auditSession=[Microsoft.PowerShell.Commands.WebRequestSession]::new()
    $fields=Get-AuditFields (Request-Audit '/Frontend/Login/Login.aspx').Content
    $fields.txtEmail=$Email; $fields.txtPassword='Example-password'; $fields.btnLogin='Sign In'
    $null=Request-Audit '/Frontend/Login/Login.aspx' $fields
}
function Guest-Fix([string]$Path) {
    Invoke-WebRequest -Uri "$BaseUrl$Path" -NoProxy -SkipHttpErrorCheck -TimeoutSec 45
}
$null=Query-Audit "UPDATE dbo.Users SET IsActive=1 WHERE UserID=$adminId"
SignIn-Fix
foreach ($json in @('{}','{"skills":[]}','null','1','[null]','[1]','[[]]')) {
    $fields=Get-AuditFields (Request-Audit '/Frontend/User/Onboarding.aspx').Content
    $fields.hfSkillsJson=$json; $fields.btnSaveStep1='Save & Exit'
    $response=Request-Audit '/Frontend/User/Onboarding.aspx' $fields
    Assert-Audit ($response.StatusCode -eq 200 -and $response.Content -match 'Skills data is invalid' -and (Query-Audit "SELECT SkillName FROM dbo.Skills WHERE UserID=$adminId") -eq 'C#') "bad JSON preserves existing skills: $json"
}
$settings=Request-Audit '/Frontend/Admin/Dashboard.aspx'
Assert-Audit ($settings.Content -match '<input[^>]*name="ucUserMenu\$chkAccountIsActive"[^>]*disabled=|<span[^>]*disabled="disabled"[^>]*>\s*<input[^>]*name="ucUserMenu\$chkAccountIsActive"') 'own active-account setting renders disabled'
$fields=Get-AuditFields $settings.Content
$fields.Remove('ucUserMenu$chkAccountIsActive')
$fields['ucUserMenu$ddlAccountRole']='Admin'
$fields['ucUserMenu$btnSaveUserAccount']='Save Changes'
$response=Request-Audit '/Frontend/Admin/Dashboard.aspx' $fields
Assert-Audit ((Query-Audit "SELECT IsActive FROM dbo.Users WHERE UserID=$adminId") -eq $true) 'omitted active checkbox cannot deactivate signed-in admin'

# Make both new private storage and legacy files only inside the copied test site.
$site=Join-Path $PSScriptRoot 'Temp/Site'
$privateImages=Join-Path $site 'App_Data/ProfileImages'
$null=New-Item -ItemType Directory -Path $privateImages -Force
$imageSource=Join-Path $PSScriptRoot '../241611JalopPersonalWebsite/Uploads/Profiles/user_2_cb5bb71a.jpg'
Copy-Item -LiteralPath $imageSource -Destination (Join-Path $privateImages 'priority-private.jpg')
Copy-Item -LiteralPath $imageSource -Destination (Join-Path $site 'Uploads/Profiles/priority-legacy.jpg')
$null=Query-Audit "UPDATE dbo.UserProfiles SET ProfileImagePath=N'~/App_Data/ProfileImages/priority-private.jpg',IsPublic=0 WHERE UserID=$ownerId"
$imageUrl="/Frontend/User/ProfileImage.ashx?userId=$ownerId&file=priority-private.jpg"
Assert-Audit ((Guest-Fix $imageUrl).StatusCode -eq 404) 'guest cannot read private avatar through handler'
Assert-Audit ((Guest-Fix '/App_Data/ProfileImages/priority-private.jpg').StatusCode -eq 404) 'new image storage blocks direct requests'
Assert-Audit ((Guest-Fix '/Uploads/Profiles/priority-legacy.jpg').StatusCode -eq 404) 'old static image URLs are blocked by IIS'
Assert-Audit ((Request-Audit $imageUrl).StatusCode -eq 200) 'active administrator can read another private avatar'
SignIn-Fix 'owner@example.test'
$ownerImage=Request-Audit $imageUrl
Assert-Audit ($ownerImage.StatusCode -eq 200 -and $ownerImage.Headers['Content-Type'] -match 'image/jpeg' -and $ownerImage.Headers['Cache-Control'] -match 'no-store') 'private owner receives image with no-store caching'
SignIn-Fix 'backup-admin@example.test'
Assert-Audit ((Request-Audit $imageUrl).StatusCode -eq 404) 'unrelated standard account cannot read private avatar'
$null=Query-Audit "UPDATE dbo.UserProfiles SET IsPublic=1 WHERE UserID=$ownerId"
Assert-Audit ((Guest-Fix $imageUrl).StatusCode -eq 200) 'public avatar is readable anonymously through handler'
Assert-Audit ((Guest-Fix "/Frontend/User/ProfileImage.ashx?userId=$adminId&file=priority-private.jpg").StatusCode -eq 404) 'image filename must belong to the requested indexed owner'
Assert-Audit ((Guest-Fix '/Frontend/User/ProfileImage.ashx?file=priority-private.jpg').StatusCode -eq 404) 'image request without a valid owner is rejected'
$null=Query-Audit "UPDATE dbo.UserProfiles SET IsPublic=0 WHERE UserID=$ownerId"
Assert-Audit ((Guest-Fix $imageUrl).StatusCode -eq 404) 'making portfolio private revokes anonymous image access immediately'
$null=Query-Audit "UPDATE dbo.UserProfiles SET ProfileImagePath=N'~/Uploads/Profiles/priority-legacy.jpg' WHERE UserID=$ownerId"
Assert-Audit ((Guest-Fix "/Frontend/User/ProfileImage.ashx?userId=$ownerId&file=priority-legacy.jpg").StatusCode -eq 404) 'legacy avatar also requires portfolio permission'
SignIn-Fix 'owner@example.test'
Assert-Audit ((Request-Audit "/Frontend/User/ProfileImage.ashx?userId=$ownerId&file=priority-legacy.jpg").StatusCode -eq 200) 'legacy owner avatar works without rewriting stored paths'
Assert-Audit ((Guest-Fix "/Frontend/User/ProfileImage.ashx?userId=$ownerId&file=..%2fWeb.config").StatusCode -ne 200) 'image traversal denied'
Assert-Audit ((Guest-Fix "/Frontend/User/ProfileImage.ashx?userId=$ownerId&file=missing.jpg").StatusCode -eq 404) 'unknown image denied'
$ownerPage=Request-Audit '/Frontend/User/Portfolio.aspx'
Assert-Audit ($ownerPage.Content -match 'ProfileImage.ashx\?userId=\d+&amp;file=priority-legacy.jpg' -and $ownerPage.Content -notmatch 'src="/Uploads/Profiles/') 'portfolio markup uses protected image URL'
$null=Query-Audit "UPDATE dbo.UserProfiles SET ProfileImagePath=NULL,IsPublic=1 WHERE UserID=$ownerId"
Write-Output "PASS: $auditPassed baseline and priority HTTP assertions."
