param([string]$BaseUrl='http://localhost:51904')
. (Join-Path $PSScriptRoot 'HttpRegressionTests.ps1') -BaseUrl $BaseUrl
$cases = [Collections.Generic.List[object]]::new()
function Record-Audit($Area,$Name,$Result,$Details='') {
    $cases.Add([pscustomobject]@{Area=$Area;Case=$Name;Result=$Result;Details=$Details})
    Write-Output "$Result | $Area | $Name | $Details"
}
function SignIn-Audit($Email='audit-admin@example.test',$Password='Example-password') {
    $script:auditSession=[Microsoft.PowerShell.Commands.WebRequestSession]::new()
    $fields=Get-AuditFields (Request-Audit '/Frontend/Login/Login.aspx').Content
    $fields.txtEmail=$Email; $fields.txtPassword=$Password; $fields.btnLogin='Sign In'
    $null=Request-Audit '/Frontend/Login/Login.aspx' $fields
}
function SaveFields-Audit($Name,$Mutate,$Button='btnSaveStep1') {
    $fields=Get-AuditFields (Request-Audit '/Frontend/User/Onboarding.aspx').Content
    & $Mutate $fields
    $fields[$Button]='Save & Exit'
    $response=Request-Audit '/Frontend/User/Onboarding.aspx' $fields
    $success=$response.Content -match 'Portfolio saved successfully'
    Record-Audit 'Onboarding' $Name $(if($success){'ACCEPTED'}else{'REJECTED'}) "HTTP $($response.StatusCode)"
    return $response
}
SignIn-Audit
foreach($button in @('btnSaveStep1','btnSaveStep2','btnSaveStep3','btnSaveStep4','btnSaveStep5','btnCompleteOnboarding')) {
    $null=SaveFields-Audit "Save button $button" {param($f)} $button
}
$null=SaveFields-Audit 'Missing first name' {param($f) $f.txtFirstName=''}
$null=SaveFields-Audit 'Invalid contact email' {param($f) $f.txtContactEmail='not-an-email'}
$null=SaveFields-Audit 'Ten digit contact number' {param($f) $f.txtContactNum='0912345678'}
$null=SaveFields-Audit 'Letters embedded in phone number' {param($f) $f.txtContactNum='abc09123456789'}
$null=SaveFields-Audit 'Birthday in future' {param($f) $f.txtBirthday='2099-01-01'}
$null=SaveFields-Audit 'Malformed birthday' {param($f) $f.txtBirthday='not-a-date'}
$null=SaveFields-Audit 'Birthday before 1900' {param($f) $f.txtBirthday='1899-12-31'}
$null=SaveFields-Audit 'Biography over 20000 characters' {param($f) $f.txtDescription=('a'*20001)}
$htmlSave=SaveFields-Audit 'Literal HTML in biography' {param($f) $f.txtDescription='<b>plain text example</b>'}
Record-Audit 'Onboarding' 'Controlled validation for literal HTML' $(if($htmlSave.StatusCode -ge 500){'ISSUE'}else{'PASS'}) "HTTP $($htmlSave.StatusCode)"
$null=SaveFields-Audit 'JSON null array item' {param($f) $f.hfSkillsJson='[null]'}
$null=SaveFields-Audit 'JSON not an array' {param($f) $f.hfSkillsJson='{}'}
$null=SaveFields-Audit 'Missing JSON payload' {param($f) $f.hfSkillsJson=''}
$null=SaveFields-Audit '101 skills' {param($f) $f.hfSkillsJson=(@(1..101 | ForEach-Object {@{skillName="Skill $_"}})|ConvertTo-Json -Compress)}
$null=SaveFields-Audit 'Skill over 100 characters' {param($f) $f.hfSkillsJson=(@(@{skillName=('a'*101)})|ConvertTo-Json -Compress -AsArray)}
$null=SaveFields-Audit 'Unsafe social scheme' {param($f) $f.hfSocialLinksJson='[{"socialLinkName":"Site","link":"javascript:alert(1)"}]'}
$null=SaveFields-Audit 'Reversed education years' {param($f) $f.hfEducationsJson='[{"courseName":"IT","university":"University","startYear":"2025","endYear":"2020"}]'}
$null=SaveFields-Audit 'Nonnumeric education year' {param($f) $f.hfEducationsJson='[{"courseName":"IT","university":"University","startYear":"nonsense","endYear":"Present"}]'}
$null=SaveFields-Audit 'Unicode name and apostrophe' {param($f) $f.txtFirstName="Líanne O'Neil"}

