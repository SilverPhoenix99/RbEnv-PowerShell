function Get-ShellRubyVersion {

    [OutputType([RubyVersionDescriptor])] # Never $null
    param()

    if (!$Env:RBENV_VERSION) {
        throw 'no shell-specific version configured'
    }

    $rubyPath = if ($Env:RBENV_VERSION -eq 'system') {
        try { (Get-SystemRubyVersion).Prefix } catch { $null }
    }
    else {
        $versionsPath = Get-VersionsPath
        $versionPath = Join-Path $versionsPath $Env:RBENV_VERSION
        if (Test-Path $versionPath -PathType Container) {
            [IO.DirectoryInfo] $versionPath
        }
    }

    if (!$rubyPath) {
        throw "shell-specific ruby version ($Env:RBENV_VERSION) is not installed"
    }

    [RubyVersionDescriptor]::new('Shell', $Env:RBENV_VERSION, 'Env:RBENV_VERSION', $rubyPath)
}
