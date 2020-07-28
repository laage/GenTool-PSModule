#requires -version 4
Function Backup-ConfigFile {
  <#
  .SYNOPSIS
    Backs up various settings files to OneDrive.

  .DESCRIPTION
    Backup-ConfigFile backs up the configuration files of Windows Terminal and VSCode to a Dotfiles folder on OneDrive.

  .INPUTS
    NONE

  .OUTPUTS
    NONE

  .EXAMPLE
    PS C:\> Backup-ConfigFile
    
    Backs up VSCode and Windows Terminal configuration files to the Dotfiles folder on OneDrive.

  .NOTES
    Version:        1.0
    Author:         Kim Laage (kimla)
    Creation Date:  2020-07-27
    Purpose/Change: Initial script development
  #>
  [CmdLetBinding()]
  Param ()
  $DotFiles = @(
    [PSCustomObject]@{
      Path = "$ENV:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json";
      Destination = "$($ENV:USERPROFILE)\OneDrive\DotFiles\$(Get-Date -f yyyyMMdd)_$($ENV:COMPUTERNAME)_terminal_settings.json"
    }
    [PSCustomObject]@{
      Path = "$ENV:AppData\Code\User\settings.json";
      Destination = "$($ENV:USERPROFILE)\OneDrive\DotFiles\$(Get-Date -f yyyyMMdd)_$($ENV:COMPUTERNAME)_vscode_settings.json"
    }
  )

  Try {
    $DotFiles | ForEach-Object {
      if (!(Test-Path -Path $_.Destination)) {
        Copy-Item -Path $_.Path -Destination $_.Destination
      }
      else {
        Write-Warning 'Filen har redan backats upp idag!'
      }
    }
  }
  Catch {
    Write-Host -BackgroundColor Red "Error: $($_.Exception)"
    Break
  }
}
