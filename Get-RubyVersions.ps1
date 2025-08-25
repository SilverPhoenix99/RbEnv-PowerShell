function Get-RubyVersions {

    $versionsPath = Get-VersionsPath -ErrorAction Ignore
    if (!$versionsPath) {
        return
    }

    $selectedVersions = Get-RubyVersion -All
    $currentVersion = $selectedVersions[0]

    if ($selectedVersions.Where({ $_.Kind -eq 'System' }, 'First')) {
        $rubyPath = Get-Command ruby -CommandType Application -ErrorAction Ignore
        $rubyPath = $rubyPath.Source
        $rubyPath = Split-Path $rubyPath -Parent
        if ((Split-Path $rubyPath -Leaf) -eq 'bin') {
            $rubyPath = Split-Path $rubyPath -Parent
        }

        $installation = [RubyInstallation]::new('system', [IO.DirectoryInfo] $rubyPath)

        if ($currentVersion.Version -eq 'system') {
            $installation.Selected = $currentVersion.Kind
            $installation.Origin = $currentVersion.Origin
        }

        Write-Output $installation
    }

    foreach ($installPath in $versionsPath.EnumerateDirectories()) {

        $installation = [RubyInstallation]::new($installPath.Name, $installPath)
        if ($currentVersion.Version -eq $installPath.Name) {
            $installation.Selected = $currentVersion.Kind
            $installation.Origin = $currentVersion.Origin
        }

        Write-Output $installation
    }
}
