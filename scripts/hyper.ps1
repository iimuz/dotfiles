<#
.SYNOPSIS
download Hyper installer for windows and run installer.
.DESCRIPTION
download Hyper installer for windows and run installer.

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
.\hyper.ps1
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

$VERSION = "2.0.0"

$URI = "https://github.com/zeit/hyper/releases/download/${VERSION}/hyper-Setup-${VERSION}.exe"

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
if ($noClean -eq $False) { rm $file }

exit 0
