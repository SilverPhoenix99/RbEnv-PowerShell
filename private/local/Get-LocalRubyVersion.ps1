function Get-LocalRubyVersion {

    [CmdletBinding()]
    [OutputType([RubyVersionDescriptor])]
    param()

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {

        $versionFile = Get-LocalVersionFile
        Write-Debug "[$($MyInvocation.MyCommand)] Version File = $($versionFile ?? '$null')"
        if (!$versionFile) {
            Write-Error 'no local version configured for this directory' `
                -RecommendedAction 'Call `Set-RubyVersion -Local` with a valid version, if you wish to set a specific ruby version for this directory and its subdirectories.'
        }

        $version = Read-VersionFile $versionFile
        Write-Debug "[$($MyInvocation.MyCommand)] Local Version = $($version ?? '$null')"
        if (!$version) {
            Write-Error "invalid version in $versionFile" `
                -RecommendedAction 'Call `Set-RubyVersion -Local` with a valid version, if you wish to set a specific ruby version for this directory and its subdirectories.'
        }

        $rubyPath = if ($version -eq 'system') {
            (Get-SystemRubyVersion).Prefix
        }
        else {
            $versionsPath = Get-VersionsPath
            $versionPath = Join-Path $versionsPath $version
            if (!(Test-Path $versionPath -PathType Container)) {
                Write-Error "local ruby version ($version) is not installed" `
                    -RecommendedAction "Install Ruby in ``$versionsPath``, and call `Set-RubyVersion -Local` with that version."
            }

            [IO.DirectoryInfo] $versionPath
        }

        return [RubyVersionDescriptor]::new('Local', $version, $versionFile, $rubyPath)
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
