<#
.SYNOPSIS
  Shows a Windows 10 balloon tip
.DESCRIPTION
  Shows a Windows 10 balloon tip with a user specified title and body text, and an optional icon.
  Default icon is of 'Info'-type
.EXAMPLE
  PS C:\> Show-BalloonTip -Title <string> -Text <string>
  Displays a balloon tip with Title and Text and the default "Info" icon
.EXAMPLE
  PS C:\> Show-BalloonTip -Title <string> -Text <string> -Icon "Warning"
  Displays a balloon tip with Title and Text and the "Warning" icon
.NOTES
    Author: Kim Laage
    Date: 2018-10-09
    Taken from this article:
    https://dotnet-helpers.com/powershell/creating-a-balloon-tip-notification-using-powershell/
    Slight refactoring done
#>
function Show-BalloonTip {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [string]$Title,
    [Parameter(Mandatory = $true)]
    [string]$Text,
    # Icon must be one of the following: 'None', 'Info', 'Warning', or 'Error'
    [Parameter()]
    $Icon = 'Info'
  )

  Add-Type -AssemblyName System.Windows.Forms

  # The function checks whether there's an icon to reuse
  if ($Script:balloonToolTip -eq $null) {
    $Script:balloonToolTip = New-Object System.Windows.Forms.NotifyIcon
  }

  $path = Get-Process -Id $PID | Select-Object -ExpandProperty Path
  $balloonToolTip.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
  $balloonToolTip.BalloonTipIcon = $Icon
  $balloonToolTip.BalloonTipTitle = $Title
  $balloonToolTip.BalloonTipText = $Text
  $balloonToolTip.Visible = $true

  # Show the tool tip for two seconds, i.e. 2000 miliseconds
  $balloonToolTip.ShowBalloonTip(2000)
}