<#
.SYNOPSIS
download Jasper and unzip binary.
.DESCRIPTION
download Jasper and unzip binary.

.PARAMETER dst
binary destination folder path.
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
.\jasper.ps1
Start process.

.NOTES
None
#>

[CmdletBinding(
  SupportsShouldProcess=$true,
  ConfirmImpact="Medium"
)]
Param(
  [string]$dst = ".",
  [switch]$force,
  [switch]$noClean
)

if ((Test-Path $dst) -eq $False) {
  mkdir $dst
}
$DST = (Resolve-Path $dst)
$VERSION = "0.6.0"
$URI = "https://github.com/jasperapp/jasper/releases/download/v${VERSION}/jasper_v${VERSION}_windows.zip"

# Download
$uri = New-Object System.Uri($URI)
$file = (Join-Path . (Split-Path $uri.AbsolutePath -Leaf))
if (((Test-Path $file) -eq $False) -or $force) {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls11
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  $client = New-Object System.Net.WebClient
  $client.DownloadFile($uri, $file)
}

# Unzip
Expand-Archive -Path $file -DestinationPath $DST

# clean
if ($noClean -eq $False) { rm $file }

exit 0