# Signup fields are sent to the real page handlers; only synthetic emails are used.
foreach($case in @(
    @{Name='Empty first name';First='';Last='Reyes';Email='empty@example.test';Password='Example-password';Confirm='Example-password'},
    @{Name='Invalid email';First='Mira';Last='Reyes';Email='bad';Password='Example-password';Confirm='Example-password'},
    @{Name='Five character password';First='Mira';Last='Reyes';Email='short@example.test';Password='short';Confirm='short'},
    @{Name='Password mismatch';First='Mira';Last='Reyes';Email='mismatch@example.test';Password='Example-password';Confirm='different'},
    @{Name='Duplicate email';First='Mira';Last='Reyes';Email='audit-admin@example.test';Password='Example-password';Confirm='Example-password'},
    @{Name='51 character name';First=('a'*51);Last='Reyes';Email='longname@example.test';Password='Example-password';Confirm='Example-password'},
    @{Name='Valid standard account';First='Noel';Last='Santos';Email='audit-standard@example.test';Password='Example-password';Confirm='Example-password'}
)) {
    $fields=Get-AuditFields (Request-Audit '/Frontend/Login/Signup.aspx').Content
    $fields.txtFirstName=$case.First; $fields.txtLastName=$case.Last; $fields.txtEmail=$case.Email
    $fields.txtPassword=$case.Password; $fields.txtConfirmPassword=$case.Confirm; $fields.btnRegister='Create Account'
    $response=Request-Audit '/Frontend/Login/Signup.aspx' $fields
    $accepted=$response.BaseResponse.RequestMessage.RequestUri.Query -match 'registered=true'
    Record-Audit 'Signup' $case.Name $(if($accepted){'ACCEPTED'}else{'REJECTED'}) "HTTP $($response.StatusCode)"
    if($case.Name -eq '51 character name') {
        $length=Query-Audit "SELECT LEN(FirstName) FROM dbo.UserProfiles WHERE UserID=(SELECT UserID FROM dbo.Users WHERE Email=N'longname@example.test')"
        Record-Audit 'Signup' 'Overlong name truncation' $(if($accepted -and $length -eq 50){'ISSUE'}else{'PASS'}) "Stored length $length"
    }
    if($case.Name -eq 'Duplicate email') {
        Record-Audit 'Signup' 'Duplicate email feedback' $(if($response.Content -match 'database operation could not'){ 'ISSUE' }else{'PASS'}) 'Duplicate error should explain account already exists'
    }
}

SignIn-Audit
$target=[int](Query-Audit "SELECT UserID FROM dbo.Users WHERE Email=N'audit-standard@example.test'")
$adminId=[int](Query-Audit "SELECT UserID FROM dbo.Users WHERE Email=N'audit-admin@example.test'")
# Reset profile to ordinary values after onboarding validation probes.
$null=Query-Audit "UPDATE dbo.UserProfiles SET FirstName=N'Mira',LastName=N'Reyes' WHERE UserID=$adminId;"
$fields=Get-AuditFields (Request-Audit '/Frontend/Admin/Dashboard.aspx').Content
$fields.hfEditUserId="$target"; $fields.txtEditFirstName='Changed-before-validation'; $fields.txtEditLastName='Santos'
$fields.txtEditEmail='audit-standard@example.test'; $fields.ddlEditRole='User'; $fields.chkEditIsActive='on'
$fields.txtEditNewPassword='short'; $fields.txtEditConfirmPassword='short'; $fields.btnUpdateUser='Save Changes'
$response=Request-Audit '/Frontend/Admin/Dashboard.aspx' $fields
$changed=Query-Audit "SELECT FirstName FROM dbo.UserProfiles WHERE UserID=$target"
Record-Audit 'Admin' 'Invalid password edit partially commits account' $(if($changed -eq 'Changed-before-validation'){'ISSUE'}else{'PASS'}) 'Name written before password validation'

