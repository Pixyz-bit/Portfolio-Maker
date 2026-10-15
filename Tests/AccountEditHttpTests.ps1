param([string]$BaseUrl='http://localhost:51904')
. (Join-Path $PSScriptRoot 'PriorityFixHttpTests.ps1') -BaseUrl $BaseUrl
SignIn-Fix
$edgeId=[int](Query-Audit "INSERT dbo.Users(Email,PasswordHash) SELECT N'edit-edge@example.test',PasswordHash FROM dbo.Users WHERE Email=N'backup-admin@example.test'; SELECT SCOPE_IDENTITY();")
$null=Query-Audit "INSERT dbo.UserProfiles(UserID,FirstName,LastName) VALUES($edgeId,N'Original',N'Fixture')"
function Edit-Edge([string]$Password,[string]$Confirmation) {
    $fields=Get-AuditFields (Request-Audit '/Frontend/Admin/Dashboard.aspx').Content
    $fields.hfEditUserId="$edgeId"; $fields.txtEditFirstName='Changed'; $fields.txtEditLastName='Fixture'; $fields.txtEditEmail='edit-edge@example.test'; $fields.ddlEditRole='User'; $fields.chkEditIsActive='on'
    $fields.txtEditNewPassword=$Password; $fields.txtEditConfirmPassword=$Confirmation; $fields.btnUpdateUser='Save Changes'
    Request-Audit '/Frontend/Admin/Dashboard.aspx' $fields
}
$short=Edit-Edge 'short' 'short'
Assert-Audit ($short.Content -match 'id="pnlEditError"' -and $short.Content.Contains("getElementById('editModal').classList.add('active')") -and (Query-Audit "SELECT FirstName FROM dbo.UserProfiles WHERE UserID=$edgeId") -eq 'Original') 'short-password edit preserves account and reopens inline error'
$mismatch=Edit-Edge 'Replacement-test-password' 'different-password'
Assert-Audit ($mismatch.Content -match 'do not match' -and (Query-Audit "SELECT FirstName FROM dbo.UserProfiles WHERE UserID=$edgeId") -eq 'Original') 'mismatched edit confirmation preserves original account'
$oldHash=[string](Query-Audit "SELECT PasswordHash FROM dbo.Users WHERE UserID=$edgeId")
$null=Query-Audit "CREATE TRIGGER dbo.AuditFailPasswordReset ON dbo.Users AFTER UPDATE AS BEGIN IF UPDATE(PasswordHash) AND EXISTS(SELECT 1 FROM inserted WHERE UserID=$edgeId) THROW 51005,'Synthetic password write failure',1; END"
try {
    $failed=Edit-Edge 'Replacement-test-password' 'Replacement-test-password'
    Assert-Audit ($failed.Content -match 'id="pnlEditError"' -and (Query-Audit "SELECT FirstName FROM dbo.UserProfiles WHERE UserID=$edgeId") -eq 'Original' -and (Query-Audit "SELECT PasswordHash FROM dbo.Users WHERE UserID=$edgeId") -eq $oldHash) 'password write failure rolls back account and profile changes together'
} finally {$null=Query-Audit 'DROP TRIGGER dbo.AuditFailPasswordReset'}
$success=Edit-Edge 'Replacement-test-password' 'Replacement-test-password'
Assert-Audit ($success.Content -match 'password updated successfully' -and (Query-Audit "SELECT FirstName FROM dbo.UserProfiles WHERE UserID=$edgeId") -eq 'Changed') 'valid account/password edit commits together'
$script:auditSession=[Microsoft.PowerShell.Commands.WebRequestSession]::new()
$login=Get-AuditFields (Request-Audit '/Frontend/Login/Login.aspx').Content
$login.txtEmail='edit-edge@example.test'; $login.txtPassword='Replacement-test-password'; $login.btnLogin='Sign In'
$signedIn=Request-Audit '/Frontend/Login/Login.aspx' $login
Assert-Audit ($signedIn.Content -match 'showLoginSuccessModal') 'password from committed account edit authenticates successfully'
Write-Output "PASS: $auditPassed baseline, priority and account-edit HTTP assertions."
