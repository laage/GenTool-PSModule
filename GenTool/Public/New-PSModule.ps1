<#
.SYNOPSIS
  Creates a new template folder for a Powershell module
.DESCRIPTION
  Creates a new template folder for a Powershell module containing:
  - A Module-folder with Private, Public and en-US help directories and
  a starting Module manifests and Module-script and an about_MODULE.help.txt.
  - A Tests folder for Pester or other test-framework.
  - Starting README.md and LICENSE.txt.
.EXAMPLE
  PS C:\> New-PSModule -ModuleName [MODULENAME]
  Creates a new blank module.
.EXAMPLE
  PS C:\> New-PSModule -ModuleName [MODULENAME] -Git
  Creates a new blank module and initalizes a Git repo.
.INPUTS
  Inputs (if any)
.OUTPUTS
  Output (if any)
.NOTES
  General notes
#>
function New-PSModule() {
  param(
    [Parameter(Mandatory=$true)]
    [string]$ModuleName,
    [switch]$Git
  )
  # Gets the users Documents folder
  $docFolder = [Environment]::GetFolderPath('Personal')
  # Creates the path where the module will be created.
  # Standard is [USERNAME]\Documents\Development\[MODULENAME]-PSModule
  # Modify to suit your own taste.
  $moduleFolder = $docFolder + '\Development\' + $ModuleName + '-PSModule'
  $author = "YOUR NAME GOES HERE"
  $companyName = "YOUR COMPANY NAME GOES HERE"
  # Formatted according to Swedish standard
  # Modify to suit your own taste
  $createDate = Get-Date -Format yyyy-MM-dd
  $moduleManifest = @{
    Path = "$moduleFolder\$moduleName\$ModuleName.psd1"
    RootModule = "$ModuleName.psm1"
    Author = $author
    CompanyName = $companyName
    PowerShellVersion = "3.0"
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
    Author: [AUTHOR]
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

  $helpContent = @'
TOPIC
  about_[MODULENAME]

  ABOUT TOPIC NOTE:
  The first header of the about topic should be the topic name.
  The second header contains the lookup name used by the help system.
  
  IE:
  # Some Help Topic Name
  ## SomeHelpTopicFileName
  
  This will be transformed into the text file
  as `about_SomeHelpTopicFileName`.
  Do not include file extensions.
  The second header should have no spaces.



SHORT DESCRIPTION
  {{ Short Description Placeholder }}

  ABOUT TOPIC NOTE:
  About topics can be no longer than 80 characters wide when rendered to text.
  Any topics greater than 80 characters will be automatically wrapped.
  The generated about topic will be encoded UTF-8.

LONG DESCRIPTION
  {{ Long Description Placeholder }}

Optional Subtopics
  {{ Optional Subtopic Placeholder }}

EXAMPLES
  {{ Code or descriptive examples of how to leverage the functions described.
  }}

NOTE
  {{ Note Placeholder - Additional information that a user needs to know.}}

TROUBLESHOOTING NOTE
  {{ Troubleshooting Placeholder - Warns users of bugs}}
  {{ Explains behavior that is likely to change with fixes }}

SEE ALSO
  {{ See also placeholder }}
  {{ You can also list related articles, blogs, and video URLs. }}

KEYWORDS
  {{List alternate names or titles for this topic that readers might use.}}
  - {{ Keyword Placeholder }}
  - {{ Keyword Placeholder }}
  - {{ Keyword Placeholder }}
  - {{ Keyword Placeholder }}
'@

  $readmeContent = @'
##Welcome to [MODULENAME]
'@

  # Create Module directory with Public and Private subdirectories
  New-Item -Path $moduleFolder -ItemType Directory -Force
  New-Item -Name "Public" -ItemType Directory -Path "$moduleFolder\$moduleName\"
  New-Item -Name "Private" -ItemType Directory -Path "$moduleFolder\$moduleName\"
  New-Item -Name "en-US" -ItemType Directory -Path "$moduleFolder\$moduleName\"
  # New-Item -Name "sv-SE" -ItemType Directory -Path "$moduleFolder\$moduleName\"
  
  # Grab content $moduleContent and add date and module name before creating the 
  # primary module psm1 file
  $moduleContent = $moduleContent.Replace("[DATE]",$createDate)
  $moduleContent = $moduleContent.Replace("[MODULENAME]",$ModuleName)
  $moduleContent = $moduleContent.Replace("[AUTHOR]",$author)
  Out-File -FilePath "$moduleFolder\$moduleName\$ModuleName.psm1" -InputObject $moduleContent -Encoding utf8
  
  # Grab $scriptContent and create an initial public ps1 script
  $scriptContent = $scriptContent.Replace("[MODULENAME]",$ModuleName)
  Out-File -FilePath "$moduleFolder\$moduleName\Public\$ModuleName.ps1" -InputObject $scriptContent -Encoding utf8

  # Grab $helpContent and create a about_[MODULENAME].help.txt file in the en-US directory
  $helpContent = $helpContent.Replace("[MODULENAME]",$ModuleName)
  Out-File -FilePath "$moduleFolder\$moduleName\en-US\about_$ModuleName.help.txt" -InputObject $helpContent -Encoding utf8

  # Create Test directory
  New-Item -Path $moduleFolder -ItemType Directory -Name "Tests"

  # Grab $readmeContent and create a README.md
  $readmeContent = $readmeContent.Replace("[MODULENAME]",$ModuleName)
  Out-File -FilePath "$moduleFolder\README.md" -InputObject $readmeContent -Encoding utf8

  # Create a new Module-Manifest based on the $moduleManifest-splat above
  New-ModuleManifest @moduleManifest

  # If the Git parameter is called it will automatically initialize a new repo in the $moduleFolder
  if ($Git.IsPresent) {
    Push-Location -Path $moduleFolder
    & git init
    Pop-Location
  }
  
} # Close New-PSModule