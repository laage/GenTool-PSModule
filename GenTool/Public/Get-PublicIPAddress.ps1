#requires -version 4
Function Get-PublicIPAddress {
  <#
  .SYNOPSIS
    Returns the public address of the computer

  .DESCRIPTION
    Get-PublicIPAddress gets the public IP address of the computer from ifconfig.me and returns it

  .INPUTS
    NONE

  .OUTPUTS
    NONE

  .EXAMPLE
    PS C:\> Get-PublicIPAddress
    
    Returns the public IP address of the computer

  .NOTES
    Version:        1.0
    Author:         Kim Laage
    Creation Date:  2020-07-22
    Purpose/Change: Initial script development
    Inspired by/adapted from: https://dev.to/mertsenel/my-powershell-swissknife-how-to-make-your-own-custom-one-57h9
  #>
  [CmdLetBinding()]
  Param ()

  Try {
    (Invoke-WebRequest -Uri 'http://ifconfig.me/ip').Content
  }

  Catch {
    Write-Host -BackgroundColor Red "Error: $($_.Exception)"
    Break
  }
}
