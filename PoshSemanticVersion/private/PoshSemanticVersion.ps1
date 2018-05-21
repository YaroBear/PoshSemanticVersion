class PoshSemanticVersion : System.IComparable, System.IEquatable[PoshSemanticVersion] {

    #region Fields

    [ValidateRange(0, 2147483647)]
    hidden [int] $_major

    [ValidateRange(0, 2147483647)]
    hidden [int] $_minor

    [ValidateRange(0, 2147483647)]
    hidden [int] $_patch

    [ValidatePattern('^(0|(\d*[A-Z-]+|[1-9A-Z-])[\dA-Z-]*)$')]          #'# This comment is to fix vscode color error.
    hidden [string[]] $_preRelease

    [ValidatePattern('^[\dA-Z-]+$')]
    hidden [string[]] $_build

    hidden [string] $_semVerString

    #endregion Fields

    #region Constructors

    PoshSemanticVersion([int] $major, [int] $minor, [int] $patch) {
        $this._init($major, $minor, $patch, @(), @())
    }

    PoshSemanticVersion([int] $major, [int] $minor, [int] $patch, [string] $preRelease, [string] $build) {
        $this._init($major, $minor, $patch, @($preRelease -split '.'), @($build -split '.'))
    }

    PoshSemanticVersion([int] $major, [int] $minor, [int] $patch, [string[]] $preRelease, [string[]] $build) {
        $this._init($major, $minor, $patch, $preRelease, $build)
    }

    #endregion Constructors

    #region Instance methods

    #region Hidden methods

    hidden [void] _init([int] $major, [int] $minor, [int] $patch, [string[]] $preRelease, [string[]] $build) {
        if ($major -ge 0 -and $major -le [int]::MaxValue) {
            $this._major = $major
        }
        else {
            throw ([System.ArgumentOutOfRangeException]::new('major'))
        }

        if ($minor -ge 0 -and $minor -le [int]::MaxValue) {
            $this._minor = $minor
        }
        else {
            throw ([System.ArgumentOutOfRangeException]::new('minor'))
        }

        if ($patch -ge 0 -and $patch -le [int]::MaxValue) {
            $this._patch = $patch
        }
        else {
            throw ([System.ArgumentOutOfRangeException]::new('patch'))
        }

        if ($preRelease.Length -gt 0) {
            [int] $i = 0
            foreach ($identifier in $preRelease) {
                if ($identifier -notmatch '^(0|(\d*[A-Z-]+|[1-9A-Z-])[\dA-Z-]*)$') {
                    throw ([System.ArgumentOutOfRangeException]::new('preRelease', "Invalid prerelease indicator at index $i"))
                }
                $i++
            }
        }

        $this._preRelease = $preRelease

        if ($build.Length -gt 0) {
            [int] $i = 0
            foreach ($identifier in $build) {
                if ($identifier -notmatch '^[\dA-Z-]+$') {
                    throw ([System.ArgumentOutOfRangeException]::new('build', "Invalid build indicator at index $i"))
                }
                $i++
            }
        }

        $this._build = $build
    }

    #endregion Hidden methods

    [int] CompareTo([object] $obj) {
        if ($null -eq $obj) {
            return 1
        }

        [PoshSemanticVersion] $otherSemVer = $obj -as [PoshSemanticVersion]

        if ($null -ne $otherSemVer) {
            return $this.CompareTo($otherSemVer)
        }
        else {
            throw ([System.ArgumentException]::new('Object is not a semantic version'))
        }
    }

    [int] CompareTo([PoshSemanticVersion] $otherSemVer) {
        if ($null -eq $otherSemVer) {
            return 1
        }

        if ($this._major -gt $otherSemVer.GetMajor()) {
            return 1
        }
        elseif ($this._major -lt $otherSemVer.GetMajor()) {
            return -1
        }

        if ($this._minor -gt $otherSemVer.GetMinor()) {
            return 1
        }
        elseif ($this._minor -lt $otherSemVer.GetMinor()) {
            return -1
        }

        if ($this._patch -gt $otherSemVer.GetPatch()) {
            return 1
        }
        elseif ($this._patch -lt $otherSemVer.GetPatch()) {
            return -1
        }

        [string[]] $thisPreRelease = @($this.GetPreRelease())
        [string[]] $thatPreRelease = @($otherSemVer.GetPreRelease())

        if ($thisPreRelease.Length -eq 0 -and $thatPreRelease.Length -ne 0) {
            return 1
        }
        elseif ($thisPreRelease.Length -ne 0 -and $thatPreRelease.Length -eq 0) {
            return -1
        }
        elseif ($thisPreRelease.Length -ne 0 -and $thatPreRelease.Length -ne 0) {
            [int] $thisElementAsNumber = 0
            [int] $thatElementAsNumber = 0
            [bool] $thisElementIsNumeric = $false
            [bool] $thatElementIsNumeric = $false

            [int] $shortestElementLength = $thisPreRelease.Length
            if ($thatPreRelease.Length -lt $shortestElementLength) {
                $shortestElementLength = $thatPreRelease.Length
            }

            for ([int] $i = 0; $i -lt $shortestElementLength; $i++) {
                $thisElementIsNumeric = [int]::TryParse($thisPreRelease[$i], [ref] $thisElementAsNumber)
                $thatElementIsNumeric = [int]::TryParse($thatPreRelease[$i], [ref] $thatElementAsNumber)

                if ($thisElementIsNumeric -and $thatElementIsNumeric) {
                    if ($thisElementAsNumber -gt $thatElementAsNumber) {
                        return 1
                    }
                    elseif ($thisElementAsNumber -lt $thatElementAsNumber) {
                        return -1
                    }
                }
                elseif (-not $thisElementIsNumeric -and $thatElementIsNumeric) {
                    return 1
                }
                elseif ($thisElementIsNumeric -and -not $thatElementIsNumeric) {
                    return -1
                }
                elseif ($thisPreRelease[$i] -gt $thatPreRelease[$i]) {
                    return 1
                }
                elseif ($thisPreRelease[$i] -lt $thatPreRelease[$i]) {
                    return -1
                }
            }

            if ($thisPreRelease.Length -gt $thatPreRelease.Length) {
                return 1
            }
            elseif ($thisPreRelease.Length -lt $thatPreRelease.Length) {
                return -1
            }
        }

        return 0
    }

    [bool] Equals([object] $obj) {
        if ($null -eq $obj) {
            return $false
        }

        [PoshSemanticVersion] $semver = $obj -as [PoshSemanticVersion]

        if ($null -eq $semver) {
            return $false
        }
        else {
            return $this.Equals($semver)
        }
    }

    [bool] Equals([PoshSemanticVersion] $semver) {
        if ($null -eq $semver) {
            return $false
        }
        else {
            return $this.CompareTo($semver) -eq 0
        }
    }

    [string[]] GetBuild() {
        return $this._build.Clone()
    }

    [int] GetHashCode() {
        return $this.ToString().GetHashCode()
    }

    [int] GetMajor() {
        return $this._major
    }

    [int] GetMinor() {
        return $this._minor
    }

    [int] GetPatch() {
        return $this._patch
    }

    [string[]] GetPreRelease() {
        return $this._preRelease.Clone()
    }

    [string] ToString() {
        if ($null -eq $this._semVerString) {
            $this._semVerString = '{0}.{1}.{2}{3}{4}' -f $this._major, $this._minor, $this._patch, $(
                if ($this._preRelease.Length -ne 0) {
                    '-' + [string]::Join('.', $this._preRelease)
                }
            ), $(
                if ($this._build.Length -ne 0) {
                    '+' + [string]::Join('.', $this._build)
                }
            )
        }

        return $this._semVerString
    }

    #endregion Instance methods

    #region Static methods

    static [PoshSemanticVersion] Parse([string] $s) {
        if ($null -eq $s) {
            throw ([System.ArgumentNullException]::new())
        }

        if ($s -notmatch ('^' + $script:NamedSemanticVersionPattern + '$')) {
            throw ([System.FormatException]::new())
        }

        [int] $major = [int]::Parse($Matches['major'])
        [int] $minor = [int]::Parse($Matches['minor'])
        [int] $patch = [int]::Parse($Matches['patch'])
        [string[]] $preRelease = @(
            if ($Matches.ContainsKey('prerelease')) {
                $Matches['prerelease'] -split '\.'
            }
        )
        [string[]] $build = @(
            if ($Matches.ContainsKey('build')) {
                $Matches['build'] -split '\.'
            }
        )

        return [PoshSemanticVersion]::new($major, $minor, $patch, $preRelease, $build)
    }

    static [bool] TryParse([string] $s, [ref] $result) {
        [bool] $isValid = $s -match ('^' + $script:SemanticVersionPattern + '$')

        if ($isValid) {
            $result.Value = [PoshSemanticVersion]::Parse($s)
        }

        return $isValid
    }

    #endregion Static methods
}
