class RubyVersionDescriptor {

    [ValidateNotNull()]
    [RubyVersion] $Version

    [Nullable[RubyConfiguration]] $Configuration

    [IO.DirectoryInfo] $Path

    [string[]] $Source

    RubyVersionDescriptor(
        [RubyVersion] $Version,
        [Nullable[RubyConfiguration]] $Configuration,
        [IO.DirectoryInfo] $Path,
        [string[]] $Source
    ) {
        $this.Version = $Version
        $this.Configuration = $Configuration
        $this.Path = $Path
        $this.Source = $Source
    }

    [IO.DirectoryInfo] ResolvePath() {
        return $this.Path?.ResolveLinkTarget($true) ?? $this.Path
    }

    [IO.FileInfo[]] GetExecutables() {

        if (!$this.Path) {
            return @()
        }

        $binDir = $this.Path.GetDirectories('bin')[0]
        if ($binDir) {
            return $binDir.GetFiles()
        }

        return @()
    }
}
