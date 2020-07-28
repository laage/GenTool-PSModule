#requires -version 4
Function Backup-ConfigFile {
  <#
  .SYNOPSIS
    Backs up various settings files to OneDrive.

  .DESCRIPTION
    Backup-ConfigFile copies the configuration files of Windows Terminal and VSCode to a Dotfiles folder on OneDrive and prepends 
    the date, computer name and program to the backed up files.

  .INPUTS
    NONE

  .OUTPUTS
    NONE

  .EXAMPLE
    PS C:\> Backup-ConfigFile
    
    Backs up VSCode and Windows Terminal configuration files to the Dotfiles folder on OneDrive.

  .NOTES
    Version:        1.0.1
    Author:         Kim Laage (kimla)
    Creation Date:  2020-07-27
    Purpose/Change: 1.0.1: Added Name to the PSCustomObjects to identify the the backed up files
  #>
  [CmdLetBinding()]
  Param ()
  # Ändra detta till önskat sökväg!
  $DestinationFolder = "$($ENV:USERPROFILE)\OneDrive - Landskrona Energi\DotFiles"
  $DotFiles = @(
    [PSCustomObject]@{
      Name = "Windows Terminal";
      Path = "$ENV:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json";
      Destination = "$($DestinationFolder)\$(Get-Date -f yyyyMMdd)_$($ENV:COMPUTERNAME)_terminal_settings.json"
    }
    [PSCustomObject]@{
      Name = "VS Code";
      Path = "$ENV:AppData\Code\User\settings.json";
      Destination = "$($DestinationFolder)\$(Get-Date -f yyyyMMdd)_$($ENV:COMPUTERNAME)_vscode_settings.json"
    }
  )

  Try {
    $DotFiles | ForEach-Object {
      if (!(Test-Path -Path $_.Destination)) {
        Copy-Item -Path $_.Path -Destination $_.Destination
      }
      else {
        Write-Warning -Message "$($_.Name)-filen har redan backats upp idag!"
      }
    }
  }
  Catch {
    Write-Host -BackgroundColor Red "Error: $($_.Exception)"
    Break
  }
}
