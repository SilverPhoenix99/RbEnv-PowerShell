function Set-ShellRubyVersion {

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'Not an exported function'
    )]
    param(
        [ValidateNotNullOrWhiteSpace()]
        [string] $Version
    )

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    try {

        if ($Version -eq '-') {

            # Swaps between the 2 versions

            if (!$Env:RBENV_VERSION_OLD) {
                Write-Error '$Env:RBENV_VERSION_OLD is not set' `
                    -RecommendedAction 'Call `Set-RubyVersion -Shell` with an existing ruby version before using this command with `-` as the version.'
            }

            $currentVersion = $Env:RBENV_VERSION

            Set-Item -Path Env:RBENV_VERSION -Value $Env:RBENV_VERSION_OLD
            Set-Item -Path Env:RBENV_VERSION_OLD -Value $currentVersion

            Write-Host "Ruby version is set to ${Env:RBENV_VERSION}"
        }
        else {
            Test-RubyVersion $Version

            Set-Item -Path Env:RBENV_VERSION_OLD -Value $Env:RBENV_VERSION
            Set-Item -Path Env:RBENV_VERSION -Value $Version
        }

        Update-RubyShims
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
}
