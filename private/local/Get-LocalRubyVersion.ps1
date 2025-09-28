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

        if ($version -eq 'system') {

            $systemVersion = Get-SystemRubyVersion

            $systemVersion.Configuration = [RubyConfiguration]::Local
            $systemVersion.Source = $versionFile.FullName

            return $systemVersion
        }

        $versionsPath = Get-VersionsPath
        $versionPath = Join-Path $versionsPath $version
        if (!(Test-Path $versionPath -PathType Container)) {
            Write-Error "local ruby version ($version) is not installed" `
                -RecommendedAction "Install Ruby in ``$versionsPath``, and call `Set-RubyVersion -Local` with that version."
        }

        $version = [RubyVersion]::Parse($version)

        return [RubyVersionDescriptor]::new(
            $version,
            [RubyConfiguration]::Local,
            $versionPath,
            $versionFile
        )
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
