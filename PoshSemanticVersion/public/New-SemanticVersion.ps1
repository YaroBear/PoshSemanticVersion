function New-SemanticVersion {
    <#
     .SYNOPSIS
        Creates a new semantic version.

     .DESCRIPTION
        Creates a new object representing a semantic version number.

     .EXAMPLE
        New-SemanticVersion -String '1.2.3-alpha.4+build.5'

        Major      : 1
        Minor      : 2
        Patch      : 3
        PreRelease : alpha.4
        Build      : build.5

        This command converts a valid Semantic Version string into a Semantic Version object. The output of the command
        is a Semantic Version object with the elements of the version split into separate properties.

     .EXAMPLE
        New-SemanticVersion -Major 1 -Minor 2 -Patch 3 -PreRelease alpha.4 -Build build.5

        Major      : 1
        Minor      : 2
        Patch      : 3
        PreRelease : alpha.4
        Build      : build.5

        This command takes the Major, Minor, Patch, PreRelease, and Build parameters and produces the same output as the
        previous example.

     .EXAMPLE
        New-SemanticVersion -Major 1 -Minor 2 -Patch 3 -PreRelease alpha, 4 -Build build, 5

        Major      : 1
        Minor      : 2
        Patch      : 3
        PreRelease : alpha.4
        Build      : build.5

        This command uses arrays for the PreRelease and Build parameters, but produces the same output as the
        previous example.

     .EXAMPLE
        $semver = New-SemanticVersion -Major 1 -Minor 2 -Patch 3 -PreRelease alpha.4 -Build build.5

        $semver.ToString()

        1.2.3-alpha.4+build.5

        This example shows that the object output from the previous command can be saved to a variable. Then by
        calling the object's ToString() method, a valid Semantic Version string is returned.

     .INPUTS
        System.Object

            All Objects piped to this function are converted into SemanticVersion objects.

    #>
    [CmdletBinding(DefaultParameterSetName='Elements')]
    [Alias('nsemver')]
    [OutputType([System.Management.Automation.SemanticVersion])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param (
        # The major version must be incremented if any backwards incompatible changes are introduced to the public API.
        [Parameter(ParameterSetName='Elements')]
        [ValidateRange(0, 2147483647)]
        [int]
        $Major = 0,

        # The minor version must be incremented if new, backwards compatible functionality is introduced to the public API.
        [Parameter(ParameterSetName='Elements')]
        [ValidateRange(0, 2147483647)]
        [int]
        $Minor = 0,

        # The patch version must be incremented if only backwards compatible bug fixes are introduced.
        [Parameter(ParameterSetName='Elements')]
        [ValidateRange(0, 2147483647)]
        [int]
        $Patch = 0,

        # A pre-release version indicates that the version is unstable and might not satisfy the intended compatibility
        # requirements as denoted by its associated normal version.
        # The value can be a string or an array of strings. If an array of strings is provided, the elements of the array
        # will be joined using dot separators.
        [Parameter(ParameterSetName='Elements')]
        [AllowEmptyCollection()]
        $PreRelease = @(),

        # The build metadata.
        # The value can be a string or an array of strings. If an array of strings is provided, the elements of the array
        # will be joined using dot separators.
        [Parameter(ParameterSetName='Elements')]
        [AllowEmptyCollection()]
        $Build = @(),

        # A valid semantic version string to be converted into a SemanticVersion object.
        [Parameter(ParameterSetName='String',
                   ValueFromPipeline=$true,
                   Mandatory=$true,
                   Position=0)]
        [ValidateScript({
            [int] $tmpInt = 0
            [decimal] $tmpDecimal = 0.0

            if ([int]::TryParse($_.ToString(), [ref] $tmpInt)) {
                $paramValue = '{0}.0.0' -f $tmpInt
            }
            elseif ([decimal]::TryParse($_.ToString(), [ref] $tmpDecimal)) {
                $paramValue = '{0}.0' -f $tmpDecimal
            }
            else {
                $paramValue = $_
            }

            if (Test-SemanticVersion -InputObject $paramValue) {
                return $true
            }
            else {
                $erHash = Debug-SemanticVersion -InputObject $paramValue -ParameterName InputObject
                $er = Write-Error @erHash 2>&1
                throw ($er)
            }
        })]
        [Alias('Version', 'v', 'String')]
        [object[]]
        $InputObject
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Elements') {
            [string] $badParameterName = 'InputObject'

            # PSv2 does not initialize $PreRelease or $Build if they were not specifies or if they had empty arrays.
            # So they have to be reinitialized here if they were not specified.
            if ($PSBoundParameters.ContainsKey('Build')) {
                [string] $testBuild = $Build -join '.'
                if ($testBuild -notmatch ('^' + $BuildPattern + '$')) {
                    $badParameterName = 'Build'
                }
                [string[]] $Build = @($testBuild -split '\.')
            }
            else {
                [string[]] $Build = @()
            }

            if ($PSBoundParameters.ContainsKey('PreRelease')) {
                [string] $testPreRelease = $PreRelease -join '.'
                if ($testPreRelease -notmatch ('^' + $PreReleasePattern + '$')) {
                    $badParameterName = 'PreRelease'
                }
                [string[]] $PreRelease = @($testPreRelease -split '\.')
            }
            else {
                [string[]] $PreRelease = @()
            }

            [string] $InputObject = "$Major.$Minor.$Patch$(if ($PreRelease.Length -gt 0) {'-' + $($PreRelease -join '.')})$(if ($Build.Length -gt 0) {'+' + $($Build -join '.')})"

            if (-not $(Test-SemanticVersion -InputObject $InputObject)) {
                $erHash = Debug-SemanticVersion -InputObject $InputObject -ParameterName $badParameterName
                $er = Write-Error @erHash 2>&1
                $PSCmdlet.ThrowTerminatingError($er)
            }
        }

        foreach ($item in $InputObject) {
            [int] $tmpInt = 0
            [decimal] $tmpDecimal = 0.0

            if ([int]::TryParse($item.ToString(), [ref] $tmpInt)) {
                $paramValue = '{0}.0.0' -f $tmpInt
            }
            elseif ([decimal]::TryParse($item.ToString(), [ref] $tmpDecimal)) {
                $paramValue = '{0}.0' -f $tmpDecimal
            }
            else {
                $paramValue = $item
            }

            [hashtable] $semVerHash = Split-SemanticVersion $paramValue.ToString()

            switch ($semVerHash.Keys) {
                'Major' {
                    [int] $Major = $semVerHash['Major']
                }

                'Minor' {
                    [int] $Minor = $semVerHash['Minor']
                }

                'Patch' {
                    [int] $Patch = $semVerHash['Patch']
                }

                'PreRelease' {
                    [string[]] $PreRelease = @($semVerHash['PreRelease'])
                }

                'Build' {
                    [string[]] $Build = @($semVerHash['Build'])
                }
            }

            [System.Management.Automation.SemanticVersion]::new($Major, $Minor, $Patch, (@($PreRelease) -join '.'), (@($Build) -join '.'))
        }
    }
}


Export-ModuleMember -Function New-SemanticVersion -Alias nsemver
