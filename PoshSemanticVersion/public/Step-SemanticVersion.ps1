function Step-SemanticVersion {
    <#
     .SYNOPSIS
        Increments a Semantic Version number.

     .DESCRIPTION
        The Step-SemanticVersion function increments the elements of a Semantic Version number in a way that is
        compliant with the Semantic Version 2.0 specification.

        - Incrementing the Major number will reset the Minor number and the Patch number to 0. A pre-release version
          will be incremented to the normal version number.
        - Incrementing the Minor number will reset the Patch number to 0. A pre-release version will be incremented to
          the normal version number.
        - Incrementing the Patch number does not change any other parts of the version number. A pre-release version
          will be incremented to the normal version number.
        - Incrementing the PreRelease number does not change any other parts of the version number.
        - Incrementing the Build number does not change any other parts of the version number.

     .EXAMPLE
        '1.1.1' | Step-SemanticVersion

        Major      : 1
        Minor      : 1
        Patch      : 2
        PreRelease : 0
        Build      :

        This command takes a semantic version string from the pipeline and increments the pre-release version. Because
        the element to increment was not specified, the default value of 'PreRelease was used'.

     .EXAMPLE
        Step-SemanticVersion -Version 1.1.1 -Level Minor

        Major      : 1
        Minor      : 2
        Patch      : 0
        PreRelease :
        Build      :

        This command converts the string '1.1.1' to the semantic version object equivalent of '1.2.0'.

     .EXAMPLE
        Step-SemanticVersion -v 1.1.1 -i patch

        Major      : 1
        Minor      : 1
        Patch      : 2
        PreRelease :
        Build      :

        This command converts the string '1.1.1' to the semantic version object equivalent of '1.1.2'. This example
        shows the use of the parameter aliases "v" and "i" for Version and Level (increment), respectively.

     .EXAMPLE
        Step-SemanticVersion 1.1.1 Major

        Major      : 2
        Minor      : 0
        Patch      : 0
        PreRelease :
        Build      :

        This command converts the string '1.1.1' to the semantic version object equivalent of '2.0.0'. This example
        shows the use of positional parameters.

    #>
    [CmdletBinding()]
    [Alias('stsemver')]
    [OutputType([System.Management.Automation.SemanticVersion])]
    param (
        # The Semantic Version number to be incremented.
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [ValidateScript({
            if (Test-SemanticVersion -InputObject $_) {
                return $true
            }
            else {
                $erHash = Debug-SemanticVersion -InputObject $_ -ParameterName InputObject
                $er = Write-Error @erHash 2>&1
                throw ($er)
            }
        })]
        [Alias('Version', 'v')]
        $InputObject,

        # The desired increment type.
        # Valid values are Build, PreRelease, PrePatch, PreMinor, PreMajor, Patch, Minor, or Major.
        # The default value is PreRelease.
        [Parameter(Position=1)]
        [string]
        [ValidateSet('Build', 'PreRelease', 'PrePatch', 'PreMinor', 'PreMajor', 'Patch', 'Minor', 'Major')]
        [Alias('Level', 'Increment', 'i')]
        $Type = 'PreRelease',

        # The metadata label to use with an incrament type of Build, PreRelease, PreMajor, PreMinor, or PrePatch.
        # If specified, the value replaces the existing label. If not specified, the existing label will be incremented.
        # This parameter is ignored for an increment type of Major, Minor, or Patch.
        [Parameter(Position=2)]
        [string]
        [Alias('preid', 'Identifier')]
        $Label
    )

    $newSemVer = New-SemVerObject -InputObject $InputObject

    if ($PSBoundParameters.ContainsKey('Label')) {
        try {
            $newSemVer.Increment($Type, $Label)
        }
        catch [System.ArgumentOutOfRangeException],[System.ArgumentException] {
            $er = Write-Error -Exception $_.Exception -Category InvalidArgument -TargetObject $InputObject 2>&1
            $PSCmdlet.ThrowTerminatingError($er)
        }
        catch {
            $er = Write-Error -Exception $_.Exception -Message ('Error using label "{0}" when incrementing version "{1}".' -f $Label, $InputObject.ToString()) -TargetObject $InputObject 2>&1
            $PSCmdlet.ThrowTerminatingError($er)
        }
    }
    else {
        $newSemVer.Increment($Type)
    }

    #BUG: PowerShell SemanticVersion implementation does not parse a semver string that has a build label
    # without a pre-release label.
    [System.Management.Automation.SemanticVersion]::new($newSemVer.Major, $newSemVer.Minor, $newSemVer.Patch, (@($newSemVer.PreRelease) -join '.'), (@($newSemVer.Build) -join '.'))
}


Export-ModuleMember -Function Step-SemanticVersion -Alias stsemver