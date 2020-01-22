param(
    [string]$apiKey,
    [string]$logId,
	[string]$version
)

$ProgressPreference = "SilentlyContinue"
$url = 'https://api.elmah.io/v3/deployments?api_key=' + $apiKey

$replaced = $ExecutionContext.InvokeCommand.ExpandString($version)

$body = @{
  version = $replaced
  description = $Env:RELEASE_RELEASEDESCRIPTION
  userName = $Env:RELEASE_REQUESTEDFOR
  logId = $logId
}
Try {
  Invoke-RestMethod -Method Post -Uri $url -Body $body
}
Catch {
  Write-Error $_.Exception.Message -ErrorAction Continue
}