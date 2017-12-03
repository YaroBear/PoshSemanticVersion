#
# Module manifest for module 'PoshSemanticVersion'
#
# Generated by: Dominick Byron
#
# Generated on: 7/18/2016
#

@{

# Script module or binary module file associated with this manifest
ModuleToProcess = 'PoshSemanticVersion.psm1'

# Version number of this module.
ModuleVersion = '1.4.0'

# ID used to uniquely identify this module
GUID = 'e9401295-557f-45ae-9538-336a63ead430'

# Author of this module
Author = 'Dominick Byron'

# Company or vendor of this module
CompanyName = ''

# Copyright statement for this module
Copyright = '(c) 2017 Dominick Byron. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Functions for working with Semantic Version numbers.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '2.0'

# Name of the Windows PowerShell host required by this module
PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
PowerShellHostVersion = ''

# Minimum version of the .NET Framework required by this module
DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
CLRVersion = ''

# Processor architecture (None, X86, Amd64, IA64) required by this module
ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module
ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
TypesToProcess = @('PoshSemanticVersion.types.ps1xml')

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = @()

# Modules to import as nested modules of the module specified in ModuleToProcess
NestedModules = @()

# Functions to export from this module
FunctionsToExport = @('New-SemanticVersion', 'Test-SemanticVersion', 'Compare-SemanticVersion', 'Step-SemanticVersion')

# Cmdlets to export from this module
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module
AliasesToExport = @('*')

# List of all modules packaged with this module
#ModuleList = @()

# List of all files packaged with this module
FileList = @('PoshSemanticVersion.psd1', 'PoshSemanticVersion.psm1', 'PoshSemanticVersion.types.ps1xml')

# Private data to pass to the module specified in ModuleToProcess
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('Semantic', 'Version', 'semver')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/chiprunner1995/PoshSemanticVersion/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/chiprunner1995/PoshSemanticVersion'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = '## 1.4.0 - 2017-12-03
### Features
- Added aliases for exported commands
- Added alias properties "PreReleaseLabel" and "BuildLabel" to match PowerShell v6.x native SemanticVersion type.
'

        # Specify if this is a pre-release version of this module.
        #IsPreRelease = $false

        # Specify the Semantic Version of this module.
        #SemanticVersion = '1.4.0'

    } # End of PSData hashtable

} # End of PrivateData hashtable

}

