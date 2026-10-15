param(
    [Parameter(Mandatory=$true)][string]$ApplicationRoot,
    [switch]$Apply,
    [ValidateRange(1,87600)][int]$MinimumAgeHours=24
)
$ErrorActionPreference='Stop'
if ([string]::IsNullOrWhiteSpace($env:SQLCONNSTR_DefaultConnection)) { throw 'Select the intended database through SQLCONNSTR_DefaultConnection first.' }
$cleanupRoot=(Resolve-Path -LiteralPath $ApplicationRoot).Path.TrimEnd('\')
$cleanupConnection=[Data.SqlClient.SqlConnection]::new($env:SQLCONNSTR_DefaultConnection)
try {
    $cleanupConnection.Open()
    foreach ($cleanupRelative in @('App_Data\ProfileImages','Uploads\Profiles')) {
        $cleanupDirectory=Join-Path $cleanupRoot $cleanupRelative
        if (!(Test-Path -LiteralPath $cleanupDirectory -PathType Container)) {continue}
        $cleanupDirectory=(Resolve-Path -LiteralPath $cleanupDirectory).Path
        $cleanupParent=Join-Path $cleanupRoot ($cleanupRelative.Split('\')[0])
        if (!$cleanupDirectory.StartsWith($cleanupRoot+'\',[StringComparison]::OrdinalIgnoreCase) -or
            ((Get-Item -LiteralPath $cleanupParent).Attributes -band [IO.FileAttributes]::ReparsePoint) -or
            ((Get-Item -LiteralPath $cleanupDirectory).Attributes -band [IO.FileAttributes]::ReparsePoint)) {throw 'Refusing image cleanup outside ordinary application storage.'}
        foreach ($cleanupFile in Get-ChildItem -LiteralPath $cleanupDirectory -File) {
            if ($cleanupFile.Extension -notin @('.jpg','.jpeg','.png','.webp') -or
                $cleanupFile.LastWriteTimeUtc -gt [DateTime]::UtcNow.AddHours(-$MinimumAgeHours)) {continue}
            if ($cleanupFile.Attributes -band [IO.FileAttributes]::ReparsePoint) {continue}
            $cleanupStoredPath='~/'+$cleanupRelative.Replace('\','/')+'/'+$cleanupFile.Name
            $cleanupCommand=$cleanupConnection.CreateCommand()
            try {
                $cleanupCommand.CommandText='SELECT COUNT(*) FROM dbo.UserProfiles WHERE ProfileImagePath=@Path'
                $null=$cleanupCommand.Parameters.Add('@Path',[Data.SqlDbType]::NVarChar,500)
                $cleanupCommand.Parameters['@Path'].Value=$cleanupStoredPath
                if ([int]$cleanupCommand.ExecuteScalar() -gt 0) {continue}
            } finally {$cleanupCommand.Dispose()}
            if ($Apply) {
                # Recheck the final absolute file path before each irreversible removal.
                $cleanupTarget=[IO.Path]::GetFullPath($cleanupFile.FullName)
                if (!$cleanupTarget.StartsWith($cleanupDirectory+'\',[StringComparison]::OrdinalIgnoreCase)) {throw 'Unsafe image target.'}
                Remove-Item -LiteralPath $cleanupTarget
                Write-Output "Removed unreferenced image: $cleanupStoredPath"
            } else {Write-Output "Would remove unreferenced image: $cleanupStoredPath"}
        }
    }
} finally {$cleanupConnection.Dispose()}
