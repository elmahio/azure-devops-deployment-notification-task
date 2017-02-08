param(
    [string]$apiKey,
    [string]$logId
)

$ProgressPreference = "SilentlyContinue"
$url = 'https://api.elmah.io/v3/deployments?api_key=' + $apiKey

$body = @{
  version = $Env:RELEASE_RELEASENAME
  description = $Env:RELEASE_RELEASEDESCRIPTION
  userName = $Env:RELEASE_REQUESTEDFOR
  logId = $logId
}
Invoke-RestMethod -Method Post -Uri $url -Body $body