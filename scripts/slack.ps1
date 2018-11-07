<#
.SYNOPSIS
Install from Microsoft store.
.DESCRIPTION
Install from Microsoft store.

.INPUTS
None. This script does not correspond.
.OUTPUTS
System.Int32
If success, this script returns 0, otherwise -1.

.EXAMPLE
.\slack.ps1
Start process.

.NOTES
None
#>

[CmdletBinding(
  SupportsShouldProcess=$true,
  ConfirmImpact="Medium"
)]
Param()

Write-Output "Please use Microsoft store."

exit 0
