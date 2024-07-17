Trace-VstsEnteringInvocation $MyInvocation

$apiKey = Get-VstsInput -Name "apiKey" -Require
$logId = Get-VstsInput -Name "logId"
$version = Get-VstsInput -Name "version"
$description = ""
$userName = ""
$userEmail = ""

if ($Env:RELEASE_RELEASENAME) {
  if (-not $version) {
    $version = $Env:RELEASE_RELEASENAME
  }
  $description = $Env:RELEASE_RELEASEDESCRIPTION
  $userName = $Env:RELEASE_REQUESTEDFOR
} else {
  if (-not $version) {
    $version = $Env:BUILD_BUILDNUMBER
  }
  $description = $Env:BUILD_SOURCEVERSIONMESSAGE
  $userName = $Env:BUILD_SOURCEVERSIONAUTHOR
  $userEmail = $Env:BUILD_SOURCEVERSIONAUTHOREMAIL
}

$ProgressPreference = "SilentlyContinue"
$url = 'https://api.elmah.io/v3/deployments?api_key=' + $apiKey

$replaced = $ExecutionContext.InvokeCommand.ExpandString($version)

$body = @{
  "version" = $replaced
  "description" = $description
  "userName" = $userName
  "userEmail" = $userEmail
  "logId" = $logId
}
Try {
  Invoke-RestMethod -Method Post -Uri $url -Body $body
}
Catch {
  Write-Error $_.Exception.Message -ErrorAction Continue
}