# Status controls, password reset and deletion only affect the new standard fixture account.
foreach($active in @($false,$true)) {
    $fields=Get-AuditFields (Request-Audit '/Frontend/Admin/Dashboard.aspx').Content
    $fields.hfStatusUserId="$target"; $fields.hfStatusNewState="$active"; $fields.btnConfirmStatusAction='Confirm'
    $null=Request-Audit '/Frontend/Admin/Dashboard.aspx' $fields
    Record-Audit 'Admin' "Status set $active" $(if((Query-Audit "SELECT IsActive FROM dbo.Users WHERE UserID=$target") -eq $active){'PASS'}else{'ISSUE'})
}
$fields=Get-AuditFields (Request-Audit '/Frontend/Admin/Dashboard.aspx').Content
$fields.hfEditUserId="$target"; $fields.txtEditFirstName='Noel'; $fields.txtEditLastName='Santos'; $fields.txtEditEmail='audit-standard@example.test'
$fields.ddlEditRole='User'; $fields.chkEditIsActive='on'; $fields.txtEditNewPassword='Different-test-password'; $fields.txtEditConfirmPassword='Different-test-password'; $fields.btnUpdateUser='Save Changes'
$null=Request-Audit '/Frontend/Admin/Dashboard.aspx' $fields
SignIn-Audit 'audit-standard@example.test' 'Different-test-password'
$normal=Request-Audit '/Frontend/User/Dashboard.aspx'
Record-Audit 'Account' 'Administrator reset password works' $(if($normal.Content -match 'Noel'){'PASS'}else{'ISSUE'})
$restricted=Request-Audit '/Frontend/Admin/Dashboard.aspx'
Record-Audit 'Permissions' 'Standard user cannot access admin dashboard' $(if($restricted.BaseResponse.RequestMessage.RequestUri.AbsolutePath -match '/Login.aspx'){'PASS'}else{'ISSUE'})
# Direct visibility button visibility is evaluated on another owner's page.
$ownerId=[int](Query-Audit "SELECT UserID FROM dbo.Users WHERE Email=N'owner@example.test'")
SignIn-Audit
$view=Request-Audit "/Frontend/User/Portfolio.aspx?userId=$ownerId"
$token=[regex]::Match($view.Content,'data-share-url="[^"]*\?u=([^"]+)"').Groups[1].Value
SignIn-Audit 'audit-standard@example.test' 'Different-test-password'
$view=Request-Audit "/Frontend/User/Portfolio.aspx?u=$token"
Record-Audit 'Permissions' 'Non-owner visibility switch shown' $(if($view.Content -match 'id="ucUserMenu_btnToggleVisibility"'){'ISSUE'}else{'PASS'}) 'Server still denies mutation'
$null=Query-Audit "UPDATE dbo.Users SET IsActive=0 WHERE UserID=$ownerId"
$script:auditSession=[Microsoft.PowerShell.Commands.WebRequestSession]::new()
$view=Request-Audit "/Frontend/User/Portfolio.aspx?u=$token"
Record-Audit 'Privacy' 'Deactivated public portfolio remains reachable' $(if($view.StatusCode -eq 200 -and $view.Content -match 'Educational Attainment'){'ISSUE'}else{'PASS'})
$null=Query-Audit "UPDATE dbo.Users SET IsActive=1 WHERE UserID=$ownerId"
SignIn-Audit
# Own account settings bypass the grid's self-deactivation restriction.
$fields=Get-AuditFields (Request-Audit '/Frontend/Admin/Dashboard.aspx').Content
$fields['ucUserMenu$ddlAccountRole']='Admin'; $fields.Remove('ucUserMenu$chkAccountIsActive'); $fields['ucUserMenu$btnSaveUserAccount']='Save Changes'
$null=Request-Audit '/Frontend/Admin/Dashboard.aspx' $fields
Record-Audit 'Admin' 'Self-deactivation through own account settings' $(if(!(Query-Audit "SELECT IsActive FROM dbo.Users WHERE UserID=$adminId")){'ISSUE'}else{'PASS'})
$null=Query-Audit "UPDATE dbo.Users SET IsActive=1 WHERE UserID=$adminId"
SignIn-Audit
$fields=Get-AuditFields (Request-Audit '/Frontend/Admin/Dashboard.aspx').Content
$fields.hfDeleteUserId="$target"; $fields.btnConfirmDeleteUser='Delete'
$null=Request-Audit '/Frontend/Admin/Dashboard.aspx' $fields
Record-Audit 'Admin' 'Delete account cascades to profile' $(if((Query-Audit "SELECT COUNT(*) FROM dbo.Users WHERE UserID=$target") -eq 0 -and (Query-Audit "SELECT COUNT(*) FROM dbo.UserProfiles WHERE UserID=$target") -eq 0){'PASS'}else{'ISSUE'})
$null=Request-Audit '/Frontend/Login/Login.aspx?action=logout'
$cases | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'Temp/final-audit-http.json')
Write-Output "Completed $($cases.Count) extended HTTP probes."
