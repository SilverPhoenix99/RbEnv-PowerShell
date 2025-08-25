function Get-GlobalRubyVersion {

    [OutputType([RubyVersionDescriptor])] # Never $null
    param()

    $versionFile = Get-GlobalVersionFile
    Write-Debug "[Get-GlobalRubyVersion] Version File = $versionFile"
    if (!(Test-Path $versionFile -PathType Leaf)) {
        throw "global version file not found: $versionFile"
    }

    $version = Read-VersionFile $versionFile
    Write-Debug "[Get-GlobalRubyVersion] Global Version = $($version ?? '$null')"
    if (!$version) {
        throw "invalid version in $versionFile"
    }

    $rubyPath = if ($version -eq 'system') {
        try { (Get-SystemRubyVersion).Prefix } catch {}
    }
    else {
        $versionsPath = Get-VersionsPath
        $versionPath = Join-Path $versionsPath $version
        if (Test-Path $versionPath -PathType Container) {
            [IO.DirectoryInfo] $versionPath
        }
    }

    [RubyVersionDescriptor]::new('Global', $version, $versionFile, $rubyPath)
}
