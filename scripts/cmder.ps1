<#
.SYNOPSIS
download cmder and unzip binary.
.DESCRIPTION
download cmder and unzip binary.

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
.\cmder.ps1 -dst cmder
Unzip binary to cmder folder.

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

$VERSION = '1.3.10'
$URI = "https://github.com/cmderdev/cmder/releases/download/v${VERSION}/cmder_mini.zip"

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
if ((Test-Path $dst) -eq $False) { mkdir $dst }
Expand-Archive -Path $file -DestinationPath $dst

# clean
if ($noClean -eq $False) { rm $file }

exit 0
