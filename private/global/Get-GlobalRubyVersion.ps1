function Get-GlobalRubyVersion {

    [CmdletBinding()]
    [OutputType([RubyVersionDescriptor])]
    param()

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {

        $versionFile = Get-GlobalVersionFile
        Write-Debug "[$($MyInvocation.MyCommand)] Version File = $versionFile"

        if (!(Test-Path $versionFile -PathType Leaf -ErrorAction Ignore)) {
            Write-Error "global version file not found: $versionFile" `
                -RecommendedAction 'Call `Set-RubyVersion -Global` with a valid version, if you wish to have ruby available across sessions.'
        }

        $version = Read-VersionFile $versionFile
        Write-Debug "[$($MyInvocation.MyCommand)] Global Version = $($version ?? '$null')"

        if (!$version) {
            Write-Error "invalid version in $versionFile" `
                -RecommendedAction 'Call `Set-RubyVersion -Global` with a valid version, or delete the file to use the system installation if present.'
        }

        if ($version -eq 'system') {

            $systemVersion = Get-SystemRubyVersion

            $systemVersion.Configuration = [RubyConfiguration]::Global
            $systemVersion.Source = $versionFile.FullName

            return $systemVersion
        }

        $versionsPath = Get-VersionsPath
        $versionPath = Join-Path $versionsPath $version
        if (!(Test-Path $versionPath -PathType Container)) {
            Write-Error "global ruby version ($version) is not installed" `
                -RecommendedAction "Call 'Install-Ruby $version', followed by 'Set-RubyVersion $version -Global'."
        }

        $version = [RubyVersion]::Parse($version)

        return [RubyVersionDescriptor]::new(
            $version,
            [RubyConfiguration]::Global,
            $versionPath,
            $versionFile
        )
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
