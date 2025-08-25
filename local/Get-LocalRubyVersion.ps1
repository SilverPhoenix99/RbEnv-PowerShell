function Get-LocalRubyVersion {

    [OutputType([RubyVersionDescriptor])] # Never $null
    param()

    $versionFile = Get-LocalVersionFile
    Write-Debug "[Get-LocalRubyVersion] Version File = $($versionFile ?? '$null')"
    if (!$versionFile) {
        throw 'no local version configured for this directory'
    }

    $version = Read-VersionFile $versionFile
    Write-Debug "[Get-LocalRubyVersion] Local Version = $($version ?? '$null')"
    if (!$version) {
        throw "invalid version in $versionFile"
    }

    $rubyPath = if ($version -eq 'system') {
        try { (Get-SystemRubyVersion).Prefix } catch { $null }
    }
    else {
        $versionsPath = Get-VersionsPath
        $versionPath = Join-Path $versionsPath $version
        if (Test-Path $versionPath -PathType Container) {
            [IO.DirectoryInfo] $versionPath
        }
    }

    if (!$rubyPath) {
        throw "local ruby version ($version) is not installed"
    }

    [RubyVersionDescriptor]::new('Local', $version, $versionFile, $rubyPath)
}
