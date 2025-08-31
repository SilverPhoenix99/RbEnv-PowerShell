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

        $rubyPath = if ($version -eq 'system') {
            (Get-SystemRubyVersion).Prefix
        }
        else {
            $versionsPath = Get-VersionsPath
            $versionPath = Join-Path $versionsPath $version
            if (!(Test-Path $versionPath -PathType Container)) {
                Write-Error "global ruby version ($version) is not installed" `
                    -RecommendedAction "Install Ruby in ``$versionsPath``, and call `Set-RubyVersion -Global` with that version."
            }

            [IO.DirectoryInfo] $versionPath
        }

        return [RubyVersionDescriptor]::new('Global', $version, $versionFile, $rubyPath)
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
