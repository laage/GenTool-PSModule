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
    Date: 2018-09-10
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

function MG-Tools() {
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
} # Close MG-Tools
