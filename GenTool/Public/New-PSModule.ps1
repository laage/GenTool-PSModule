function New-PSModule() {
  param(
    [Parameter(Mandatory=$true)]
    [string]$ModuleName
  )
  $docFolder = [Environment]::GetFolderPath('Personal')
  $moduleFolder = $docFolder + '\' + $ModuleName
  $createDate = Get-Date -Format yyyy-MM-dd
  $moduleManifest = @{
    Path = "$moduleFolder\$ModuleName.psd1"
    RootModule = "$ModuleName.psm1"
    Author = "Kim Laage"
  }
  $moduleContent = @'
<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    Author: Kim Laage
    Date: [DATE]
#>


# Get public and private function definition files.
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the files
foreach($import in @($Public + $Private)) {
  try {
    . $import.fullname
  }
  catch {
    Write-Error -Message "Det gick inte att importera funktionen $($import.fullname): $_"
  }
}

# Export the Public modules
Export-ModuleMember -Function $Public.Basename
'@

  $scriptContent = @'
function [MODULENAME]() {
  <#
  .SYNOPSIS
      Short description
  .DESCRIPTION
      Long description
  .EXAMPLE
      PS C:\> <example usage>
      Explanation of what the example does
  .INPUTS
      Inputs (if any)
  .OUTPUTS
      Output (if any)
  #>

  param (
  )
} # Close [MODULENAME]
'@

  # Create Module directory with Public and Private subdirectories
  New-Item -Path $moduleFolder -ItemType Directory -Force
  New-Item -Name "Public" -ItemType Directory -Path $moduleFolder
  New-Item -Name "Private" -ItemType Directory -Path $moduleFolder
  
  # Grab content $moduleContent and add date and module name before creating the 
  # primary module psm1 file
  $moduleContent = $moduleContent.Replace("[DATE]",$createDate)
  $moduleContent = $moduleContent.Replace("[MODULENAME]",$ModuleName)
  Out-File -FilePath "$moduleFolder\$ModuleName.psm1" -InputObject $moduleContent -Encoding utf8
  
  # Grab $scriptContent and create an initial public ps1 script
  $scriptContent = $scriptContent.Replace("[MODULENAME]",$ModuleName)
  Out-File -FilePath "$moduleFolder\Public\$ModuleName.ps1" -InputObject $scriptContent -Encoding utf8

  New-ModuleManifest @moduleManifest 
  
} # Close New-PSModule