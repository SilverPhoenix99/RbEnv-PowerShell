function Get-RubyVersions {

    [CmdletBinding()]
    [OutputType([RubyInstallation[]])]
    param()

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {
        $selectedVersions = (Get-RubyVersion -All -ErrorAction Ignore) ?? @()
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

        $versionsPath = Get-VersionsPath
        foreach ($installPath in $versionsPath.EnumerateDirectories()) {

            $installation = [RubyInstallation]::new($installPath.Name, $installPath)
            if ($currentVersion.Version -eq $installPath.Name) {
                $installation.Selected = $currentVersion.Kind
                $installation.Origin = $currentVersion.Origin
            }

            Write-Output $installation
        }
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
