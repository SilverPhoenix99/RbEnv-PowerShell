class RubyVersionDescriptor {

    [ValidateNotNull()]
    [ValidateSet('System', 'Global', 'Local', 'Shell')]
    [string] $Kind

    [ValidateNotNullOrWhiteSpace()]
    [string] $Version

    [ValidateNotNullOrWhiteSpace()]
    [string] $Origin

    [ValidateNotNull()]
    [IO.DirectoryInfo] $Prefix

    RubyVersionDescriptor(
        [string] $Kind,
        [string] $Version,
        [string] $Origin,
        [IO.DirectoryInfo] $Prefix
    ) {
        $this.Kind = $Kind
        $this.Version = $Version
        $this.Origin = $Origin
        $this.Prefix = $Prefix
    }

    [IO.DirectoryInfo] ResolvePath() {
        return $this.Prefix.ResolveLinkTarget($true) ?? $this.Prefix
    }

    [IO.FileInfo[]] GetExecutables() {

        $binDir = $this.Prefix.GetDirectories('bin')[0]
        if ($binDir) {
            return $binDir.GetFiles()
        }

        return @()
    }
}
