param([string]$BaseUrl='http://localhost:51904')
$ErrorActionPreference='Stop'
if($BaseUrl -notmatch '^http://localhost:\d+$'){throw 'Only a local test server is allowed.'}
function Get-AuditFields([string]$Html) {
    $fields=@{}
    foreach($match in [regex]::Matches($Html,'<input\b[^>]*>','IgnoreCase')) {
        $tag=$match.Value;$name=[regex]::Match($tag,'\bname="([^"]*)"').Groups[1].Value
        $type=[regex]::Match($tag,'\btype="([^"]*)"').Groups[1].Value
        if(!$name -or $type -in @('submit','button','file')){continue}
        if($type -eq 'checkbox' -and $tag -notmatch '\bchecked\b'){continue}
        $value=[regex]::Match($tag,'\bvalue="([^"]*)"')
        $fields[$name]=if($type -eq 'checkbox' -and !$value.Success){'on'}else{[Net.WebUtility]::HtmlDecode($value.Groups[1].Value)}
    }
    foreach($match in [regex]::Matches($Html,'<textarea\b[^>]*name="([^"]*)"[^>]*>([\s\S]*?)</textarea>')){
        $fields[$match.Groups[1].Value]=[Net.WebUtility]::HtmlDecode($match.Groups[2].Value)
    }
    return $fields
}
function Request-Audit([string]$Path,$Fields=$null) {
    $options=@{Uri="$BaseUrl$Path";WebSession=$script:auditSession;NoProxy=$true;SkipHttpErrorCheck=$true;TimeoutSec=45}
    if($null -ne $Fields){$options.Method='Post';$options.Body=$Fields}
    Invoke-WebRequest @options
}
$auditSession=[Microsoft.PowerShell.Commands.WebRequestSession]::new()
$login=Get-AuditFields (Request-Audit '/Frontend/Login/Login.aspx').Content
$login.txtEmail='audit-admin@example.test';$login.txtPassword='Example-password';$login.btnLogin='Sign In'
$null=Request-Audit '/Frontend/Login/Login.aspx' $login
$result=@()
foreach($case in @(
    @{Name='Renamed nonimage';File='fake.jpg';Bytes=[Text.Encoding]::UTF8.GetBytes('not an image');Mime='image/jpeg'},
    @{Name='Disallowed extension';File='fake.txt';Bytes=[Text.Encoding]::UTF8.GetBytes('not an image');Mime='text/plain'},
    @{Name='Over 2 MB';File='large.png';Bytes=[byte[]]::new(2097153);Mime='image/png'},
    @{Name='Valid PNG';File='portrait.png';Bytes=[IO.File]::ReadAllBytes((Join-Path $PSScriptRoot 'Temp/Site/Uploads/Profiles/audit-private.png'));Mime='image/png'}
)) {
    $fields=Get-AuditFields (Request-Audit '/Frontend/User/Onboarding.aspx').Content
    $fields.btnSaveStep1='Save & Exit'
    $handler=[Net.Http.HttpClientHandler]::new();$handler.UseProxy=$false;$handler.CookieContainer=$auditSession.Cookies
    $client=[Net.Http.HttpClient]::new($handler)
    $form=[Net.Http.MultipartFormDataContent]::new()
    try {
        foreach($key in $fields.Keys) {$form.Add([Net.Http.StringContent]::new([string]$fields[$key]),$key)}
        $file=[Net.Http.ByteArrayContent]::new($case.Bytes)
        $file.Headers.ContentType=[Net.Http.Headers.MediaTypeHeaderValue]::new($case.Mime)
        $form.Add($file,'fileProfileImage',$case.File)
        $response=$client.PostAsync("$BaseUrl/Frontend/User/Onboarding.aspx",$form).GetAwaiter().GetResult()
        $body=$response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
        $accepted=$body -match 'Portfolio saved successfully'
        $record=[pscustomobject]@{Case=$case.Name;Accepted=$accepted;Status=[int]$response.StatusCode}
        $record | ConvertTo-Json -Compress | Write-Output
        $result+=$record
    } finally {$form.Dispose();$client.Dispose();$handler.Dispose()}
}
$result|ConvertTo-Json|Set-Content (Join-Path $PSScriptRoot 'Temp/final-audit-uploads.json')
