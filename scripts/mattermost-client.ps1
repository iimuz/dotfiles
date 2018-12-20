<#
.SYNOPSIS
download mattermost-client and unzip binary.
.DESCRIPTION
download mattermost-client and unzip binary.

.PARAMETER force
download installer if file exists.
.PARAMETER noClean
do not remove installer when finish install process.

.INPUTS
None. This script does not correspond.
.OUTPUTS
System.Int32
If success, this script returns 0, otherwise -1.

.EXAMPLE
.\mattermost-client.ps1
Start process.

.NOTES
None
#>

[CmdletBinding(
  SupportsShouldProcess=$true,
  ConfirmImpact="Medium"
)]
Param(
  [switch]$force,
  [switch]$noClean
)

$VERSION = "4.2.0"
$ARCH = "win64"
$URI = "https://releases.mattermost.com/desktop/${VERSION}/mattermost-setup-${VERSION}-${ARCH}.exe"

# Download
$uri = New-Object System.Uri($URI)
$file = (Join-Path . (Split-Path $uri.AbsolutePath -Leaf))
if (((Test-Path $file) -eq $False) -or $force) {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls11
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  $client = New-Object System.Net.WebClient
  $client.DownloadFile($uri, $file)
}

# Install
Start-Process -Wait $file

# clean
if ($noClean -eq $False) { Remove-Item $file }

exit 0
