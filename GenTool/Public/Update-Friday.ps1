#Requires -Version 4.0
#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Updates choco-installed software, installed PS-modules and the PS help files
.DESCRIPTION
  Update-Friday runs the "choco upgrade all -y" command, followed by an
  "Update-Module" and "Update-Help"
.EXAMPLE
  PS C:\> Update-Friday
#>
function Update-Friday {
  [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
  param (
  )
  choco upgrade all -y 
  Update-Module -Force
  Update-Help
}