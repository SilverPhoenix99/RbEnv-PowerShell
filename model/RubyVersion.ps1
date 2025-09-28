class RubyVersion : IComparable, IEquatable[object] {

    [uint] $Major
    [uint] $Minor
    [uint] $Patch
    [uint] $Revision

    RubyVersion(
        [uint] $Major,
        [uint] $Minor,
        [uint] $Patch,
        [uint] $Revision
    ) {
        $this.Major = $Major
        $this.Minor = $Minor
        $this.Patch = $Patch
        $this.Revision = $Revision
    }

    [int] CompareTo([object] $other) {

        if ($null -eq $other) {
            return 1
        }

        if (-not ($other -is [RubyVersion])) {
            throw [ArgumentException] "Object must be of type [RubyVersion]."
        }

        $cmp = $this.Major.CompareTo($other.Major)
        if ($cmp -ne 0) { return $cmp }

        $cmp = $this.Minor.CompareTo($other.Minor)
        if ($cmp -ne 0) { return $cmp }

        $cmp = $this.Patch.CompareTo($other.Patch)
        if ($cmp -ne 0) { return $cmp }

        return $this.Revision.CompareTo($other.Revision)
    }

    [bool] Equals([object] $other) {
        return $other -is [RubyVersion] -and $this.CompareTo($other) -eq 0
    }

    [int] GetHashCode() {
        return [HashCode]::Combine($this.Major, $this.Minor, $this.Patch, $this.Revision)
    }

    [string] ToString() {
        return -join @(
            $this.Major
            '.'
            $this.Minor
            '.'
            $this.Patch
            $this.Revision -eq 0 ? '' : "-$($this.Revision)"
        )
    }

    static [RubyVersion] Parse([string] $versionString) {

        $versionString = ${versionString}?.Trim()
        if ([string]::IsNullOrEmpty($versionString)) {
            throw [FormatException] 'Version string is null or empty.'
        }

        $version = $versionString -split '[.-]' | ForEach-Object { [uint] $_ }

        return [RubyVersion]::new(
            $version[0],
            $version[1],
            $version[2],
            $version[3] ?? 0
        )
    }
}
