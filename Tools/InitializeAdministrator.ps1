param(
    [Parameter(Mandatory=$true)][string]$FirstName,
    [Parameter(Mandatory=$true)][string]$LastName,
    [Parameter(Mandatory=$true)][string]$Email
)
$ErrorActionPreference = 'Stop'
if ($PSVersionTable.PSEdition -ne 'Desktop') {
    throw 'Run this .NET Framework setup script in Windows PowerShell 5.1 (powershell.exe).'
}
if ([string]::IsNullOrWhiteSpace($env:SQLCONNSTR_DefaultConnection)) {
    throw 'Set SQLCONNSTR_DefaultConnection to the intended database connection before running setup.'
}
$assemblyPath = Join-Path $PSScriptRoot '../241611JalopPersonalWebsite/bin/241611JalopPersonalWebsite.dll'
if (!(Test-Path -LiteralPath $assemblyPath)) { throw 'Build the web application before running setup.' }
Add-Type -Path (Resolve-Path -LiteralPath $assemblyPath).Path
$setupPassword = Read-Host 'Unique administrator password (at least 12 characters)' -AsSecureString
$setupConfirmation = Read-Host 'Confirm administrator password' -AsSecureString
$setupPasswordPointer = [IntPtr]::Zero
$setupConfirmationPointer = [IntPtr]::Zero
try {
    $setupPasswordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($setupPassword)
    $setupConfirmationPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($setupConfirmation)
    $setupPlainPassword = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($setupPasswordPointer)
    $setupPlainConfirmation = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($setupConfirmationPointer)
    if ($setupPlainPassword -cne $setupPlainConfirmation) { throw 'Passwords do not match.' }
    $setupError = ''
    if (![_241611JalopPersonalWebsite.Backend.Common.AdministratorSetup]::CreateFirst($FirstName,$LastName,$Email,$setupPlainPassword,[ref]$setupError)) {
        throw $setupError
    }
    Write-Output 'First administrator created. Sign in with the email and password you supplied.'
} finally {
    if ($setupPasswordPointer -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($setupPasswordPointer) }
    if ($setupConfirmationPointer -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($setupConfirmationPointer) }
    $setupPlainPassword = $null
    $setupPlainConfirmation = $null
    $setupPassword.Dispose()
    $setupConfirmation.Dispose()
}
