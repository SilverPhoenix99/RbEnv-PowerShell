function Get-ShellRubyVersion {

    [CmdletBinding()]
    [OutputType([RubyVersionDescriptor])]
    param()

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {

        if (!$Env:RBENV_VERSION) {
            Write-Error 'no shell-specific version configured' `
                -RecommendedAction 'Call `Set-RubyVersion -Shell` with a valid ruby version. It will be in effect for all directories until the end of the session.'
        }

        if ($Env:RBENV_VERSION -eq 'system') {

            $systemVersion = Get-SystemRubyVersion

            $systemVersion.Configuration = [RubyConfiguration]::Shell
            $systemVersion.Source = 'Env:RBENV_VERSION'

            return $systemVersion
        }

        $versionsPath = Get-VersionsPath
        $versionPath = Join-Path $versionsPath $Env:RBENV_VERSION
        if (!(Test-Path $versionPath -PathType Container)) {
            Write-Error "shell-specific ruby version ($Env:RBENV_VERSION) is not installed" `
                -RecommendedAction 'Call `Set-RubyVersion -Shell` with a valid ruby version. It will be in effect for all directories until the end of the session.'
        }

        $version = [RubyVersion]::Parse($Env:RBENV_VERSION)

        return [RubyVersionDescriptor]::new(
            $version,
            [RubyConfiguration]::Shell,
            $versionPath,
            'Env:RBENV_VERSION'
        )
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
