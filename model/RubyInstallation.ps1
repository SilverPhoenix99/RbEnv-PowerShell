class RubyInstallation {

    [ValidateNotNullOrWhiteSpace()]
    [string] $Version

    [ValidateNotNull()]
    [IO.DirectoryInfo] $Prefix

    [ValidateSet('System', 'Global', 'Local', 'Shell')]
    [string] $Selected

    [string] $Origin

    RubyInstallation(
        [string] $Version,
        [IO.DirectoryInfo] $Prefix
    ) {
        $this.Version = $Version
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
